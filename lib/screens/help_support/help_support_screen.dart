import 'package:flutter/material.dart';

import '../../services/support_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState
    extends State<HelpSupportScreen> {
  final SupportService supportService =
      SupportService();

  final TextEditingController subjectController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

  bool isSending = false;

  Future<void> sendSupportMessage() async {
    final String subject =
        subjectController.text.trim();

    final String message =
        messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a subject and message.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await supportService.createSupportMessage(
        subject: subject,
        message: message,
      );

      subjectController.clear();
      messageController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your support message has been sent.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to send message: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Widget buildFaq(
    String question,
    String answer,
  ) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(
          Icons.help_outline,
          color: Colors.blue,
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(answer),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Find answers to common questions or contact the WatchHub support team.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildFaq(
              'How do I place an order?',
              'Open a watch, tap Buy Now, choose your quantity, and tap Place Order.',
            ),

            buildFaq(
              'How can I track my order?',
              'Open the Orders section to view your orders and their current status.',
            ),

            buildFaq(
              'Can I add a watch to my wishlist?',
              'Yes. Open a product and tap the heart icon to add it to your wishlist.',
            ),

            buildFaq(
              'How do I change my personal information?',
              'Go to Profile, open Personal Information, update your first or last name, and tap Save Changes.',
            ),

            const SizedBox(height: 30),

            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon:
                    Icon(Icons.subject),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: messageController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Describe your issue',
                alignLabelWithHint: true,
                prefixIcon:
                    Icon(Icons.message_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    isSending
                        ? null
                        : sendSupportMessage,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
                label: Text(
                  isSending
                      ? 'Sending...'
                      : 'Send Message',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.support_agent,
                  color: Colors.blue,
                  size: 35,
                ),
                title: const Text(
                  'WatchHub Support',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Send us a message and our support team can review your request.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}