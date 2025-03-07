import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:installed_apps/app_info.dart';
import 'package:smartq/constants/constants.dart';

import 'package:installed_apps/installed_apps.dart';
import 'package:smartq/main.dart';
import 'package:smartq/provider/bottom_bar_provider.dart';
import 'package:smartq/provider/cartprovider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final double totalAmount;

  const PaymentPage({super.key, required this.totalAmount});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final String upiId = myupiId;
  final String payeeName = "SmartQ Canteen";
  List<Map<String, String>> upiApps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUpiApps();
  }

  Future<void> _fetchUpiApps() async {
    List<String> upiPackages = [
      "com.google.android.apps.nbu.paisa.user", // Google Pay
      "net.one97.paytm", // Paytm
      "com.phonepe.app", // PhonePe
      "com.whatsapp", // WhatsApp Pay
    ];

    try {
      List<AppInfo> installedApps = await InstalledApps.getInstalledApps();
      List<String> installedPackages =
          installedApps.map((app) => app.packageName).toList();

      setState(() {
        upiApps =
            upiPackages
                .where((pkg) => installedPackages.contains(pkg))
                .map(
                  (pkg) => {
                    "packageName": pkg,
                    "appName":
                        pkg.contains("google")
                            ? "Google Pay"
                            : pkg.contains("paytm")
                            ? "Paytm"
                            : pkg.contains("phonepe")
                            ? "PhonePe"
                            : "WhatsApp Pay",
                  },
                )
                .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch installed UPI apps!")),
      );
    }
  }

  void _startPayment(String packageName) async {
    String upiUrl =
        "upi://pay?pa=$upiId&pn=$payeeName&am=${widget.totalAmount.toStringAsFixed(2)}&cu=INR";
    Uri uri = Uri.parse(upiUrl);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        await Future.delayed(const Duration(seconds: 5));
        await _addBooking();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch $packageName")),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Payment Error: $e\n$stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed! Try again.")),
      );
    } finally {
      Navigator.pop(context);
    }
  }

  // void _startPayment(String packageName) async {
  //   String upiUrl =
  //       "upi://pay?pa=$upiId&pn=$payeeName&am=${widget.totalAmount.toStringAsFixed(2)}&cu=INR";
  //   Uri uri = Uri.parse(upiUrl);

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(child: CircularProgressIndicator()),
  //   );

  //   try {
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //       await Future.delayed(const Duration(seconds: 5));
  //       await _addBooking();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Could not launch UPI app")),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Payment failed! Try again.")),
  //     );
  //   } finally {
  //     Navigator.pop(context);
  //   }
  // }

  Future<void> _addBooking() async {
    final cartState = ref.read(cartProvider);
    final cartItems =
        cartState.keys.map((id) {
          return {"id": id, "quantity": cartState[id] ?? 1};
        }).toList();
    final String orderDateTime = DateTime.now().toIso8601String();

    final response = await http.post(
      Uri.parse("${baseUrl}bookings"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"items": cartItems, "dateTime": orderDateTime}),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order booked successfully!")),
      );
      ref.read(cartProvider.notifier).clearCart();
      ref.read(bottomBarIndexProvider.notifier).state = 1;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const BottomBar()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to book order! Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select UPI App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose a UPI App to Proceed",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : upiApps.isEmpty
                ? const Center(child: Text("No UPI apps found!"))
                : Expanded(
                  child: ListView.builder(
                    itemCount: upiApps.length,
                    itemBuilder: (context, index) {
                      var app = upiApps[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            app["appName"]!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () => _startPayment(app["packageName"]!),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
