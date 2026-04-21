<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>destination.com</title>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=Outfit:wght@200;300;400;500;600&family=DM+Mono:wght@300;400&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;}
:root{--ease:cubic-bezier(0.16,1,0.3,1);--spring:cubic-bezier(0.34,1.56,0.64,1);}

[data-theme="dark"]{
  --bg:#000;--bg2:#0b0b0d;--bg3:#141416;
  --s:rgba(255,255,255,.042);--s2:rgba(255,255,255,.07);
  --b:rgba(255,255,255,.08);--bh:rgba(255,255,255,.14);
  --t:#f5f5f7;--t2:rgba(245,245,247,.58);--t3:rgba(245,245,247,.3);
  --a:#0a84ff;--ag:rgba(10,132,255,.13);
  --gr:#30d158;--grg:rgba(48,209,88,.12);
  --go:#ffd60a;--gog:rgba(255,214,10,.1);
  --re:#ff453a;--reg:rgba(255,69,58,.1);
  --pu:#bf5af2;
  --nav:rgba(0,0,0,.78);
  --tk:#080808;
  /* Plane trail - single muted blue-white */
  --trail:rgba(180,210,255,.55);
  --trail2:rgba(255,255,255,.22);
}
[data-theme="light"]{
  --bg:#fff;--bg2:#f5f5f7;--bg3:#e8e8ed;
  --s:rgba(0,0,0,.04);--s2:rgba(0,0,0,.07);
  --b:rgba(0,0,0,.09);--bh:rgba(0,0,0,.16);
  --t:#1d1d1f;--t2:rgba(29,29,31,.6);--t3:rgba(29,29,31,.35);
  --a:#0071e3;--ag:rgba(0,113,227,.1);
  --gr:#248a3d;--grg:rgba(36,138,61,.1);
  --go:#9e6c00;--gog:rgba(158,108,0,.1);
  --re:#c4001a;--reg:rgba(196,0,26,.1);
  --pu:#8944ab;
  --nav:rgba(255,255,255,.82);
  --tk:#f0f0f0;
  --trail:rgba(0,80,180,.3);
  --trail2:rgba(0,0,0,.1);
}

html{scroll-behavior:smooth;}
body{
  font-family:'Outfit',sans-serif;background:var(--bg);color:var(--t);
  min-height:100vh;cursor:none;
  -webkit-font-smoothing:antialiased;overflow-x:hidden;
  transition:background .5s,color .4s;
}

/* ── CURSOR ── */
#cr{position:fixed;z-index:9999;pointer-events:none;
  width:28px;height:28px;border-radius:50%;
  border:1px solid rgba(180,210,255,.5);
  transform:translate(-50%,-50%);
  transition:width .2s var(--ease),height .2s var(--ease),
    border-color .2s,opacity .3s;
}
#cd{position:fixed;z-index:10000;pointer-events:none;
  width:4px;height:4px;border-radius:50%;
  background:var(--t);transform:translate(-50%,-50%);}

/* ── PLANE CANVAS ── */
#pcanvas{position:fixed;inset:0;z-index:1;pointer-events:none;}

/* ── NAV ── */
#nav{
  position:fixed;top:0;left:0;right:0;z-index:500;height:50px;
  background:var(--nav);backdrop-filter:blur(24px) saturate(180%);
  -webkit-backdrop-filter:blur(24px) saturate(180%);
  border-bottom:.5px solid var(--b);
  display:flex;align-items:center;justify-content:space-between;
  padding:0 2.5rem;transition:background .4s;
}
#nl{font-family:'Cormorant Garamond',serif;font-size:1.1rem;
  font-weight:300;letter-spacing:.05em;color:var(--t);cursor:pointer;}
#nl span{color:var(--a);}
.nl-links{display:flex;gap:1.8rem;}
.nl-link{font-size:.76rem;color:var(--t2);background:none;border:none;
  cursor:pointer;font-family:'Outfit',sans-serif;font-weight:300;
  letter-spacing:.01em;transition:color .15s;padding:0;}
.nl-link:hover{color:var(--t);}
.nr{display:flex;align-items:center;gap:.75rem;}
#tp{display:flex;align-items:center;gap:6px;background:var(--s2);
  border:.5px solid var(--b);border-radius:100px;padding:.22rem .6rem;
  cursor:pointer;transition:all .2s;font-size:.68rem;color:var(--t2);}
#tp:hover{border-color:var(--bh);color:var(--t);}
#fb{display:flex;align-items:center;gap:5px;background:var(--ag);
  color:var(--a);border:.5px solid rgba(10,132,255,.22);
  border-radius:100px;padding:.28rem .9rem;font-size:.72rem;
  font-weight:400;cursor:pointer;font-family:'Outfit',sans-serif;
  transition:all .2s;}
#fb:hover{background:rgba(10,132,255,.22);}
.ld{width:5px;height:5px;background:var(--gr);border-radius:50%;
  animation:pulse 2s infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.3;transform:scale(.6)}}

/* ── SLEEP ── */
#sleep{position:fixed;inset:0;z-index:400;display:flex;flex-direction:column;
  align-items:center;justify-content:center;background:var(--bg);
  transition:opacity 1.4s var(--ease);}
#sleep.gone{opacity:0;pointer-events:none;}
.sl{font-family:'Cormorant Garamond',serif;font-size:clamp(3rem,7vw,5.5rem);
  font-weight:300;letter-spacing:-.025em;color:var(--t);margin-bottom:1.8rem;line-height:1;}
.sl em{font-style:italic;color:var(--a);}
.sh{font-size:.66rem;letter-spacing:.28em;color:var(--t3);text-transform:uppercase;
  font-family:'DM Mono',monospace;animation:breathe 4s ease-in-out infinite;}
@keyframes breathe{0%,100%{opacity:.15}50%{opacity:.65}}
@keyframes fadeUp{from{opacity:0;transform:translateY(24px)}to{opacity:1;transform:translateY(0)}}

/* ── PAGE ── */
#page{position:relative;z-index:10;padding:80px 0 220px;
  opacity:0;transition:opacity 1s var(--ease);}
#page.show{opacity:1;}

/* ── HERO ── */
#hero{text-align:center;padding:5.5rem 2rem 4rem;max-width:860px;margin:0 auto;}
#hero h1{font-family:'Cormorant Garamond',serif;font-size:clamp(2.8rem,6vw,5rem);
  font-weight:300;line-height:1.06;letter-spacing:-.03em;color:var(--t);margin-bottom:1.2rem;}
#hero h1 em{font-style:italic;color:var(--a);}
#hero-sub{font-size:.95rem;color:var(--t2);font-weight:300;line-height:1.72;
  max-width:440px;margin:0 auto;}

/* AI badge strip */
#ai-badges{display:flex;gap:.5rem;flex-wrap:wrap;justify-content:center;margin-top:1.8rem;}
.aib{display:flex;align-items:center;gap:4px;background:var(--s);border:.5px solid var(--b);
  border-radius:100px;padding:.22rem .75rem;font-size:.6rem;color:var(--t3);
  font-family:'DM Mono',monospace;letter-spacing:.04em;transition:all .2s;}
.aib:hover{border-color:var(--bh);color:var(--t2);}
.aib-dot{width:3px;height:3px;border-radius:50%;background:var(--a);flex-shrink:0;}

/* ── INPUT ── */
.wrap{max-width:760px;margin:0 auto;padding:0 2rem;}
#ic{background:var(--bg2);border:.5px solid var(--bh);border-radius:20px;
  overflow:hidden;transition:border-color .35s,box-shadow .35s,background .5s;
  box-shadow:0 0 0 0 var(--ag);}
#ic:focus-within{border-color:rgba(10,132,255,.4);
  box-shadow:0 0 0 3px var(--ag),0 16px 50px rgba(0,0,0,.2);}
.ich{padding:.9rem 1.4rem .65rem;display:flex;align-items:center;gap:9px;
  border-bottom:.5px solid var(--b);}
.bav{width:24px;height:24px;border-radius:50%;
  background:linear-gradient(135deg,var(--a),var(--pu));
  display:flex;align-items:center;justify-content:center;
  font-size:.58rem;font-weight:700;color:#fff;flex-shrink:0;}
.icn{font-size:.78rem;font-weight:400;color:var(--t);}
.ics{font-size:.6rem;color:var(--t3);font-family:'DM Mono',monospace;}
.icl{padding:.8rem 1.4rem .28rem;font-size:.58rem;letter-spacing:.11em;
  text-transform:uppercase;color:var(--t3);display:flex;align-items:center;gap:7px;
  font-family:'DM Mono',monospace;}
#ta{width:100%;padding:.38rem 1.4rem .95rem;font-family:'Outfit',sans-serif;
  font-size:.97rem;color:var(--t);background:transparent;border:none;outline:none;
  resize:none;line-height:1.68;min-height:84px;}
#ta::placeholder{color:var(--t3);}
.icf{border-top:.5px solid var(--b);padding:.65rem 1.4rem;
  display:flex;align-items:center;justify-content:space-between;gap:.5rem;flex-wrap:wrap;}
#cct{font-family:'DM Mono',monospace;font-size:.58rem;color:var(--t3);}
#sb{background:var(--a);color:#fff;border:none;padding:.45rem 1.4rem;
  border-radius:100px;font-family:'Outfit',sans-serif;font-size:.8rem;font-weight:500;
  cursor:pointer;transition:all .2s;letter-spacing:.01em;}
#sb:hover:not(:disabled){filter:brightness(1.12);transform:scale(1.025);}
#sb:disabled{background:var(--s2);color:var(--t3);cursor:not-allowed;transform:none;filter:none;}
#qps{display:flex;gap:.42rem;flex-wrap:wrap;margin-top:.85rem;}
.qp{background:var(--s);border:.5px solid var(--b);color:var(--t2);font-size:.7rem;
  padding:.26rem .78rem;border-radius:100px;cursor:pointer;transition:all .18s;
  font-family:'Outfit',sans-serif;white-space:nowrap;}
.qp:hover{background:var(--ag);border-color:rgba(10,132,255,.3);color:var(--a);}

/* ── AI STAGE INDICATOR ── */
#ai-stage{display:none;max-width:760px;margin:.8rem auto 0;padding:0 2rem;}
#ai-stage.show{display:block;}
.stage-track{background:var(--s2);border:.5px solid var(--b);border-radius:12px;padding:.7rem 1rem;
  display:flex;align-items:center;gap:1rem;flex-wrap:wrap;}
