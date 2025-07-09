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
      data-placeholder="Announce something to your class"
    ></div>
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
    <button type="button"><img src="{{ asset('images/google-drive.png') }}" alt="Google Drive" class="button-icon"></button>
    <button type="button"><img src="{{ asset('images/youtube.png') }}" alt="" class="button-icon"></button>
    <button type="button"><img src="{{ asset('images/Upload.png') }}" alt="Upload" class="button-icon"></button>
    <button type="button"><img src="{{ asset('images/Link.png') }}" alt="Link" class="button-icon"></button>
  </div>
  <div class="actions-row">
    <button type="button" id="cancel-announcement">Cancel</button>
    <button type="submit" id="post-announcement" disabled>Post</button>
  </div>
</form>

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