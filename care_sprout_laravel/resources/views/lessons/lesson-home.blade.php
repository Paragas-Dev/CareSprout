<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Lessons Home</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- CSS and icon includes -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="{{ asset('css/lesson-home.css') }}">
    <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
</head>
<body>
    @include('partials.sidebar')
    <div class="main-container">
        <header>
            @include('partials.header')
        </header>
        <div class="lessons row" id="lessons-container">

        </div>
    </div>
    <template id="lessonOptionsTemplate">
        <div class="lesson-options-dropdown">
            <ul>
                <li class="copy-option">Copy Code</li>
                <li class="edit-option">Edit</li>
                <li class="archive-option">Archive</li>
            </ul>
        </div>
    </template>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>
        window.addEventListener('firebaseReady', () => {
            const db = window.db;
            const lessonsContainer = document.getElementById('lessons-container');

            const displayLessons = async () => {
                lessonsContainer.innerHTML = "";

                try {
                    const querySnapshot = await db.collection("lessons").get();

                    const displayLessons = [];

                    querySnapshot.forEach((doc) => {
                        const lesson = doc.data();
                        if (!lesson.status || lesson.status !== "archived") {
                            displayLessons.push({ id: doc.id, data: lesson });
                        }
                    });

                    displayLessons.forEach(({ id, data: lesson }) => {
                        const lessonCard = `
                        <div class="col-md-3 mb-3">
                            <div class="card lesson-card lesson-card-link" data-id="${id}" data-joincode="${lesson.joinCode || ''}" style="cursor:pointer;">
                                <div class="card-header" style="--lesson-color: ${lesson.color || '#cccccc'};">
                                    <span class="lesson-name">${lesson.name || 'Unnamed Lesson'}</span>
                                    <div class="header-icons">
                                        <i class="bi bi-three-dots-vertical lesson-options-icon"></i>
                                    </div>
                                </div>
                                <div class="card-body">
                                    </div>
                                <div class="card-footer">
                                    </div>
                            </div>
                        </div>
                        `;
                        lessonsContainer.innerHTML += lessonCard;
                    });

                    attachEventListeners();

                } catch (error) {
                    console.error("Error fetching or displaying lessons:", error);
                    lessonsContainer.innerHTML = '<p class="text-danger">Failed to load lessons. Please try again.</p>';
                }
            };

            const attachEventListeners = () => {
                document.querySelectorAll('.lesson-card-link').forEach(card => {
                    card.removeEventListener('click', handleCardClick);
                    card.addEventListener('click', handleCardClick);
                });

                document.querySelectorAll('.lesson-options-icon').forEach(icon => {
                    icon.removeEventListener('click', handleOptionsIconClick);
                    icon.addEventListener('click', handleOptionsIconClick);
                });

                document.removeEventListener('click', handleOutsideClick);
                document.addEventListener('click', handleOutsideClick);
            };

            const handleCardClick = function() {
                const lessonId = this.getAttribute('data-id');
                window.location.href = `/lesson-stream/${lessonId}`;
            };

            const handleOptionsIconClick = function(event) {
                event.stopPropagation();

                document.querySelectorAll('.lesson-options-dropdown').forEach(dropdown => {
                    if (dropdown !== this.nextElementSibling) {
                        dropdown.style.display = 'none';
                    }
                });

                const cardHeader = this.closest('.card-header');
                let dropdown = cardHeader.querySelector('.lesson-options-dropdown');

                if (!dropdown) {
                    const template = document.getElementById('lessonOptionsTemplate');
                    dropdown = template.content.cloneNode(true).querySelector('.lesson-options-dropdown');
                    cardHeader.appendChild(dropdown);
                }

                dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';

                if (dropdown.style.display === 'block') {
                    const lessonCard = this.closest('.lesson-card');
                    const lessonId = lessonCard.getAttribute('data-id');
                    const joinCode = lessonCard.getAttribute('data-joincode');

                    const copyOption = dropdown.querySelector('.copy-option');
                    const editOption = dropdown.querySelector('.edit-option');
                    const archiveOption = dropdown.querySelector('.archive-option');

                    copyOption.onclick = null;
                    editOption.onclick = null;
                    archiveOption.onclick = null;


                    copyOption.onclick = (e) => {
                        e.stopPropagation();
                        copyCode(joinCode, dropdown);
                    };
                    editOption.onclick = (e) => {
                        e.stopPropagation();
                        editLesson(lessonId, dropdown);
                    };
                    archiveOption.onclick = (e) => {
                        e.stopPropagation();
                        archiveLesson(lessonId, dropdown);
                    };
                }
            };

            const handleOutsideClick = function(event) {
                if (!event.target.closest('.lesson-options-dropdown') && !event.target.closest('.lesson-options-icon')) {
                    document.querySelectorAll('.lesson-options-dropdown').forEach(dropdown => {
                        dropdown.style.display = 'none';
                    });
                }
            };

            const copyCode = (code, dropdown) => {
                navigator.clipboard.writeText(code)
                    .then(() => {
                        dropdown.style.display = 'none';
                        alert('Join code copied to clipboard!');
                    }).catch(err => {
                        console.error('Failed to copy text: ', err);
                        alert('Failed to copy join code. Please try again.');
                    });
            };

            const editLesson = (lessonId, dropdown) => {
                // window.location.href = `/edit-lesson/${lessonId}`;
                dropdown.style.display = 'none';
            };

            const archiveLesson = (lessonId, dropdown) => {
                if (confirm('Are you sure you want to archive this lesson?')) {
                    db.collection("lessons").doc(lessonId).update({
                        status: 'archived',
                        archivedAt: firebase.firestore.FieldValue.serverTimestamp()
                    }).then(() => {
                        alert('Lesson archived successfully!');
                        displayLessons();
                        dropdown.style.display = 'none';
                    }).catch(error => {
                        console.error("Error archiving lesson:", error);
                        alert("Error archiving lesson. Please check console for details.");
                    });
                }
            };

            displayLessons();
        });
    </script>
</body>
</html>
