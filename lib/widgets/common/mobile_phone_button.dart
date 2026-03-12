import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MobilePhoneButton extends StatelessWidget {
  final String mobileNumber;

  const MobilePhoneButton({Key? key, required this.mobileNumber})
    : super(key: key);

  Future<void> _launchPhoneCall() async {
    final url = 'tel:$mobileNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchSms() async {
    final url = 'sms:$mobileNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchWhatsApp() async {
    final url = 'https://wa.me/$mobileNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to regular SMS if WhatsApp fails
      await _launchSms();
    }
  }

  Future<void> _copyNumber(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: mobileNumber));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showPhoneOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Contact Customer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D8AA8),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Phone number display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mobileNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Call option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[50],
                child: const Icon(Icons.call, color: Colors.green),
              ),
              title: const Text('Call'),
              subtitle: Text(mobileNumber),
              onTap: () {
                Navigator.pop(context);
                _launchPhoneCall();
              },
            ),

            // SMS option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[50],
                child: const Icon(Icons.message, color: Colors.blue),
              ),
              title: const Text('SMS'),
              subtitle: Text(mobileNumber),
              onTap: () {
                Navigator.pop(context);
                _launchSms();
              },
            ),

            // WhatsApp option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[50],
                child: const Icon(Icons.chat, color: Colors.green),
              ),
              title: const Text('WhatsApp'),
              subtitle: Text(mobileNumber),
              onTap: () {
                Navigator.pop(context);
                _launchWhatsApp();
              },
            ),

            // Copy option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[100],
                child: const Icon(Icons.copy, color: Colors.grey),
              ),
              title: const Text('Copy Number'),
              onTap: () {
                Navigator.pop(context);
                _copyNumber(context);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPhoneOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF5D8AA8).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, size: 14, color: Color(0xFF5D8AA8)),
            const SizedBox(width: 4),
            Text(
              mobileNumber,
              style: const TextStyle(
                color: Color(0xFF5D8AA8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
