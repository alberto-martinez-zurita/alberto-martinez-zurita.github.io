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

  const savedTheme = localStorage.getItem(THEME_STORAGE_KEY) || 'dark';
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

async function exportToPDF() {
  const btn = document.getElementById('pdf-export');
  if (!btn) return;

  // Guard Clause: Early return if libraries not loaded
  if (!window.html2canvas || !window.jspdf) {
    console.error('PDF libraries not loaded');
    return;
  }

  const originalHTML = btn.innerHTML;
  btn.disabled = true;
  btn.innerHTML = '<span aria-hidden="true">⏳</span>';
  btn.style.opacity = '0.6';

  try {
    const { jsPDF } = window.jspdf;

    // Hide sidebar before capture
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    const sidebarDisplay = sidebar ? sidebar.style.display : '';
    const mainMargin = mainContent ? mainContent.style.marginLeft : '';

    if (sidebar) sidebar.style.display = 'none';
    if (mainContent) {
      mainContent.style.marginLeft = '0';
      mainContent.style.maxWidth = '100%';
    }

    // Fix gradient issue in name-title for PDF capture
    const nameTitle = document.querySelector('.name-title');
    const originalStyles = {};
    if (nameTitle) {
      originalStyles.background = nameTitle.style.background;
      originalStyles.webkitBackgroundClip = nameTitle.style.webkitBackgroundClip;
      originalStyles.webkitTextFillColor = nameTitle.style.webkitTextFillColor;
      originalStyles.backgroundClip = nameTitle.style.backgroundClip;

      nameTitle.style.background = 'none';
      nameTitle.style.webkitBackgroundClip = 'unset';
      nameTitle.style.webkitTextFillColor = 'unset';
      nameTitle.style.backgroundClip = 'unset';
    }

    // Wait a bit for reflow
    await new Promise(resolve => setTimeout(resolve, 100));

    // Capture the content
    const canvas = await html2canvas(document.body, {
      scale: 2,
      useCORS: true,
      logging: false,
      backgroundColor: getComputedStyle(document.body).backgroundColor
    });

    // Restore sidebar
    if (sidebar) sidebar.style.display = sidebarDisplay;
    if (mainContent) {
      mainContent.style.marginLeft = mainMargin;
      mainContent.style.maxWidth = '';
    }

    // Restore name-title styles
    if (nameTitle) {
      nameTitle.style.background = originalStyles.background;
      nameTitle.style.webkitBackgroundClip = originalStyles.webkitBackgroundClip;
      nameTitle.style.webkitTextFillColor = originalStyles.webkitTextFillColor;
      nameTitle.style.backgroundClip = originalStyles.backgroundClip;
    }

    // Create PDF
    const imgData = canvas.toDataURL('image/jpeg', 0.95);
    const imgWidth = canvas.width;
    const imgHeight = canvas.height;

    // A4 proportions
    const pdf = new jsPDF({
      orientation: 'portrait',
      unit: 'px',
      format: [imgWidth, imgHeight]
    });

    pdf.addImage(imgData, 'JPEG', 0, 0, imgWidth, imgHeight, undefined, 'FAST');

    // Add clickable links to PDF
    const links = document.querySelectorAll('a[href]');
    const scale = 2; // Same scale used in html2canvas

    links.forEach(link => {
      const href = link.getAttribute('href');

      // Skip anchor links and relative links, only process full URLs
      if (!href || href.startsWith('#')) return;

      // Convert relative URLs to absolute URLs
      let fullUrl = href;
      if (!href.startsWith('http://') && !href.startsWith('https://')) {
        fullUrl = new URL(href, window.location.origin).href;
      }

      const rect = link.getBoundingClientRect();
      const bodyRect = document.body.getBoundingClientRect();

      // Calculate position relative to body (not viewport)
      const x = (rect.left - bodyRect.left) * scale;
      const y = (rect.top - bodyRect.top) * scale;
      const width = rect.width * scale;
      const height = rect.height * scale;

      // Add clickable area with absolute URL
      pdf.link(x, y, width, height, { url: fullUrl });
    });

    pdf.save('CV_Alberto_Martinez_Zurita.pdf');

  } catch (error) {
    console.error('Error generating PDF:', error);
    alert('Error al generar el PDF. Por favor, intenta de nuevo.');
  } finally {
    btn.disabled = false;
    btn.innerHTML = originalHTML;
    btn.style.opacity = '';
  }
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
