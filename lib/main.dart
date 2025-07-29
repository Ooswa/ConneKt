import 'screens/donationDetailsScreen.dart';
import 'screens/donationsScreen.dart';
import 'screens/editProfileScreen.dart';
import 'screens/oppurtunitiesScreen.dart';
import 'screens/oppurtunityDetailsScreen.dart';
import 'screens/profileScreen.dart';
import 'screens/splashScreen.dart';
import 'screens/trackActivitiesScreen.dart';
import 'screens/loginPage.dart';
import 'screens/signupPage.dart';
import 'screens/homePage.dart';
import 'theme_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  try {
    Stripe.publishableKey = 'pk_test_51RPejV2U8RTuvVXHhVepViuD3gbo8qh9ucVyY3oa8kn6t1O8v2yZWUFyzbSVFUGgrB771qKkGQjI7TnLqkwIQKrf00Mw29GHdf';
    await Stripe.instance.applySettings();
    print("Stripe initialized");
  } catch (e) {
    print("Stripe init error: $e");
  }

  await Firebase.initializeApp();
  runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider()..loadTheme(),
        child: ConneKt(),
      ),
  );
}

class ConneKt extends StatelessWidget {
  const ConneKt({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);  // add provider here

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ConneKt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffDF999D), brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffDF999D), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      home: SplashScreen(),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/opportunities': (context) => OpportunitiesScreen(),
        '/opportunityDetails': (context) => OpportunityDetailsScreen(),
        '/donations': (context) => DonationsScreen(),
        '/donationDetails': (context) => DonationDetailsScreen(),
        '/trackActivities': (context) => TrackActivitiesScreen(),
        '/profile': (context) => ProfileScreen(),
        '/editProfile': (context) => EditProfileScreen(),
      },
    );
  }
}