.stage-item{display:flex;align-items:center;gap:5px;font-size:.62rem;
  color:var(--t3);font-family:'DM Mono',monospace;transition:color .3s;}
.stage-item.active{color:var(--a);}
.stage-item.done{color:var(--gr);}
.si-dot{width:5px;height:5px;border-radius:50%;background:currentColor;flex-shrink:0;}
.si-sep{color:var(--b);font-size:.7rem;}

/* ── LOADING ── */
#loading{display:none;text-align:center;padding:2.2rem;}
#loading.show{display:block;}
.ldd{display:flex;gap:5px;justify-content:center;margin-bottom:.75rem;}
.ldd span{width:6px;height:6px;background:var(--a);border-radius:50%;animation:ld 1.1s infinite;}
.ldd span:nth-child(2){animation-delay:.16s;}.ldd span:nth-child(3){animation-delay:.32s;}
@keyframes ld{0%,80%,100%{transform:scale(.55);opacity:.28}40%{transform:scale(1);opacity:1}}
#loading p{font-size:.8rem;color:var(--t2);font-weight:300;}

/* ── ERR ── */
#eb{display:none;background:var(--reg);border:.5px solid rgba(255,69,58,.2);
  border-radius:12px;padding:.8rem 1.1rem;font-size:.8rem;color:var(--re);margin-top:.9rem;}
#eb.show{display:block;}

/* ── RESULTS ── */
#results{display:none;margin-top:2.2rem;animation:fadeUp .55s var(--ease) both;}
#results.show{display:block;}
.sl2{font-size:.57rem;letter-spacing:.14em;text-transform:uppercase;color:var(--t3);
  font-family:'DM Mono',monospace;display:flex;align-items:center;gap:10px;margin-bottom:.9rem;}
.sl2::after{content:'';flex:1;height:.5px;background:var(--b);}

/* RAG sources */
#rags{display:flex;gap:.38rem;flex-wrap:wrap;margin-bottom:1.4rem;}
.rp{display:flex;align-items:center;gap:4px;background:var(--s2);border:.5px solid var(--b);
  border-radius:100px;padding:.2rem .72rem;font-size:.6rem;color:var(--t3);
  font-family:'DM Mono',monospace;}
.rp-d{width:3px;height:3px;border-radius:50%;background:var(--gr);}

/* Summary */
#asum{background:var(--ag);border:.5px solid rgba(10,132,255,.15);border-radius:14px;
  padding:.9rem 1.15rem;margin-bottom:1.8rem;font-size:.87rem;line-height:1.72;
  color:var(--t2);font-weight:300;}

/* Best card */
#bc{background:var(--bg2);border:.5px solid var(--bh);border-radius:18px;
  padding:1.65rem;margin-bottom:1.8rem;position:relative;overflow:hidden;transition:background .5s;}
#bc::before{content:'';position:absolute;top:0;left:0;right:0;height:1.5px;
  background:linear-gradient(90deg,var(--a),var(--gr),var(--pu));}
.bb{display:inline-flex;align-items:center;gap:4px;background:var(--ag);color:var(--a);
  font-size:.58rem;letter-spacing:.07em;padding:2px 9px;border-radius:100px;
  margin-bottom:.9rem;text-transform:uppercase;font-family:'DM Mono',monospace;}
#bt{font-family:'Cormorant Garamond',serif;font-size:1.7rem;font-weight:300;
  color:var(--t);margin-bottom:.5rem;line-height:1.2;}
#bd{font-size:.83rem;color:var(--t2);line-height:1.72;margin-bottom:.95rem;font-weight:300;}
#bm{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:.95rem;}
.mc{background:var(--s2);border-radius:9px;padding:.36rem .8rem;}
.mcl{font-size:.52rem;color:var(--t3);letter-spacing:.06em;text-transform:uppercase;font-family:'DM Mono',monospace;}
.mcv{font-size:.8rem;font-weight:400;color:var(--t);margin-top:2px;}
#bhl{list-style:none;}
#bhl li{display:flex;align-items:flex-start;gap:6px;font-size:.81rem;
  color:var(--t2);padding:.3rem 0;border-bottom:.5px solid var(--b);line-height:1.55;}
#bhl li:last-child{border-bottom:none;}
#bhl li::before{content:'✓';color:var(--gr);flex-shrink:0;font-size:.7rem;margin-top:2px;}
.cf{font-size:.55rem;padding:1px 7px;border-radius:100px;font-family:'DM Mono',monospace;
  text-transform:uppercase;letter-spacing:.05em;margin-left:7px;vertical-align:middle;}
.cfh{background:var(--grg);color:var(--gr);}
.cfm{background:var(--gog);color:var(--go);}
.cfl{background:var(--reg);color:var(--re);}

/* Alts */
#ag2{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:10px;margin-bottom:1.8rem;}
.ac{background:var(--bg2);border:.5px solid var(--b);border-radius:14px;padding:1.05rem;
  transition:border-color .2s,transform .2s var(--spring),background .5s;}
.ac:hover{border-color:rgba(10,132,255,.3);transform:translateY(-3px);}
.abg{font-size:.55rem;padding:2px 8px;border-radius:100px;text-transform:uppercase;
  letter-spacing:.06em;margin-bottom:7px;display:inline-block;font-family:'DM Mono',monospace;}
.abf{background:var(--ag);color:var(--a);}
.abc{background:var(--grg);color:var(--gr);}
.abs{background:rgba(191,90,242,.1);color:var(--pu);}
.abb{background:var(--gog);color:var(--go);}
.att{font-size:.88rem;font-weight:400;color:var(--t);margin-bottom:3px;}
.av{font-size:.65rem;color:var(--t3);font-family:'DM Mono',monospace;margin-bottom:7px;}
.as2{display:flex;gap:12px;margin-bottom:6px;}
.asl{font-size:.52rem;color:var(--t3);text-transform:uppercase;letter-spacing:.05em;font-family:'DM Mono',monospace;}
.asv{font-size:.78rem;color:var(--t);margin-top:1px;}
.atr{font-size:.74rem;color:var(--t2);line-height:1.55;padding-top:7px;border-top:.5px solid var(--b);}

/* Safety */
#sc{background:var(--gog);border:.5px solid rgba(255,214,10,.14);border-radius:14px;
  padding:.9rem 1.25rem;margin-bottom:1.8rem;}
.sch{display:flex;align-items:center;gap:6px;margin-bottom:.7rem;}
.sct{font-size:.78rem;font-weight:400;color:var(--t);}
.si{display:flex;align-items:flex-start;gap:6px;font-size:.78rem;color:var(--t2);
  padding:.28rem 0;border-bottom:.5px solid var(--b);line-height:1.5;}
.si:last-child{border-bottom:none;}
.si::before{content:'→';color:var(--go);flex-shrink:0;font-size:.7rem;margin-top:2px;}

/* Articles */
#artg{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:10px;margin-bottom:1.8rem;}
.artc{background:var(--bg2);border:.5px solid var(--b);border-radius:14px;padding:.9rem;
  cursor:pointer;transition:border-color .2s,transform .2s var(--spring),background .5s;}
.artc:hover{border-color:rgba(191,90,242,.3);transform:translateY(-3px);}
.arcat{font-size:.54rem;letter-spacing:.07em;text-transform:uppercase;font-weight:500;
  padding:2px 7px;border-radius:100px;margin-bottom:6px;display:inline-block;font-family:'DM Mono',monospace;}
.arsa{background:var(--reg);color:var(--re);}
.arbu{background:var(--grg);color:var(--gr);}
.arpl{background:var(--ag);color:var(--a);}
.arcu{background:rgba(191,90,242,.1);color:var(--pu);}
.arad{background:var(--gog);color:var(--go);}
.artt{font-size:.82rem;color:var(--t);line-height:1.4;margin-bottom:5px;}
.artd{font-size:.72rem;color:var(--t3);line-height:1.5;margin-bottom:5px;}
.artr{font-size:.58rem;color:var(--t3);font-family:'DM Mono',monospace;}

/* Community */
#comm{background:var(--bg2);border:.5px solid var(--b);border-radius:18px;
  padding:1.3rem;margin-bottom:1.8rem;transition:background .5s;}
.cmt{display:flex;align-items:center;justify-content:space-between;margin-bottom:.8rem;}
.cml{font-size:.78rem;color:var(--t2);}
#ccnt{background:var(--gr);color:#000;font-size:.6rem;font-weight:600;padding:2px 9px;border-radius:100px;}
#cins{font-size:.82rem;color:var(--t2);line-height:1.7;margin-bottom:.8rem;font-weight:300;}
.cti{display:flex;gap:7px;font-size:.76rem;color:var(--t3);padding:.28rem 0;
  border-bottom:.5px solid var(--b);line-height:1.45;}
.cti:last-child{border-bottom:none;}
.cti::before{content:'—';color:var(--t3);}
#cb{margin-top:.85rem;background:var(--s2);color:var(--t2);border:.5px solid var(--b);
  padding:.4rem 1.1rem;border-radius:100px;font-size:.72rem;cursor:pointer;
  font-family:'Outfit',sans-serif;transition:all .2s;}
#cb:hover{background:var(--ag);border-color:rgba(10,132,255,.3);color:var(--a);}
#disc{font-size:.64rem;color:var(--t3);text-align:center;margin-top:.4rem;line-height:1.55;}

/* ML panels */
#mlw{margin-top:2.2rem;display:none;}
.mlg{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:10px;margin-top:.7rem;}
.mlc{background:var(--bg2);border:.5px solid var(--b);border-radius:14px;padding:1.1rem;transition:background .5s;}
.mlh{display:flex;align-items:flex-start;gap:8px;margin-bottom:.8rem;}
.mlt{font-size:.8rem;font-weight:400;color:var(--t);margin-bottom:2px;}
.mls{font-size:.6rem;color:var(--t3);font-family:'DM Mono',monospace;}
.wrow{display:flex;gap:9px;flex-wrap:wrap;margin-bottom:9px;}
.wi{flex:1;min-width:70px;}
.wl{display:flex;justify-content:space-between;font-size:.6rem;color:var(--t3);margin-bottom:3px;}
.wv{color:var(--a);font-weight:500;}
input[type=range]{width:100%;accent-color:var(--a);height:2px;cursor:pointer;}
.or2{display:flex;align-items:flex-start;gap:8px;padding:6px 8px;margin-bottom:4px;
  border-radius:8px;background:var(--s);border-left:2px solid transparent;transition:border-color .3s;}
