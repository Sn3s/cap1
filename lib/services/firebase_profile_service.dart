part of '../main.dart';

class FirebaseProfileService {
  const FirebaseProfileService._();

  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  static DocumentReference<Map<String, dynamic>> _profileRef(String uid) {
    return _firestore.collection('profiles').doc(uid);
  }

  static Future<UserCredential> signInWithGoogle({
    bool forceFreshSession = false,
  }) async {
    await GoogleSignIn.instance.initialize();
    if (forceFreshSession) {
      await _disconnectGoogle();
      await _auth.signOut();
    }
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (exception) {
      await _disconnectGoogle();
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: exception.description ??
            'Google sign-in failed. Check that Firebase has this app debug SHA-1 and try again.',
      );
    } on FirebaseAuthException {
      await _disconnectGoogle();
      await _auth.signOut();
      rethrow;
    }
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> createUserWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<Map<String, dynamic>?> loadProfile(String uid) async {
    final snapshot = await _profileRef(uid).get();
    return snapshot.data();
  }

  static Future<void> saveProfile({
    required User user,
    required Map<String, dynamic> profile,
  }) {
    return _profileRef(user.uid).set(profile, SetOptions(merge: true));
  }

  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
  }

  static Future<void> _disconnectGoogle() async {
    try {
      await GoogleSignIn.instance.disconnect();
    } on GoogleSignInException {
      await GoogleSignIn.instance.signOut();
    }
  }
}
