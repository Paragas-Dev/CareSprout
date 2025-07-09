# Custom CKEditor 4 Implementation Guide

This guide shows how to implement and customize CKEditor 4 in your Laravel application.

## 🚀 What's Been Implemented

### **1. Custom CKEditor Configuration**
- **File**: `public/js/ckeditor-config.js`
- **Features**: Custom toolbar, styling, image upload, and event handling

### **2. Custom CSS Styling**
- **File**: `public/css/ckeditor-custom.css`
- **Features**: Matches your app's design, responsive design, custom fonts

### **3. Image Upload System**
- **Route**: `/upload-image`
- **Controller**: `PageController@uploadImage`
- **Storage**: Files stored in `storage/app/public/uploads/`

### **4. Integration with Announcement Form**
- **File**: `resources/views/partials/announcement-form.blade.php`
- **Features**: Rich text editing with custom toolbar

## 📁 File Structure

```
public/
├── ckeditor/                    # CKEditor 4 files
│   ├── ckeditor.js
│   ├── config.js
│   └── ...
├── css/
│   └── ckeditor-custom.css     # Custom styling
├── js/
│   └── ckeditor-config.js      # Custom configuration
└── storage/                    # Uploaded files
    └── uploads/
```

## ⚙️ Configuration Options

### **Basic Configuration**
```javascript
{
    height: 120,                    // Editor height
    width: '100%',                  // Editor width
    removeButtons: 'Save,NewPage',  // Remove unwanted buttons
    removePlugins: 'elementspath',  // Remove unwanted plugins
}
```

### **Custom Toolbar**
```javascript
toolbar: [
    { name: 'basicstyles', items: ['Bold', 'Italic', 'Underline'] },
    { name: 'paragraph', items: ['NumberedList', 'BulletedList'] },
    { name: 'links', items: ['Link', 'Unlink'] },
    { name: 'insert', items: ['Image', 'Table'] },
    { name: 'colors', items: ['TextColor', 'BGColor'] }
]
```

### **Font Settings**
```javascript
font_names: 'Arial;Times New Roman;Verdana;Roboto',
font_size_sizes: '8/8px;12/12px;16/16px;20/20px;24/24px'
```

### **Color Palette**
```javascript
colorButton_colors: '000,800000,8B4513,2F4F4F,008080,000080,4B0082'
```

## 🎨 Customization Examples

### **1. Add Custom Button**
```javascript
// In ckeditor-config.js
CKEDITOR.plugins.add('customButton', {
    init: function(editor) {
        editor.addCommand('customCommand', {
            exec: function(editor) {
                // Your custom functionality
                alert('Custom button clicked!');
            }
        });
        
        editor.ui.addButton('CustomButton', {
            label: 'Custom Button',
            command: 'customCommand',
            toolbar: 'insert'
        });
    }
});
```

### **2. Custom Event Handling**
```javascript
on: {
    instanceReady: function(evt) {
        console.log('Editor is ready!');
        this.focus();
    },
    
    change: function(evt) {
        const content = this.getData();
        // Handle content changes
    },
    
    blur: function(evt) {
        // Handle when editor loses focus
    }
}
```

### **3. Custom Styling**
```css
/* In ckeditor-custom.css */
.cke_chrome {
    border: 1px solid #e0e0e0 !important;
    border-radius: 8px !important;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1) !important;
}

.cke_editable {
    font-family: 'Roboto', Arial, sans-serif !important;
    font-size: 14px !important;
    line-height: 1.6 !important;
}
```

## 🔧 Usage Examples

### **1. Basic Implementation**
```html
<textarea id="my-editor"></textarea>
<script>
    initCKEditor('my-editor');
</script>
```

### **2. Custom Configuration**
```html
<textarea id="my-editor"></textarea>
<script>
    initCKEditor('my-editor', {
        height: 200,
        toolbar: [
            { name: 'basicstyles', items: ['Bold', 'Italic'] }
        ]
    });
</script>
```

