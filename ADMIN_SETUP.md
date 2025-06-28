# Admin Setup Guide

## Setting Up Admin Authentication

### 1. Create Admin Account in Firebase

1. Go to your Firebase Console
2. Navigate to Authentication > Users
3. Click "Add User"
4. Enter the admin email: `admin@example.com` (or change this in `lib/services/auth_service.dart`)
5. Set a secure password
6. Click "Add User"

### 2. Test Admin Login

1. Run your Flutter app: `flutter run -d chrome`
2. Click the "Login" button in the top right
3. Enter the admin credentials:
   - Email: `admin@example.com`
   - Password: (the password you set in Firebase)
4. Click "Login"

### 3. Verify Admin Access

When logged in as admin, you should see:

- **Red "ADMIN" badge** next to the app title
- **Admin banner** at the top: "Admin Mode: You can see all user information and moderate content"
- **Admin email** in the top right with a dropdown menu
- **Real user names and NTIDs** instead of "Anonymous" in photo details
- **Edit/Delete buttons** on all photos and comments
- **"ADMIN" indicators** on all admin actions

### 4. Admin Features

As an admin, you can:

- **View real user information**: See actual names and NTIDs instead of "Anonymous"
- **Edit any photo**: Change descriptions or replace images
- **Delete any photo**: Remove inappropriate content
- **Delete any comment**: Moderate the community
- **See admin indicators**: Clear visual feedback for all admin actions

### 5. Testing Admin Functionality

1. **Upload a photo** as a regular user (without logging in)
2. **Log in as admin** using the credentials above
3. **Verify you can see** the real name and NTID of the uploader
4. **Test edit functionality** by clicking the edit button on a photo
5. **Test delete functionality** by clicking the delete button
6. **Add comments** and test comment moderation

### 6. Troubleshooting

**If admin login fails:**
- Check that the email matches exactly in `lib/services/auth_service.dart`
- Verify the user exists in Firebase Authentication
- Check the password is correct
- Look for error messages in the login dialog

**If admin features don't work:**
- Ensure you're logged in with the correct admin email
- Check the browser console for any errors
- Verify Firebase configuration is correct

### 7. Customizing Admin Email

To change the admin email, edit `lib/services/auth_service.dart`:

```dart
static const String adminEmail = 'your-admin-email@example.com';
```

Then create a new user in Firebase with that email address.

### 8. Security Notes

- Keep the admin password secure
- Consider using environment variables for the admin email in production
- Regularly review admin actions in Firebase logs
- Consider implementing additional security measures for production use 