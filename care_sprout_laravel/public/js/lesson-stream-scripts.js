function stripHtml(html) {
    var tmp = document.createElement("DIV");
    tmp.innerHTML = html;
    return tmp.textContent || tmp.innerText || "";
  }
  function getLessonIdFromUrl() {
    const parts = window.location.pathname.split('/');
    return parts[parts.length - 1];
  }
  const lessonId = getLessonIdFromUrl();
  let lessonName = '';
  let lessonCode = '';
  let currentUserName = 'Loading User...';
  let editingPostId = null;
  let currentAttachments = [];

  // DOM Elements
  const announcementCard = document.getElementById('announcement-card');
  const announcementFormContainer = document.getElementById('announcement-form-container');
  const announcementModalBackdrop = document.getElementById('announcement-modal-backdrop');

  const announcementForm = document.getElementById('new-announcement-form');
  const textarea = document.getElementById('announcement-text');
  const attachedFilesContainer = document.getElementById('attached-files-container');
  const postBtn = document.getElementById('post-announcement');
  const cancelBtn = document.getElementById('cancel-announcement');
  const postsContainer = document.getElementById('posts-container');
  const lessonTitle = document.querySelector('h1 #lesson-title');

  const teacherListDiv = document.getElementById('teacher-list');
  const adminPerson = document.getElementById('admin-person-row');
  const adminName = adminPerson.querySelector('.person-name');

  const studentsPeopleList = document.getElementById('students-people-list');
  const studentsState = document.getElementById('students-empty-state');

  //attachment buttons elements
  const youtubeBtn = document.getElementById('youtube-btn');
  const cloudinaryBtn = document.getElementById('cloudinary-upload-btn');
  const linkBtn = document.getElementById('link-btn');

  // Status of the Upload
  const uploadStatus = document.getElementById('upload-status');

  // Modal Link Elements
  const linkModal = document.getElementById('link-modal');
  const linkUrlInput = document.getElementById('link-url-input');
  const linkTextInput = document.getElementById('link-text-input');
  const cancelLinkBtn = document.getElementById('cancel-link');
  const insertLinkBtn = document.getElementById('insert-link');

  // Modal youtube elements
  const youtubeModal = document.getElementById('youtube-modal');
  const youtubeUrlInput = document.getElementById('youtube-url-input');
  const cancelYoutubeBtn = document.getElementById('cancel-youtube');
  const insertYoutubeBtn = document.getElementById('insert-youtube');

  const cloudName = "dhndcgc3o";
  const uploadPreset = "CareSprout_Preset";

  //upload logic for cloudinary
  async function uploadFileToCloudinary(file, origin = 'local') {
    uploadStatus.textContent = `Uploading ${file.name} to Cloudinary...`;
    uploadStatus.style.color = '#555';

    if (typeof cloudinary === 'undefined' || !cloudName || !uploadPreset) {
        uploadStatus.textContent = 'Cloudinary configuration or script not loaded.';
        uploadStatus.style.color = 'red';
        console.error('Cloudinary configuration or script is not loaded.');
        return;
    }

    const formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', uploadPreset);
    formData.append('folder', `announcements/${lessonId}`);

    try {
        const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/auto/upload`, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error.message || 'Cloudinary upload failed.');
        }

        const uploadedAsset = await response.json();
        console.log('Done uploading file to Cloudinary!', uploadedAsset);
        uploadStatus.textContent = `Uploaded ${uploadedAsset.original_filename || uploadedAsset.public_id} to Cloudinary!`;
        uploadStatus.style.color = 'green';

        // Add to current Attachments and display the chip container below the ckeditor
        addAttachmentToPreview({
            type: uploadedAsset.resource_type === 'image' || uploadedAsset.resource_type === 'video' ? uploadedAsset.resource_type : 'file',
            url: uploadedAsset.secure_url,
            name: uploadedAsset.original_filename || uploadedAsset.public_id,
            format: uploadedAsset.format,
            public_id: uploadedAsset.public_id,
            origin: origin
        });
        updatePostButtonState();

        setTimeout(() => { uploadStatus.textContent = ''; }, 3000);
    } catch (error) {
        console.error('Cloudinary Upload Error:', error);
        uploadStatus.textContent = `Cloudinary upload failed: ${error.message}`;
        uploadStatus.style.color = 'red';
    }
  }

// YouTube and Link Logic

// Handle YouTube button click
if (youtubeBtn && youtubeModal && youtubeUrlInput && cancelYoutubeBtn && insertYoutubeBtn) {
    youtubeBtn.addEventListener('click', () => {
        youtubeUrlInput.value = '';
        youtubeModal.style.display = 'flex';
    });

    cancelYoutubeBtn.addEventListener('click', () => {
        youtubeModal.style.display = 'none';
    });

    insertYoutubeBtn.addEventListener('click', () => {
        const videoUrl = youtubeUrlInput.value.trim();
        if (videoUrl) {
            const videoIdMatch = videoUrl.match(/(?:https?:\/\/)?(?:www\.)?(?:youtube\.com|youtu\.be)\/(?:watch\?v=|embed\/|v\/|)([\w-]{11})(?:\S+)?/);
            if (videoIdMatch && videoIdMatch[1]) {
                const videoId = videoIdMatch[1];
                // Add YouTube video as an attachment
                addAttachmentToPreview({
                    type: 'youtube',
                    url: `https://www.youtube.com/embed/${videoId}`,
                    name: `YouTube Video: ${videoId}`,
                    videoId: videoId
                });
                updatePostButtonState();
                youtubeModal.style.display = 'none';
            } else {
                alert("Invalid YouTube URL. Please enter a valid YouTube video URL.");
            }
        } else {
            alert("Please enter a YouTube URL.");
        }
    });
}

