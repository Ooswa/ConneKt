import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackActivitiesScreen extends StatefulWidget {
  @override
  _TrackActivitiesScreenState createState() => _TrackActivitiesScreenState();
}

class _TrackActivitiesScreenState extends State<TrackActivitiesScreen> {
  String selectedRole = 'volunteer';
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      print('User not logged in!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
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
                const SizedBox(width: 10),
                Text(
                  "ConneKt",
                  style: GoogleFonts.jimNightshade(
                    fontStyle: FontStyle.italic,
                    fontSize: 32,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.person, color: colorScheme.onPrimary),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  tooltip: 'Profile',
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: colorScheme.onPrimary),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  tooltip: 'Logout',
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        body: Center(
            child: Text(
              'Please log in to see your activities.',
              style: textTheme.bodyMedium,
            )),
      );
    }

    final collectionName =
    selectedRole == 'volunteer' ? 'volunteerActivities' : 'donationActivities';

    return Scaffold(
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // My Activities Title (like reference)
            Text(
              'My Activities',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            // Tabs styled as rounded containers (like reference _buildTab)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRoleTab(
                  'Volunteer',
                  isSelected: selectedRole == 'volunteer',
                  primaryColor: colorScheme.primary,
                  onSelectedColor: colorScheme.onPrimary,
                  unselectedColor: colorScheme.primary,
                ),
                const SizedBox(width: 16),
                _buildRoleTab(
                  'Donor',
                  isSelected: selectedRole == 'donor',
                  primaryColor: colorScheme.primary,
                  onSelectedColor: colorScheme.onPrimary,
                  unselectedColor: colorScheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Cards Container (styled box with border & shadow)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.secondary.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.background.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(4, 6),
                    ),
                  ],
                  color: colorScheme.background,
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName)
                      .where('userId', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No activities found for $selectedRole',
                          style: GoogleFonts.inter(
                              fontSize: 16, color: colorScheme.onBackground),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 30),
                      itemBuilder: (context, index) {
                        final rawData = docs[index].data();
                        if (rawData is! Map<String, dynamic>) {
                          return const SizedBox(); // Skip invalid doc
                        }
                        final data = rawData;

                        DateTime? date;
                        try {
                          date = DateTime.parse(data['date'] ?? '');
                        } catch (_) {
                          date = null;
                        }
                        final formattedDate = date != null
                            ? "${date.day}/${date.month}/${date.year}"
                            : "Unknown date";

                        if (selectedRole == 'volunteer') {
                          final title = data['opportunityTitle'] ?? 'Unknown Opportunity';

                          return _buildActivityCard(
                            icon: Icons.volunteer_activism,
                            iconColor: Colors.green.shade400,
                            title: title,
                            subtitle: 'Date: $formattedDate',
                            textColor: colorScheme.onBackground,
                            borderColor: colorScheme.secondary.withOpacity(0.6),
                            backgroundColor: colorScheme.surface,
                          );
                        } else {
                          final donationTitle = data['donationTitle'] ?? 'Unknown Donation';
                          final amount = (data['amount'] ?? 0).toDouble();
                          final currency = data['currency']?.toUpperCase() ?? 'USD';

                          return _buildActivityCard(
                            icon: Icons.payment,
                            iconColor: Colors.blue.shade400,
                            title: donationTitle,
                            subtitle:
                            'Amount: $currency ${amount.toStringAsFixed(2)} | Date: $formattedDate',
                            textColor: colorScheme.onBackground,
                            borderColor: colorScheme.secondary.withOpacity(0.6),
                            backgroundColor: colorScheme.surface,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTab(String label,
      {required bool isSelected,
        required Color primaryColor,
        required Color onSelectedColor,
        required Color unselectedColor}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = label.toLowerCase() == 'volunteer' ? 'volunteer' : 'donor';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: primaryColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.8 : 0.05),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isSelected ? onSelectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color borderColor,
    required Color backgroundColor, // NEW: theme-aware background color
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF9B3137), // You can also theme this
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
