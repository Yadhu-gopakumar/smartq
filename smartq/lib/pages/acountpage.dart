import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartq/auth/auth_provider.dart';
import 'package:smartq/reusable/acountcard.dart';
import 'package:smartq/reusable/launchemail.dart';


class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  void _sendfeedback() {
    String email = 'useremail@gmail.com';
    String query = 'subject=feedback&body=Write your feedback here';
    EmailHelper emailinst = EmailHelper(email: email, query: query);
    emailinst.launchEmail();
  }

//sendsupposrt method
  void _sendsupport() {
    String email = 'useremail@gmail.com';
    String query = 'subject=support&body=what support needed';
    EmailHelper emailinst = EmailHelper(email: email, query: query);
    emailinst.launchEmail();
  }

//logout methods
  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).logout(context,ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accounts',
          style: TextStyle(
              letterSpacing: 2,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: _sendfeedback,
            child: const AccountCards(
                aicon: Icons.feedback_outlined, atext: 'Feedback'),
          ),
          GestureDetector(
            onTap: _sendsupport,
            child: const AccountCards(
                aicon: Icons.contact_support_outlined, atext: 'Support'),
          ),
          GestureDetector(
            onTap: () => _logout(context, ref),
            child: const AccountCards(
                aicon: Icons.logout_rounded, atext: 'Logout'),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'All rights reserved',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                Text(
                  'version 1.0',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
