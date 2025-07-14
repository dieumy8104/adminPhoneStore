import 'package:admin/provider/order.dart';
import 'package:admin/widget/widget/order_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderInfoPage extends StatefulWidget {
  const OrderInfoPage({super.key});
  static String routeName = '/order_info';
  @override
  State<OrderInfoPage> createState() => _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
          'Quản lí đơn hàng',
          style: TextStyle(
            color: Color.fromRGBO(203, 89, 128, 1),
          ),
        ),
      ),
      body: StreamBuilder(
          stream:
              Provider.of<OrderProvider>(context, listen: false).streamOrder(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final data = snapshot.data;
              int waitingPrepair = 0;
              int waitingDelivery = 0;
              int completedOrders = 0;
              int returnOrder = 0;
              if (data != null) {
                waitingPrepair = data
                    .where((order) => order.orderStatus == "Chờ giao hàng")
                    .toList()
                    .length;
                waitingDelivery = data
                    .where((order) => order.orderStatus == "Đang chờ giao hàng")
                    .toList()
                    .length;
                completedOrders = data
                    .where((order) => order.orderStatus == "Đã giao hàng")
                    .toList()
                    .length;
                returnOrder = data
                    .where((order) => order.orderStatus == "Trả hàng")
                    .toList()
                    .length;
              }

              return Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Đơn hàng',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderStatusPage.routeName,
                              arguments: {"index": 0},
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.alarm_on_outlined,
                                      size: 30,
                                    ),
                                  ),
                                  if (waitingPrepair > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          waitingPrepair.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                'Chờ giao hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderStatusPage.routeName,
                              arguments: {"index": 1},
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.fire_truck,
                                      size: 30,
                                    ),
                                  ),
                                  if (waitingDelivery > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          waitingDelivery.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                'Đang giao hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderStatusPage.routeName,
                              arguments: {"index": 2},
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.done_all,
                                      size: 30,
                                    ),
                                  ),
                                  if (completedOrders > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          completedOrders.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                'Đã giao hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderStatusPage.routeName,
                              arguments: {"index": 3},
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.restart_alt,
                                      size: 30,
                                    ),
                                  ),
                                  if (returnOrder > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          returnOrder.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                'Trả hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
