
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  signUp({String email, String password}) async {
    try {
      final result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result.user;
    } on AuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  Future<FirebaseUser> loginUser({String email, String password}) async {
    try {
      final result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result.user;
    } on AuthException catch (e) {
      throw  AuthException(e.code, e.message);
    }
  }

  Future<FirebaseUser>  signInAnonymously() async {
    // TODO: FIX - use signInWithCustomToken
    // TODO: to avoid multiple user
    try {
      final result = await  FirebaseAuth.instance.signInAnonymously();
      notifyListeners();
      return result.user;
    } on AuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  // wrapping the firebase calls
  Future logout() async {
    final result = await FirebaseAuth.instance.signOut();
    notifyListeners();
    return result;
  }


}
