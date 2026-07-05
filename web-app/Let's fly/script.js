/*
  =========================================
  Let's Fly Philanthropy - Core Javascript
  =========================================
*/

// --- SMOOTH SCROLLING ---
function goTo(id) {
  var el = document.getElementById(id);
  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
}

// --- MOBILE DRAWER DRAWER ---
function closeMobile() {
  document.querySelector('.mobile-menu').classList.remove('open');
}

// --- FAQ ACCORDION EXPANSION ---
function toggleFaq(el) {
  var ans = el.nextElementSibling;
  var arrow = el.querySelector('.faq-arrow');
  var isOpen = ans.classList.contains('open');
  
  document.querySelectorAll('.faq-a').forEach(function(a) {
    a.classList.remove('open');
  });
  document.querySelectorAll('.faq-arrow').forEach(function(a) {
    a.classList.remove('open');
  });
  
  if (!isOpen) {
    ans.classList.add('open');
    arrow.classList.add('open');
  }
}

// --- RESIZE DRAWER RESET ---
window.addEventListener('resize', function() {
  if (window.innerWidth > 700) {
    document.querySelector('.mobile-menu').classList.remove('open');
  }
});



// --- BOOKING MODAL AND PAYMENT ROUTING ---
function openBookingModal(sessionType) {
  const modal = document.getElementById('booking-modal');
  if (modal) {
    // Reset two-step state each time modal opens
    const checkbox = document.getElementById('assessment-confirm');
    const step2 = document.getElementById('booking-step-2');
    const proceedBtn = document.getElementById('btn-proceed-payment');
    const lockMsg = document.getElementById('booking-lock-msg');

    if (checkbox) checkbox.checked = false;
    if (step2) {
      step2.classList.add('booking-step-locked');
      step2.classList.remove('booking-step-unlocked');
    }
    if (proceedBtn) proceedBtn.disabled = true;
    if (lockMsg) lockMsg.classList.remove('hidden');

    modal.classList.add('open');
    document.body.style.overflow = 'hidden'; // Lock page scroll behind modal
  }
}

function closeBookingModal() {
  const modal = document.getElementById('booking-modal');
  if (modal) {
    modal.classList.remove('open');
    document.body.style.overflow = ''; // Unlock page scroll
  }
}

// --- TWO-STEP BOOKING: ASSESSMENT CHECKBOX TOGGLE ---
function toggleBookingStep2() {
  const checkbox = document.getElementById('assessment-confirm');
  const step2 = document.getElementById('booking-step-2');
  const proceedBtn = document.getElementById('btn-proceed-payment');
  const lockMsg = document.getElementById('booking-lock-msg');

  if (checkbox && checkbox.checked) {
    step2.classList.remove('booking-step-locked');
    step2.classList.add('booking-step-unlocked');
    proceedBtn.disabled = false;
    if (lockMsg) lockMsg.classList.add('hidden');
  } else {
    step2.classList.add('booking-step-locked');
    step2.classList.remove('booking-step-unlocked');
    proceedBtn.disabled = true;
    if (lockMsg) lockMsg.classList.remove('hidden');
  }
}

function proceedToPayment() {
  closeBookingModal();
  
  // Scroll smoothly to the payment section
  goTo('payment');
  
  // Highlight the payment card with a golden glow after scroll animation completes
  setTimeout(() => {
    const paymentCard = document.querySelector('.payment-qr-card');
    if (paymentCard) {
      paymentCard.classList.add('highlight-glow');
      
      // Remove glow after 3 seconds
      setTimeout(() => {
        paymentCard.classList.remove('highlight-glow');
      }, 3000);
    }
  }, 800);
}

// Close modal when clicking backdrop area
window.addEventListener('click', (e) => {
  const modal = document.getElementById('booking-modal');
  if (e.target === modal) {
    closeBookingModal();
  }
});

