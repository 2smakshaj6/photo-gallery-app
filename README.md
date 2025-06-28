# Company Photo Gallery App

A Flutter web application for internal photo sharing within a company. Employees can upload photos, like, and comment on shared images.

## Features

- **Netflix-style Photo Grid**: Responsive grid layout with modern card design
- **Photo Upload**: Upload PNG/JPG images with user information
- **Like System**: Like/unlike photos with real-time updates
- **Comments**: Add comments to photos with user attribution
- **User Management**: Local storage of user name and department code
- **Dark Theme**: Modern Netflix-inspired dark UI
- **Real-time Updates**: Live updates using Firebase Firestore

## Tech Stack

- **Frontend**: Flutter 3.22+ (Web)
- **Backend**: Firebase
  - Firestore (Database)
  - Firebase Storage (Image storage)
- **State Management**: Riverpod
- **Local Storage**: SharedPreferences

## Setup Instructions

### 1. Prerequisites

- Flutter SDK 3.22 or later
- Firebase account
- Web browser for testing

### 2. Firebase Setup

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Firestore Database
   - Enable Firebase Storage

2. **Configure Firestore**:
   - Go to Firestore Database
   - Create database in test mode (for development)
   - Set up security rules:

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

3. **Configure Storage**:
   - Go to Storage
   - Create storage bucket
   - Set up security rules:

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

4. **Configure CORS for Firebase Storage (Crucial for Web)**:
   - You need the `gsutil` command-line tool. [Install Google Cloud SDK](https://cloud.google.com/sdk/docs/install) if you don't have it.
   - Create a file named `cors.json` with the following content:
       ```json
       [
         {
           "origin": ["*"],
           "method": ["GET"],
           "maxAgeSeconds": 3600
         }
       ]
       ```
       *Note: For production, you should replace `"*"` with your web app's domain (e.g., `"https://your-app-name.web.app"`).*
   - Run the following command, replacing `YOUR_BUCKET_NAME` with your Firebase Storage bucket URL (e.g., `gs://photo-gallery-app-49bf3.appspot.com`):
       ```bash
       gsutil cors set cors.json gs://YOUR_BUCKET_NAME
       ```

5. **Get Firebase Config**:
   - Go to Project Settings
   - Add Web App
   - Copy the configuration

### 3. Update Firebase Configuration

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  authDomain: 'YOUR_ACTUAL_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_ACTUAL_PROJECT_ID.appspot.com',
  measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID',
);
```

### 4. Install Dependencies

```bash
cd photo_gallery_app
flutter pub get
```

### 5. Run the Application

#### For Web Development:
```bash
flutter run -d chrome
```

#### For Production Build:
```bash
flutter build web
```

The built files will be in `build/web/` directory.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   ├── photo.dart           # Photo data model
│   ├── comment.dart         # Comment data model
│   └── user_info.dart       # User information model
├── services/
│   ├── firebase_service.dart # Firebase operations
│   └── local_storage_service.dart # Local storage operations
├── providers/
│   └── app_providers.dart   # Riverpod state management
├── screens/
│   ├── landing_screen.dart  # Main photo grid screen
│   └── upload_screen.dart   # Photo upload screen
└── widgets/
    ├── photo_grid.dart      # Photo grid widget
    ├── photo_detail_modal.dart # Photo detail modal
    └── user_info_dialog.dart # User info input dialog
```

## Usage

1. **First Time Setup**:
   - Enter your name and department code
   - This information is stored locally and used for all actions

2. **Uploading Photos**:
   - Click the "Upload" button or use the menu
   - Select an image from your device
   - Click "Upload Photo"

3. **Viewing Photos**:
   - Photos are displayed in a responsive grid
   - Click any photo to view details and comments

4. **Liking Photos**:
   - Click the heart icon on any photo
   - Like count updates in real-time

5. **Adding Comments**:
   - Open a photo detail view
   - Type your comment and press Enter or click Send

## Features in Detail

### Photo Grid
- Responsive 3-column grid layout
- Netflix-style card design with hover effects
- Shows uploader info, like count, and timestamp
- Optimized image loading with placeholders

### Photo Upload
- Drag and drop or click to select
- Image compression and optimization
- Progress indicators and error handling
- Automatic file naming with timestamps

### Real-time Updates
- Live photo feed updates
- Real-time like count changes
- Instant comment updates
- Optimistic UI updates

### User Experience
- Dark theme with Netflix-inspired design
- Smooth animations and transitions
- Responsive design for different screen sizes
- Error handling with user-friendly messages

## Security Considerations

⚠️ **Important**: For a production app, you must implement proper security. The rules below are a good starting point once you add authentication.

### Production Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Requires user to be authenticated to read or write
    match /photos/{photoId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;

      // Allow owner to update or delete
      allow update, delete: if request.auth.uid == resource.data.uploaderUid;

      match /comments/{commentId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;

        // Allow owner to update or delete their comment
        allow update, delete: if request.auth.uid == resource.data.commenterUid;
      }
    }
  }
}
```

### Production Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /photos/{fileName} {
      // Allow reads if the user is authenticated
      allow read: if request.auth != null;
      
      // Allow writes only for authenticated users, for files under 5MB, and of image type
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Deployment

### Firebase Hosting (Recommended)

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Initialize Firebase Hosting:
```bash
firebase init hosting
```

4. Build and deploy:
```bash
flutter build web
firebase deploy
```

### Other Hosting Options

- **Netlify**: Drag and drop `build/web/` folder
- **Vercel**: Connect GitHub repository
- **GitHub Pages**: Push `build/web/` to gh-pages branch

## Troubleshooting

### Common Issues

1. **Firebase not initialized**:
   - Check `firebase_options.dart` configuration
   - Ensure Firebase project is properly set up

2. **Images not loading (CORS Error)**:
   - This is the most common issue for web apps.
   - You **must** configure CORS on your Firebase Storage bucket. See the "Firebase Setup" section above for instructions.
   - Verify Firebase Storage rules allow read access.

3. **Real-time updates not working**:
   - Check Firestore rules
   - Verify internet connection

4. **Upload failures**:
   - Check file size limits
   - Verify Firebase Storage configuration

### Debug Mode

Run with debug flags for more information:
```bash
flutter run -d chrome --verbose
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
