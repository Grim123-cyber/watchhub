
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../orders/orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cartService = CartService();
  final OrderService orderService = OrderService();

  bool isCheckingOut = false;

  Future<void> removeItem(String productId) async {
    try {
      await cartService.removeFromCart(productId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart.'),
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

  Future<void> checkout(
    List<QueryDocumentSnapshot> documents,
  ) async {
    if (documents.isEmpty) {
      return;
    }

    setState(() {
      isCheckingOut = true;
    });

    try {
      List<Map<String, dynamic>> items = [];

      int total = 0;

      for (var document in documents) {
        final data =
            document.data()
                as Map<String, dynamic>;

        String productId =
            data['productId'] ?? document.id;

        String name =
            data['name'] ?? 'Unknown Product';

        int price =
            data['price'] ?? 0;

        int quantity =
            data['quantity'] ?? 1;

        items.add({
          'productId': productId,
          'name': name,
          'price': price,
          'quantity': quantity,
        });

        total += price * quantity;
      }

      // CREATE ORDER
      String orderId =
          await orderService.createOrder(
        items: items,
        total: total,
      );

      // REMOVE ITEMS FROM CART
      for (var document in documents) {
        await cartService.removeFromCart(
          document.id,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order created successfully!\nOrder ID: $orderId',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // OPEN ORDERS SCREEN
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const OrdersScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Checkout failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCheckingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: cartService.getCart(),

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

          // EMPTY CART
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Your cart is empty.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Add some watches to your cart.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final documents =
              snapshot.data!.docs;

          // CALCULATE TOTAL
          int total = 0;

          for (var document in documents) {
            final data =
                document.data()
                    as Map<String, dynamic>;

            int price =
                data['price'] ?? 0;

            int quantity =
                data['quantity'] ?? 1;

            total += price * quantity;
          }

          return Column(
            children: [

              // CART ITEMS
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.all(16),

                  itemCount:
                      documents.length,

                  itemBuilder:
                      (context, index) {

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

                    int quantity =
                        data['quantity'] ?? 1;

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),

                      elevation: 2,

                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        child: Row(
                          children: [

                            // WATCH ICON
                            Container(
                              width: 80,
                              height: 80,

                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.grey.shade200,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),

                              child:
                                  const Icon(
                                Icons.watch,
                                size: 45,
                              ),
                            ),

                            const SizedBox(
                              width: 15,
                            ),

                            // PRODUCT INFO
                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(
                                    name,

                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight
                                              .bold,
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
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  Text(
                                    'Quantity: $quantity',

                                    style:
                                        TextStyle(
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // DELETE
                            IconButton(
                              icon:
                                  const Icon(
                                Icons
                                    .delete_outline,
                                color:
                                    Colors.red,
                              ),

                              onPressed: () {
                                removeItem(
                                  productId,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // CHECKOUT AREA
              Container(
                padding:
                    const EdgeInsets.all(20),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(0.2),

                      blurRadius: 10,

                      offset:
                          const Offset(0, -3),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    // TOTAL
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(
                          'Total',

                          style:
                              TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        Text(
                          '₦$total',

                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // CHECKOUT
                    SizedBox(
                      width:
                          double.infinity,

                      height: 55,

                      child:
                          ElevatedButton(
                        onPressed:
                            isCheckingOut
                                ? null
                                : () {
                                    checkout(
                                      documents,
                                    );
                                  },

                        child:
                            isCheckingOut
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Proceed to Checkout',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          17,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

