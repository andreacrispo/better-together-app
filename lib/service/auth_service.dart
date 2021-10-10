
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> getUser() {
    return  Future.value(_auth.currentUser);
  }

  signUp({String email, String password}) async {
    try {
      final result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<User> loginUser({String email, String password}) async {
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<User>  signInAnonymously() async {
    // TODO: FIX - use signInWithCustomToken
    // TODO: to avoid multiple user
    try {
      final result = await  FirebaseAuth.instance.signInAnonymously();
      notifyListeners();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw  FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // wrapping the firebase calls
  Future logout() async {
    final result = await FirebaseAuth.instance.signOut();
    notifyListeners();
    return result;
  }


}
