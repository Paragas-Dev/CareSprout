window.addEventListener('firebaseReady', function() {
  const db = window.db;
  
  function populateSidebarLessons() {
    const sidebarSubmenu = document.querySelector('.submenu');
    if (!sidebarSubmenu) return;
    sidebarSubmenu.innerHTML = '';
    db.collection('lessons').orderBy('createdAt', 'asc').get().then(snapshot => {
      snapshot.forEach(doc => {
        const data = doc.data();
        const a = document.createElement('a');
        a.className = 'submenu-item';
        a.href = `/lesson-stream/${doc.id}`;
        a.textContent = data.name;
        sidebarSubmenu.appendChild(a);
      });
    });
  }
  
  // Call the function when Firebase is ready
  populateSidebarLessons();
}); 