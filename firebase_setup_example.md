# Firebase Setup Example

This file shows you how to configure Firebase for the Photo Gallery App.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: "photo-gallery-app"
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Services

### Firestore Database
1. Go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

### Storage
1. Go to "Storage" in the left sidebar
2. Click "Get started"
3. Choose "Start in test mode" (for development)
4. Select the same location as Firestore
5. Click "Done"

## Step 3: Configure Security Rules

### Firestore Rules
Go to Firestore Database > Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /photos/{photoId} {
      allow read, write: if true;
      match /comments/{commentId} {
        allow read, write: if true;
      }
    }
  }
}
```

### Storage Rules
Go to Storage > Rules and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

## Step 4: Add Web App

1. Go to Project Settings (gear icon)
2. Scroll down to "Your apps"
3. Click the web icon (</>)
4. Enter app nickname: "Photo Gallery Web"
5. Click "Register app"
6. Copy the configuration

## Step 5: Update Firebase Config

Replace the values in `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyC...', // Your actual API key
  appId: '1:123456789:web:abc123', // Your actual app ID
  messagingSenderId: '123456789', // Your actual sender ID
  projectId: 'your-project-id', // Your actual project ID
  authDomain: 'your-project-id.firebaseapp.com', // Your actual auth domain
  storageBucket: 'your-project-id.appspot.com', // Your actual storage bucket
  measurementId: 'G-ABC123', // Your actual measurement ID
);
```

## Step 6: Test the App

1. Run the app: `flutter run -d chrome`
2. Enter your name and department code
3. Upload a test photo
4. Verify it appears in the grid
5. Test liking and commenting

## Production Considerations

⚠️ **Important**: The current rules allow public access. For production:

1. **Add Authentication**: Implement Firebase Auth
2. **Restrict Access**: Update rules to require authentication
3. **Rate Limiting**: Add upload limits
4. **Content Moderation**: Validate images
5. **Backup**: Set up regular backups

Example production Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /photos/{photoId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.auth.token.email_verified == true;
      match /comments/{commentId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null 
          && request.auth.token.email_verified == true;
      }
    }
  }
}
```

Example production Storage rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /photos/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.auth.token.email_verified == true
        && request.resource.size < 10 * 1024 * 1024 // 10MB limit
        && request.resource.contentType.matches('image/.*');
    }
  }
}
``` 