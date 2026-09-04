// === MacPeek Landing Page Scripts ===
document.addEventListener("DOMContentLoaded",()=>{
  // Init i18n
  buildLangDropdown();
  applyLang(detectLang());

  // Navbar scroll effect
  const nav=document.getElementById("navbar");
  window.addEventListener("scroll",()=>{
    nav.classList.toggle("scrolled",window.scrollY>40);
  },{passive:true});

  // Language dropdown toggle
  const langBtn=document.getElementById("langBtn");
  const langDD=document.getElementById("langDropdown");
  if(langBtn&&langDD){
    langBtn.addEventListener("click",e=>{
      e.stopPropagation();
      langDD.classList.toggle("open");
    });
    document.addEventListener("click",()=>langDD.classList.remove("open"));
  }

  // Mobile nav toggle
  const toggle=document.getElementById("navToggle");
  const links=document.querySelector(".nav-links");
  if(toggle&&links){
    toggle.addEventListener("click",()=>{
      links.style.display=links.style.display==="flex"?"none":"flex";
      links.style.flexDirection="column";
      links.style.position="absolute";
      links.style.top="64px";
      links.style.right="24px";
      links.style.background="var(--bg2)";
      links.style.padding="16px";
      links.style.borderRadius="12px";
      links.style.border="1px solid var(--border)";
    });
  }

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(a=>{
    a.addEventListener("click",e=>{
      const target=document.querySelector(a.getAttribute("href"));
      if(target){e.preventDefault();target.scrollIntoView({behavior:"smooth",block:"start"});}
    });
  });

  // Intersection observer for section animations
  const observer=new IntersectionObserver(entries=>{
    entries.forEach(entry=>{
      if(entry.isIntersecting){
        entry.target.style.opacity="1";
        entry.target.style.transform="translateY(0)";
      }
    });
  },{threshold:0.1});

  document.querySelectorAll(".feature-card,.step-card,.pricing-card,.faq-item").forEach(el=>{
    el.style.opacity="0";
    el.style.transform="translateY(24px)";
    el.style.transition="opacity .5s ease,transform .5s ease";
    observer.observe(el);
  });
});
