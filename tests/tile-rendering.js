import { drawScene, MAP_BOUNDS } from '../js/render/scene.js';

export async function tileRenderingTests(test, equal) {
  const catalog = await fetch('../data/catalog.json').then(response => response.json());
  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d', { willReadFrequently: true });
  for (const [bank, paths] of Object.entries(catalog.tileBanks)) {
    await test(`${bank} tiles fill stretched preview cells without SVG padding`, async () => {
      const sourceWidth = 28, sourceHeight = bank === 'world' ? 24 : 32;
      // Ten times the actual preview cell dimensions, to sample every source
      // pixel without downsampling. Composed cities retain their native ratio.
      const sizes = bank === 'world' ? [[126, 90], [252, 180], [56, 48]] :
        [[252, 180], [504, 360], [350, 400], [56, 64]];
      for (const path of paths) {
        const image = new Image();
        image.src = `../${path}`;
        await image.decode();
        canvas.width = sourceWidth; canvas.height = sourceHeight;
        context.imageSmoothingEnabled = false;
        context.drawImage(image, 0, 0, sourceWidth, sourceHeight);
        const native = context.getImageData(0, 0, sourceWidth, sourceHeight).data;
        for (const [width, height] of sizes) {
          canvas.width = width; canvas.height = height;
          context.imageSmoothingEnabled = false;
          context.drawImage(image, 0, 0, width, height);
          const scaled = context.getImageData(0, 0, width, height).data;
          let mismatches = 0;
          for (let y = 0; y < sourceHeight; y++) for (let x = 0; x < sourceWidth; x++) {
            const px = Math.floor((x + .5) * width / sourceWidth);
            const py = Math.floor((y + .5) * height / sourceHeight);
            if ((native[(y * sourceWidth + x) * 4 + 3] > 128) !==
                (scaled[(py * width + px) * 4 + 3] > 128)) mismatches++;
          }
          equal({ path, width, height, mismatches }, { path, width, height, mismatches: 0 });
        }
      }
    });
  }
  await test('World preview has no seams between opaque tiles at fractional display scales', async () => {
    const path = catalog.tileBanks.world[12], image = new Image();
    image.src = `../${path}`; await image.decode();
    canvas.width = 28; canvas.height = 24;
    context.drawImage(image, 0, 0, 28, 24);
    const expected = [...context.getImageData(14, 12, 1, 1).data];
    const assets = { catalog, images: { [path]: image },
      maps: { worlds: [{ tiles: Array.from({ length: 24 }, () => Array(40).fill(12)) }] } };
    for (const scale of [.61, 1, 1.1, 1.5]) {
      drawScene(canvas, { view: 'worlds', indices: { worlds: 0 } }, assets, scale);
      const sx = canvas.width / 640, sy = canvas.height / 480;
      const left = Math.round(MAP_BOUNDS.x * sx), top = Math.round(MAP_BOUNDS.y * sy);
      const right = Math.round((MAP_BOUNDS.x + MAP_BOUNDS.width) * sx);
      const bottom = Math.round((MAP_BOUNDS.y + MAP_BOUNDS.height) * sy);
      const pixels = context.getImageData(left, top, right - left, bottom - top).data;
      let mismatches = 0;
      for (let i = 0; i < pixels.length; i += 4)
        if (expected.some((value, channel) => pixels[i + channel] !== value)) mismatches++;
      equal({ scale, mismatches }, { scale, mismatches: 0 });
    }
  });
}

