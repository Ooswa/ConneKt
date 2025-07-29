import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Themed background

      appBar: AppBar(
        backgroundColor: const Color(0xFFDF999D), // Custom color
        elevation: 4,
        titleSpacing: 0,
        centerTitle: true,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 50),
              Image.asset(
                'assets/icon.png',
                height: 32,
              ),
              const SizedBox(width: 3),
              Text(
                "ConneKt",
                style: GoogleFonts.jimNightshade(
                  fontStyle: FontStyle.italic,
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              // Profile
              IconButton(
                icon: const Icon(Icons.person, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                tooltip: 'Profile',
              ),

              const SizedBox(width: 12),
            ],
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No donation campaigns available.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final title = doc['title'] ?? 'Untitled';
              final imageUrl = doc['imageUrl'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/donationDetails',
                    arguments: doc.id,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 110,
                          height: 110,
                          color: theme.colorScheme.surfaceVariant,
                          child: Icon(Icons.volunteer_activism,
                              size: 50, color: theme.iconTheme.color),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
