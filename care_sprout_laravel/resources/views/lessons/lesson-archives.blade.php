<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Archives</title>
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
    <template id="archiveLessonOptionsTemplate">
        <div class="lesson-options-dropdown">
            <ul>
                <li class="restore-option">Restore</li>
                <li class="delete-option">Delete</li>
            </ul>
        </div>
    </template>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>
        window.addEventListener('firebaseReady', () => {
            const db = window.db;
            const lessonsContainer = document.getElementById('lessons-container');

            const displayArchivedLessons = async () => {
                lessonsContainer.innerHTML = "";

                try {
                    const querySnapshot = await db.collection("lessons")
                        .where("status", "==", "archived")
                        .get();

                    if (querySnapshot.empty) {
                        lessonsContainer.innerHTML = '<p class="text-center w-100 mt-5">No archived lessons found.</p>';
                        return;
                    }

                    querySnapshot.forEach((doc) => {
                        const lesson = doc.data();
                        const lessonCard = `
                        <div class="col-md-3 mb-3">
                            <div class="card lesson-card archived-lesson-card" data-id="${doc.id}" data-joincode="${lesson.joinCode || ''}" style="cursor:pointer;">
                                <div class="card-header" style="--lesson-color: ${lesson.color || '#cccccc'};">
                                    <span class="lesson-name">${lesson.name || 'Unnamed Lesson'}</span>
                                    <div class="header-icons">
                                        <i class="bi bi-three-dots-vertical lesson-options-icon"></i>
                                    </div>
                                </div>
                                <div class="card-body">
                                </div>
                                <div class="card-footer">
                                    <p class="card-text">Archived On: ${lesson.archivedAt ? new Date(lesson.archivedAt.seconds * 1000).toLocaleDateString() : 'N/A'}</p>
                                </div>
                            </div>
                        </div>
                        `;
                        lessonsContainer.innerHTML += lessonCard;
                    });

                    attachEventListeners();
                } catch (error) {
                    console.error("Error fetching archived lessons:", error);
                    lessonsContainer.innerHTML = '<p class="text-danger">Failed to load archived lessons. Please try again.</p>';
                }
            };

            const attachEventListeners = () => {
                document.querySelectorAll('.lesson-options-icon').forEach(icon => {
                    icon.removeEventListener('click', handleOptionsIconClick);
                    icon.addEventListener('click', handleOptionsIconClick);
                });

                document.removeEventListener('click', handleOutsideClick);
                document.addEventListener('click', handleOutsideClick);

                document.querySelectorAll('.archived-lesson-card').forEach(card => {
                    card.removeEventListener('click', handleCardClickArchived);
                    card.addEventListener('click', handleCardClickArchived);
                });
            };

            const handleCardClickArchived = function() {
                const lessonId = this.getAttribute('data-id');
                console.log(`Clicked archived lesson with ID: ${lessonId}`);
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
                    const template = document.getElementById('archiveLessonOptionsTemplate');
                    dropdown = template.content.cloneNode(true).querySelector('.lesson-options-dropdown');
                    cardHeader.appendChild(dropdown);
                }

                dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';

                if (dropdown.style.display === 'block') {
                    const lessonCard = this.closest('.lesson-card');
                    const lessonId = lessonCard.getAttribute('data-id');

                    const restoreOption = dropdown.querySelector('.restore-option');
                    const deleteOption = dropdown.querySelector('.delete-option');

                    restoreOption.onclick = null;
                    deleteOption.onclick = null;

                    restoreOption.onclick = (e) => {
                        e.stopPropagation();
                        restoreLesson(lessonId, dropdown);
                    };
                    deleteOption.onclick = (e) => {
                        e.stopPropagation();
                        deleteLesson(lessonId, dropdown);
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

            const restoreLesson = (lessonId, dropdown) => {
                if (confirm('Are you sure you want to restore this lesson?')) {
                    db.collection("lessons").doc(lessonId).update({
                        status: 'active',
                        archivedAt: firebase.firestore.FieldValue.delete()
                    }).then(() => {
                        alert('Lesson restored successfully!');
                        displayArchivedLessons();
                        dropdown.style.display = 'none';
                    }).catch(error => {
                        console.error("Error restoring lesson:", error);
                        alert("Error restoring lesson. Please check console for details.");
                    });
                }
            };
            const deleteLesson = (lessonId, dropdown) => {
                if (confirm('Are you sure you want to PERMANENTLY delete this lesson? This action cannot be undone.')) {
                    db.collection("lessons").doc(lessonId).delete()
                        .then(() => {
                            alert('Lesson permanently deleted!');
                            displayArchivedLessons();
                            dropdown.style.display = 'none';
                        }).catch(error => {
                            console.error("Error deleting lesson:", error);
                            alert("Error deleting lesson. Please check console for details.");
                        });
                }
            };

            displayArchivedLessons();

        });
    </script>
</body>
</html>
