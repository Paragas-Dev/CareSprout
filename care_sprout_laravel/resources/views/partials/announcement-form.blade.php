<form id="new-announcement-form">
  <div class="form-label">For</div>
  <div class="form-row">
    <button type="button" class="students-btn">
      <i class="fas fa-users"></i> All students
    </button>
  </div>
  <div class="custom-editor">
    <div
      id="announcement-editor"
      class="editor-content"
      contenteditable="true"
      data-placeholder="Announce something to your class">
    </div>
    <div id="attached-files-container" class="attached-files-container">
        {{-- Attached file chips will be appended here dynamically by JS --}}
    </div>
    <div class="editor-toolbar">
      <button type="button" data-command="bold" title="Bold"><b>B</b></button>
      <button type="button" data-command="italic" title="Italic"><i>I</i></button>
      <button type="button" data-command="underline" title="Underline"><u>U</u></button>
      <button type="button" data-command="insertUnorderedList" title="Bulleted List">&#8226;</button>
      <button type="button" data-command="strikeThrough" title="Strikethrough"><s>S</s></button>
    </div>
  </div>
  <input type="hidden" name="announcement-text" id="announcement-text">
  <div class="attachments-row">
    <button type="button" id="youtube-btn" title="Add YouTube video"><img src="{{ asset('images/youtube.png') }}" alt="YouTube" class="button-icon"></button>
    <button type="button" id="cloudinary-upload-btn" title="Upload from computer"><img src="{{ asset('images/Upload.png') }}" alt="Upload" class="button-icon"></button>
    <button type="button" id="link-btn" title="Add Link"><img src="{{ asset('images/Link.png') }}" alt="Link" class="button-icon"></button>
  </div>

    <div id="upload-status" style="font-size: 0.9em; color: #555; margin-top: 10px;"></div>

    <div id="link-modal" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <h2>Insert Link</h2>
            <input type="url" id="link-url-input" placeholder="Enter URL" class="modal-input">
            <input type="text" id="link-text-input" placeholder="Link text (optional)" class="modal-input">
            <div class="modal-actions">
                <button type="button" id="cancel-link" class="cancel-btn">Cancel</button>
                <button type="button" id="insert-link" class="post-btn">Insert</button>
            </div>
        </div>
    </div>

    <div id="youtube-modal" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <h2>Insert YouTube Video</h2>
            <input type="url" id="youtube-url-input" placeholder="Enter YouTube Video URL" class="modal-input">
            <div class="modal-actions">
                <button type="button" id="cancel-youtube" class="cancel-btn">Cancel</button>
                <button type="button" id="insert-youtube" class="post-btn">Insert</button>
            </div>
        </div>
    </div>
  <div class="actions-row">
    <button type="button" id="cancel-announcement">Cancel</button>
    <button type="submit" id="post-announcement" disabled>Post</button>
  </div>
</form>

<script src="https://cdn.ckeditor.com/4.25.1-lts/standard/ckeditor.js"></script>
<script>
    const editor = document.getElementById('announcement-editor');
    document.querySelectorAll('.editor-toolbar button').forEach(btn => {
    btn.addEventListener('click', function() {
        document.execCommand(this.dataset.command, false, null);
        editor.focus();
    });
    });

    // Post button
    editor.addEventListener('input', function() {
    const postBtn = document.getElementById('post-announcement');
    if (editor.textContent.trim() !== '' && editor.innerHTML.trim() !== '') {
        postBtn.disabled = false;
        postBtn.style.opacity = 1;
        postBtn.style.cursor = 'pointer';
        postBtn.style.background = '#1a73e8';
        postBtn.style.color = '#fff';
    } else {
        postBtn.disabled = true;
        postBtn.style.opacity = 0.7;
        postBtn.style.cursor = 'not-allowed';
        postBtn.style.background = '#e3e3e3';
        postBtn.style.color = '#b0b0b0';
    }
    });
    const form = document.getElementById('new-announcement-form');
    form.addEventListener('submit', function(e) {
    document.getElementById('announcement-text').value = editor.innerHTML;
    });
</script>
