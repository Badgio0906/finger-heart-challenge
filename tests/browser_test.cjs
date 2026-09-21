const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const fs = require('node:fs');
const assert = require('node:assert/strict');
const base = process.argv[2] || 'http://localhost:8765/';
const output = 'tests/artifacts';
fs.mkdirSync(output,{recursive:true});
(async()=>{
 const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-webgl','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
 const results=[];
 for(const device of [
  {name:'desktop',viewport:{width:1280,height:720},hasTouch:false},
  {name:'mobile',viewport:{width:390,height:844},hasTouch:true,isMobile:true,deviceScaleFactor:2},
  {name:'small-phone',viewport:{width:360,height:640},hasTouch:true,isMobile:true},
  {name:'mobile-landscape',viewport:{width:844,height:390},hasTouch:true,isMobile:true}
 ]){
  const context=await browser.newContext(device);
  const page=await context.newPage();
  const errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
  await page.goto(base+'?qa=1');
  await page.waitForFunction(()=>window.__fingerHeart?.width>0,{timeout:30000});
  assert.equal(await page.title(),'畑島さんの指ハートチャレンジ');
  const read=()=>page.evaluate(()=>window.__fingerHeart);
  const wait=pred=>page.waitForFunction(pred,null,{polling:'raf',timeout:10000});
  await wait(()=>window.__fingerHeart.hand===0&&window.__fingerHeart.state===0);
  await page.screenshot({path:`${output}/${device.name}.png`});
  // Actual browser input only: the QA bridge exposes observations, never game mutation.
  if(device.hasTouch)await page.touchscreen.tap(150,300);
  else await page.keyboard.press('Enter');
  await wait(()=>window.__fingerHeart.state===1);
  let state=await read();
  assert.equal(state.score,1);
  assert.equal(state.result,'指ハート！ +1');
  if(device.hasTouch)await page.touchscreen.tap(150,300);
  else await page.keyboard.press('Enter');
  assert.equal((await read()).score,1);
  await page.screenshot({path:`${output}/${device.name}-success.png`});
  await wait(()=>window.__fingerHeart.state===0&&window.__fingerHeart.hand!==0);
  if(device.hasTouch)await page.touchscreen.tap(150,300);
  else await page.keyboard.press('Space');
  await wait(()=>window.__fingerHeart.state===1);
  assert.equal((await read()).score,1);
  assert.equal((await read()).result,'ざんねん！');
  state=await read();
  const x=(state.reset[0]+state.reset[2]/2)*device.viewport.width/state.width;
  const y=(state.reset[1]+state.reset[3]/2)*device.viewport.height/state.height;
  if(device.hasTouch)await page.touchscreen.tap(x,y);
  else await page.mouse.click(x,y);
  await wait(()=>window.__fingerHeart.state===0&&window.__fingerHeart.score===0);
  await wait(()=>window.__fingerHeart.hand===0&&window.__fingerHeart.state===0);
  if(device.hasTouch)await page.touchscreen.tap(150,300);
  else await page.mouse.click(150,300);
  await wait(()=>window.__fingerHeart.state===1);
  assert.equal((await read()).score,1);
  assert.deepEqual(errors,[]);
  results.push({device:device.name,viewport:device.viewport,passed:true,errors});
  console.log(`PASS ${device.name}: render, success, failure, score, rapid input, resume, reset, ${device.hasTouch?'touch':'Enter/Space/click'}`);
  await context.close();
 }
 fs.writeFileSync(`${output}/browser-results.json`,JSON.stringify({url:base,results},null,2));
 await browser.close();
})().catch(e=>{console.error(e);process.exit(1)});
