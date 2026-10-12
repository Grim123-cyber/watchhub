import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/support_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() =>
      _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final SupportService supportService = SupportService();

  final TextEditingController subjectController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

  bool isSending = false;

  Future<void> sendSupportMessage() async {
    String subject =
        subjectController.text.trim();

    String message =
        messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in both fields.',
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
            'Support message sent successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sending message: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSending = false;
      });
    }
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Just now';
    }

    DateTime date = timestamp.toDate();

    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color getStatusColor(String status) {
    if (status == 'Open') {
      return Colors.orange;
    }

    if (status == 'Resolved') {
      return Colors.green;
    }

    return Colors.blue;
  }

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support',
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

            // SUPPORT HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Column(
                children: [

                  Icon(
                    Icons.support_agent,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'How can we help?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Send us a message and our support '
                    'team will get back to you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SEND MESSAGE TITLE
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // SUBJECT
            TextField(
              controller: subjectController,

              decoration: InputDecoration(
                labelText: 'Subject',
                hintText:
                    'Example: Problem with my order',
                prefixIcon: const Icon(
                  Icons.subject,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // MESSAGE
            TextField(
              controller: messageController,

              maxLines: 5,

              decoration: InputDecoration(
                labelText: 'Message',
                hintText:
                    'Describe your problem...',
                alignLabelWithHint: true,

                prefixIcon: const Padding(
                  padding: EdgeInsets.only(
                    bottom: 80,
                  ),
                  child: Icon(
                    Icons.message_outlined,
                  ),
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // SEND BUTTON
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

            const SizedBox(height: 35),

            // PREVIOUS MESSAGES
            const Text(
              'My Support Messages',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream:
                  supportService
                      .getMySupportMessages(),

              builder:
                  (
                    context,
                    snapshot,
                  ) {

                // LOADING
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                // ERROR
                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(20),

                    decoration:
                        BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Text(
                      'Error loading messages:\n'
                      '${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                // NO MESSAGES
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(25),

                    decoration:
                        BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Column(
                      children: [

                        Icon(
                          Icons.inbox_outlined,
                          size: 50,
                          color: Colors.grey[500],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'No support messages yet.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // MESSAGES
                return ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount:
                      snapshot.data!.docs.length,

                  itemBuilder:
                      (
                        context,
                        index,
                      ) {

                    final document =
                        snapshot.data!.docs[index];

                    final data =
                        document.data()
                            as Map<String, dynamic>;

                    String subject =
                        data['subject'] ?? '';

                    String message =
                        data['message'] ?? '';

                    String status =
                        data['status'] ?? 'Open';

                    Timestamp? timestamp =
                        data['createdAt']
                            as Timestamp?;

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      elevation: 2,

                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            // SUBJECT + STATUS
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Expanded(
                                  child: Text(
                                    subject,
                                    style:
                                        const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        getStatusColor(
                                              status,
                                            )
                                            .withOpacity(
                                              0.1,
                                            ),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      20,
                                    ),
                                  ),

                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color:
                                          getStatusColor(
                                        status,
                                      ),

                                      fontWeight:
                                          FontWeight.bold,

                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // MESSAGE
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    Colors.grey[700],
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // DATE
                            Row(
                              children: [

                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color:
                                      Colors.grey[600],
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  formatDate(
                                    timestamp,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}