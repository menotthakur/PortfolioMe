// Simple JavaScript for smooth scrolling to internal links
document.addEventListener('DOMContentLoaded', function() {
  // Smooth scrolling for internal links
  const internalLinks = document.querySelectorAll('a[href^="#"]');
  
  internalLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      
      const targetId = this.getAttribute('href').substring(1);
      const targetElement = document.getElementById(targetId);
      
      if (targetElement) {
        window.scrollTo({
          top: targetElement.offsetTop - 20,
          behavior: 'smooth'
        });
      }
    });
  });
  
  // Typing animation effect for tagline
  const tagline = document.querySelector('p[style="color: #de1e4c;"]');
  if (tagline) {
    const originalText = tagline.textContent;
    tagline.textContent = '';
    
    let i = 0;
    const typeWriter = () => {
      if (i < originalText.length) {
        tagline.textContent += originalText.charAt(i);
        i++;
        setTimeout(typeWriter, 50);
      }
    };
    
    // Start the typing animation after a short delay
    setTimeout(typeWriter, 500);
  }
  
  // Add a subtle animation to project items when they come into view
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
      }
    });
  }, { threshold: 0.1 });
  
  document.querySelectorAll('.project-item').forEach(item => {
    item.style.opacity = '0';
    item.style.transform = 'translateY(20px)';
    item.style.transition = 'all 0.5s ease';
    observer.observe(item);
  });
});