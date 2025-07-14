import 'package:admin/models/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailOrder extends StatefulWidget {
  const DetailOrder({super.key});
  static String routeName = '/orderDetail';
  @override
  State<DetailOrder> createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;
    UserOrder order = data['order'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          'Thông tin đơn hàng',
          style: TextStyle(
            color: Color.fromRGBO(203, 89, 128, 1),
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin vận chuyển',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                color: Colors.grey),
                            SizedBox(width: 10),
                            Text(
                              'Nhanh',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: Color.fromARGB(255, 233, 233, 233),
                    thickness: 1,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Địa chỉ nhận hàng',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.grey),
                                    const SizedBox(width: 10),
                                    Text(
                                      order.userAddress ,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, color: Colors.grey),
                                    const SizedBox(width: 10),
                                    Text(
                                     order.userPhone  ,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  ...order.orderProduct.map(
                    (item) {
                      final product =
                          data['product'].firstWhere((p) => p.id == item.id);
                      return GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                  child: SizedBox(
                                    height: 65,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.phoneName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.topRight,
                                              child: Text(
                                                'x${order.orderProduct.first.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  height: 1.0,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough,
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
                                                letterSpacing: 0.38,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Color.fromARGB(255, 233, 233, 233),
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Thành tiền: ',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${NumberFormat("#,###", "en_US").format(order.totalPrice)}đ',
                        style: const TextStyle(
                          letterSpacing: 0.38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
