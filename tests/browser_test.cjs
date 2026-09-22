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
  {name:'mobile',viewport:{width:390,height:844},hasTouch:true,isMobile:true}
 ]){
  const context=await browser.newContext(device);
  const page=await context.newPage();
  const errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
  const url=new URL(base);url.searchParams.set('qa','1');
  await page.goto(url.href);
  const wait=pred=>page.waitForFunction(pred,null,{polling:'raf',timeout:30000});
  const read=()=>page.evaluate(()=>window.__fingerHeart);
  const press=async()=>{if(device.hasTouch)await page.touchscreen.tap(150,300);else await page.keyboard.press('Enter');};
  const button=async name=>{
   const s=await read(),r=s[name],v=page.viewportSize();
   const x=(r[0]+r[2]/2)*v.width/s.width,y=(r[1]+r[3]/2)*v.height/s.height;
   if(device.hasTouch)await page.touchscreen.tap(x,y);else await page.mouse.click(x,y);
  };
  await wait(()=>window.__fingerHeart?.width>0);
  await page.screenshot({path:`${output}/stages-${device.name}.png`});
  await wait(()=>window.__fingerHeart.state===0&&window.__fingerHeart.hand!==0);
  await press();
  await wait(()=>window.__fingerHeart.state===3);
  await page.waitForTimeout(150);
  assert.equal((await read()).ending,'Failure');
  assert.equal((await read()).message,'指ハートマスターへの道は遠い');
  await page.screenshot({path:`${output}/failure-${device.name}.png`});
  await press();await page.waitForTimeout(900);
  assert.equal((await read()).state,3);
  await button('retry');
  await wait(()=>window.__fingerHeart.state===0&&window.__fingerHeart.score===0);
  for(let score=1;score<=25;score++){
   await wait(()=>window.__fingerHeart.state===0&&window.__fingerHeart.hand===0);
   await press();
   await page.waitForFunction(n=>window.__fingerHeart.score===n,score,{timeout:2000});
   if(score<25){
    await press();assert.equal((await read()).score,score);
    await wait(()=>window.__fingerHeart.state===0);
    const s=await read();
    assert.equal(s.stage,Math.floor(score/5)+1);
    assert.equal(s.interval,[.65,.55,.45,.35,.25][Math.floor(score/5)]);
    if(score%5===0)console.log(`PASS ${device.name}: ${score} successes, stage ${s.stage}, interval ${s.interval}`);
   }
  }
  await wait(()=>window.__fingerHeart.state===2);
  await page.waitForTimeout(150);
  assert.equal((await read()).ending,'Clear');
  assert.equal((await read()).message,'これであなたも指ハートマスター');
  await page.screenshot({path:`${output}/clear-${device.name}.png`});
  await press();await page.waitForTimeout(900);
  assert.equal((await read()).score,25);assert.equal((await read()).state,2);
  if(device.hasTouch){
   for(const [name,viewport] of [['small-phone',{width:360,height:640}],['mobile-landscape',{width:844,height:390}]]){
    await page.setViewportSize(viewport);await page.waitForTimeout(200);
    await page.screenshot({path:`${output}/clear-${name}.png`});
   }
   await page.setViewportSize(device.viewport);await page.waitForTimeout(200);
   // Refresh read-only layout observations via a resize-safe normal retry target.
  }
  await button('retry');
  await wait(()=>window.__fingerHeart.state===0&&window.__fingerHeart.score===0);
  assert.equal((await read()).stage,1);assert.equal((await read()).interval,.65);
  await wait(()=>window.__fingerHeart.state===0&&window.__fingerHeart.hand===0);
  await press();await wait(()=>window.__fingerHeart.state===1);
  await button('reset');await wait(()=>window.__fingerHeart.state===0&&window.__fingerHeart.score===0);
  assert.deepEqual(errors,[]);
  results.push({device:device.name,passed:true,errors});
  console.log(`PASS ${device.name}: full 25-success run, terminal screens, retry and reset`);
  await context.close();
 }
 fs.writeFileSync(`${output}/browser-results.json`,JSON.stringify({url:base,results},null,2));
 await browser.close();
})().catch(e=>{console.error(e);process.exit(1)});
