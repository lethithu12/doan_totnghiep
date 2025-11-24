import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Check if user is admin (based on email or role in database)
  bool get isAdmin {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.email?.toLowerCase().contains('admin') ?? false;
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUserData(user.uid);
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi: ${e.toString()}';
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phone,
    String? address,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw 'Không thể tạo tài khoản. Vui lòng thử lại.';
      }

      // Update display name if provided
      if (displayName != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      // Determine role based on email
      final isAdminEmail = email.toLowerCase().contains('admin');
      final role = isAdminEmail ? 'admin' : 'user';

      // Create user data model
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName,
        phone: phone,
        address: address,
        role: role,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      // Save user data to Cloud Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi: ${e.toString()}';
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData({
    required String uid,
    String? displayName,
    String? phone,
    String? address,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (displayName != null) {
        updates['displayName'] = displayName;
      }
      if (phone != null) {
        updates['phone'] = phone;
      }
      if (address != null) {
        updates['address'] = address;
      }

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw 'Không thể cập nhật thông tin: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Đã xảy ra lỗi khi đăng xuất: ${e.toString()}';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi: ${e.toString()}';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng. Vui lòng thử lại.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Thao tác này không được phép.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      default:
        return 'Đã xảy ra lỗi: ${e.message ?? e.code}';
    }
  }
}
