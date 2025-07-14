import 'package:admin/models/feedBack.dart';
import 'package:admin/models/order.dart';
import 'package:admin/models/product_model.dart';
import 'package:admin/provider/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});
  static String routeName = '/order_status';
  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _initialTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 5, vsync: this, initialIndex: _initialTabIndex);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final args = ModalRoute.of(context)?.settings.arguments
            as Map<String, int>?; // Kiểm tra kiểu Map
        if (args != null && args.containsKey("index")) {
          final tabIndex = args["index"];
          if (tabIndex != null && tabIndex >= 0 && tabIndex < 5) {
            setState(() {
              _tabController.index = tabIndex; // Chuyển đến tab tương ứng
            });
          }
        }
      },
    );
  }

  Future<void> updateInfo(String id, String orderId, String newInfo) async {
    final userRef = FirebaseFirestore.instance.collection('orders').doc(id);
    final userDoc = await userRef.get();
    if (userDoc.exists) {
      List<dynamic> orderUserList = userDoc.data()?['orderUser'] ?? [];

      // Tìm và cập nhật đơn hàng có id trùng
      for (int i = 0; i < orderUserList.length; i++) {
        if (orderUserList[i]['id'] == orderId) {
          orderUserList[i]['orderStatus'] = newInfo;

          // Gửi bản cập nhật lên Firestore
          await userRef.update({'orderUser': orderUserList});
          return;
        }
      }
    }
  }

  Future<Map<String, List<FeedBackModal>>> getAllFeedback(
      List<String> productIds, BuildContext context) async {
    Map<String, List<FeedBackModal>> feedbackMap = {};

    for (var id in productIds) {
      final userDoc =
          await FirebaseFirestore.instance.collection('products').doc(id).get();
      if (userDoc.exists && userDoc.data()!.containsKey('feedBack')) {
        List<dynamic> existingProducts = List.from(userDoc.data()!['feedBack']);

        final filtered = existingProducts
            .where((item) => item['reply'] == null)
            .map((item) => FeedBackModal.fromMap(item))
            .toList();

        feedbackMap[id] = filtered;
      }
    }

    return feedbackMap;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.keyboard_backspace,
              color: Color.fromRGBO(203, 89, 128, 1),
            ),
          ),
          title: const Text(
            'Đơn hàng đã mua',
            style: TextStyle(
              color: Color.fromRGBO(203, 89, 128, 1),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: "Chờ giao hàng"),
                Tab(text: "Đang giao hàng"),
                Tab(text: "Đã giao hàng"),
                Tab(text: "Trả hàng"),
                Tab(text: "Đánh giá"),
              ],
            ),
          ),
        ),
        body: StreamBuilder(
          stream:
              Provider.of<OrderProvider>(context, listen: false).streamOrder(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No categories available',
                    style: TextStyle(color: Colors.red)),
              );
            } else {
              final data = snapshot.data!;

              final waitingPrepair = data
                  .where((order) => order.orderStatus == "Chờ giao hàng")
                  .toList();
              final waitingDelivery = data
                  .where((order) => order.orderStatus == "Đang giao hàng")
                  .toList();
              final completedOrders = data
                  .where((order) => order.orderStatus == "Đã giao")
                  .toList();
              final returnOrder = data
                  .where((order) => order.orderStatus == "Trả hàng")
                  .toList();
              final feedbackOrders = data
                  .where((order) => order.orderStatus == "Đánh giá")
                  .toList();
              return StreamBuilder(
                stream: Provider.of<OrderProvider>(context, listen: false)
                    .getProducts(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      !productSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = productSnapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        orderItem(context, waitingPrepair, products),
                        orderItem(context, waitingDelivery, products),
                        orderItem(context, completedOrders, products),
                        orderItem(context, returnOrder, products),
                        feedBack(context, feedbackOrders, products),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget orderItem(
      BuildContext context, List<UserOrder> category, List<Product> products) {
    return category.isNotEmpty
        ? ListView.builder(
            itemCount: category.length,
            itemBuilder: (context, orderIndex) {
              final order = category[orderIndex];
              final ValueNotifier<bool> isExpanded = ValueNotifier(false);

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/orderDetail',
                    arguments: {
                      "order": order,
                      "product": products,
                    },
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isExpanded,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...order.orderProduct.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            final product =
                                products.firstWhere((p) => p.id == item.id);

                            // Hiện index = 0 luôn, còn lại thì chỉ hiện nếu isExpanded = true
                            if (index > 0 && !value) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        product.phoneImage,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.phoneName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'x${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(
                                                  product.phonePrice -
                                                      ((product.phonePrice *
                                                              product
                                                                  .phoneDiscount) /
                                                          100),
                                                )}đ',
                                                style: const TextStyle(
                                                  color: Color(0xffEF6A62),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }),
                          if (order.orderProduct.length > 1)
                            TextButton(
                              onPressed: () {
                                isExpanded.value = !isExpanded.value;
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    value ? "Ẩn bớt" : "Xem thêm",
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                  ),
                                  Icon(
                                    value
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Tổng tiền: ${NumberFormat("#,###", "en_US").format(order.totalPrice)} đ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          order.orderStatus != "Đã giao"
                              ? TextButton(
                                  onPressed: () {
                                    if (order.orderStatus == "Chờ giao hàng") {
                                      updateInfo(order.userId, order.id,
                                          "Đang giao hàng");
                                    } else if (order.orderStatus ==
                                        "Đang giao hàng") {
                                      updateInfo(
                                          order.userId, order.id, "Đã giao");
                                    }
                                  },
                                  child: const Text(
                                    'Chuyển trạng thái',
                                    style: TextStyle(
                                      color: Color.fromRGBO(203, 89, 128, 1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          )
        : const Center(child: Text("Bạn chưa có bất kì đơn hàng nào!"));
  }

  Widget feedBack(
      BuildContext context, List<UserOrder> category, List<Product> products) {
    // Lấy danh sách sản phẩm duy nhất (unique)
    final uniqueProductIds = category
        .expand((order) => order.orderProduct.map((item) => item.id))
        .toSet();

    return FutureBuilder<Map<String, List<FeedBackModal>>>(
      future: getAllFeedback(uniqueProductIds.toList(), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No categories available',
                style: TextStyle(color: Colors.red)),
          );
        }

        final feedbackMap = snapshot.data ?? {};
        final allFeedbackNoReply = feedbackMap.values
            .expand((list) => list)
            .every((fb) => (fb.reply == null || fb.reply!.isEmpty));

        if (allFeedbackNoReply) {
          return const Center(
            child: Text(
              "No categories available",
            ),
          );
        }
        return ListView(
          children: uniqueProductIds.map((productId) {
            final product = products.firstWhere((p) => p.id == productId);
            final feedbackList = feedbackMap[productId] ?? [];

            if (feedbackList.isEmpty) return const SizedBox.shrink();

            return Column(
              children: feedbackList.map((feedBack) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.phoneImage,
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              product.phoneName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: List.generate(
                          feedBack.vote,
                          (_) => const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        feedBack.feedBackText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/replyFeedBack',
                                arguments: {
                                  'feedBack': feedBack,
                                  'productId': product.id,
                                },
                              );
                            },
                            child: const Text(
                              "Phản hồi: ",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            )),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