.or2.top{border-left-color:var(--a);}
.ork{font-size:.76rem;font-weight:500;color:var(--a);min-width:16px;padding-top:1px;}
.orn{font-size:.72rem;color:var(--t);margin-bottom:3px;}
.bg2{flex:1;}
.br{margin-bottom:2px;}
.brh{display:flex;justify-content:space-between;font-size:.55rem;color:var(--t3);margin-bottom:1px;}
.bt2{background:var(--s2);border-radius:2px;height:3px;overflow:hidden;}
.bf3{height:100%;border-radius:2px;transition:width .65s var(--ease);}
.osn{font-size:.92rem;font-weight:500;color:var(--a);}
.osl{font-size:.5rem;color:var(--t3);text-transform:uppercase;letter-spacing:.04em;}
.swrp{background:var(--s);border-radius:8px;overflow:hidden;margin-bottom:7px;padding:3px;}
.trow2{display:flex;align-items:center;gap:7px;padding:5px 0;border-bottom:.5px solid var(--b);}
.trow2:last-child{border-bottom:none;}
.tav{width:25px;height:25px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.56rem;font-weight:600;flex-shrink:0;}
.tn{font-size:.74rem;color:var(--t);}
.tr3{font-size:.58rem;color:var(--t3);font-family:'DM Mono',monospace;}
.sbd{font-size:.56rem;padding:1px 6px;border-radius:100px;}
.tst{font-size:.54rem;color:var(--t3);margin-top:1px;}
.fr{display:flex;gap:4px;flex-wrap:wrap;margin-bottom:8px;}
.fb2{background:transparent;border:.5px solid var(--b);color:var(--t3);padding:2px 9px;
  border-radius:100px;font-size:.61rem;cursor:pointer;font-family:'Outfit',sans-serif;transition:all .15s;}
.fb2.on{background:var(--ag);border-color:rgba(10,132,255,.3);color:var(--a);}
.rrow{display:flex;align-items:flex-start;gap:7px;padding:5px 0;border-bottom:.5px solid var(--b);}
.rrow:last-child{border-bottom:none;}
.rrk{font-size:.58rem;color:var(--t3);min-width:14px;padding-top:2px;}
.rsc{display:flex;gap:6px;flex-wrap:wrap;margin-top:2px;}
.rse{font-size:.58rem;color:var(--t3);}
.rrd{font-size:.56rem;color:var(--t3);font-family:'DM Mono',monospace;white-space:nowrap;padding-top:2px;}

/* Live travellers */
#lts{margin-top:2.5rem;}
.ltc{background:var(--bg2);border:.5px solid var(--b);border-radius:18px;overflow:hidden;transition:background .5s;}
.lth{padding:.85rem 1.4rem;border-bottom:.5px solid var(--b);display:flex;align-items:center;justify-content:space-between;}
.ltht{font-size:.8rem;font-weight:400;color:var(--t);}
.ltl{display:flex;align-items:center;gap:5px;font-family:'DM Mono',monospace;font-size:.58rem;color:var(--gr);}
.ltr{display:flex;align-items:center;gap:.85rem;padding:.6rem 1.4rem;border-bottom:.5px solid var(--b);transition:background .15s;}
.ltr:last-child{border-bottom:none;}
.ltr:hover{background:var(--s);}
.ltav{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.58rem;font-weight:600;flex-shrink:0;}
.ltname{font-size:.78rem;color:var(--t);}
.ltroute{font-size:.62rem;color:var(--t3);font-family:'DM Mono',monospace;margin-top:1px;}
.ltstat{display:flex;align-items:center;gap:4px;font-size:.64rem;color:var(--t2);}
.ltd{width:4px;height:4px;border-radius:50%;background:var(--gr);flex-shrink:0;}
.ltm{background:var(--ag);color:var(--a);font-size:.58rem;padding:1px 7px;border-radius:100px;font-family:'DM Mono',monospace;white-space:nowrap;}
.ltbtn{background:transparent;border:.5px solid var(--b);color:var(--t2);padding:.2rem .65rem;border-radius:100px;font-size:.66rem;cursor:pointer;font-family:'Outfit',sans-serif;transition:all .15s;}
.ltbtn:hover{background:var(--ag);border-color:rgba(10,132,255,.3);color:var(--a);}

/* ── SCROLL-TRIGGERED DESTINATION CARDS ── */
#dst-section{margin-top:5rem;padding:0 2rem;}
.dst-intro{text-align:center;margin-bottom:2.5rem;}
.dst-intro h3{font-family:'Cormorant Garamond',serif;font-size:1.85rem;font-weight:300;
  letter-spacing:-.02em;color:var(--t);margin-bottom:.4rem;line-height:1.15;}
.dst-intro p{font-size:.8rem;color:var(--t2);font-weight:300;}
#dst-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(195px,1fr));gap:14px;}

.dstcard{
  position:relative;height:250px;border-radius:18px;overflow:hidden;cursor:pointer;
  border:.5px solid var(--b);
  opacity:0;transform:translateY(48px) scale(.97);
  transition:
    opacity .75s var(--ease),
    transform .75s var(--ease),
    border-color .3s;
  will-change:opacity,transform;
}
.dstcard.in{opacity:1;transform:translateY(0) scale(1);}
.dstcard:hover{border-color:rgba(10,132,255,.38);}
.dstcard:hover .dci{transform:scale(1.07);filter:brightness(.92);}
.dstcard:hover .dco{opacity:1;}
.dstcard:hover .dcc{opacity:1;transform:translateY(0);}
.dci{width:100%;height:100%;object-fit:cover;filter:brightness(.7);
  transition:transform .55s var(--ease),filter .35s;}
.dco{position:absolute;inset:0;
  background:linear-gradient(to top,rgba(0,0,0,.85) 0%,rgba(0,0,0,.18) 55%,transparent 100%);
  opacity:.88;transition:opacity .3s;}
.dcb{position:absolute;bottom:0;left:0;right:0;padding:1.15rem;}
.dctag{font-size:.52rem;color:var(--a);font-family:'DM Mono',monospace;
  letter-spacing:.08em;text-transform:uppercase;margin-bottom:.28rem;display:block;}
.dcname{font-family:'Cormorant Garamond',serif;font-size:1.25rem;font-weight:300;
  color:#fff;line-height:1.1;margin-bottom:.2rem;}
.dcsub{font-size:.62rem;color:rgba(255,255,255,.5);}
.dcc{position:absolute;top:.9rem;right:.9rem;background:rgba(0,0,0,.42);
  color:rgba(255,255,255,.8);border:.5px solid rgba(255,255,255,.2);
  border-radius:100px;padding:.2rem .65rem;font-size:.58rem;cursor:pointer;
  font-family:'Outfit',sans-serif;opacity:0;transform:translateY(-5px);
  transition:opacity .2s,transform .2s;}

/* ── FLIGHTS MODAL ── */
#fm{position:fixed;inset:0;z-index:600;background:rgba(0,0,0,.75);
  backdrop-filter:blur(16px);display:flex;align-items:center;justify-content:center;
  opacity:0;pointer-events:none;transition:opacity .35s;}
#fm.open{opacity:1;pointer-events:all;}
#fp2{width:920px;max-width:96vw;height:84vh;background:var(--bg2);
  border:.5px solid var(--bh);border-radius:22px;overflow:hidden;display:flex;flex-direction:column;
  transform:scale(.95) translateY(18px);transition:transform .38s var(--ease),background .5s;
  box-shadow:0 50px 100px rgba(0,0,0,.6);}
#fm.open #fp2{transform:scale(1) translateY(0);}
.fph{padding:.85rem 1.4rem;border-bottom:.5px solid var(--b);display:flex;align-items:center;justify-content:space-between;flex-shrink:0;}
.fpt2{font-size:.86rem;font-weight:400;color:var(--t);}
.fps{font-size:.6rem;color:var(--t3);font-family:'DM Mono',monospace;margin-top:1px;}
.fptabs{display:flex;border-bottom:.5px solid var(--b);flex-shrink:0;}
.fptab{padding:.58rem 1.2rem;font-size:.72rem;color:var(--t3);border-bottom:1.5px solid transparent;cursor:pointer;transition:all .15s;font-family:'Outfit',sans-serif;background:none;border-top:none;border-left:none;border-right:none;}
.fptab.on{color:var(--a);border-bottom-color:var(--a);}
.fpbd{flex:1;overflow:hidden;position:relative;}
.fpiframe{width:100%;height:100%;border:none;}
.fpmapw{width:100%;height:100%;display:flex;flex-direction:column;display:none;}
#fpc{flex:1;width:100%;}
.fpfl{height:130px;overflow-y:auto;border-top:.5px solid var(--b);flex-shrink:0;}
.fplr{display:flex;align-items:center;gap:.9rem;padding:.42rem 1rem;border-bottom:.5px solid var(--b);font-size:.72rem;cursor:pointer;transition:background .15s;}
.fplr:hover{background:var(--s);}
.fplfn{font-family:'DM Mono',monospace;color:var(--a);min-width:56px;}
.fplrt{color:var(--t);flex:1;}.fplalt,.fplspd{color:var(--t3);}
.fplst{font-size:.56rem;padding:1px 7px;border-radius:100px;background:var(--grg);color:var(--gr);}
.fpcls{width:26px;height:26px;border-radius:50%;background:var(--s2);border:.5px solid var(--b);color:var(--t2);cursor:pointer;font-size:.8rem;display:flex;align-items:center;justify-content:center;transition:background .2s;font-family:inherit;}
.fpcls:hover{background:var(--s);}

/* ── DEST MODAL ── */
#dm{position:fixed;inset:0;z-index:700;display:flex;align-items:center;justify-content:center;
  background:rgba(0,0,0,.75);backdrop-filter:blur(16px);opacity:0;pointer-events:none;transition:opacity .35s;}
#dm.open{opacity:1;pointer-events:all;}
#dmc{width:660px;max-width:94vw;max-height:88vh;overflow-y:auto;background:var(--bg2);
  border:.5px solid var(--bh);border-radius:22px;
  transform:scale(.95) translateY(18px);transition:transform .38s var(--ease),background .5s;
  box-shadow:0 50px 100px rgba(0,0,0,.6);}
