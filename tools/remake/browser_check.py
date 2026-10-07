#!/usr/bin/env python3
"""Serve the remake for one Playwright CLI check, then shut down cleanly."""
import argparse
import functools
import http.server
import json
from pathlib import Path
import re
import subprocess
import threading

ROOT = Path(__file__).resolve().parents[2]
RULES = '''async page => {
  const context=await page.context().browser().newContext(),p=await context.newPage(),errors=[];
  p.on('pageerror',e=>errors.push(e.message));
  try {
    await p.goto('http://127.0.0.1:8000/tests/');
    try {await p.waitForFunction(()=>document.documentElement.dataset.result,null,{timeout:60000})}
    catch(e) {return {browser:page.context().browser().version(),status:'fail',errors,failures:[e.message]}}
    const lines=(await p.locator('#results').innerText()).split('\\n');
    return {browser:page.context().browser().version(),checks:lines.length,
      status:await p.locator('html').getAttribute('data-result'),
      failures:lines.filter(s=>s.startsWith('FAIL')).map(s=>s.slice(0,300)),errors};
  } finally {await context.close()}
}'''

class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('script', nargs='?', type=Path)
    parser.add_argument('--output', type=Path)
    args=parser.parse_args()
    code=args.script.read_text() if args.script else RULES
    handler=functools.partial(QuietHandler,directory=str(ROOT/'remake'))
    with http.server.ThreadingHTTPServer(('127.0.0.1',8000),handler) as server:
        threading.Thread(target=server.serve_forever,daemon=True).start()
        try:
            cli=['npx','--yes','--package','@playwright/cli','playwright-cli','-s=remake']
            opened=subprocess.run([*cli,'open','http://127.0.0.1:8000/tests/','--config=tools/remake/chrome.config.json'],cwd=ROOT,capture_output=True,text=True)
            if opened.returncode or '### Error' in opened.stdout:
                raise RuntimeError(opened.stdout+opened.stderr)
            checked=subprocess.run([*cli,'run-code',code],cwd=ROOT,capture_output=True,text=True)
            match=re.search(r'### Result\n(.*?)\n###',checked.stdout,re.S)
            if checked.returncode or not match or '### Error' in checked.stdout:
                raise RuntimeError((checked.stdout+checked.stderr)[:4000])
            result=json.loads(match[1])
            if args.output:
                args.output.parent.mkdir(parents=True,exist_ok=True)
                args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
            print(json.dumps(result,ensure_ascii=False,indent=2))
            if result.get('failures') or result.get('errors') or result.get('status')=='fail':
                raise SystemExit(1)
        finally:
            server.shutdown()

if __name__=='__main__':
    main()