// Handle Link button click
if (linkBtn && linkModal && linkUrlInput && linkTextInput && cancelLinkBtn && insertLinkBtn) {
    linkBtn.addEventListener('click', () => {
        linkUrlInput.value = '';
        linkTextInput.value = '';
        linkModal.style.display = 'flex';
    });

    cancelLinkBtn.addEventListener('click', () => {
        linkModal.style.display = 'none';
    });

    insertLinkBtn.addEventListener('click', () => {
        let url = linkUrlInput.value.trim();
        let text = linkTextInput.value.trim();

        if (url) {
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
                url = 'https://' + url;
            }
            if (!text) {
                text = url;
            }
            // Add link as an attachment
            addAttachmentToPreview({
                type: 'link',
                url: url,
                name: text
            });
            updatePostButtonState();
            linkModal.style.display = 'none';
        } else {
            alert("Please enter a valid URL.");
        }
    });
}

// attachment functions

    // adding attachment to the announcement-form
    function addAttachmentToPreview(attachment) {
        attachment.id = 'attachment-' + Date.now() + Math.random().toString(36).substr(2, 9);
        currentAttachments.push(attachment);
        renderAttachmentsPreview();
    }

    // removing attachments by id
    function removeAttachment(attachmentId) {
        currentAttachments = currentAttachments.filter(att => att.id !== attachmentId);
        renderAttachmentsPreview();
        updatePostButtonState();
    }

    // rendering of attachments in the announcement-form
    function renderAttachmentsPreview() {
        if (!attachedFilesContainer) return;

        attachedFilesContainer.innerHTML = '';
        currentAttachments.forEach(attachment => {
            const attachmentChip = document.createElement('div');
            attachmentChip.className = 'attachment-chip';
            attachmentChip.setAttribute('data-attachment-id', attachment.id);

            let iconHtml = '';
            let typeText = '';

            if (attachment.type === 'image') {
                iconHtml = `<img src="https://res.cloudinary.com/${cloudName}/image/upload/w_40,h_40,c_fill/${attachment.public_id}.${attachment.format}" alt="Image" class="attachment-thumbnail">`;
                typeText = 'Image';
            } else if (attachment.type === 'video') {
                iconHtml = `<img src="https://res.cloudinary.com/${cloudName}/video/upload/w_40,h_40,c_fill,f_image,q_auto:eco/v${attachment.public_id}.jpg" alt="Video" class="attachment-thumbnail">`;
                typeText = 'Video';
            } else if (attachment.type === 'youtube') {
                iconHtml = `<img src="https://img.youtube.com/vi/${attachment.videoId}/default.jpg" alt="YouTube Thumbnail" class="attachment-thumbnail">`;
                typeText = 'YouTube Video';
            } else if (attachment.type === 'link') {
                iconHtml = `<i class="fas fa-link attachment-icon"></i>`;
                typeText = 'Link';
            } else {
                iconHtml = `<i class="fas fa-file attachment-icon"></i>`;
                typeText = 'File';
            }

            attachmentChip.innerHTML = `
                <div class="attachment-thumbnail-wrapper">
                    ${iconHtml}
                </div>
                <div class="attachment-info">
                    <span class="attachment-name">${attachment.name}</span>
                    <span class="attachment-type">${typeText}</span>
                </div>
                <button type="button" class="attachment-remove-btn" title="Remove attachment">
                    <i class="fas fa-times"></i>
                </button>
            `;

            attachedFilesContainer.appendChild(attachmentChip);

            attachmentChip.querySelector('.attachment-remove-btn').addEventListener('click', () => {
                removeAttachment(attachment.id);
            });
        });
    }

  // Firebase Ready Event
  window.addEventListener('firebaseReady', function() {
    const db = window.db;
    const auth = window.auth;

    const lessonInfoIcon = document.getElementById('lesson-info-icon');
    const lessonInfoPopup = document.getElementById('lesson-info-popup');
    const joinCodeDisplay = document.getElementById('join-code-display');
    const copyIcon = lessonInfoPopup.querySelector('.copy-icon');
    const copyFeedback = document.getElementById('copy-feedback');

      //upload files storing to cloudinary
      var myWidget = cloudinary.createUploadWidget(
        {
            cloudName: cloudName,
            uploadPreset: uploadPreset,
            sources: ['local', 'url', 'camera'],
            multiple: false,
            resourceType: 'auto',
            clientAllowedFormats: ['png', 'gif', 'jpeg', 'mp4', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
            maxFileSize: 10000000,
            folder: `announcements/${lessonId}`,
            styles: {
                palette: {
                    window: "#FFFFFF", windowBorder: "#90A0B3", tabIcon: "#0078FF",
                    menuIcons: "#5A616A", text: "#444444", inactiveText: "#B6B6B6",
                    link: "#0078FF", action: "#FF620C", inProgress: "#0078FF",
                    complete: "#20B832", error: "#EA2727", sourceBg: "#E4EBF1"
                },
                fonts: { default: null, "sans-serif": { url: null, active: true } }
            }
        },
        (error, result) => {
            if (!error && result && result.event === "success") {
                const uploadedAsset = result.info;
                console.log('Done uploading file via widget to Cloudinary!', uploadedAsset);

                addAttachmentToPreview({
                    type: uploadedAsset.resource_type === 'image' || uploadedAsset.resource_type === 'video' ? uploadedAsset.resource_type : 'file',
                    url: uploadedAsset.secure_url,
                    name: uploadedAsset.original_filename || uploadedAsset.public_id,
                    format: uploadedAsset.format,
                    public_id: uploadedAsset.public_id,
                    origin: 'local'
                });
                updatePostButtonState();

                setTimeout(() => { uploadStatus.textContent = ''; }, 3000);

            } else if (result && result.event === "abort") {
                setTimeout(() => { uploadStatus.textContent = ''; }, 2000);
            } else if (error) {
                console.error("Cloudinary Upload Widget Error:", error);
                uploadStatus.textContent = `Upload error: ${error.message || 'Unknown error'}`;
                uploadStatus.style.color = 'red';
            }
        }
    );

    if (cloudinaryBtn) {
        cloudinaryBtn.addEventListener('click', () => {
            uploadStatus.textContent = '';
            myWidget.open();
        });
    }

    auth.onAuthStateChanged(user => {
        if (user) {
            currentUserName = user.displayName || user.email || 'Admin';
            console.log('Firebase User Name:', currentUserName);
        } else {
            currentUserName = document.body.dataset.authUserName || 'Default Admin Name';
            console.log('No Firebase User. Using Laravel fallback (if available):', currentUserName);
        }
    })
    // Fetch Lesson Title
    db.collection('lessons').doc(lessonId).get().then(doc => {
      if (doc.exists) {
        lessonName = doc.data().name;
        lessonCode = doc.data().joinCode;
        lessonTitle.textContent = lessonName;
        joinCodeDisplay.textContent = lessonCode;
      } else {
        lessonTitle.textContent = 'Lesson Not Found';
        joinCodeDisplay.textContent = 'N/A';
      }

        // lesson info icon
      lessonInfoIcon.addEventListener('click', (event) => {
        lessonInfoPopup.classList.toggle('show');
        event.stopPropagation();
      });

      copyIcon.addEventListener('click', async () => {
        try {
            await navigator.clipboard.writeText(lessonCode);
            if (copyFeedback) {
                copyFeedback.style.opacity = '1';
                setTimeout(() => {
                    copyFeedback.style.opacity = '0';
                }, 1500);
            }
        } catch (error) {
            console.error('Failed to copy: ', error);
        }
      });

      document.addEventListener('click', (event) => {
        if (lessonInfoPopup.classList.contains('show') && !lessonInfoPopup.contains(event.target) && event.target !== lessonInfoIcon) {
            lessonInfoPopup.classList.remove('show');
        }
      });
    });

    // Initial Post Rendering
    renderPostsFromFirestore();

    // Announcement Card Events
    announcementCard.addEventListener('click', function() {
        editingPostId = null;
        if (CKEDITOR.instances['announcement-text']) {
            CKEDITOR.instances['announcement-text'].setData('');
        } else {
            textarea.value = '';
        }
        currentAttachments = [];
        renderAttachmentsPreview();
        showForm(false);
    });

    cancelBtn.onclick = function() {
        hideForm();
    };

    // changes in content
    function updatePostButtonState(editorContent = null) {
        const textContent = stripHtml(editorContent !== null ? editorContent : (CKEDITOR.instances['announcement-text'] ? CKEDITOR.instances['announcement-text'].getData() : textarea.value));

        if (postBtn) {
            // Enable if there's text content OR if there are attachments
            if (textContent.trim() || currentAttachments.length > 0) {
                postBtn.disabled = false;
                postBtn.style.opacity = 1;
                postBtn.style.cursor = 'pointer';
                postBtn.style.background = '#1a73e8';
                postBtn.style.color = '#fff';
            } else {
                postBtn.disabled = true;
                postBtn.style.opacity = 1;
                postBtn.style.cursor = 'not-allowed';
                postBtn.style.background = '#e3e3e3';
                postBtn.style.color = '#b0b0b0';
            }
        }
    }

    // Announcement Form Submission
    if (announcementForm) {
        announcementForm.onsubmit = function(e) {
            e.preventDefault();
            const editorData = CKEDITOR.instances['announcement-text'] ? CKEDITOR.instances['announcement-text'].getData() : textarea.value;
            const plainText = stripHtml(editorData).trim();

            // Allow posting if there's text OR attachments
            if (!plainText && currentAttachments.length === 0) {
                alert('Please enter some text or add an attachment to your announcement.');
                return;
            }

            const postData = {
                lessonId: lessonId,
                name: currentUserName,
                text: editorData,
                attachments: currentAttachments
            };

            if (editingPostId) {
                db.collection('lessons')
                    .doc(lessonId)
                    .collection('posts')
                    .doc(editingPostId)
                    .update({
                        text: editorData,
                        attachments: currentAttachments,
                        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
                    })
                    .then(() => {
                        console.log("Post updated successfully!");
                        hideForm();
                        renderPostsFromFirestore();
                    })
                    .catch(error => {
                        console.error("Error updating post: ", error);
                        alert("Failed to update announcement. Please try again.");
                    });
            } else {
                postData.createdAt = firebase.firestore.FieldValue.serverTimestamp();
                db.collection('lessons')
                    .doc(lessonId)
                    .collection('posts')
                    .add(postData)
                    .then(() => {
                        console.log("Post added successfully!");
                        hideForm();
                        renderPostsFromFirestore();
                    })
                    .catch(error => {
                        console.error("Error adding post: ", error);
                        alert("Failed to post announcement. Please try again.");
                    });
            }
        };
    }

    async function sendComment(postId, commentText) {
        if (!commentText.trim()) {
            alert('Comment cannot be empty.');
            return;
        }

        try {
            await db.collection('lessons')
                .doc(lessonId)
                .collection('posts')
                .doc(postId)
                .collection('class_comments')
                .add({
                    comment: commentText,
                    timestamp: firebase.firestore.FieldValue.serverTimestamp(),
                    author: currentUserName
                });
            console.log("Comment added successfully!");
            renderPostsFromFirestore();
        } catch (error) {
            console.error("Error adding comment: ", error);
            alert("Failed to send comment. Please try again.");
        }
    }

    // Render Posts
    async function renderPostsFromFirestore() {
      if (!postsContainer) return;

      db.collection('lessons')
      .doc(lessonId)
      .collection('posts')
      .orderBy('createdAt', 'desc')
      .get()
      .then(querySnapshot => {
        postsContainer.innerHTML = '';
        if (querySnapshot.empty) {
            postsContainer.innerHTML = '<p style="text-align: center; color: #777;">No announcements yet. Be the first to post!</p>';
        }

        querySnapshot.forEach(doc => {
          const post = doc.data();
          const postId = doc.id;

          const postContent = post.text;
          const postAttachments = post.attachments || [];

          const postDiv = document.createElement('div');
          postDiv.className = 'post-card dynamic-post';
          postDiv.setAttribute('data-post-id', postId);

          let attachmentsHtml = '';
            if (postAttachments.length > 0) {
                attachmentsHtml += '<div class="post-attachments-display">';
                postAttachments.forEach(att => {
                    let icon = '';
                    let typeDisplay = '';
                    let url = att.url;
                    let name = att.name;

                    if (att.type === 'image') {
                        icon = `<img src="https://res.cloudinary.com/${cloudName}/image/upload/w_48,h_48,c_fill/${att.public_id}.${att.format}" alt="Image Thumbnail" class="attachment-display-thumbnail">`;
                        typeDisplay = 'Image';
                    } else if (att.type === 'video') {
                                // Cloudinary video thumbnail (first frame)
                        icon = `<img src="https://res.cloudinary.com/${cloudName}/video/upload/w_48,h_48,c_fill,f_image,q_auto:eco/v${att.public_id}.jpg" alt="Video Thumbnail" class="attachment-display-thumbnail">`;
                        typeDisplay = 'Video';
                    } else if (att.type === 'youtube') {
                                // YouTube default thumbnail
                        icon = `<img src="https://img.youtube.com/vi/${att.videoId}/default.jpg" alt="YouTube Thumbnail" class="attachment-display-thumbnail">`;
                        typeDisplay = 'YouTube Video';
                        url = att.url; // Use embed URL for YouTube
                    } else if (att.type === 'link') {
                        icon = `<i class="fas fa-link attachment-display-icon"></i>`;
                        typeDisplay = 'Link';
                    } else { // Generic file (pdf, docx, etc.)
                        icon = `<i class="fas fa-file attachment-display-icon"></i>`;
                        typeDisplay = 'File';
                    }

                    attachmentsHtml += `
                        <a href="${url}" target="_blank" rel="noopener noreferrer" class="attachment-display-chip">
                            <div class="attachment-display-thumbnail-wrapper">
                                ${icon}
                            </div>
                        <div class="attachment-display-info">
                            <span class="attachment-display-name">${name}</span>
                            <span class="attachment-display-type">${typeDisplay}</span>
                            </div>
                        </a>
                    `;
                });
                attachmentsHtml += '</div>';
            }

          postDiv.innerHTML = `
            <div class="post-header">
              <i class="fas fa-user-circle"></i>
              <span>${post.name}</span>
              <div class="post-options">
                <i class="fas fa-ellipsis-v"></i>
                <ul class="post-options-dropdown">
                  <li class="edit-post-btn" data-post-id="${postId}">Edit</li>
                  <li class="delete-post-btn" data-post-id="${postId}">Delete</li>
                </ul>
              </div>
            </div>
            <div class="post-body">
                ${postContent}
                ${attachmentsHtml}
            </div>
            <div class="post-comments-section">
                <div class="latest-comment-display"></div>
                <div class="post-footer">
                    <input type="text" class="comment-input" placeholder="Add class comment...">
                    <i class="fas fa-paper-plane send-comment-btn" style="color: #b0b0b0; cursor: not-allowed;"></i>
                </div>
            </div>
          `;
          postsContainer.appendChild(postDiv);
          // Add event listeners for the ellipsis icon
          const optionsIcon = postDiv.querySelector('.post-options .fa-ellipsis-v');
          const dropdownMenu = postDiv.querySelector('.post-options-dropdown');

          if (optionsIcon && dropdownMenu) {
            optionsIcon.addEventListener('click', (event) => {
                document.querySelectorAll('.post-options-dropdown.show').forEach(openDropdown => {
                    if (openDropdown !== dropdownMenu) {
                        openDropdown.classList.remove('show');
                    }
                });
                dropdownMenu.classList.toggle('show');
                event.stopPropagation();
            });

            postDiv.querySelector('.edit-post-btn').addEventListener('click', () => {
                dropdownMenu.classList.remove('show');
                // Pass current attachments to edit form
                openEditPostForm(postId, post.text, postAttachments);
            });

            postDiv.querySelector('.delete-post-btn').addEventListener('click', () => {
                dropdownMenu.classList.remove('show');
                deletePost(postId);
            });
        }

        // listeners for comments
        const commentInput = postDiv.querySelector('.comment-input');
        const sendCommentBtn = postDiv.querySelector('.send-comment-btn');
        const latestCommentDisplay = postDiv.querySelector('.latest-comment-display');

        db.collection('lessons')
            .doc(lessonId)
            .collection('posts')
            .doc(postId)
            .collection('class_comments')
            .orderBy('timestamp', 'desc')
            .limit(1)
            .get()
            .then(commentSnapshot => {
                if (!commentSnapshot.empty) {
                    const latestComment = commentSnapshot.docs[0].data();
                    const commentTime = latestComment.timestamp ? new Date(latestComment.timestamp.toDate()).toLocaleString() : 'Just now';
                    latestCommentDisplay.innerHTML = `
                        <div class="comment-item">
                            <span class="comment-author">${latestComment.author}:</span>
                            <span class="comment-text">${latestComment.comment}</span>
                            <span class="comment-time">${commentTime}</span>
                        </div>
                    `;
                    latestCommentDisplay.style.display = 'block';
                } else {
                    latestCommentDisplay.style.display = 'none';
                }
            }).catch(error => {
                console.error("Error fetching latest comment: ", error);
                latestCommentDisplay.style.display = 'none';
            });

            // enable - disable of send button
            commentInput.addEventListener('input', () => {
                if (commentInput.value.trim()) {
                  sendCommentBtn.style.color = '#1a73e8';
                  sendCommentBtn.style.cursor = 'pointer';
                } else {
                  sendCommentBtn.style.color = '#b0b0b0';
                  sendCommentBtn.style.cursor = 'not-allowed';
                }
            });

            sendCommentBtn.addEventListener('click', () => {
                const commentText = commentInput.value.trim();
                if (commentText) {
                  sendComment(postId, commentText);
                  commentInput.value = '';
                  sendCommentBtn.style.color = '#b0b0b0';
                  sendCommentBtn.style.cursor = 'not-allowed';
                }
            });

            commentInput.addEventListener('keypress', (event) => {
                if (event.key === 'Enter') {
                  const commentText = commentInput.value.trim();
                  if (commentText) {
                    sendComment(postId, commentText);
                    commentInput.value = '';
                    sendCommentBtn.style.color = '#b0b0b0';
                    sendCommentBtn.style.cursor = 'not-allowed';
                  }
                }
            });

        });

        document.addEventListener('click', (event) => {
            document.querySelectorAll('.post-options-dropdown.show').forEach(openDropdown => {
                const optionsContainer = openDropdown.closest('.post-options');
                if (optionsContainer && !optionsContainer.contains(event.target)) {
                    openDropdown.classList.remove('show');
                }
            });
        });

        postsContainer.scrollTop = postsContainer.scrollHeight;
      })
      .catch(error => {
            console.error("Error getting posts: ", error);
            if (postsContainer) postsContainer.innerHTML = `<p style="color: red; text-align: center;">Error loading announcements.</p>`;
        });
    }

// Edit Post Modal Functions
  // open modal
    function showForm(isModalMode) {
        if (announcementFormContainer && announcementModalBackdrop && announcementCard && postBtn) {
            announcementFormContainer.classList.add('show');
            if (isModalMode) {
                announcementFormContainer.classList.add('modal-mode');
                announcementModalBackdrop.classList.add('show');
                document.body.style.overflow = 'hidden';
                postBtn.textContent = 'Save Changes';
            } else {
                announcementFormContainer.classList.remove('modal-mode');
                announcementModalBackdrop.classList.remove('show');
                document.body.style.overflow = '';
                postBtn.textContent = 'Post';
            }
            announcementCard.style.display = 'none';

            setTimeout(function() {
                if (CKEDITOR.instances['announcement-text']) {
                    CKEDITOR.instances['announcement-text'].focus();
                    CKEDITOR.instances['announcement-text'].fire('change');
                } else if (textarea) {
                    textarea.dispatchEvent(new Event('input'));
                }
            }, 100);
            updatePostButtonState();
        }
    }
    // close modal
    function hideForm() {
        if (announcementFormContainer && announcementModalBackdrop && announcementCard && postBtn) {
            announcementFormContainer.classList.remove('show');
            announcementFormContainer.classList.remove('modal-mode');
            announcementModalBackdrop.classList.remove('show');
            document.body.style.overflow = '';
            announcementCard.style.display = 'flex';

            editingPostId = null;
            postBtn.textContent = 'Post';
            if (CKEDITOR.instances['announcement-text']) {
                CKEDITOR.instances['announcement-text'].setData('');
            } else if (textarea) {
                textarea.value = '';
            }
            currentAttachments = [];
            renderAttachmentsPreview();
            updatePostButtonState();
        }
    }

    // Edit Post Function
    function openEditPostForm(postId, postText, attachments = []) {
        editingPostId = postId;
        currentAttachments = attachments.map(att => ({ ...att, id: 'attachment-' + Date.now() + Math.random().toString(36).substr(2, 9) }));
        renderAttachmentsPreview();
        showForm(true);
        if (CKEDITOR.instances['announcement-text']) {
            CKEDITOR.instances['announcement-text'].setData(postText);
        } else if (textarea) {
            textarea.value = postText;
        }
    }

    // Delete Post Function
    function deletePost(postId) {
        if (confirm("Are you sure you want to delete this announcement? This action cannot be undone.")) {
            db.collection('lessons')
                .doc(lessonId)
                .collection('posts')
                .doc(postId)
                .delete()
                .then(() => {
                    console.log("Post successfully deleted!");
                    renderPostsFromFirestore();
                })
                .catch(error => {
                    console.error("Error removing post: ", error);
                    alert("Failed to delete announcement. Please try again.");
                });
        }
    }

    // student dropdown close
    function closeAllStudentDropdowns(event) {
    document.querySelectorAll('.person-options-dropdown.show').forEach(openDropdown => {
        const optionsContainer = openDropdown.closest('.person-options');
        if (optionsContainer && !optionsContainer.contains(event.target)) {
            openDropdown.classList.remove('show');
        }
    });
}

    function removeStudent(studentUid, studentName) {
        if (confirm(`Are you sure you want to remove ${studentName || 'this student'} from the class? This action cannot be undone.`)) {
            db.collection('lessons')
                .doc(lessonId)
                .collection('joinedStudents')
                .doc(studentUid)
                .delete()
                .then(() => {
                    console.log(`Student ${studentName} (${studentUid}) removed successfully!`);
                    renderPeopleSection();
                }).catch(error => {
                    console.error("Error removing student: ", error);
                    alert(`Failed to remove ${studentName || 'student'}. Please try again.`);
                });
        }
    }
    function renderPeopleSection() {
        if (!studentsPeopleList || !studentsState || !adminName) return;

        studentsPeopleList.innerHTML = '';
        studentsState.style.display = 'none';

        adminName.textContent = 'Loading Teacher...';

        db.collection('lessons').doc(lessonId)
            .get()
            .then(doc => {
            if (doc.exists) {
                const lessonData = doc.data();
                const creatorName = lessonData.createdBy && lessonData.createdBy.name
                                    ? lessonData.createdBy.name
                                    : 'Unknown Teacher';

                adminName.textContent = creatorName;

            } else {
                adminName.textContent = 'Lesson Not Found';
            }
        }).catch(error => {
            console.error("Error fetching lesson creator:", error);
            adminName.textContent = 'Error Loading Teacher';
        });

        db.collection('lessons')
            .doc(lessonId)
            .collection('joinedStudents')
            .get()
            .then(querySnapshot => {
                if (querySnapshot.empty) {
                    studentsState.style.display = 'flex';
                    if (!studentsPeopleList.contains(studentsState)) {
                    studentsPeopleList.appendChild(studentsState);
                    }
                } else {
                    studentsState.style.display = 'none';
                    querySnapshot.forEach(doc => {
                        const student = doc.data();
                        const studentUid = doc.id;
                        const studentEmail = student.email || '';
                        const studentName = student.userName || 'Anonymous Student';

                        const studentRow = document.createElement('div');
                        studentRow.className = 'person-row';

                        studentRow.setAttribute('data-student-uid', studentUid);
                        studentRow.setAttribute('data-student-email', studentEmail);
                        studentRow.setAttribute('data-student-name', studentName);

                        studentRow.innerHTML = `
                            <i class="fas fa-user-circle fa-2x"></i>
                            <span class="person-name">${student.userName}</span>
                            <div class="person-options">
                                <i class="fas fa-ellipsis-v"></i>
                                <ul class="person-options-dropdown">
                                <li class="remove-student-btn">Remove</li>
                                </ul>
                            </div>
                        `;
                        studentsPeopleList.appendChild(studentRow);

                        const optionsIcon = studentRow.querySelector('.person-options .fa-ellipsis-v');
                        const dropdownMenu = studentRow.querySelector('.person-options-dropdown');

                        if (optionsIcon && dropdownMenu) {
                            optionsIcon.addEventListener('click', (event) => {
                                document.querySelectorAll('.person-options-dropdown.show').forEach(openDropdown => {
                                    if (openDropdown !== dropdownMenu) {
                                        openDropdown.classList.remove('show');
                                    }
                                });
                                dropdownMenu.classList.toggle('show');
                                event.stopPropagation();
                            });

                            studentRow.querySelector('.remove-student-btn').addEventListener('click', (event) => {
                                dropdownMenu.classList.remove('show');
                                removeStudent(studentUid, studentName);
                                event.stopPropagation()
                            });
                        }
                    });
                    document.removeEventListener('click', closeAllStudentDropdowns);
                    document.addEventListener('click', closeAllStudentDropdowns);
                }
            }).catch(error => {
                console.error("Error fetching joined students:", error);
                studentsPeopleList.innerHTML = `<p style="color: red; text-align: center;">Error loading students.</p>`;
                studentsState.style.display = 'none';
            });
    }

    // Tab Switching Logic
    document.querySelectorAll('.lessons-tabs .tab').forEach(tab => {
      tab.addEventListener('click', function() {
        document.querySelectorAll('.lessons-tabs .tab').forEach(t => t.classList.remove('active'));
        this.classList.add('active');
        const selected = this.getAttribute('data-tab');

        document.getElementById('tab-content-stream').style.display = selected === 'stream' ? '' : 'none';
        document.getElementById('tab-content-progress').style.display = selected === 'progress' ? '' : 'none';
        document.getElementById('tab-content-people').style.display = selected === 'people' ? '' : 'none';

        if (selected === 'stream') {
                document.getElementById('tab-content-stream').style.display = '';
            } else if (selected === 'progress') {
                document.getElementById('tab-content-progress').style.display = '';
            } else if (selected === 'people') {
                document.getElementById('tab-content-people').style.display = '';
                renderPeopleSection();
            }
        });
    });

    renderPostsFromFirestore();

}); // firebase EnD

  // Sidebar Toggle
  function toggleSidebar(element) {
    const sidebar = document.querySelector('.sidebar');
    sidebar.classList.toggle('open');

    // Toggle the icon between bars and times
    const icon = element.querySelector('i');
    if (sidebar.classList.contains('open')) {
      icon.classList.remove('fa-bars');
      icon.classList.add('fa-times');
    } else {
      icon.classList.remove('fa-times');
      icon.classList.add('fa-bars');
    }
  }
