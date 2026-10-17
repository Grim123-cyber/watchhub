
import 'package:flutter/material.dart';

import '../../services/support_service.dart';

const Color supportPurple = Color(0xFF4C1D95);
const Color supportBrightPurple = Color(0xFF7C3AED);
const Color supportPalePurple = Color(0xFFF5F3FF);

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final SupportService supportService = SupportService();

  final TextEditingController subjectController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

  bool isSending = false;

  Future<void> sendSupportMessage() async {
    final String subject = subjectController.text.trim();
    final String message = messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter a subject and message.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
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

      if (!mounted) return;

      subjectController.clear();
      messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Your support message has been sent successfully!',
          ),
          backgroundColor: supportPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to send message: $error'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
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

  Widget buildFaq(String question, String answer) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: supportPalePurple,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.help_outline,
            color: supportBrightPurple,
          ),
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: supportPurple,
          ),
        ),
        iconColor: supportBrightPurple,
        collapsedIconColor: supportBrightPurple,
        childrenPadding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          18,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: supportPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/watchhub_logo.png',
              width: 75,
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.watch,
                  size: 30,
                );
              },
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Help & Support',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER BANNER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        supportPurple,
                        supportBrightPurple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'How can we help?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Find answers to common questions or send a message to the WatchHub support team.',
                              style: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.9,
                                ),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.support_agent,
                        size: 58,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: supportPurple,
                  ),
                ),

                const SizedBox(height: 12),

                buildFaq(
                  'How do I place an order?',
                  'Open a watch, tap Buy Now, choose your quantity, and follow the checkout steps to place your order.',
                ),

                buildFaq(
                  'How can I track my order?',
                  'Open My Profile and select My Orders to view your purchases and their current status.',
                ),

                buildFaq(
                  'Can I add a watch to my wishlist?',
                  'Yes! Open a product and tap the heart icon to save it to your wishlist.',
                ),

                buildFaq(
                  'How do I change my personal information?',
                  'Open My Profile, select Personal Information, update your details, and tap Save Changes.',
                ),

                buildFaq(
                  'How do I remove a watch from my wishlist?',
                  'Open My Wishlist and tap the heart icon beside the watch you want to remove.',
                ),

                const SizedBox(height: 28),

                const Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: supportPurple,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Still need help? Tell us what happened, and submit your message for the support team to review.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // SUPPORT FORM
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Send us a message',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: supportPurple,
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextField(
                          controller: subjectController,
                          textCapitalization:
                              TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            hintText:
                                'e.g. Question about my order',
                            prefixIcon: const Icon(
                              Icons.subject,
                              color: supportBrightPurple,
                            ),
                            filled: true,
                            fillColor: supportPalePurple,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: supportBrightPurple,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: messageController,
                          textCapitalization:
                              TextCapitalization.sentences,
                          maxLines: 6,
                          minLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Describe your issue',
                            hintText:
                                'Tell us how we can help...',
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(
                                bottom: 85,
                              ),
                              child: Icon(
                                Icons.message_outlined,
                                color: supportBrightPurple,
                              ),
                            ),
                            filled: true,
                            fillColor: supportPalePurple,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: supportBrightPurple,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isSending
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
                                : const Icon(Icons.send),
                            label: Text(
                              isSending
                                  ? 'Sending...'
                                  : 'Send Message',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  supportBrightPurple,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SUPPORT NOTE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: supportPalePurple,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: supportBrightPurple.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.support_agent,
                        color: supportPurple,
                        size: 34,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WatchHub Support',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: supportPurple,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Your message will be submitted to WatchHub for review. This screen does not provide live chat or guarantee an immediate response.',
                              style: TextStyle(
                                height: 1.5,
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: Text(
                    'WATCHHUB • YOUR TIME. YOUR STYLE.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
