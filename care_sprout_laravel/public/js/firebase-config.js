// Centralized Firebase Configuration
// This file ensures Firebase is only initialized once across all pages

// Firebase configuration object
const firebaseConfig = {
  apiKey: "AIzaSyA3zAXTNwFi9lYAago4EFwE0tIhWQNgRj4",
  authDomain: "caresprout-71e11.firebaseapp.com",
  databaseURL: "https://caresprout-71e11-default-rtdb.firebaseio.com",
  projectId: "caresprout-71e11",
  storageBucket: "caresprout-71e11.firebasestorage.app",
  messagingSenderId: "8378246898",
  appId: "1:8378246898:web:3854c2e8370efd7e96926b"
};

// Initialize Firebase only if it hasn't been initialized already
if (!window.firebase || !window.firebase.apps || !window.firebase.apps.length) {
  // Load Firebase SDKs if not already loaded
  if (typeof firebase === 'undefined') {
    // Create script elements for Firebase SDKs
    const firebaseAppScript = document.createElement('script');
    firebaseAppScript.src = 'https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js';
    firebaseAppScript.async = true;
    
    const firebaseAuthScript = document.createElement('script');
    firebaseAuthScript.src = 'https://www.gstatic.com/firebasejs/8.10.1/firebase-auth.js';
    firebaseAuthScript.async = true;
    
    const firebaseFirestoreScript = document.createElement('script');
    firebaseFirestoreScript.src = 'https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js';
    firebaseFirestoreScript.async = true;
    
    // Load scripts in sequence
    firebaseAppScript.onload = function() {
      document.head.appendChild(firebaseAuthScript);
    };
    
    firebaseAuthScript.onload = function() {
      document.head.appendChild(firebaseFirestoreScript);
    };
    
    firebaseFirestoreScript.onload = function() {
      // Initialize Firebase after all SDKs are loaded
      firebase.initializeApp(firebaseConfig);
      window.auth = firebase.auth();
      window.db = firebase.firestore();
      
      // Dispatch custom event to notify that Firebase is ready
      window.dispatchEvent(new CustomEvent('firebaseReady'));
    };
    
    document.head.appendChild(firebaseAppScript);
  } else {
    // Firebase SDKs are already loaded, just initialize
    firebase.initializeApp(firebaseConfig);
    window.auth = firebase.auth();
    window.db = firebase.firestore();
    
    // Dispatch custom event to notify that Firebase is ready
    window.dispatchEvent(new CustomEvent('firebaseReady'));
  }
} else {
  // Firebase is already initialized, just set up global references
  window.auth = firebase.auth();
  window.db = firebase.firestore();
  
  // Dispatch custom event to notify that Firebase is ready
  window.dispatchEvent(new CustomEvent('firebaseReady'));
}

// Export for use in other scripts
window.firebaseConfig = firebaseConfig; 