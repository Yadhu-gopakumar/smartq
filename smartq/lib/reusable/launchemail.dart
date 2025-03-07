import 'package:url_launcher/url_launcher.dart';

class EmailHelper {
  final String email;
  final String query;

  EmailHelper({required this.email, required this.query});

  Future<void> launchEmail() async {
    const String recipient = "smartqexample@gmail.com";
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: recipient,
      query: query, 
    );

    if (!await launchUrl(emailUri)) {}
  }
}
