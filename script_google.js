/**
 * @file script.js - v6.0
 * @description Logic for Theme, Lang, Mobile Menu & Native PDF
 */

const html = document.documentElement;
const sidebar = document.getElementById('sidebar');
const mobileBtn = document.getElementById('mobile-menu-toggle');

// INIT
(function init() {
  const savedLang = localStorage.getItem('portfolio-lang') || 'es';
  applyLanguage(savedLang);
  const savedTheme = localStorage.getItem('portfolio-theme') || 'light';
  applyTheme(savedTheme);
})();

// EVENT LISTENERS
mobileBtn.addEventListener('click', () => {
  sidebar.classList.toggle('active');
  // Change icon
  const icon = sidebar.classList.contains('active') ? '✕' : '☰';
  mobileBtn.querySelector('.hamburger-icon').textContent = icon;
});

// Close mobile menu on link click
document.querySelectorAll('.nav-link').forEach(link => {
  link.addEventListener('click', () => {
    if (window.innerWidth <= 1024) {
      sidebar.classList.remove('active');
      mobileBtn.querySelector('.hamburger-icon').textContent = '☰';
    }
  });
});

// Delegation for buttons
document.addEventListener('click', (event) => {
  const target = event.target.closest('button');
  if (!target) return;
  const id = target.id;

  if (id === 'lang-toggle') toggleLanguage();
  if (id === 'theme-toggle') toggleTheme();
  
  // NATIVE PDF EXPORT
  // This triggers the browser's print dialog, which uses the @media print CSS
  // to generate a perfect vector PDF.
  if (id === 'pdf-export') window.print();
  
  if (id === 'share-linkedin') shareSocial('linkedin');
});

// LOGIC
function toggleLanguage() {
  const current = html.getAttribute('data-lang');
  const next = current === 'es' ? 'en' : 'es';
  applyLanguage(next);
  localStorage.setItem('portfolio-lang', next);
}

function applyLanguage(lang) {
  html.setAttribute('data-lang', lang);
  const btnText = lang === 'es' ? 'EN' : 'ES';
  const btn = document.getElementById('lang-toggle');
  if(btn) btn.querySelector('span:not(.hidden)').textContent = btnText;
}

function toggleTheme() {
  const current = html.getAttribute('data-theme') || 'light';
  const next = current === 'light' ? 'dark' : 'light';
  applyTheme(next);
  localStorage.setItem('portfolio-theme', next);
}

function applyTheme(theme) {
  html.setAttribute('data-theme', theme);
  const sun = document.querySelector('.icon-sun');
  const moon = document.querySelector('.icon-moon');
  if (theme === 'dark') {
    sun?.classList.add('hidden');
    moon?.classList.remove('hidden');
  } else {
    sun?.classList.remove('hidden');
    moon?.classList.add('hidden');
  }
}

function shareSocial(platform) {
  const url = encodeURIComponent(window.location.href);
  if (platform === 'linkedin') {
    window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${url}`, '_blank');
  }
}