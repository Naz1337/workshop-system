import 'package:firebase_auth/firebase_auth.dart';
import 'package:workshop_system/models/app_user_model.dart';
import 'package:workshop_system/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService;

  AuthService({required FirestoreService firestoreService}) : _firestoreService = firestoreService;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  get currentUser => null;

  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      throw Exception(e.message); // Re-throw other exceptions
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> deleteCurrentUserAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'This operation is sensitive and requires recent authentication. Please re-authenticate before trying again.',
        );
      }
      throw Exception('Failed to delete account: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  Future<void> reauthenticateUser(String email, String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception('Re-authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Re-authentication failed: ${e.toString()}');
    }
  }

  Future<AppUser?> getCurrentAppUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestoreService.getDocument(
        collectionPath: 'users',
        documentId: user.uid,
      );
      return AppUser.fromFirestore(doc);
    } catch (e) {
      print('Error getting current AppUser: $e');
      return null;
    }
  }

  Future<bool> isWorkshopOwner() async {
    try {
      final appUser = await getCurrentAppUser();
      return appUser?.role == 'workshop_owner';
    } catch (e) {
      print('Error checking if workshop owner: $e');
      return false;
    }
  }

  Future<bool> isForeman() async {
    try {
      final appUser = await getCurrentAppUser();
      return appUser?.role == 'foreman';
    } catch (e) {
      print('Error checking if foreman: $e');
      return false;
    }
  }

  Future<String?> getCurrentForemanId() async {
    try {
      if (await isForeman()) {
        return _firebaseAuth.currentUser?.uid;
      }
      return null;
    } catch (e) {
      print('Error getting current foreman ID: $e');
      return null;
    }
  }
}
