
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/order_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderService orderService =
        OrderService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: orderService.getMyOrders(),

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

          // NO ORDERS
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Text(
                    'No orders yet.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Your orders will appear here.',
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: documents.length,

            itemBuilder: (context, index) {

              final document =
                  documents[index];

              final data =
                  document.data()
                      as Map<String, dynamic>;

              String orderId =
                  document.id;

              int total =
                  data['total'] ?? 0;

              String status =
                  data['status'] ?? 'Pending';

              List<dynamic> items =
                  data['items'] ?? [];

              Timestamp? createdAt =
                  data['createdAt'];

              String dateText =
                  'Date unavailable';

              if (createdAt != null) {
                DateTime date =
                    createdAt.toDate();

                dateText =
                    '${date.day}/${date.month}/${date.year}';
              }

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 15,
                ),

                elevation: 3,

                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ORDER HEADER
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [

                          const Text(
                            'Order',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Text(
                            '#${orderId.substring(
                              0,
                              orderId.length > 8
                                  ? 8
                                  : orderId.length,
                            )}',

                            style:
                                TextStyle(
                              color: Colors
                                  .grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // DATE
                      Text(
                        'Date: $dateText',
                        style: TextStyle(
                          color: Colors
                              .grey.shade700,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // STATUS
                      Row(
                        children: [

                          const Text(
                            'Status: ',
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight.bold,
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
                                  Colors.orange
                                      .shade50,

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
                                    Colors.orange
                                        .shade800,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(
                        height: 30,
                      ),

                      // PRODUCTS
                      const Text(
                        'Items',
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      ...items.map(
                        (item) {

                          String name =
                              item['name'] ??
                                  'Unknown';

                          int price =
                              item['price'] ??
                                  0;

                          int quantity =
                              item['quantity'] ??
                                  1;

                          return Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              bottom: 8,
                            ),

                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [

                                Expanded(
                                  child: Text(
                                    '$name x$quantity',
                                  ),
                                ),

                                Text(
                                  '₦$price',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const Divider(
                        height: 25,
                      ),

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
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Text(
                            '₦$total',

                            style:
                                const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight
                                      .bold,
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
    );
  }
}

