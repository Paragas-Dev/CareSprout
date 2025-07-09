# Firebase Configuration Setup

This document explains how Firebase is configured in the CareSprout application to ensure it's only initialized once and can be used across all Blade templates.

## Overview

The application now uses a centralized Firebase configuration system that:
- Initializes Firebase only once
- Provides global access to Firebase services
- Uses an event-driven system to ensure Firebase is ready before use
- Eliminates duplicate initialization across multiple pages

## Files Structure

### Core Configuration
- `public/js/firebase-config.js` - Centralized Firebase configuration and initialization
- `resources/views/test-firebase.blade.php` - Test page to verify Firebase setup
- `public/js/test-firebase.js` - Test script for Firebase functionality

### Updated Files
The following files have been updated to use the centralized configuration:

#### Layout Files
- `resources/views/layouts/teacher.blade.php`
- `resources/views/layouts/principal.blade.php`
- `resources/views/layouts/mswd.blade.php`

#### Page Files
- `resources/views/auth/login.blade.php`
- `resources/views/admin/create-admin.blade.php`
- `resources/views/layouts/add.blade.php`
- `resources/views/dashboard/home.blade.php`
- `resources/views/lessons/lesson-stream.blade.php`
- `resources/views/management/approval.blade.php`

#### Partial Files
- `resources/views/partials/header.blade.php`
- `resources/views/partials/sidebar.blade.php`

#### JavaScript Files
- `public/js/sidebar-lessons.js`

## How It Works

### 1. Centralized Configuration (`firebase-config.js`)

The `firebase-config.js` file:
- Contains the Firebase configuration object
- Checks if Firebase is already initialized
- Loads Firebase SDKs if not already loaded
- Initializes Firebase only once
- Sets up global references (`window.auth`, `window.db`)
- Dispatches a `firebaseReady` event when Firebase is ready

### 2. Event-Driven Usage

All Firebase-dependent code now:
- Listens for the `firebaseReady` event
- Uses global references (`window.auth`, `window.db`)
- Ensures Firebase is ready before executing

Example:
```javascript
window.addEventListener('firebaseReady', function() {
    const auth = window.auth;
    const db = window.db;
    
    // Your Firebase code here
    db.collection('users').get().then(snapshot => {
        // Handle data
    });
});
```

### 3. Global References

After Firebase is initialized, the following global references are available:
- `window.auth` - Firebase Authentication instance
- `window.db` - Firestore Database instance
- `window.firebaseConfig` - Firebase configuration object

## Testing

To test the Firebase configuration:

1. Visit `/test-firebase` in your browser
2. Check the console for detailed logs
3. Verify all status indicators show success

## Benefits

1. **Single Initialization**: Firebase is initialized only once, preventing conflicts
2. **Consistent Access**: All pages use the same Firebase instances
3. **Event-Driven**: Code waits for Firebase to be ready before executing
4. **Maintainable**: Configuration is centralized in one place
5. **Performance**: Reduces duplicate SDK loading and initialization

## Migration Notes

If you need to add Firebase functionality to new pages:

1. Include the centralized configuration:
   ```html
   <script src="{{ asset('js/firebase-config.js') }}"></script>
   ```

2. Wrap Firebase-dependent code in the event listener:
   ```javascript
   window.addEventListener('firebaseReady', function() {
       const auth = window.auth;
       const db = window.db;
       
       // Your Firebase code here
   });
   ```

3. Use global references instead of creating new instances

## Troubleshooting

### Firebase not initializing
- Check browser console for errors
- Verify Firebase credentials are correct
- Ensure `firebase-config.js` is loaded before any Firebase code

### Event not firing
- Make sure `firebase-config.js` is included in the page
- Check that the event listener is added before the script loads
- Verify no JavaScript errors are preventing execution

### Global references not available
- Wait for the `firebaseReady` event
- Use `window.auth` and `window.db` instead of local variables
- Check that Firebase SDKs are loaded properly 