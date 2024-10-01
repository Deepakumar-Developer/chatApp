import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

String name = '';

double height(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

void customStatusBar(var statusBarColor, systemNavigationBarColor,
    statusBarIconBrightness, systemNavigationBarIconBrightness) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: statusBarIconBrightness,
    systemNavigationBarColor: systemNavigationBarColor,
    systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
  ));
}

class Auth {
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      setProfile(name);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('error to login $e');
    }
    return null;
  }

  Future<void> addContent(
      String content, BuildContext context, location) async {
    String id = '${DateTime.now().microsecondsSinceEpoch}';
    final docRef = FirebaseFirestore.instance
        .collection('Chat')
        .doc('content')
        .collection('allContent')
        .doc(id);

    final data = {
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'name': name.isNotEmpty ? name : '',
      'content': content,
      'image': location,
      'date': DateTime.now().toString().substring(0, 10),
      'id': id,
    };

    try {
      await docRef.set(data);
    } catch (error) {
      showToast('$error', context);
    }
  }

  Future<void> setProfile(String name) async {
    CollectionReference profile = FirebaseFirestore.instance
        .collection('Chat')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Profiles');

    await profile.doc('name').set({'name': name});
    getProfile();
  }

  Future<void> getProfile() async {
    CollectionReference profile = FirebaseFirestore.instance
        .collection('Chat')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Profiles');
    final dataProfile = await profile.doc('name').get()
        as DocumentSnapshot<Map<String, dynamic>>;

    final data = dataProfile.data();
    if (data != null) {
      name = data['name'];
    }
  }
}

void showToast(String msg, BuildContext context) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Theme.of(context).colorScheme.surface,
      textColor: Theme.of(context).colorScheme.tertiary,
      fontSize: 16.0);
}

// Future<void> translateToTamil(String content) async {
//   final inputText = content;
//   if (inputText.isEmpty) {
//     return; // Handle empty input gracefully (optional: show a snackbar)
//   }
//
//   try {
//     final translate = GoogleTranslator();
//     final translatedText = await translate.translate(
//       inputText,
//       from: 'en',
//       to: 'ta',
//     );
//     setState(() {
//       tamilContent = translatedText.toString();
//     });
//     print(tamilContent);
//   } catch (error) {
//     print('Translation error: $error');
//     // Handle translation errors gracefully (optional: show a snackbar)
//   }
// }
