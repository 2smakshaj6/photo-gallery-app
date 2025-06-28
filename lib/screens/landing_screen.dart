import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../widgets/photo_grid.dart';
import 'upload_screen.dart';
import 'login_screen.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosProvider);
    final authState = ref.watch(currentUserProvider);
    final authService = ref.read(authServiceProvider);

    return authState.when(
      data: (user) {
        final isAdmin = user?.email == AuthService.adminEmail;
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Stack(
                children: [
                  // Blurred gradient background
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.withOpacity(0.85),
                            Colors.pinkAccent.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  // AppBar content
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Row(
                      children: [
                        Text(
                          'Pixel Perspective',
                          style: GoogleFonts.pacifico(
                            textStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF3EFFF),
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.4),
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.red[400], size: 18),
                                const SizedBox(width: 6),
                                const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      if (isAdmin) ...[
                        // Admin info and logout
                        PopupMenuButton<String>(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.red[400]),
                                const SizedBox(width: 8),
                                Text(
                                  user?.email ?? 'Admin',
                                  style: TextStyle(
                                    color: Colors.red[400],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'admin_info',
                              child: Row(
                                children: [
                                  const Icon(Icons.info, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text('Admin Panel Active'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  const Icon(Icons.logout, color: Colors.red),
                                  const SizedBox(width: 8),
                                  const Text('Logout'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'logout') {
                              await authService.signOut();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.logout, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Admin logged out successfully'),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ] else ...[
                        // Admin login button
                        TextButton.icon(
                          onPressed: () => _showAdminLoginDialog(context, ref),
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                repeat: ImageRepeat.repeat,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Admin status banner
                  if (isAdmin)
                    MaterialBanner(
                      backgroundColor: Colors.red.withOpacity(0.08),
                      content: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.red[400], size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Admin Mode: You can see all user information and moderate content',
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: const [SizedBox.shrink()],
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    ),
                  // Photos content
                  Expanded(
                    child: photosAsync.when(
                      data: (photos) => photos.isEmpty
                          ? const Center(
                              child: Text(
                                'No photos yet. Be the first to upload!',
                                style: TextStyle(fontSize: 18, color: Colors.white70),
                              ),
                            )
                          : PhotoGrid(photos: photos),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(
                        child: Text('Error: ${e.toString()}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadScreen()),
              );
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Upload'),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const LoginScreen(),
    );
  }

  void _showAdminLoginDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final authService = ref.read(authServiceProvider);
    final formKey = GlobalKey<FormState>();
    ValueNotifier<String?> errorText = ValueNotifier(null);
    ValueNotifier<bool> isLoading = ValueNotifier(false);
    ValueNotifier<bool> showPassword = ValueNotifier(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Login'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Admin Email',
                    hintText: 'Enter admin email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                  enabled: !isLoading.value,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: showPassword,
                  builder: (context, isVisible, child) {
                    return TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () => showPassword.value = !isVisible,
                          tooltip: isVisible ? 'Hide password' : 'Show password',
                        ),
                      ),
                      obscureText: !isVisible,
                      validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                      enabled: !isLoading.value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String?>(
                  valueListenable: errorText,
                  builder: (context, value, child) => value == null
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading.value ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                return ElevatedButton(
                  onPressed: loading ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    isLoading.value = true;
                    errorText.value = null;
                    
                    try {
                      await authService.signInWithEmailAndPassword(
                        emailController.text.trim(),
                        passwordController.text,
                      );
                      
                      // Check if login was successful and user is admin
                      final user = authService.currentUser;
                      if (user?.email == AuthService.adminEmail) {
                        Navigator.pop(context);
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('Welcome, Admin ${user?.email}!'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        // User logged in but is not admin
                        await authService.signOut();
                        errorText.value = 'Access denied. This account is not an admin.';
                      }
                    } catch (e) {
                      String errorMessage = 'Login failed';
                      
                      if (e.toString().contains('user-not-found')) {
                        errorMessage = 'No admin account found with this email';
                      } else if (e.toString().contains('wrong-password')) {
                        errorMessage = 'Incorrect password';
                      } else if (e.toString().contains('invalid-email')) {
                        errorMessage = 'Invalid email format';
                      } else if (e.toString().contains('too-many-requests')) {
                        errorMessage = 'Too many failed attempts. Please try again later.';
                      } else if (e.toString().contains('network')) {
                        errorMessage = 'Network error. Please check your connection.';
                      } else {
                        errorMessage = 'Login failed: ${e.toString().replaceAll('Exception:', '').trim()}';
                      }
                      
                      errorText.value = errorMessage;
                    } finally {
                      isLoading.value = false;
                    }
                  },
                  child: loading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
                );
              },
            ),
          ],
        );
      },
    );
  }
} 