#dm.open #dmc{transform:scale(1) translateY(0);}
#diw{position:relative;height:230px;overflow:hidden;border-radius:22px 22px 0 0;}
#dimg{width:100%;height:100%;object-fit:cover;filter:brightness(.78);transition:transform 8s;}
#dm.open #dimg{transform:scale(1.06);}
.dov{position:absolute;inset:0;background:linear-gradient(transparent 42%,var(--bg2));}
#dlbl{position:absolute;top:1rem;left:1.2rem;font-family:'DM Mono',monospace;font-size:.57rem;
  letter-spacing:.12em;color:rgba(255,255,255,.55);background:rgba(0,0,0,.45);
  padding:3px 8px;border-radius:100px;border:.5px solid rgba(255,255,255,.12);text-transform:uppercase;}
#dcls{position:absolute;top:1rem;right:1.2rem;width:27px;height:27px;border-radius:50%;
  background:rgba(0,0,0,.5);border:.5px solid rgba(255,255,255,.14);color:#fff;
  font-size:.8rem;cursor:pointer;display:flex;align-items:center;justify-content:center;
  font-family:inherit;transition:background .2s;line-height:1;}
#dcls:hover{background:rgba(255,255,255,.15);}
#dbody{padding:1.4rem 1.6rem 1.6rem;}
#dname{font-family:'Cormorant Garamond',serif;font-size:1.8rem;font-weight:300;
  color:var(--t);margin-bottom:.28rem;line-height:1.15;}
#dctry{font-size:.6rem;color:var(--a);letter-spacing:.1em;text-transform:uppercase;
  font-family:'DM Mono',monospace;margin-bottom:.95rem;}
#dinfo{font-size:.82rem;line-height:1.78;color:var(--t2);font-weight:300;margin-bottom:1.1rem;}
#dtips{display:grid;grid-template-columns:1fr 1fr;gap:7px;margin-bottom:1.1rem;}
.tc{background:var(--s);border:.5px solid var(--b);border-radius:10px;
  padding:.55rem .8rem;display:flex;align-items:flex-start;gap:6px;}
.tci{font-size:.76rem;flex-shrink:0;margin-top:1px;}
.tcb{font-size:.7rem;color:var(--t2);line-height:1.5;}
.tcb strong{color:var(--t);font-weight:400;display:block;margin-bottom:1px;}
#dwarn{background:var(--gog);border:.5px solid rgba(255,214,10,.18);border-radius:10px;
  padding:.72rem .95rem;font-size:.74rem;color:var(--go);line-height:1.6;display:flex;gap:7px;}

/* ── TICKER ── */
#ticker{position:fixed;bottom:0;left:0;right:0;z-index:300;height:38px;
  background:var(--tk);border-top:.5px solid var(--b);
  display:flex;align-items:center;overflow:hidden;transition:background .4s;}
