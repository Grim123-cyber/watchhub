
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() =>
      _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService wishlistService =
      WishlistService();

  Future<void> removeItem(String productId) async {
    try {
      await wishlistService.removeFromWishlist(
        productId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Removed from wishlist.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not remove item: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: wishlistService.getWishlist(),

        builder: (context, snapshot) {

          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Something went wrong:\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // EMPTY WISHLIST
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Your wishlist is empty.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Save watches you love here.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // GET WISHLIST DOCUMENTS
          final documents =
              snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: documents.length,

            itemBuilder: (context, index) {

              final document =
                  documents[index];

              final data =
                  document.data()
                      as Map<String, dynamic>;

              String productId =
                  data['productId'] ??
                  document.id;

              String name =
                  data['name'] ??
                  'Unknown Product';

              int price =
                  data['price'] ?? 0;

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                elevation: 2,

                child: Padding(
                  padding:
                      const EdgeInsets.all(12),

                  child: Row(
                    children: [

                      // WATCH IMAGE
                      Container(
                        width: 85,
                        height: 85,

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.grey.shade200,

                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),

                        child: const Icon(
                          Icons.watch,
                          size: 50,
                        ),
                      ),

                      const SizedBox(
                        width: 15,
                      ),

                      // PRODUCT DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              name,

                              style:
                                  const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),

                              maxLines: 2,

                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              '₦$price',

                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            const Text(
                              'Saved to wishlist',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // REMOVE BUTTON
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),

                        onPressed: () {
                          removeItem(productId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
