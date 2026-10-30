// Exercise the built site with its real Pagefind index and a Pages-style prefix.
import {chromium} from 'playwright';
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {readFile} from 'node:fs/promises';
import {resolve, extname, sep} from 'node:path';

const root=resolve('docs');
const mime={'.html':'text/html','.js':'text/javascript','.css':'text/css',
  '.json':'application/json','.wasm':'application/wasm','.svg':'image/svg+xml',
  '.png':'image/png','.pdf':'application/pdf'};
const server=createServer(async(req,res)=>{
  try {
    let path=decodeURIComponent(new URL(req.url,'http://localhost').pathname);
    if(path==='/favicon.ico'){res.writeHead(204).end();return;}
    path=path.replace(/^\/courses\//,'/');
    if(path.endsWith('/'))path+='index.html';
    const file=resolve(root,'.'+path);
    if(!file.startsWith(root+sep)){res.writeHead(403).end();return;}
    const body=await readFile(file);
    res.writeHead(200,{'Content-Type':mime[extname(file)]||'application/octet-stream'}).end(body);
  } catch {res.writeHead(404).end();}
});
await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
let browser;
try {
  browser=await chromium.launch({headless:true});
  const page=await browser.newPage();
  page.setDefaultTimeout(15000);
  page.setDefaultNavigationTimeout(30000);
  const errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  // External fonts, analytics, and the graph CDN are not needed for the
  // catalogue/search contract. Verify graceful operation without them.
  await page.route('**/*',route=>new URL(route.request().url()).hostname==='127.0.0.1'
    ? route.continue() : route.abort());
  const origin=`http://127.0.0.1:${server.address().port}`;
  await page.goto(origin+'/courses/overview.html?from=2026&to=-1');
  const count=()=>page.locator('#tutorial-list article').count();
  await page.waitForFunction(()=>document.querySelectorAll('#tutorial-list article').length===80);
  await page.locator('#network-reset').click();
  await page.locator('#topic-filter-bar button[data-value="course3"]').focus();
  await page.keyboard.press('Enter');
  assert.equal(await count(),20);
  await page.locator('#filter-reset').click();
  assert.equal(await count(),80);
  await page.locator('#overview-search').fill('bootstrap');
  await page.waitForFunction(()=>document.querySelectorAll('#tutorial-list .desc-snippet').length>0);
  assert.ok(await count()>0 && await count()<80);
  assert.equal(await page.locator('#search-status').innerText(),'');
  await page.locator('#overview-search').fill('"qzxvjkqzxvjk"');
  await page.waitForFunction(()=>document.querySelectorAll('#tutorial-list article').length===0);
  assert.ok(await page.locator('#tutorial-list-empty').isVisible());
  await page.locator('#filter-reset').click();
  assert.equal(await count(),80);
  await page.setViewportSize({width:390,height:844});
  await page.locator('#all-tutorials-nav summary').first().click();
  assert.ok(await page.locator('#all-tutorials-nav a').first().isVisible());
  await page.locator('#all-tutorials-nav a').first().click();
  await page.waitForURL(/lab_week/);
  assert.ok((await page.locator('h1').innerText()).includes('Session'));
  await page.route('**/pagefind/pagefind.js',route=>route.abort());
  await page.goto(origin+'/overview.html');
  await page.waitForFunction(()=>document.querySelectorAll('#tutorial-list article').length===80);
  await page.locator('#overview-search').fill('bootstrap');
  await page.waitForFunction(()=>document.querySelector('#search-status').textContent.includes('could not load'));
  await page.locator('#filter-reset').click();
  assert.equal(await count(),80);
  assert.deepEqual(errors,[]);
  console.log('Browser checks passed: catalogue, keyboard filters/reset, real search, empty results, mobile links, unavailable assets.');
} finally {
  await browser?.close();
  await new Promise(resolve=>server.close(resolve));
}