### **3. Get/Set Content**
```javascript
// Get content
const content = getCKEditorContent('my-editor');

// Set content
setCKEditorContent('my-editor', '<p>New content</p>');
```

### **4. Form Submission**
```javascript
document.getElementById('my-form').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const content = getCKEditorContent('announcement-text');
    
    // Send to server
    fetch('/submit-announcement', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ content: content })
    });
});
```

## 🖼️ Image Upload Configuration

### **1. Upload Route**
```php
Route::post('/upload-image', [PageController::class, 'uploadImage'])->name('upload.image');
```

### **2. Controller Method**
```php
public function uploadImage(Request $request)
{
    if ($request->hasFile('upload')) {
        $file = $request->file('upload');
        
        // Validate
        $request->validate([
            'upload' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);
        
        // Store
        $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs('uploads', $filename, 'public');
        
        // Return CKEditor format
        return response()->json([
            'uploaded' => 1,
            'fileName' => $filename,
            'url' => asset('storage/' . $path)
        ]);
    }
}
```

### **3. CKEditor Configuration**
```javascript
filebrowserUploadUrl: '/upload-image',
filebrowserUploadMethod: 'form'
```

## 🎯 Available Toolbar Items

### **Basic Styles**
- `Bold`, `Italic`, `Underline`, `Strike`
- `Subscript`, `Superscript`

### **Paragraph**
- `NumberedList`, `BulletedList`
- `Outdent`, `Indent`
- `Blockquote`, `CreateDiv`

### **Links**
- `Link`, `Unlink`, `Anchor`

### **Insert**
- `Image`, `Flash`, `Table`
- `HorizontalRule`, `Smiley`
- `SpecialChar`, `PageBreak`

### **Colors**
- `TextColor`, `BGColor`

### **Tools**
- `Maximize`, `ShowBlocks`
- `Source`

## 🔒 Security Considerations

### **1. File Upload Security**
```php
// Validate file types and size
$request->validate([
    'upload' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
]);

// Generate unique filenames
$filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
```

### **2. Content Sanitization**
```php
// In your controller
$content = strip_tags($request->content, '<p><br><strong><em><u><s><ul><ol><li><a><img><table><tr><td><th>');
```

### **3. CSRF Protection**
```html
<meta name="csrf-token" content="{{ csrf_token() }}">
```

## 🚀 Performance Tips

### **1. Lazy Loading**
```javascript
// Load CKEditor only when needed
document.getElementById('show-editor').addEventListener('click', function() {
    if (!CKEDITOR.instances['my-editor']) {
        initCKEditor('my-editor');
    }
});
```

### **2. Destroy Instances**
```javascript
// Clean up when done
if (CKEDITOR.instances['my-editor']) {
    CKEDITOR.instances['my-editor'].destroy();
}
```

### **3. Optimize Configuration**
```javascript
// Remove unused plugins
removePlugins: 'elementspath,resize,about,showblocks'
```

## 🐛 Troubleshooting

### **Common Issues**

1. **Editor not loading**
   - Check if CKEditor files are in correct location
   - Verify script paths in HTML

2. **Image upload not working**
   - Check storage link: `php artisan storage:link`
   - Verify upload directory permissions
   - Check CSRF token

3. **Styling issues**
   - Ensure custom CSS is loaded
   - Check for CSS conflicts
   - Use browser dev tools to inspect

4. **Content not saving**
   - Verify form submission
   - Check server-side validation
   - Ensure proper content sanitization

## 📚 Additional Resources

- [CKEditor 4 Documentation](https://ckeditor.com/docs/ckeditor4/latest/)
- [CKEditor 4 API Reference](https://ckeditor.com/docs/ckeditor4/latest/api/)
- [CKEditor 4 Configuration](https://ckeditor.com/docs/ckeditor4/latest/guide/dev_configuration.html) 