import{u as v,y as j,j as e,q as m,I as w,J as g,K as y,N,O as k,Q as $}from"./main-Dx-FSaIV.js";import{D as C}from"./download-jnK77Shm.js";function T({onNavigate:t,certificates:n}){const{user:s,fullName:a,company:i}=v(),{company:d}=j(),x=n;return s?e.jsxs("div",{className:"pt-16 min-h-screen",children:[e.jsx("div",{className:"border-b border-steel-700/60 bg-navy-950/40",children:e.jsxs("div",{className:"max-w-7xl mx-auto px-4 sm:px-6 py-8",children:[e.jsx("h1",{className:"font-display text-3xl font-bold text-white mb-1",children:"My Certificates"}),e.jsx("p",{className:"text-steel-400",children:"Official Certificates of Completion from ForgeLine Academy. Download or print for your records."})]})}),e.jsx("div",{className:"max-w-7xl mx-auto px-4 sm:px-6 py-8",children:x.length===0?e.jsxs("div",{className:"card p-12 text-center",children:[e.jsx(m,{className:"w-12 h-12 text-steel-600 mx-auto mb-4"}),e.jsx("h2",{className:"text-xl font-semibold text-white mb-2",children:"No certificates yet"}),e.jsx("p",{className:"text-steel-400 mb-5 max-w-md mx-auto",children:"Complete all lessons in a course (passing each knowledge check at 80% or higher) to earn your Certificate of Completion."}),e.jsx("button",{onClick:()=>t({name:"catalog"}),className:"btn-primary",children:"Browse Courses"})]}):e.jsx("div",{className:"grid grid-cols-1 lg:grid-cols-2 gap-6",children:x.map(o=>e.jsx(A,{cert:o,userName:a||(s==null?void 0:s.email)||"Technician",companyName:(i==null?void 0:i.name)??null,companyLogo:(i==null?void 0:i.logo_url)??null,brandCompany:d},o.id))})})]}):e.jsx("div",{className:"pt-16 min-h-screen flex items-center justify-center",children:e.jsxs("div",{className:"card p-8 max-w-md text-center",children:[e.jsx(m,{className:"w-12 h-12 text-premium-400 mx-auto mb-4"}),e.jsx("h2",{className:"text-xl font-semibold text-white mb-2",children:"Sign in to view certificates"}),e.jsx("p",{className:"text-steel-400 mb-5",children:"Your certificates are stored with your account. Sign in to view and download them."}),e.jsx("button",{onClick:()=>t({name:"auth"}),className:"btn-primary",children:"Sign in / Create account"})]})})}function A({cert:t,userName:n,companyName:s,companyLogo:a,brandCompany:i}){var o;const d=new Date(t.issued_at).toLocaleDateString("en-US",{year:"numeric",month:"long",day:"numeric"});function x(){var p;if(!document.getElementById(`cert-${t.id}`))return;const l=window.open("","_blank","width=1000,height=700");if(!l)return;const r=z(!!i),b=c(n),h=c(((p=t.course)==null?void 0:p.title)??"Industrial Maintenance Course"),u=i?F(i,r):B(r);l.document.write(`<!DOCTYPE html>
<html><head><title>ForgeLine Certificate - ${t.certificate_number}</title>
<style>
  @page { size: landscape; margin: 0; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #e8e8e8; font-family: 'Georgia', 'Times New Roman', serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 30px; }
  .cert {
    width: 980px; height: 680px; background: ${r.bg}; position: relative;
    padding: 50px 70px; color: #fff; overflow: hidden;
  }
  .cert::before {
    content: ''; position: absolute; inset: 14px;
    border: 2px solid ${r.frame}; border-radius: 4px;
  }
  .cert::after {
    content: ''; position: absolute; inset: 22px;
    border: 1px solid ${r.frameInner}; border-radius: 2px;
  }
  .corner { position: absolute; width: 40px; height: 40px; border: 3px solid ${r.strong}; }
  .corner.tl { top: 14px; left: 14px; border-right: none; border-bottom: none; }
  .corner.tr { top: 14px; right: 14px; border-left: none; border-bottom: none; }
  .corner.bl { bottom: 14px; left: 14px; border-right: none; border-top: none; }
  .corner.br { bottom: 14px; right: 14px; border-left: none; border-top: none; }
  .brand { display: flex; align-items: center; justify-content: center; gap: 10px; margin-bottom: 6px; }
  .brand-hex { width: 28px; height: 28px; }
  .brand-text { font-size: 13px; letter-spacing: 5px; color: ${r.light}; font-weight: bold; text-transform: uppercase; }
  .co-logo { height: 34px; max-width: 120px; object-fit: contain; background: #fff; border-radius: 6px; padding: 2px; }
  .co-initials { width: 34px; height: 34px; border-radius: 8px; display: inline-flex; align-items: center; justify-content: center; font: bold 14px Arial, sans-serif; background: ${r.strong}; color: ${r.onStrong}; }
  .co-by { text-align: center; font-size: 9px; letter-spacing: 3px; color: #94A3B8; text-transform: uppercase; margin-bottom: 4px; font-family: Arial, sans-serif; }
  .doc-type { text-align: center; font-size: 11px; letter-spacing: 4px; color: #64748B; text-transform: uppercase; margin-bottom: 30px; }
  .title { text-align: center; font-size: 38px; font-weight: bold; color: #fff; margin-bottom: 8px; letter-spacing: 1px; }
  .subtitle { text-align: center; font-size: 14px; color: #94A3B8; margin-bottom: 35px; }
  .name { text-align: center; font-size: 30px; font-weight: bold; color: ${r.light}; border-bottom: 1px solid #334155; display: inline-block; padding: 0 50px 6px; margin: 0 auto 20px; }
  .name-wrap { text-align: center; margin-bottom: 18px; }
  .completed-text { text-align: center; font-size: 14px; color: #94A3B8; margin-bottom: 12px; }
  .course { text-align: center; font-size: 22px; font-style: italic; color: #CBD5E1; max-width: 600px; margin: 0 auto; line-height: 1.4; }
  .footer { position: absolute; bottom: 60px; left: 70px; right: 70px; display: flex; justify-content: space-between; align-items: flex-end; }
  .sig-block { text-align: center; }
  .sig-line { border-top: 1px solid #475569; width: 180px; margin-bottom: 6px; }
  .sig-label { font-size: 11px; color: #64748B; text-transform: uppercase; letter-spacing: 2px; }
  .sig-value { font-size: 13px; color: #94A3B8; margin-top: 2px; }
  .cert-no { position: absolute; bottom: 30px; left: 0; right: 0; text-align: center; font-size: 10px; color: #475569; letter-spacing: 2px; font-family: monospace; }
  .seal { position: absolute; bottom: 110px; right: 80px; width: 70px; height: 70px; border: 2px solid ${r.strong}; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 9px; color: ${r.light}; text-transform: uppercase; letter-spacing: 1px; font-weight: bold; transform: rotate(-12deg); }
</style></head><body>
<div class="cert">
  <div class="corner tl"></div><div class="corner tr"></div>
  <div class="corner bl"></div><div class="corner br"></div>
  ${u}
  <div class="doc-type">Certificate of Completion</div>
  <div class="title">Certificate of Completion</div>
  <div class="subtitle">This is to certify that</div>
  <div class="name-wrap"><span class="name">${b}</span></div>
  <div class="completed-text">has successfully completed all required lessons and knowledge checks for</div>
  <div class="course">${h}</div>
  <div class="seal">Verified</div>
  <div class="footer">
    <div class="sig-block">
      <div class="sig-line"></div>
      <div class="sig-label">Date Issued</div>
      <div class="sig-value">${d}</div>
    </div>
    <div class="sig-block">
      <div class="sig-line"></div>
      <div class="sig-label">Authorized By</div>
      <div class="sig-value">ForgeLine Academy</div>
    </div>
  </div>
  <div class="cert-no">Certificate No: ${t.certificate_number}</div>
</div>
</body></html>`),l.document.close(),setTimeout(()=>{l.focus(),l.print()},400)}return e.jsxs("div",{className:"card overflow-hidden",children:[e.jsxs("div",{id:`cert-${t.id}`,className:"relative p-6 sm:p-8 bg-gradient-to-br from-navy-900 via-navy-950 to-black border-b border-steel-700/60",children:[e.jsx("div",{className:"absolute top-3 left-3 w-8 h-8 border-l-2 border-t-2 border-accent-500/50 rounded-tl"}),e.jsx("div",{className:"absolute top-3 right-3 w-8 h-8 border-r-2 border-t-2 border-accent-500/50 rounded-tr"}),e.jsx("div",{className:"absolute bottom-3 left-3 w-8 h-8 border-l-2 border-b-2 border-accent-500/50 rounded-bl"}),e.jsx("div",{className:"absolute bottom-3 right-3 w-8 h-8 border-r-2 border-b-2 border-accent-500/50 rounded-br"}),e.jsx("div",{className:"absolute inset-5 border border-steel-600/30 rounded-lg pointer-events-none"}),e.jsxs("div",{className:"relative text-center py-6",children:[i?e.jsxs("div",{className:"flex flex-col items-center gap-1.5 mb-5",children:[e.jsxs("div",{className:"flex items-center gap-2.5",children:[e.jsx(w,{company:i,className:"h-8 w-8 text-sm"}),e.jsx("span",{className:"text-sm font-bold tracking-[0.2em] text-accent-300 uppercase",children:g(i.name)})]}),e.jsx(y,{})]}):e.jsxs("div",{className:"flex items-center justify-center gap-2 mb-5",children:[e.jsx(N,{className:"w-7 h-7 text-accent-500",strokeWidth:1.6}),e.jsx("div",{className:"text-xs font-bold tracking-[0.3em] text-accent-300 uppercase",children:"ForgeLine Academy"}),s&&e.jsxs(e.Fragment,{children:[e.jsx("div",{className:"w-px h-4 bg-steel-600/50"}),a?e.jsx("img",{src:a,alt:s,className:"h-6 w-auto max-w-[80px] object-contain opacity-80"}):e.jsx("span",{className:"text-[10px] text-steel-400 font-semibold uppercase tracking-wider",children:s})]})]}),e.jsx("div",{className:"text-[10px] uppercase tracking-[0.3em] text-steel-500 mb-1",children:"Official Document"}),e.jsx("div",{className:"text-xl font-display font-bold text-white mb-1",children:"Certificate of Completion"}),e.jsx("div",{className:"w-16 h-px bg-accent-500/40 mx-auto mb-6"}),e.jsx("div",{className:"text-xs uppercase tracking-widest text-steel-400 mb-3",children:"This is to certify that"}),e.jsx("div",{className:"text-2xl font-display font-bold text-accent-300 border-b border-steel-600/50 inline-block px-10 pb-2 mb-5",children:n}),e.jsx("div",{className:"text-sm text-steel-400 mb-3",children:"has successfully completed all required lessons and knowledge checks for"}),e.jsx("div",{className:"text-lg font-display font-semibold text-white italic max-w-md mx-auto leading-snug",children:((o=t.course)==null?void 0:o.title)??"Industrial Maintenance Course"}),e.jsx("div",{className:"flex justify-center mt-5",children:e.jsx("div",{className:"w-16 h-16 rounded-full border-2 border-accent-500/40 flex items-center justify-center -rotate-12",children:e.jsxs("div",{className:"text-center",children:[e.jsx(k,{className:"w-5 h-5 text-accent-400/60 mx-auto",strokeWidth:1.5}),e.jsx("div",{className:"text-[7px] font-bold uppercase tracking-wider text-accent-300/70 mt-0.5",children:"Verified"})]})})}),e.jsxs("div",{className:"flex items-center justify-center gap-8 mt-6 pt-5 border-t border-steel-700/40 text-xs text-steel-500",children:[e.jsxs("div",{children:[e.jsx("div",{className:"text-steel-300 font-medium",children:d}),e.jsx("div",{className:"text-[10px] uppercase tracking-wider mt-0.5",children:"Date Issued"})]}),e.jsx("div",{className:"w-px h-8 bg-steel-700/40"}),e.jsxs("div",{children:[e.jsx("div",{className:"text-steel-300 font-medium font-mono",children:t.certificate_number}),e.jsx("div",{className:"text-[10px] uppercase tracking-wider mt-0.5",children:"Certificate No."})]})]})]})]}),e.jsxs("div",{className:"p-4 flex items-center justify-between",children:[e.jsxs("div",{className:"flex items-center gap-2 text-sm text-steel-400",children:[e.jsx(m,{className:"w-4 h-4 text-premium-400"}),"Verified completion"]}),e.jsxs("button",{onClick:x,className:"btn-secondary text-sm",children:[e.jsx(C,{className:"w-4 h-4"}),"Download / Print"]})]})]})}const f="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z";function c(t){return t.replace(/[&<>"']/g,n=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"})[n])}function z(t){if(!t)return{bg:"#0A1628",frame:"#2A4D7A",frameInner:"#1a3a5a",strong:"#3B82F6",light:"#60A5FA",onStrong:"#FFFFFF"};const n=getComputedStyle(document.documentElement),s=a=>`rgb(${n.getPropertyValue(a).trim()||"0 0 0"})`;return{bg:s("--fl-navy-900"),frame:s("--fl-navy-500"),frameInner:s("--fl-navy-600"),strong:s("--fl-rok-500"),light:s("--fl-accent-300"),onStrong:s("--fl-on-rok")}}function B(t){return`<div class="brand">
    <svg class="brand-hex" viewBox="0 0 24 24" fill="none" stroke="${t.light}" stroke-width="1.6"><path d="${f}"/></svg>
    <span class="brand-text">ForgeLine Academy</span>
  </div>`}function F(t,n){const s=`<span class="co-initials"${t.logoUrl?' style="display:none"':""}>${c($(t.name))}</span>`;return`<div class="brand">${t.logoUrl?`<img class="co-logo" src="${c(t.logoUrl)}" alt="" onerror="this.style.display='none';this.nextElementSibling.style.display='inline-flex'">`:""}${s}<span class="brand-text">${c(g(t.name))}</span></div>
  <div class="co-by">Training by <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="${n.strong}" stroke-width="2"><path d="${f}"/></svg> ForgeLine Academy</div>`}export{T as Certificates};
