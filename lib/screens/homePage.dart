import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Use themed background

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFDF999D),
        elevation: 4,
        titleSpacing: 0,
        centerTitle: true,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Image.asset(
                'assets/icon.png',
                height: 32,
              ),
              const SizedBox(width: 75),
              Text(
                "ConneKt",
                style: GoogleFonts.jimNightshade(
                    fontStyle: FontStyle.italic,
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              // Profile Icon Button
              IconButton(
                icon: const Icon(Icons.person, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                tooltip: 'Profile',
              ),

              // Logout Icon Button
              // IconButton(
              //   icon: const Icon(Icons.logout, color: Colors.black),
              //   onPressed: () async {
              //     await FirebaseAuth.instance.signOut();
              //     Navigator.pushReplacementNamed(context, '/login');
              //   },
              //   tooltip: 'Logout',
              // ),

              const SizedBox(width: 12),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/home.png',
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 32),

            // Example of themed container
            _buildThemedCard(
              context,
              image: 'assets/homepage1.png',
              text: 'Volunteer Now',
              route: '/opportunities',
            ),

            _buildThemedCard(
              context,
              image: 'assets/homepage2.png',
              text: 'Donate Now',
              route: '/donations',
            ),

            _buildThemedCard(
              context,
              image: 'assets/homepage3.png',
              text: 'Track your activities',
              route: '/trackActivities',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedCard(BuildContext context,
      {required String image, required String text, required String route}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          width: double.infinity,
          height: 108,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFEABEC0)
                : theme.colorScheme.secondary.withOpacity(0.2),

          ),
          child: Row(
            children: [
              Expanded(child: Image.asset(image)),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color, // theme text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
