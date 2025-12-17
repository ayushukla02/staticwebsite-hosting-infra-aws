// Smooth scroll for nav links
document.querySelectorAll('a[href^="#"]').forEach(link => {
  link.addEventListener('click', e => {
    const targetId = link.getAttribute('href');
    const targetEl = document.querySelector(targetId);
    if (!targetEl) return;

    e.preventDefault();
    targetEl.scrollIntoView({ behavior: 'smooth' });
  });
});

// Theme toggle (light / dark)
const root = document.documentElement;
const themeToggle = document.getElementById('themeToggle');
const storedTheme = localStorage.getItem('theme');

if (storedTheme) {
  root.setAttribute('data-theme', storedTheme);
}

themeToggle.addEventListener('click', () => {
  const currentTheme = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
  root.setAttribute('data-theme', currentTheme);
  localStorage.setItem('theme', currentTheme);
});

// Footer year
document.getElementById('year').textContent = new Date().getFullYear();

// Dummy contact form handler
function handleFormSubmit(event) {
  event.preventDefault();
  const status = document.getElementById('formStatus');
  status.textContent = "Thanks! This is a static demo form for S3 deployment.";
}
