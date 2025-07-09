<!-- Create Class Modal -->
<div id="createClassModal" class="class-modal">
  <div class="class-modal-content">
    <h2 class="class-modal-title">Create lesson</h2>
    <form id="createClassForm" autocomplete="off" class="class-modal-form">
        <div>
            <input id="classNameInput" type="text" placeholder="Lesson name (required)" class="class-modal-input class-modal-input-main" required />
        </div>
        <div>
            <label class="class-modal-label">Select theme color</label>
            <div class="class-modal-color-row">
            <div class="class-modal-color-circle" data-color="#dbeafe" style="border-color:#3b82f6;background:#dbeafe;"></div>
            <div class="class-modal-color-circle" data-color="#d1fae5" style="border-color:#10b981;background:#d1fae5;"></div>
            <div class="class-modal-color-circle" data-color="#fde7f3" style="border-color:#ec4899;background:#fde7f3;"></div>
            <div class="class-modal-color-circle" data-color="#fef3c7" style="border-color:#f59e42;background:#fef3c7;"></div>
            <div class="class-modal-color-circle" data-color="#cffafe" style="border-color:#06b6d4;background:#cffafe;"></div>
            <div class="class-modal-color-circle" data-color="#ede9fe" style="border-color:#a78bfa;background:#ede9fe;"></div>
            <div class="class-modal-color-circle" data-color="#f3f4f6" style="border-color:#6b7280;background:#f3f4f6;"></div>
            </div>
        </div>
        <div class="class-modal-actions">
            <button type="button" id="cancelCreateClass" class="class-modal-cancel">Cancel</button>
            <button type="submit" id="submitCreateClass" class="class-modal-submit" disabled>Create</button>
        </div>
    </form>
  </div>
</div> 