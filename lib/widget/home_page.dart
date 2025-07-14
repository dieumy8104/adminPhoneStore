import 'package:admin/widget/notification_page.dart';
import 'package:admin/widget/widget/addNoti.dart';
import 'package:admin/widget/widget/add_category.dart';
import 'package:admin/widget/widget/add_product.dart';
import 'package:admin/widget/widget/order_info.dart'; 
import 'package:admin/widget/widget/view_products.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String route = '/home_page';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2,
          ),
          children: [
            myContainer(
                icon: const Icon(Icons.add),
                text: 'Add category',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const AddCategory(),
                    ),
                  );
                }),
            myContainer(
                icon: const Icon(Icons.add),
                text: 'Add product',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const AddProduct(),
                    ),
                  );
                }),
            myContainer(
                icon: const Icon(Icons.list),
                text: 'View categories',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const ViewProducts(),
                    ),
                  );
                }),
            myContainer(
              icon: const Icon(Icons.notifications),
              text: 'Notification',
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute<void>(
                //     builder: (BuildContext context) => const NotificationPage(),
                //   ),
                // );
              },
            ),
            myContainer(
              icon: const Icon(Icons.delivery_dining),
              text: 'View orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const OrderInfoPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class myContainer extends StatelessWidget {
  const myContainer({super.key, this.onTap, required this.icon, this.text});
  final String? text;
  final VoidCallback? onTap;
  final Icon icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Text(
              text!,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
