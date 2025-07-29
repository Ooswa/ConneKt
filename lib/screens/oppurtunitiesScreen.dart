import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class OpportunitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('[DEBUG] OpportunitiesScreen build() called');

    final theme = Theme.of(context);

    Widget buildOpportunityCard({
      required String imageUrl,
      required String title,
      required String date,
      required VoidCallback onTap,
    }) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : theme.colorScheme.surfaceVariant,
          // themed background
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 120,
                  height: 90,
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.volunteer_activism,
                    size: 40,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Themed background

      appBar: AppBar(
        backgroundColor: const Color(0xFFDF999D), // custom, not themed
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
        stream: FirebaseFirestore.instance.collection('opportunities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No opportunities available.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final title = doc['title'] ?? 'Untitled';
              final imageUrl = doc['imageUrl'] ?? '';
              final date = doc['date'] ?? 'No date';

              return buildOpportunityCard(
                imageUrl: imageUrl,
                title: title,
                date: date,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/opportunityDetails',
                    arguments: doc.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
