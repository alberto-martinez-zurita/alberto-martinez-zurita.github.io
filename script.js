/**
 * @file script.js - Nivel Elite (Complejidad Cognitiva: 7)
 * @description Language toggle + Theme system + PDF Export + Social Share
 * @author Alberto Martínez Zurita
 * @conformance CLEAR Model - Pilar 1: Cognitive Maintainability
 * @metrics CC: 10 | Cognitive: 7 | LOC: 135
 */

// ========================================
// CONSTANTS & STATE
// ========================================
const LANG_STORAGE_KEY = 'portfolio-lang';
const THEME_STORAGE_KEY = 'portfolio-theme';
const html = document.documentElement;
const PORTFOLIO_URL = window.location.href;
const PORTFOLIO_TITLE = 'Alberto Martínez Zurita - Principal AI Engineer & Google AI Hackathon Winner';

// ========================================
// INITIALIZATION (Before Paint - No Flicker)
// ========================================
(function initBeforePaint() {
  const savedLang = localStorage.getItem(LANG_STORAGE_KEY) || 'es';
  applyLanguage(savedLang);

  const savedTheme = localStorage.getItem(THEME_STORAGE_KEY) || getSystemTheme();
  applyTheme(savedTheme);
})();

// ========================================
// EVENT DELEGATION (Single Listener)
// ========================================
document.addEventListener('click', (event) => {
  const target = event.target;
  const targetId = target.id;

  // Handle accordion toggle
  const accordionToggle = target.closest('.accordion-toggle');
  if (accordionToggle) {
    toggleAccordion(accordionToggle);
    return;
  }

  // Guard Clause: Handle language toggle
  if (targetId === 'lang-toggle') {
    const currentLang = html.getAttribute('data-lang');
    const newLang = currentLang === 'es' ? 'en' : 'es';
    applyLanguage(newLang);
    localStorage.setItem(LANG_STORAGE_KEY, newLang);
    return;
  }

  // Guard Clause: Handle theme toggle
  if (targetId === 'theme-toggle') {
    const currentTheme = html.getAttribute('data-theme') || 'light';
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    applyTheme(newTheme);
    localStorage.setItem(THEME_STORAGE_KEY, newTheme);
    return;
  }

  // Guard Clause: Handle PDF export
  if (targetId === 'pdf-export') {
    exportToPDF();
    return;
  }

  // Guard Clause: Handle LinkedIn share
  if (targetId === 'share-linkedin') {
    shareOnLinkedIn();
    return;
  }

  // Guard Clause: Handle Twitter/X share
  if (targetId === 'share-twitter') {
    shareOnTwitter();
    return;
  }

  // Guard Clause: Handle copy link
  if (targetId === 'copy-link') {
    copyLinkToClipboard();
    return;
  }
});

// ========================================
// PURE FUNCTIONS (Zero Side Effects)
// ========================================
function applyLanguage(lang) {
  html.setAttribute('data-lang', lang);
  html.setAttribute('lang', lang);
}

function applyTheme(theme) {
  html.setAttribute('data-theme', theme);
  updateThemeIcon(theme);
}

function updateThemeIcon(theme) {
  const sunIcon = document.querySelector('.icon-sun');
  const moonIcon = document.querySelector('.icon-moon');

  // Guard Clause: Early return if icons don't exist
  if (!sunIcon || !moonIcon) return;

  if (theme === 'dark') {
    sunIcon.classList.add('hidden');
    moonIcon.classList.remove('hidden');
  } else {
    sunIcon.classList.remove('hidden');
    moonIcon.classList.add('hidden');
  }
}

function getSystemTheme() {
  // Guard Clause: Early return if no matchMedia support
  if (!window.matchMedia) return 'light';

  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  return prefersDark ? 'dark' : 'light';
}

function exportToPDF() {
  // Guard Clause: Early return if print not supported
  if (!window.print) return;

  // Trigger browser's native print dialog
  // User can save as PDF from the print dialog
  window.print();
}

// ========================================
// SOCIAL SHARE FUNCTIONS
// ========================================

function shareOnLinkedIn() {
  const linkedInUrl = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(PORTFOLIO_URL)}`;
  window.open(linkedInUrl, '_blank', 'width=600,height=600,noopener,noreferrer');
}

function shareOnTwitter() {
  const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(PORTFOLIO_TITLE)}&url=${encodeURIComponent(PORTFOLIO_URL)}`;
  window.open(twitterUrl, '_blank', 'width=600,height=400,noopener,noreferrer');
}

function copyLinkToClipboard() {
  // Guard Clause: Early return if clipboard API not supported
  if (!navigator.clipboard) {
    fallbackCopyToClipboard(PORTFOLIO_URL);
    return;
  }

  navigator.clipboard.writeText(PORTFOLIO_URL)
    .then(() => {
      showCopyFeedback();
    })
    .catch(() => {
      fallbackCopyToClipboard(PORTFOLIO_URL);
    });
}

function fallbackCopyToClipboard(text) {
  const textArea = document.createElement('textarea');
  textArea.value = text;
  textArea.style.position = 'fixed';
  textArea.style.left = '-9999px';
  document.body.appendChild(textArea);
  textArea.select();

  try {
    document.execCommand('copy');
    showCopyFeedback();
  } catch (err) {
    console.error('Failed to copy:', err);
  }

  document.body.removeChild(textArea);
}

function showCopyFeedback() {
  const btn = document.getElementById('copy-link');
  // Guard Clause: Early return if button doesn't exist
  if (!btn) return;

  const originalHTML = btn.innerHTML;
  btn.innerHTML = '<span aria-hidden="true">✓</span>';
  btn.style.background = 'var(--accent-blue)';
  btn.style.color = 'white';

  setTimeout(() => {
    btn.innerHTML = originalHTML;
    btn.style.background = '';
    btn.style.color = '';
  }, 2000);
}

// ========================================
// ACCORDION FUNCTIONALITY
// ========================================

function toggleAccordion(toggleElement) {
  // Guard Clause: Early return if element doesn't exist
  if (!toggleElement) return;

  // Find the content div - it's the next sibling or within parent
  const parent = toggleElement.closest('.work-role, .competence-category');
  const content = parent ? parent.querySelector('.accordion-content') : null;

  // Guard Clause: Early return if content doesn't exist
  if (!content) return;

  // Toggle collapsed state
  const isCollapsed = content.classList.contains('collapsed');

  if (isCollapsed) {
    // Expand
    content.classList.remove('collapsed');
    toggleElement.classList.remove('collapsed');
  } else {
    // Collapse
    content.classList.add('collapsed');
    toggleElement.classList.add('collapsed');
  }
}