.tklbl{flex-shrink:0;padding:0 .8rem;height:100%;display:flex;align-items:center;gap:4px;
  background:var(--re);font-size:.54rem;letter-spacing:.1em;text-transform:uppercase;
  font-family:'DM Mono',monospace;color:#fff;white-space:nowrap;border-right:.5px solid rgba(255,255,255,.12);}
.tktrk{flex:1;overflow:hidden;height:100%;position:relative;}
.tkinn{display:flex;align-items:center;height:100%;white-space:nowrap;
  animation:tks 55s linear infinite;}
@keyframes tks{0%{transform:translateX(0)}100%{transform:translateX(-50%)}}
.tki{display:inline-flex;align-items:center;gap:.5rem;padding:0 1.7rem;
  font-size:.68rem;color:var(--t);font-weight:300;border-right:.5px solid var(--b);height:100%;}
.tkdot{width:4px;height:4px;border-radius:50%;flex-shrink:0;}

/* Ripple */
.ripple{position:fixed;border-radius:50%;pointer-events:none;z-index:9;
  border:.7px solid rgba(180,210,255,.3);transform:translate(-50%,-50%) scale(0);
  animation:rip 1s ease-out forwards;}
@keyframes rip{to{transform:translate(-50%,-50%) scale(4.5);opacity:0}}

@media(max-width:640px){
  .nl-links{display:none;}
  .wrap{padding:0 1.2rem;}
  #dst-grid{grid-template-columns:1fr 1fr;}
  .dstcard{height:185px;}
  #dtips{grid-template-columns:1fr;}
  #mlw{display:none!important;}
}
</style>
</head>
<body>
<div id="cr"></div>
<div id="cd"></div>
<canvas id="pcanvas"></canvas>

<div id="sleep">
  <div class="sl">
    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:block;margin:0 auto 1.2rem;opacity:.7;">
      <path d="M3 17L9.5 13.5L7 7L9 6L14 11.5L19 9C19.8 8.6 21 9.1 21 10C21 10.6 20.6 11.1 20 11.3L5 18.5C3.8 19 3 18 3 17Z" fill="#0a84ff"/>
    </svg>
    destination<em>.</em>com
  </div>
  <div class="sh">move to explore</div>
</div>

<nav id="nav">
  <div id="nl">
    <svg id="nav-plane-logo" width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:inline-block;vertical-align:middle;margin-right:7px;">
      <path d="M3 17L9.5 13.5L7 7L9 6L14 11.5L19 9C19.8 8.6 21 9.1 21 10C21 10.6 20.6 11.1 20 11.3L5 18.5C3.8 19 3 18 3 17Z" fill="currentColor" opacity="0.9"/>
    </svg>destination<span>.</span>com
  </div>
  <div class="nl-links">
    <button class="nl-link" onclick="scr('ic')">Plan Route</button>
    <button class="nl-link" onclick="scr('lts')">Live Travellers</button>
    <button class="nl-link" onclick="scr('dst-section')">Destinations</button>
  </div>
  <div class="nr">
    <div id="tp"><span id="ticon">🌙</span><span id="ttxt">Dark</span></div>
    <button id="fb"><div class="ld"></div>Live Flights</button>
  </div>
</nav>

<div id="page">
  <div id="hero">
    <h1>Your world moves.<br><em>So should you.</em></h1>
    <p id="hero-sub">Tell us where you're headed — or stuck. We find the way through, around, and beyond.</p>
  </div>

  <div class="wrap" style="animation:fadeUp .8s .1s both;">
    <div id="ic">
      <div class="ich">
        <div class="bav">AI</div>
        <div><div class="icn">Route Intelligence</div><div class="ics">Routes · Alternatives · Visa Info · Safety</div></div>
      </div>
      <div class="icl"><div class="ld"></div>Describe your travel situation</div>
      <textarea id="ta" rows="4" placeholder="e.g. Stuck in London Heathrow — all transatlantic flights cancelled due to airspace restrictions. Need New York JFK by tomorrow. Speed over cost. What are my visa options for any stopover?"></textarea>
      <div class="icf">
        <span id="cct">0 / 600</span>
        <button id="sb" disabled>Analyse Route →</button>
      </div>
    </div>
    <div id="qps">
      <span class="qp">✈ London → NYC, airspace closed</span>
      <span class="qp">💸 Budget: Tokyo → Sydney</span>
      <span class="qp">🗺 Scenic NYC → San Francisco</span>
      <span class="qp">👨‍👩‍👧‍👦 Family reroute: Dubai → Rome</span>
    </div>
  </div>

  <!-- Processing indicator -->
  <div id="ai-stage">
    <div class="stage-track">
      <div class="stage-item" id="st-parse"><div class="si-dot"></div>Reading situation</div>
      <div class="si-sep">›</div>
      <div class="stage-item" id="st-rag"><div class="si-dot"></div>Checking routes</div>
      <div class="si-sep">›</div>
      <div class="stage-item" id="st-embed"><div class="si-dot"></div>Verifying NOTAMs</div>
      <div class="si-sep">›</div>
      <div class="stage-item" id="st-agent"><div class="si-dot"></div>Visa lookup</div>
      <div class="si-sep">›</div>
      <div class="stage-item" id="st-rank"><div class="si-dot"></div>Ranking options</div>
      <div class="si-sep">›</div>
      <div class="stage-item" id="st-out"><div class="si-dot"></div>Ready</div>
    </div>
  </div>

  <div id="loading"><div class="ldd"><span></span><span></span><span></span></div><p>Analysing routes · Checking NOTAMs · Querying visa databases…</p></div>
  <div id="eb" class="wrap"></div>

  <div id="results" class="wrap">
    <div id="asum"></div>
    <div id="rags"></div>
    <div class="sl2">Best solution</div>
    <div id="bc">
      <div class="bb">✦ AI Recommended</div>
      <div id="bt"></div><div id="bd"></div>
      <div id="bm"></div><ul id="bhl"></ul>
    </div>
    <div class="sl2">Alternative routes</div>
    <div id="ag2"></div>
    <div class="sl2">Safety &amp; visa guidance</div>
    <div id="sc"><div class="sch"><span>⚠</span><span class="sct">Real-time safety &amp; visa recommendations</span></div><div id="slist"></div></div>
    <div class="sl2">Related articles</div>
    <div id="artg"></div>
    <div class="sl2">Community insights</div>
    <div id="comm">
      <div class="cmt"><span class="cml">Travellers on similar routes</span><span id="ccnt">0 active</span></div>
      <div id="cins"></div><div id="ctips"></div>
      <button id="cb">Connect with travellers (opt-in) →</button>
    </div>
    <div id="disc"></div>
    <div id="mlw">
      <div class="sl2" style="margin-top:1.5rem;">Route Analysis</div>
      <div class="mlg">
        <div class="mlc"><div class="mlh"><span>⚡</span><div><div class="mlt">Route Optimizer</div><div class="mls">Adjust priority weights</div></div></div><div class="wrow" id="wrow"></div><div id="orows"></div></div>
        <div class="mlc"><div class="mlh"><span>🔗</span><div><div class="mlt">Traveller Matching</div><div class="mls">Similar routes near you</div></div></div><div class="swrp"><svg id="simsvg" width="100%" height="88" viewBox="0 0 290 88" style="display:block;"></svg></div><div id="simlist"></div></div>
        <div class="mlc"><div class="mlh"><span>📚</span><div><div class="mlt">Recommended Reading</div><div class="mls">Curated for your journey</div></div></div><div class="fr" id="rfilt"></div><div id="rlist"></div></div>
      </div>
    </div>
  </div>

  <!-- Live Travellers -->
  <div class="wrap" id="lts" style="margin-top:2.5rem;">
    <div class="sl2">Live travellers</div>
    <div class="ltc">
      <div class="lth"><div class="ltht">Active routes right now</div><div class="ltl"><div class="ld"></div>Real-time</div></div>
      <div id="ltent"></div>
    </div>
  </div>

  <!-- SCROLL-TRIGGERED DESTINATIONS -->
  <div id="dst-section" class="wrap" style="margin-top:5rem;">
    <div class="dst-intro">
      <h3>Layover destinations</h3>
      <p>Scroll to discover. Select a city for layover tips, attractions, and local guidance.</p>
    </div>
    <div id="dst-grid"></div>
  </div>
</div>

<!-- Ticker -->
<div id="ticker">
  <div class="tklbl">⚡ LIVE</div>
  <div class="tktrk"><div class="tkinn" id="tkinn"></div></div>
</div>

<!-- Flights Modal -->
<div id="fm">
  <div id="fp2">
    <div class="fph">
      <div><div class="fpt2">Live Flight Tracker</div><div class="fps">Real-time global flight data</div></div>
      <button class="fpcls" id="fmcls">✕</button>
    </div>
    <div class="fptabs">
      <button class="fptab on" data-tab="fr24">FlightRadar24</button>
      <button class="fptab" data-tab="map">Route Map</button>
    </div>
    <div class="fpbd">
      <div id="tab-fr24" style="width:100%;height:100%;">
        <iframe class="fpiframe" src="https://www.flightradar24.com/?airline=all" allowfullscreen loading="lazy" title="FlightRadar24"></iframe>
      </div>
      <div class="fpmapw" id="tab-map">
        <canvas id="fpc"></canvas>
        <div class="fpfl" id="fpfl"></div>
      </div>
    </div>
  </div>
</div>

<!-- Dest Modal -->
<div id="dm">
  <div id="dmc">
    <div id="diw">
      <img id="dimg" src="" alt=""/>
      <div class="dov"></div>
      <div id="dlbl">LAYOVER CITY</div>
      <button id="dcls">✕</button>
    </div>
    <div id="dbody">
      <div id="dname"></div><div id="dctry"></div>
      <div id="dinfo"></div><div id="dtips"></div>
      <div id="dwarn"><span>⚠</span><span id="dwt"></span></div>
    </div>
  </div>
</div>

<script>
/* ════ DATA ════ */
const DESTS={
  dubai:{name:"Dubai",country:"UAE · Middle East",img:"https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80",thumb:"https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=600&q=75",tag:"Iconic Skyline",sub:"UAE · 3h layover",info:"This is the place you go to for more about Dubai. If this is your layover, stroll around the Burj Khalifa district and grab a bite at a waterfront café in the Marina. Head back to the airport 3 hours before your flight. Be cautious of unlicensed taxi touts.",tips:[{i:"🕌",t:"Burj Khalifa",b:"360° views. Book online."},{i:"🛍",t:"Dubai Mall",b:"Metro-connected. World's largest."},{i:"🌊",t:"JBR Beach",b:"30 min by metro. Free."},{i:"🍽",t:"Local Eats",b:"Al Dhiyafa Road for Emirati food."}],warn:"Dress modestly. No photography of government buildings. Use licensed RTA taxis only."},
  tokyo:{name:"Tokyo",country:"Japan · East Asia",img:"https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800&q=80",thumb:"https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600&q=75",tag:"Neon & Tradition",sub:"Japan · 2.5h to city",info:"This is the place you go to for more about Tokyo. Stroll through Shinjuku or Shibuya and grab ramen at a local shop. Head back 3 hours before your flight. Overpriced rickshaws near Asakusa are a common scam.",tips:[{i:"⛩",t:"Senso-ji",b:"Asakusa. Stunning at dawn."},{i:"🌆",t:"Shibuya Crossing",b:"World's busiest pedestrian crossing."},{i:"🍜",t:"Ramen Alley",b:"Omoide Yokocho — tiny stalls."},{i:"🚄",t:"Narita Express",b:"55 min to city."}],warn:"Very safe. Download offline maps. Cash still widely used."},
  istanbul:{name:"Istanbul",country:"Turkey · Bosphorus",img:"https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800&q=80",thumb:"https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=600&q=75",tag:"East Meets West",sub:"Turkey · 45min to Sultanahmet",info:"This is the place you go to for more about Istanbul. Stroll the Golden Horn and grab köfte. Head back 3 hours before your flight. Carpet shop tours near Hagia Sophia are scams.",tips:[{i:"🕍",t:"Hagia Sophia",b:"UNESCO site. Free — cover shoulders."},{i:"🛒",t:"Grand Bazaar",b:"Always negotiate."},{i:"⛵",t:"Bosphorus Ferry",b:"Cross two continents cheaply."},{i:"☕",t:"Turkish Tea",b:"Any çay bahçesi is authentic."}],warn:"Be firm declining street guides. Agree taxi fares beforehand."},
  singapore:{name:"Singapore",country:"Singapore · SEA",img:"https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=800&q=80",thumb:"https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=600&q=75",tag:"Garden City",sub:"Singapore · 30min by MRT",info:"This is the place you go to for more about Singapore. Stroll through Gardens by the Bay and eat at a hawker centre. Head back 3 hours before your flight — Changi is very large.",tips:[{i:"🌿",t:"Gardens by the Bay",b:"Supertree Grove free at ground level."},{i:"🦁",t:"Marina Bay Sands",b:"Lobby is free."},{i:"🍢",t:"Hawker Centre",b:"Maxwell Food Centre, Chinatown."},{i:"🚇",t:"MRT",b:"Airport to city 30 min, S$1.70."}],warn:"Strict laws — no gum, no littering, no jaywalking. Fines are heavy."},
  amsterdam:{name:"Amsterdam",country:"Netherlands · Europe",img:"https://images.unsplash.com/photo-1512470876302-972faa2aa9a4?w=800&q=80",thumb:"https://images.unsplash.com/photo-1512470876302-972faa2aa9a4?w=600&q=75",tag:"Canal City",sub:"Netherlands · 20min from AMS",info:"This is the place you go to for more about Amsterdam. Stroll Prinsengracht and grab a stroopwafel. Head back 3 hours before your flight. Pickpockets frequent Centraal Station.",tips:[{i:"🚲",t:"Rent a Bike",b:"€10–€15, most authentic way."},{i:"🏛",t:"Rijksmuseum",b:"Rembrandt & Vermeer."},{i:"🌷",t:"Keukenhof",b:"March–May tulip season."},{i:"🧇",t:"Poffertjes",b:"Albert Cuyp market."}],warn:"Cyclists have right of way. Photography of RLD workers strictly forbidden."},
  sydney:{name:"Sydney",country:"Australia · Pacific",img:"https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800&q=80",thumb:"https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=600&q=75",tag:"Harbour & Sun",sub:"Australia · 30min to CBD",info:"This is the place you go to for more about Sydney. Stroll Circular Quay, grab fish and chips at the Rocks. Head back 3 hours before your flight.",tips:[{i:"🎭",t:"Opera House",b:"Walk around free — iconic."},{i:"🏖",t:"Bondi Beach",b:"30 min by bus. Swim between the flags."},{i:"🌉",t:"Harbour Bridge",b:"Walk across free."},{i:"🦘",t:"Taronga Zoo",b:"Best harbour views."}],warn:"Sun is extremely strong — sunscreen essential. Tipping not customary."},
};
const TK=[
  {type:'alert',text:'NOTAM: North Atlantic Track NAT-B & NAT-C suspended until 14:00 UTC — southern routing via Azores or Lisbon recommended.'},
  {type:'alert',text:'Iran FIR: Overflights suspended. Reroute via Turkey or Saudi Arabia. Allow +35 min transit.'},
  {type:'info',text:'LHR arrivals: 45 min ATC ground delay in effect. Check terminal boards.'},
  {type:'ok',text:'Trans-Siberian routes fully restored following NOTAM D4421/26 cancellation.'},
  {type:'alert',text:'DXB → IST: Turkish industrial action — TK-operated services delayed 60–90 min.'},
  {type:'info',text:'Typhoon HAIYAN advisory: NRT/HND rerouting possible 19–22 Apr. Check airline updates.'},
  {type:'ok',text:'Changi T4 fully reopened. Fast track security available all terminals.'},
  {type:'alert',text:'Marseille ATC strike 22 Apr — avoid CDG–BCN corridor. Use MAD or LIS as alternate.'},
  {type:'info',text:'New polar route POLAR1 operational — SFO to ICN, saving ~45 min on KE services.'},
  {type:'alert',text:'Ukraine FIR closed indefinitely. All overflights suspended. European routing adds 20–40 min.'},
];
const LT_DATA=[
  {av:'GH',name:'Giulia H.',route:'LHR → DUB → JFK',status:'In transit · Dublin',match:94,col:'#4a8fff'},
  {av:'JR',name:'James R.',route:'LHR → MAD → EWR',status:'Booked · 17:45',match:87,col:'#3db56a'},
  {av:'YM',name:'Yuki M.',route:'NRT → MNL → SYD',status:'Departed 3h ago',match:82,col:'#9b6fd4'},
  {av:'SC',name:'Sara C.',route:'DXB → CAI → FCO',status:'Checking in',match:76,col:'#c8a020'},
  {av:'MK',name:'Meera K.',route:'LHR → LIS → JFK',status:'Planning tomorrow',match:71,col:'#d44a40'},
];
const MOCK_FLIGHTS=[
  {fn:'BA117',from:'LHR',to:'JFK',prog:.45,lat1:51.5,lon1:-.5,lat2:40.6,lon2:-73.8,alt:'37,000ft',spd:'520kts'},
  {fn:'EK202',from:'DXB',to:'JFK',prog:.28,lat1:25.3,lon1:55.4,lat2:40.6,lon2:-73.8,alt:'38,000ft',spd:'510kts'},
  {fn:'SQ321',from:'SIN',to:'LHR',prog:.62,lat1:1.4,lon1:103.9,lat2:51.5,lon2:-.5,alt:'39,000ft',spd:'535kts'},
  {fn:'QF1',from:'SYD',to:'DXB',prog:.35,lat1:-33.9,lon1:151.2,lat2:25.3,lon2:55.4,alt:'37,500ft',spd:'498kts'},
  {fn:'AA100',from:'JFK',to:'LHR',prog:.75,lat1:40.6,lon1:-73.8,lat2:51.5,lon2:-.5,alt:'36,000ft',spd:'505kts'},
];

/* ════ PLANE TRAIL CANVAS ════
   Slow-moving condensation trails from cursor position
   Single muted blue-white — no color variation
*/
const pc=document.getElementById('pcanvas');
const pctx=pc.getContext('2d');
let PW,PH;
function presz(){PW=pc.width=window.innerWidth;PH=pc.height=window.innerHeight;}
presz();window.addEventListener('resize',presz);

let planes=[],mx=-999,my=-999,mactive=false,midleT;

function mkPlane(){
  /* Slow plane taking off from cursor — drifts upward gently */
  const angle = -Math.PI/2 + (Math.random()-0.5)*0.5; // mostly upward, slight spread
  const speed  = Math.random()*0.55+0.25; // SLOW — was 1.8+1.0, now 0.25–0.8
  return {
    x: mx, y: my,
    vx: Math.cos(angle)*speed,
    vy: Math.sin(angle)*speed,
    life: 1,
    decay: Math.random()*0.004+0.002, // long life — was 0.012, now 0.002–0.006
    trail: [],
    size: Math.random()*1.6+0.8,
    age: 0,
  };
}

let spawnT2=0;
(function drawPlanes(){
  pctx.clearRect(0,0,PW,PH);
  if(mactive){
    spawnT2++;
    // Spawn 1 plane every 6 frames — sparse
    if(spawnT2%6===0 && planes.length<28) planes.push(mkPlane());
  }
  planes=planes.filter(p=>p.life>0);
  planes.forEach(p=>{
    p.age++;
    // Very gentle drift — slow acceleration upward
    p.vx *= 0.999;
    p.vy *= 0.999;
    p.vy -= 0.004; // slow antigravity
    p.x += p.vx;
    p.y += p.vy;
    p.life -= p.decay;

    p.trail.push({x:p.x, y:p.y});
    if(p.trail.length > 55) p.trail.shift(); // long trail

    // Draw trail — tapered, soft blue-white condensation
    if(p.trail.length > 2){
      for(let i=1; i<p.trail.length; i++){
        const frac = i/p.trail.length;
        const alpha = frac * p.life * 0.38;
        pctx.beginPath();
        pctx.moveTo(p.trail[i-1].x, p.trail[i-1].y);
        pctx.lineTo(p.trail[i].x, p.trail[i].y);
        pctx.strokeStyle = `rgba(195,220,255,${alpha})`;
        pctx.lineWidth = p.size * (0.3 + frac*0.7);
        pctx.lineCap = 'round';
        pctx.stroke();
      }
    }
    // Plane head — tiny glowing white dot
    if(p.life > 0.1){
      pctx.save();
      pctx.globalAlpha = Math.min(p.life * 1.2, 1);
      // glow halo
      const g = pctx.createRadialGradient(p.x,p.y,0,p.x,p.y,p.size*3.5);
      g.addColorStop(0,'rgba(210,232,255,0.5)');
      g.addColorStop(1,'rgba(210,232,255,0)');
      pctx.fillStyle = g;
      pctx.beginPath();
      pctx.arc(p.x,p.y,p.size*3.5,0,Math.PI*2);
      pctx.fill();
      // bright core
      pctx.fillStyle = 'rgba(240,248,255,0.95)';
      pctx.beginPath();
      pctx.arc(p.x,p.y,p.size*0.85,0,Math.PI*2);
      pctx.fill();
      pctx.restore();
    }
  });
  requestAnimationFrame(drawPlanes);
})();

/* ════ CURSOR + WAKE ════ */
const ring=document.getElementById('cr');
const cdot=document.getElementById('cd');
const sleepEl=document.getElementById('sleep');
const pageEl=document.getElementById('page');
let awakened=false;

window.addEventListener('mousemove',e=>{
  mx=e.clientX;my=e.clientY;mactive=true;
  ring.style.left=mx+'px';ring.style.top=my+'px';
  cdot.style.left=mx+'px';cdot.style.top=my+'px';
  clearTimeout(midleT);midleT=setTimeout(()=>mactive=false,200);
  if(!awakened){
    awakened=true;
    sleepEl.classList.add('gone');
    setTimeout(()=>pageEl.classList.add('show'),850);
    setTimeout(buildDests,1800);
    setTimeout(buildLT,600);
  }
});
window.addEventListener('click',e=>{
  const r=document.createElement('div');r.className='ripple';
  r.style.left=e.clientX+'px';r.style.top=e.clientY+'px';
  r.style.width=r.style.height='32px';
  document.body.appendChild(r);setTimeout(()=>r.remove(),1050);
});
document.querySelectorAll('button,a,.qp,.ltc,.ac,.artc').forEach(el=>{
  el.addEventListener('mouseenter',()=>{ring.style.width='44px';ring.style.height='44px';});
  el.addEventListener('mouseleave',()=>{ring.style.width='28px';ring.style.height='28px';});
});

/* ════ THEME ════ */
const tp=document.getElementById('tp');
function applyTheme(t){
  document.documentElement.setAttribute('data-theme',t);
  document.getElementById('ticon').textContent=t==='dark'?'🌙':'☀️';
  document.getElementById('ttxt').textContent=t==='dark'?'Dark':'Light';
  localStorage.setItem('dst-theme',t);
}
applyTheme(localStorage.getItem('dst-theme')||'dark');
tp.addEventListener('click',()=>applyTheme(document.documentElement.getAttribute('data-theme')==='dark'?'light':'dark'));

/* ════ TICKER ════ */
(()=>{
  const items=[...TK,...TK];
  document.getElementById('tkinn').innerHTML=items.map(it=>`
    <div class="tki">
      <div class="tkdot" style="background:${it.type==='alert'?'var(--re)':it.type==='ok'?'var(--gr)':'var(--a)'}"></div>
      <span style="color:${it.type==='alert'?'var(--re)':it.type==='ok'?'var(--gr)':it.type==='info'?'var(--a)':'var(--t)'}">${it.text}</span>
    </div>`).join('');
})();

/* ════ LIVE TRAVELLERS ════ */
function buildLT(){
  document.getElementById('ltent').innerHTML=LT_DATA.map(t=>`
    <div class="ltr">
      <div class="ltav" style="background:${t.col}22;color:${t.col}">${t.av}</div>
      <div style="flex:1"><div class="ltname">${t.name}</div><div class="ltroute">${t.route}</div></div>
      <div class="ltstat"><div class="ltd"></div>${t.status}</div>
      <span class="ltm">${t.match}% match</span>
      <button class="ltbtn">Connect</button>
    </div>`).join('');
}
setInterval(()=>{
  const ns=['Alex B.','Priya S.','Tom N.','Fatima A.','Kenji W.'];
  const rs=['CDG→MAD→JFK','AMS→DUB→ORD','FRA→IST→DXB'];
  const cs=['#4a8fff','#3db56a','#9b6fd4','#c8a020'];
  const n=ns[Math.floor(Math.random()*ns.length)];
  const r=rs[Math.floor(Math.random()*rs.length)];
  const c=cs[Math.floor(Math.random()*cs.length)];
  const av=n.split(' ').map(x=>x[0]).join('');
  const entries=document.getElementById('ltent');
  const row=document.createElement('div');row.className='ltr';
  row.style.animation='fadeUp .4s ease';
  row.innerHTML=`<div class="ltav" style="background:${c}22;color:${c}">${av}</div>
    <div style="flex:1"><div class="ltname">${n} <span style="font-size:.56rem;background:var(--grg);color:var(--gr);padding:1px 5px;border-radius:100px;font-family:'DM Mono',monospace;">NEW</span></div>
    <div class="ltroute">${r}</div></div>
    <div class="ltstat"><div class="ltd"></div>Just joined</div>
    <span class="ltm">${Math.floor(Math.random()*30+55)}% match</span>
    <button class="ltbtn">Connect</button>`;
  entries.insertBefore(row,entries.firstChild);
  if(entries.children.length>7)entries.removeChild(entries.lastChild);
},14000);

/* ════ SCROLL-TRIGGERED DESTINATIONS ════ */
function buildDests(){
  const grid=document.getElementById('dst-grid');
  grid.innerHTML='';
  Object.entries(DESTS).forEach(([key,d],idx)=>{
    const card=document.createElement('div');
    card.className='dstcard';
    card.style.transitionDelay=`${idx*0.075}s`;
    card.innerHTML=`
      <img class="dci" src="${d.thumb}" alt="${d.name}" loading="lazy"/>
      <div class="dco"></div>
      <div class="dcb">
        <span class="dctag">${d.tag}</span>
        <div class="dcname">${d.name}</div>
        <div class="dcsub">${d.sub}</div>
      </div>
      <div class="dcc">Explore →</div>`;
    card.addEventListener('click',()=>openDest(key));
    card.addEventListener('mouseenter',()=>{ring.style.width='46px';ring.style.height='46px';});
    card.addEventListener('mouseleave',()=>{ring.style.width='28px';ring.style.height='28px';});
    grid.appendChild(card);
  });
  // IntersectionObserver — reveal ONLY when scrolled into view
  const obs=new IntersectionObserver((entries)=>{
    entries.forEach(e=>{if(e.isIntersecting)e.target.classList.add('in');});
  },{threshold:.12,rootMargin:'0px 0px -50px 0px'});
  grid.querySelectorAll('.dstcard').forEach(c=>obs.observe(c));
}

/* ════ TEXTAREA ════ */
const ta=document.getElementById('ta');
const btn=document.getElementById('sb');
const cct=document.getElementById('cct');
ta.addEventListener('input',()=>{
  ta.value=ta.value.slice(0,600);
  cct.textContent=`${ta.value.length} / 600`;
  btn.disabled=ta.value.trim().length<5;
});
ta.addEventListener('keydown',e=>{if(e.key==='Enter'&&e.metaKey)analyse();});
document.querySelectorAll('.qp').forEach(p=>{
  p.addEventListener('click',()=>{
    const m={
      '✈ London → NYC, airspace closed':"I'm stuck in London Heathrow. All transatlantic flights cancelled due to North Atlantic airspace restrictions. Need New York JFK as fast as possible. Speed over cost. What are my visa options for any stopover city?",
      '💸 Budget: Tokyo → Sydney':"Flying Tokyo to Sydney in two weeks. Budget is my absolute priority. Flexible on dates ±3 days. What's cheapest including any visa requirements for stopovers?",
      '🗺 Scenic NYC → San Francisco':"Traveling from New York to San Francisco next month on a budget. Want to avoid major highways and see nature. Solo traveller — safety tips and visa info appreciated.",
      '👨‍👩‍👧‍👦 Family reroute: Dubai → Rome':"Family of 4 — two adults, kids 6 and 9 — Dubai to Rome. Istanbul connection cancelled due to strike. Need options today or tomorrow. Keep group together. Do we need visas for any alternative stopover?"
    };
    ta.value=m[p.textContent]||'';
    cct.textContent=`${ta.value.length} / 600`;
    btn.disabled=false;ta.focus();
  });
});

/* ════ AI STAGE ANIMATION ════ */
const stages=['st-parse','st-rag','st-embed','st-agent','st-rank','st-out'];
function animStages(){
  stages.forEach(id=>document.getElementById(id).className='stage-item');
  let i=0;
  const interval=setInterval(()=>{
    if(i>0)document.getElementById(stages[i-1]).className='stage-item done';
    if(i<stages.length){document.getElementById(stages[i]).className='stage-item active';i++;}
    else clearInterval(interval);
  },420);
}

/* ════ CLAUDE API — calls /api/route (Vercel backend) ════
   NOTE: In production deploy, the fetch goes to /api/route
   which is the serverless function in api/route.js
   API key is NEVER in the frontend — it stays in Vercel env vars.
   For local testing without backend, falls back to direct call.
*/
const SYSTEM_PROMPT=`You are an expert AI travel routing assistant and visa specialist for destination.com.
You have access to real-time airspace restriction data, visa requirement databases, and safety advisories.

Your knowledge base includes:
- EUROCONTROL NOTAM feeds (live airspace restrictions)
- IATA visa requirement database (visa-on-arrival, e-visa, visa required)
- WHO travel safety advisories
- IATA route optimization data
- Historical flight pricing data

Respond ONLY with valid JSON — no markdown, no backticks, no preamble. Schema:
{
  "summary": "One empathetic sentence about the situation",
  "ragSources": ["source 1", "source 2", "source 3"],
  "bestSolution": {
    "title": "Route with real IATA airport codes",
    "description": "2-3 sentences. Include specific airline codes where possible.",
    "cost": "Realistic cost estimate e.g. £820–£1,140",
    "time": "Total journey time e.g. ~10h 40m",
    "modality": "e.g. Flight + Train",
    "confidence": "High | Medium | Low",
    "highlights": ["point 1", "point 2", "point 3"]
  },
  "alternatives": [
    {"title":"Route name","via":"e.g. LHR→DUB→JFK","cost":"...","time":"...","tradeoff":"why this option","badge":"FASTEST|CHEAPEST|SCENIC|BALANCED"},
    {"title":"...","via":"...","cost":"...","time":"...","tradeoff":"...","badge":"..."}
  ],
  "safetyTips": [
    "Visa: [specific visa requirement for this route and passport types]",
    "Airspace: [current relevant restriction or clearance]",
    "Safety tip 1",
    "Safety tip 2"
  ],
  "articles": [
    {"title":"...","description":"one sentence","readTime":"5 min read","category":"Safety|Budget|Planning|Culture|Adventure"},
    {"title":"...","description":"...","readTime":"...","category":"..."},
    {"title":"...","description":"...","readTime":"...","category":"..."}
  ],
  "communityInsights": {
    "activeUsers": 4,
    "insight": "one sentence traveller community insight",
    "tips": ["community tip 1", "community tip 2"]
  },
  "disclaimer": "Prices, visa info and times are estimates. Always verify with official sources before travel."
}

IMPORTANT:
- Always include visa requirements in safetyTips (first tip should be about visas)
- Always mention active airspace restrictions relevant to the route
- Use real IATA codes, real airline codes, realistic prices
- Exactly 2 alternatives, exactly 3 articles, 4 safety tips minimum`;

btn.addEventListener('click',analyse);
async function analyse(){
  const q=ta.value.trim();if(q.length<5)return;
  showLoad(true);clearRes();animStages();
  try{
    // Production: call your Vercel API route
    // const res=await fetch('/api/route',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({query:q})});

    // Dev/demo: direct call (swap for /api/route in production)
    const res=await fetch('https://api.anthropic.com/v1/messages',{
      method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({model:'claude-sonnet-4-20250514',max_tokens:2200,system:SYSTEM_PROMPT,messages:[{role:'user',content:q}]})
    });
    const d=await res.json();
    if(!d.content)throw new Error(d.error?.message||'API error');
    const raw=d.content.map(b=>b.text||'').join('').trim();
    const json=JSON.parse(raw.replace(/```json|```/g,'').trim());
    render(json);
  }catch(e){showErr('Could not analyse route. '+e.message);}
  finally{showLoad(false);}
}

/* ════ RENDER ════ */
function render(d){
  document.getElementById('asum').innerHTML=`<strong style="color:var(--a)">Route Intelligence</strong> — ${esc(d.summary)}`;
  document.getElementById('rags').innerHTML=(d.ragSources||[]).map(s=>`<div class="rp"><div class="rp-d"></div>${esc(s)}</div>`).join('');
  const c=d.bestSolution;
  document.getElementById('bt').innerHTML=esc(c.title)+`<span class="cf ${c.confidence==='High'?'cfh':c.confidence==='Medium'?'cfm':'cfl'}">${esc(c.confidence)}</span>`;
  document.getElementById('bd').textContent=c.description;
  document.getElementById('bm').innerHTML=[['Cost',c.cost],['Time',c.time],['Mode',c.modality]].map(([l,v])=>`<div class="mc"><div class="mcl">${l}</div><div class="mcv">${esc(v)}</div></div>`).join('');
  document.getElementById('bhl').innerHTML=(c.highlights||[]).map(h=>`<li>${esc(h)}</li>`).join('');
  const bm={FASTEST:'abf',CHEAPEST:'abc',SCENIC:'abs',BALANCED:'abb'};
  document.getElementById('ag2').innerHTML=(d.alternatives||[]).map(a=>`
    <div class="ac"><span class="abg ${bm[a.badge]||'abb'}">${esc(a.badge)}</span>
    <div class="att">${esc(a.title)}</div><div class="av">${esc(a.via)}</div>
    <div class="as2"><div><div class="asl">Cost</div><div class="asv">${esc(a.cost)}</div></div><div><div class="asl">Time</div><div class="asv">${esc(a.time)}</div></div></div>
    <div class="atr">${esc(a.tradeoff)}</div></div>`).join('');
  document.getElementById('slist').innerHTML=(d.safetyTips||[]).map(t=>`<div class="si">${esc(t)}</div>`).join('');
  const cm={Safety:'arsa',Budget:'arbu',Planning:'arpl',Culture:'arcu',Adventure:'arad'};
  document.getElementById('artg').innerHTML=(d.articles||[]).map(a=>`
    <div class="artc"><span class="arcat ${cm[a.category]||'arpl'}">${esc(a.category)}</span>
    <div class="artt">${esc(a.title)}</div><div class="artd">${esc(a.description)}</div>
    <div class="artr">${esc(a.readTime)}</div></div>`).join('');
  const ci=d.communityInsights||{};
  document.getElementById('ccnt').textContent=`${ci.activeUsers||0} active`;
  document.getElementById('cins').textContent=ci.insight||'';
  document.getElementById('ctips').innerHTML=(ci.tips||[]).map(t=>`<div class="cti">${esc(t)}</div>`).join('');
  document.getElementById('disc').textContent='⚠ '+d.disclaimer;
  const routes=[{name:c.title,cs:.92,ts:.85,fs:.90},...(d.alternatives||[]).map((a,i)=>({name:a.title,cs:.72-i*.14,ts:.76-i*.11,fs:.68-i*.09}))];
  renderML(d,routes);
  document.getElementById('mlw').style.display='block';
  document.getElementById('results').classList.add('show');
  setTimeout(()=>document.getElementById('results').scrollIntoView({behavior:'smooth',block:'start'}),100);
}

/* ════ ML PANELS ════ */
let wts={cost:.4,time:.35,feasibility:.25};
function renderML(d,routes){
  const wr=document.getElementById('wrow');
  wr.innerHTML=Object.keys(wts).map(k=>`<div class="wi"><div class="wl"><span>${k}</span><span class="wv" id="wv-${k}">${Math.round(wts[k]*100)}%</span></div><input type="range" min="10" max="80" step="5" value="${Math.round(wts[k]*100)}" data-k="${k}"/></div>`).join('');
  wr.querySelectorAll('input').forEach(inp=>{
    inp.addEventListener('input',function(){
      const k=this.dataset.k,v=parseInt(this.value)/100,rem=1-v,oth=Object.keys(wts).filter(x=>x!==k),sum=oth.reduce((s,x)=>s+wts[x],0);
      oth.forEach(x=>wts[x]=sum>0?+(wts[x]/sum*rem).toFixed(2):+(rem/2).toFixed(2));wts[k]=v;
      wr.querySelectorAll('input').forEach(ii=>{document.getElementById('wv-'+ii.dataset.k).textContent=Math.round(wts[ii.dataset.k]*100)+'%';ii.value=Math.round(wts[ii.dataset.k]*100);});
      updOpt(routes);
    });
  });
  updOpt(routes);renderSim();renderRec(d.articles||[]);
}
function updOpt(routes){
  const sc=routes.map(r=>({...r,score:r.cs*wts.cost+r.ts*wts.time+r.fs*wts.feasibility})).sort((a,b)=>b.score-a.score);
  document.getElementById('orows').innerHTML=sc.map((r,i)=>`
    <div class="or2 ${i===0?'top':''}">
      <div class="ork">${i===0?'★':'#'+(i+1)}</div>
      <div class="bg2"><div class="orn">${esc(r.name)}</div>
        ${[['cost',r.cs,'var(--gr)'],['time',r.ts,'var(--a)'],['feasibility',r.fs,'var(--go)']].map(([l,v,c])=>`<div class="br"><div class="brh"><span>${l}</span><span>${Math.round(v*100)}%</span></div><div class="bt2"><div class="bf3" style="width:${v*100}%;background:${c}"></div></div></div>`).join('')}
      </div>
      <div style="text-align:center;min-width:30px;"><div class="osn">${Math.round(sc[i].score*100)}</div><div class="osl">score</div></div>
    </div>`).join('');
}
function renderSim(){
  const tr=[{av:'GH',n:'Giulia H.',r:'LHR→DUB→JFK',sim:.94,col:'#4a8fff',st:'In transit'},
    {av:'JR',n:'James R.',r:'LHR→MAD→EWR',sim:.87,col:'#3db56a',st:'Planning'},
    {av:'YM',n:'Yuki M.',r:'LHR→ICN→JFK',sim:.76,col:'#9b6fd4',st:'Departed'}];
  const svg=document.getElementById('simsvg');
  svg.innerHTML=`<circle cx="145" cy="44" r="9" fill="var(--a)" opacity=".9"/><text x="145" y="48" text-anchor="middle" font-size="6" fill="white" font-weight="600">YOU</text>`+
    tr.map((t,i)=>{const a=(i/tr.length)*Math.PI*2-Math.PI/4,d2=(1-t.sim)*100+36,tx=145+Math.cos(a)*d2,ty=44+Math.sin(a)*d2;
      return `<line x1="145" y1="44" x2="${tx}" y2="${ty}" stroke="${t.col}" stroke-opacity="${t.sim*.28}" stroke-width="${t.sim*1.4}" stroke-dasharray="3,4"/>
        <circle cx="${tx}" cy="${ty}" r="${5.5*t.sim+2}" fill="${t.col}" opacity=".85"/>
        <text x="${tx}" y="${ty+3}" text-anchor="middle" font-size="5.5" fill="black" font-weight="700">${t.av}</text>
        <text x="${tx}" y="${ty-13}" text-anchor="middle" font-size="7" fill="var(--t3)">${Math.round(t.sim*100)}%</text>`;
    }).join('');
  document.getElementById('simlist').innerHTML=tr.map(t=>`
    <div class="trow2"><div class="tav" style="background:${t.col}20;color:${t.col}">${t.av}</div>
    <div style="flex:1"><div class="tn">${t.n}</div><div class="tr3">${t.r}</div></div>
    <div><span class="sbd" style="background:${t.col}18;color:${t.col}">${Math.round(t.sim*100)}%</span><div class="tst">${t.st}</div></div></div>`).join('');
}
let recF='All';
function renderRec(arts){
  const cats=['All','Safety','Budget','Planning','Culture','Adventure'];
  const cc2={Safety:'var(--re)',Budget:'var(--gr)',Planning:'var(--a)',Culture:'var(--pu)',Adventure:'var(--go)'};
  document.getElementById('rfilt').innerHTML=cats.map(c=>`<button class="fb2 ${c===recF?'on':''}" data-c="${c}">${c}</button>`).join('');
  document.querySelectorAll('.fb2').forEach(b=>b.addEventListener('click',function(){recF=this.dataset.c;renderRec(arts);}));
  const fl=recF==='All'?arts:arts.filter(a=>a.category===recF);
  const sc=fl.map((a,i)=>({...a,cf:+(0.94-i*.07).toFixed(2),sem:+(0.91-i*.06).toFixed(2),fin:+(0.92-i*.065).toFixed(2)}));
  document.getElementById('rlist').innerHTML=sc.length?sc.map((a,i)=>`
    <div class="rrow"><div class="rrk">#${i+1}</div>
    <div style="flex:1"><div style="display:flex;align-items:center;gap:5px;margin-bottom:2px;">
      <span style="font-size:.54rem;padding:1px 6px;border-radius:100px;background:${(cc2[a.category]||'var(--a)')}18;color:${cc2[a.category]||'var(--a)'};text-transform:uppercase;letter-spacing:.04em;">${esc(a.category)}</span>
      <span style="font-size:.75rem;color:var(--t)">${esc(a.title)}</span></div>
      <div class="rsc"><span class="rse">CF <b>${Math.round(a.cf*100)}%</b></span><span class="rse">Sem <b>${Math.round(a.sem*100)}%</b></span><span class="rse" style="color:var(--a)">Final <b>${Math.round(a.fin*100)}%</b></span></div>
    </div><div class="rrd">${esc(a.readTime)}</div></div>`).join('')
    :'<div style="font-size:.72rem;color:var(--t3);padding:.3rem 0;">No articles in this category.</div>';
}

/* ════ FLIGHTS MODAL ════ */
const fm=document.getElementById('fm');
document.getElementById('fb').addEventListener('click',()=>{fm.classList.add('open');document.body.style.cursor='auto';});
document.getElementById('fmcls').addEventListener('click',()=>{fm.classList.remove('open');document.body.style.cursor='none';});
fm.addEventListener('click',e=>{if(e.target===fm){fm.classList.remove('open');document.body.style.cursor='none';}});
document.querySelectorAll('.fptab').forEach(tab=>{
  tab.addEventListener('click',function(){
    document.querySelectorAll('.fptab').forEach(t=>t.classList.remove('on'));this.classList.add('on');
    document.getElementById('tab-fr24').style.display=this.dataset.tab==='fr24'?'block':'none';
    const mapEl=document.getElementById('tab-map');
    mapEl.style.display=this.dataset.tab==='map'?'flex':'none';
    if(this.dataset.tab==='map')initMap();
  });
});
let mapInit=false;
function initMap(){
  if(mapInit)return;mapInit=true;
  const cvs=document.getElementById('fpc');const c=cvs.getContext('2d');
  document.getElementById('fpfl').innerHTML=MOCK_FLIGHTS.map(f=>`<div class="fplr"><span class="fplfn">${f.fn}</span><span class="fplrt">${f.from} → ${f.to}</span><span class="fplalt">${f.alt}</span><span class="fplspd">${f.spd}</span><span class="fplst">En Route</span></div>`).join('');
  function proj(lat,lon,w,h){return{x:(lon+180)/360*w,y:(90-lat)/180*h};}
  function lerp(a,b,t){return a+(b-a)*t;}
  const continents=[[{lat:70,lon:-140},{lat:60,lon:-65},{lat:25,lon:-80},{lat:15,lon:-90},{lat:60,lon:-140}],[{lat:72,lon:-10},{lat:72,lon:30},{lat:35,lon:30},{lat:35,lon:-10}],[{lat:72,lon:30},{lat:72,lon:145},{lat:10,lon:145},{lat:10,lon:30}],[{lat:35,lon:-20},{lat:35,lon:50},{lat:-35,lon:50},{lat:-35,lon:-20}],[{lat:-15,lon:115},{lat:-15,lon:155},{lat:-40,lon:155},{lat:-40,lon:115}]];
  (function draw(){
    const w=cvs.offsetWidth||800,h=cvs.offsetHeight||300;
    if(cvs.width!==w||cvs.height!==h){cvs.width=w;cvs.height=h;}
    c.clearRect(0,0,w,h);c.fillStyle='#050510';c.fillRect(0,0,w,h);
    c.strokeStyle='rgba(10,132,255,.06)';c.lineWidth=.5;
    for(let g=-180;g<=180;g+=30){const{x}=proj(0,g,w,h);c.beginPath();c.moveTo(x,0);c.lineTo(x,h);c.stroke();}
    for(let g=-90;g<=90;g+=30){const{y}=proj(g,0,w,h);c.beginPath();c.moveTo(0,y);c.lineTo(w,y);c.stroke();}
    c.fillStyle='rgba(20,30,20,.72)';
    continents.forEach(pts=>{c.beginPath();pts.forEach((p,i)=>{const pt=proj(p.lat,p.lon,w,h);i===0?c.moveTo(pt.x,pt.y):c.lineTo(pt.x,pt.y);});c.closePath();c.fill();});
    MOCK_FLIGHTS.forEach(f=>{
      const p1=proj(f.lat1,f.lon1,w,h),p2=proj(f.lat2,f.lon2,w,h);
      c.beginPath();c.moveTo(p1.x,p1.y);c.quadraticCurveTo((p1.x+p2.x)/2,(p1.y+p2.y)/2-h*.07,p2.x,p2.y);
      c.strokeStyle='rgba(10,132,255,.16)';c.lineWidth=.9;c.stroke();
      const px=lerp(p1.x,p2.x,f.prog),py=lerp(p1.y,p2.y,f.prog)-Math.sin(f.prog*Math.PI)*h*.06;
      c.save();
      const g2=c.createRadialGradient(px,py,0,px,py,7);g2.addColorStop(0,'#0a84ff');g2.addColorStop(1,'transparent');
      c.fillStyle=g2;c.beginPath();c.arc(px,py,7,0,Math.PI*2);c.fill();
      c.fillStyle='#fff';c.beginPath();c.arc(px,py,2,0,Math.PI*2);c.fill();
      c.font='bold 7px DM Mono,monospace';c.fillStyle='rgba(255,255,255,.5)';
      c.fillText(f.fn,px+6,py-4);c.restore();
    });
    requestAnimationFrame(draw);
  })();
}

/* ════ DEST MODAL ════ */
const dm=document.getElementById('dm');
function openDest(k){
  const d=DESTS[k];if(!d)return;
  document.getElementById('dimg').src=d.img;
  document.getElementById('dname').textContent=d.name;
  document.getElementById('dctry').textContent=d.country;
  document.getElementById('dinfo').textContent=d.info;
  document.getElementById('dtips').innerHTML=d.tips.map(t=>`<div class="tc"><span class="tci">${t.i}</span><div class="tcb"><strong>${t.t}</strong>${t.b}</div></div>`).join('');
  document.getElementById('dwt').textContent=d.warn;
  dm.classList.add('open');document.body.style.cursor='auto';
}
document.getElementById('dcls').addEventListener('click',()=>{dm.classList.remove('open');document.body.style.cursor='none';});
dm.addEventListener('click',e=>{if(e.target===dm){dm.classList.remove('open');document.body.style.cursor='none';}});

/* ════ HELPERS ════ */
function showLoad(s){
  document.getElementById('loading').className=s?'ldd show':'';
  document.getElementById('loading').className=s?'show':'';
  document.getElementById('ai-stage').className=s?'show':'';
  btn.disabled=s;btn.textContent=s?'Analysing…':'Analyse Route →';
}
function clearRes(){document.getElementById('results').classList.remove('show');document.getElementById('eb').classList.remove('show');}
function showErr(m){const e=document.getElementById('eb');e.textContent=m;e.classList.add('show');}
function esc(s){if(!s)return'';return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function scr(id){const el=document.getElementById(id);if(el)el.scrollIntoView({behavior:'smooth',block:'start'});}
document.addEventListener('keydown',e=>{if(e.key==='Escape'){dm.classList.remove('open');fm.classList.remove('open');document.body.style.cursor='none';}});
</script>
</body>
</html>
