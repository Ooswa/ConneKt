import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final theme = doc.data()?['theme'] ?? 'light';
      _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      _themeMode = ThemeMode.light; // fallback to light on error
    }
    notifyListeners();
  }


  Future<void> toggleTheme() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'theme': _themeMode == ThemeMode.dark ? 'dark' : 'light',
    });
    notifyListeners();
  }
}
