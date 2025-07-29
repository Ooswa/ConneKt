import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationDetailsScreen extends StatefulWidget {
  @override
  _DonationDetailsScreenState createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  final TextEditingController _amountController = TextEditingController(text: '500');
  String? donationId;

  String donationTitle = 'Loading...';
  String donationDescription = '';
  double currentAmount = 0.0;
  double targetAmount = 0.0;
  String imageUrl = '';

  bool isLoading = true;
  bool isProcessingPayment = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (donationId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        donationId = args;
        _fetchDonationDetails();
      } else {
        setState(() {
          donationTitle = 'Invalid donation ID';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDonationDetails() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('donations').doc(donationId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          donationTitle = data['title'] ?? 'No title found';
          donationDescription = data['description'] ?? '';
          currentAmount = (data['currentAmount'] ?? 0).toDouble();
          targetAmount = (data['targetAmount'] ?? 0).toDouble();
          imageUrl = data['imageUrl'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          donationTitle = 'Donation not found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        donationTitle = 'Error loading donation';
        isLoading = false;
      });
    }
  }

  Future<void> _makePayment(BuildContext context) async {
    if (donationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid donation ID')));
      return;
    }

    final enteredAmountStr = _amountController.text.trim();
    if (enteredAmountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a donation amount')));
      return;
    }

    double? enteredAmount = double.tryParse(enteredAmountStr);
    if (enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid positive amount')));
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    try {
      final int amountInPaisa = (enteredAmount * 100).toInt();

      final response = await http.post(
        Uri.parse('http://YOUR_IP:4242/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amountInPaisa}),
      );

      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['clientSecret'];
      if (clientSecret == null) {
        throw Exception("Client secret is missing in response.");
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ConneKt Donations',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('donationActivities').add({
          'amount': enteredAmount,
          'currency': 'PKR',
          'date': DateTime.now().toIso8601String().split('T').first,
          'donationId': donationId,
          'donationTitle': donationTitle,
          'userId': user.uid,
        });

        await FirebaseFirestore.instance.collection('donations').doc(donationId).update({
          'currentAmount': currentAmount + enteredAmount,
        });

        setState(() {
          currentAmount += enteredAmount;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Donation successful and recorded!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Payment failed: $e')));
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  PreferredSizeWidget buildCustomAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFDF999D),
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
    );
  }

  Widget detailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildCustomAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              donationTitle,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(Icons.broken_image, size: 80, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                  ),
                ),
              ),
            if (imageUrl.isNotEmpty) const SizedBox(height: 16),
            Text(
              donationDescription,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),
            detailRow('Raised:', 'PKR $currentAmount / PKR $targetAmount'),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Enter donation amount (PKR)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixText: 'PKR ',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 24),
            Center(
              child: isProcessingPayment
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () => _makePayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Donate Now',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
