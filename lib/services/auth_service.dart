import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Define admin email - you can change this to your admin's email
  static const String adminEmail = 'gowripooja.alamuri@in.bosch.com';
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if current user is admin
  bool get isAdmin => currentUser?.email == adminEmail;
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
  
  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get user display name or email
  String getUserDisplayName() {
    final user = currentUser;
    if (user == null) return 'Anonymous';
    return user.displayName ?? user.email ?? 'Anonymous';
  }
  
  // Get user email
  String? getUserEmail() {
    return currentUser?.email;
  }
}

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider for admin status
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.email == AuthService.adminEmail;
}); 