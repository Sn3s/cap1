part of '../main.dart';

class FirebaseProfileService {
  const FirebaseProfileService._();

  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static const _webClientId =
      '837901302693-40aao89shd99d4obt9pph1uvgrkqnt13.apps.googleusercontent.com';

  static User? get currentUser => _auth.currentUser;

  static DocumentReference<Map<String, dynamic>> _profileRef(String uid) {
    return _firestore.collection('profiles').doc(uid);
  }

  static Future<UserCredential> signInWithGoogle({
    bool forceFreshSession = false,
  }) async {
    await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
    if (forceFreshSession) {
      await _signOutGoogle();
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
      await _clearAuthState();
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: _googleSignInMessage(exception),
      );
    } on FirebaseAuthException {
      await _clearAuthState();
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
    await _clearAuthState();
  }

  static Future<void> _clearAuthState() async {
    await Future.wait([
      _auth.signOut(),
      _signOutGoogle(),
    ]);
  }

  static Future<void> _signOutGoogle() async {
    try {
      await GoogleSignIn.instance.signOut();
    } on GoogleSignInException {
      // Google cleanup is best effort; Firebase sign-out is the source of truth.
    }
  }

  static String _googleSignInMessage(GoogleSignInException exception) {
    final description = exception.description?.trim();
    if (description != null &&
        description.toLowerCase().contains('account reauth failed')) {
      return 'Google could not refresh that account session. Please try again and choose your Google account when prompted.';
    }
    return description?.isNotEmpty == true
        ? description!
        : 'Google sign-in failed. Check that Firebase has this app debug SHA-1 and try again.';
  }
}
