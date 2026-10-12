
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/review_service.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ReviewsScreen> createState() =>
      _ReviewsScreenState();
}

class _ReviewsScreenState
    extends State<ReviewsScreen> {

  final ReviewService reviewService =
      ReviewService();

  int selectedRating = 5;

  final TextEditingController commentController =
      TextEditingController();

  bool isSubmitting = false;

  Future<void> submitReview() async {
    String comment =
        commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please write a review first.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await reviewService.addReview(
        productId: widget.productId,
        productName: widget.productName,
        rating: selectedRating,
        comment: comment,
      );

      commentController.clear();

      setState(() {
        selectedRating = 5;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Review submitted successfully!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not submit review: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),

      body: Column(
        children: [

          // WRITE REVIEW
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Review ${widget.productName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Your Rating',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: List.generate(
                        5,
                        (index) {
                          int starNumber =
                              index + 1;

                          return IconButton(
                            onPressed: () {
                              setState(() {
                                selectedRating =
                                    starNumber;
                              });
                            },
                            icon: Icon(
                              starNumber <=
                                      selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller:
                          commentController,

                      maxLines: 3,

                      decoration:
                          InputDecoration(
                        hintText:
                            'Write your review...',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed:
                            isSubmitting
                                ? null
                                : submitReview,

                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit Review',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(),

          // EXISTING REVIEWS
          Expanded(
            child:
                StreamBuilder<QuerySnapshot>(
              stream: reviewService
                  .getProductReviews(
                widget.productId,
              ),

              builder:
                  (context, snapshot) {

                if (snapshot
                        .connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Something went wrong:\n\n${snapshot.error}',
                      textAlign:
                          TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot
                        .data!
                        .docs
                        .isEmpty) {
                  return const Center(
                    child: Text(
                      'No reviews yet.',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                final reviews =
                    snapshot.data!.docs;

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(16),

                  itemCount:
                      reviews.length,

                  itemBuilder:
                      (context, index) {

                    final document =
                        reviews[index];

                    final data =
                        document.data()
                            as Map<String,
                                dynamic>;

                    String email =
                        data['userEmail'] ??
                            'Customer';

                    int rating =
                        data['rating'] ?? 0;

                    String comment =
                        data['comment'] ??
                            '';

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              email,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Row(
                              children:
                                  List.generate(
                                5,
                                (index) {
                                  return Icon(
                                    index < rating
                                        ? Icons.star
                                        : Icons
                                            .star_border,
                                    color:
                                        Colors.amber,
                                    size: 20,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              comment,
                              style:
                                  const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

