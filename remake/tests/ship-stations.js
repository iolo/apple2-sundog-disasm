import { drawShipStations } from '../js/render/ship-stations.js';

export async function shipStationTests(test, equal) {
  const geometry = await fetch('../data/ship-walk.json').then(response => response.json());
  const canvas = document.createElement('canvas');
  canvas.width = 640; canvas.height = 480;
  const context = canvas.getContext('2d', { willReadFrequently: true });
  const bounds = { x: 32, y: 46, width: 640, height: 384 };
  const draw = (position, options = {}) => {
    context.clearRect(0, 0, 640, 480);
    drawShipStations(context, geometry, bounds, position,
      { campaign: true, landed: true, podAttached: true, ...options });
  };
  // Sample at pointer centres, independently of the sprite's saved anchor.
  const pixel = (x, y) => [...context.getImageData(
    Math.floor(32 + (x + .5) * 640 / 280), 46 + y * 2 + 1, 1, 1).data];
  await test('Station hints use pointer centres at stores, locker and airlock, not sprite left edges', () => {
    for (const [x, y] of [[57, 85], [85, 108], [57, 115]]) {
      draw({ x: x - 3, y: y + 3 });
      equal(pixel(x, y), [234, 185, 117, 255]);
      equal(pixel(x - 3, y)[3], 0);
    }
  });
  await test('Hints exclude solid fixture pixels and brighten only the reached station', () => {
    draw({ x: 54, y: 88 });
    equal(pixel(57, 85)[3], 255);
    equal(pixel(85, 108)[3] > 0 && pixel(85, 108)[3] < 255, true);
    equal(pixel(89, 108)[3], 0); // Locker wall, not an approach point.
  });
  await test('Unavailable exits and walkthrough-only controls have no hint', () => {
    draw(geometry.spawn, { landed: false });
    equal(pixel(57, 115)[3], 0);
    equal(pixel(103, 116)[3], 0);
    draw(geometry.spawn, { podAttached: false });
    equal(pixel(103, 116)[3], 0);
    draw(geometry.spawn, { campaign: false });
    equal(pixel(57, 85)[3] > 0, true);
    equal(pixel(85, 108)[3] > 0, true);
    equal(pixel(57, 115)[3], 0);
    equal(pixel(113, 56)[3], 0);
  });

  for (const variant of ['ship', 'ship-section']) {
    await test(`${variant} SVG retains source pixels and scales without padding`, async () => {
      const image = new Image();
      image.src = `../assets/svg/${variant}.svg`;
      await image.decode();
      equal([image.naturalWidth, image.naturalHeight], [geometry.width, geometry.height]);
      canvas.width = geometry.width; canvas.height = geometry.height;
      context.imageSmoothingEnabled = false;
      context.drawImage(image, 0, 0, geometry.width, geometry.height);
      const native = context.getImageData(0, 0, geometry.width, geometry.height).data;
      let missingSourcePixels = 0;
      for (let y = 0; y < geometry.height; y++) for (let x = 0; x < geometry.width; x++) {
        const occupied = !!(geometry.backgrounds[variant][y][Math.floor(x / 7)] & (1 << (x % 7)));
        if (occupied && native[(y * geometry.width + x) * 4 + 3] <= 128) missingSourcePixels++;
      }
      equal(missingSourcePixels, 0);
      for (const [width, height] of [[280, 192], [640, 384], [1280, 768]]) {
        canvas.width = width; canvas.height = height;
        context.imageSmoothingEnabled = false;
        context.drawImage(image, 0, 0, width, height);
        const pixels = context.getImageData(0, 0, width, height).data;
        let mismatches = 0;
        for (let y = 0; y < geometry.height; y++) for (let x = 0; x < geometry.width; x++) {
          // Color fills gaps between patterned dots; compare scaling against
          // the native artwork, not the old monochrome collision silhouette.
          const occupied = native[(y * geometry.width + x) * 4 + 3] > 128;
          const px = Math.floor((x + .5) * width / geometry.width), py = Math.floor((y + .5) * height / geometry.height);
          if ((pixels[(py * width + px) * 4 + 3] > 128) !== occupied) mismatches++;
        }
        equal({ width, height, mismatches }, { width, height, mismatches: 0 });
      }
    });
  }
}
