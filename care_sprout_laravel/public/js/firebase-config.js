// public/js/firebase-config.js

const firebaseConfig = {
    apiKey: "AIzaSyA3zAXTNwFi9lYAago4EFwE0tIhWQNgRj4",
    authDomain: "caresprout-71e11.firebaseapp.com",
    databaseURL: "https://caresprout-71e11-default-rtdb.firebaseio.com",
    projectId: "caresprout-71e11",
    storageBucket: "caresprout-71e11.firebasestorage.app",
    messagingSenderId: "8378246898",
    appId: "1:8378246898:web:3854c2e8370efd7e96926b"
  };

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const s = document.createElement('script');
      s.src = src;
      s.async = true;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  // Initialize Firebase only if not yet initialized
  (async function initFirebase() {
    try {
      if (typeof firebase === 'undefined' || !firebase.auth || !firebase.firestore) {
        await loadScript('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
        await loadScript('https://www.gstatic.com/firebasejs/8.10.1/firebase-auth.js');
        await loadScript('https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js');
        await loadScript('https://www.gstatic.com/firebasejs/8.10.1/firebase-database.js');
      }

      if (!firebase.apps.length) {
        firebase.initializeApp(firebaseConfig);
      }

      window.auth = firebase.auth();
      window.firebase = firebase;
      window.db = firebase.firestore();

      auth.onAuthStateChanged((user) => {
        window.auth = auth;
        window.db = db;
        window.currentUser = user;

        window.dispatchEvent(new CustomEvent('firebaseReady'));
      });

    } catch (error) {
      console.error('Firebase initialization error:', error);
    }
  })
  ();
