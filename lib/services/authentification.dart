//class related to the users authentification
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/register.dart';
import '../models/user.dart';
import '../Services-old/database.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

//return the user's id
  AppUser? _userFromFirebaseUser(User? user) {
    return user != null ? AppUser(user.uid) : null;
  }

//stream that uses _userFromFirebaseUser to get the user in real time
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

//function used to sing the user in
  Future signInWithEmailAndPassword(String email, String password) async {
    //try statement to only connect the user if the informations are correct
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (exception) {
      print(exception.toString());
      return null;
    }
  }

//function used to register the user
  Future registerWithEmailAndPassword(
      String name, String email, String password, DateTime? dateOfBirth) async {
    //try statement to ensure a right registration
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user == null) {
        throw Exception("No user found");
      } else {
        //save a the same time a user twin in the firestore
        await DatabaseService(user.uid).saveUser(name, email, dateOfBirth);
        return _userFromFirebaseUser(user);
      }
    } catch (exception) {
      print(exception.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (exception) {
      print(exception.toString());
      return null;
    }
  }
}
