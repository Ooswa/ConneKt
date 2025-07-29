import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        userData = doc.data() ?? {};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final containerColor = isDark
        ? theme.colorScheme.onSecondaryContainer
        : const Color(0xFFEABEC0);

    final labelStyle = GoogleFonts.inter(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: theme.colorScheme.onBackground,
    );

    final valueStyle = GoogleFonts.poppins(
      fontSize: 16,
      color: isDark ? Colors.grey[300] : Colors.black87,
    );

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFDF999D),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icon.png', height: 40),
                  const SizedBox(width: 10),
                  Text(
                    'ConneKt',
                    style: GoogleFonts.jimNightshade(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Email
            _profileRow('Email', user!.email ?? 'Not available', labelStyle, valueStyle),
            const SizedBox(height: 16),

            // Name
            _profileRow('Name', userData['name'] ?? 'Not set', labelStyle, valueStyle),
            const SizedBox(height: 16),

            // Phone
            _profileRow('Phone', userData['phone'] ?? 'Not set', labelStyle, valueStyle),
            const SizedBox(height: 16),

            // Address
            _profileRow('Address', userData['address'] ?? 'Not set', labelStyle, valueStyle),
            const SizedBox(height: 30),

            // Theme toggle
            SwitchListTile(
              title: Text("Dark Theme", style: labelStyle),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
            const SizedBox(height: 60),

            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: _themedButton(
                text: 'Edit Profile',
                backgroundColor: containerColor,
                textColor: Colors.black,
                onPressed: () async {
                  await Navigator.pushNamed(context, '/editProfile');
                  _loadUserProfile(); // Refresh after editing
                },
              ),
            ),
            const SizedBox(height: 30),

            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: _themedButton(
                text: 'Log Out',
                backgroundColor: containerColor,
                textColor: Colors.red,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Confirm Logout'),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: labelStyle),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }

  Widget _themedButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Center(
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
