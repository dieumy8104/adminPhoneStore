import 'package:admin/firebase_api/firebase_api.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/provider/category.dart';
import 'package:admin/provider/order.dart';
import 'package:admin/provider/product.dart';
import 'package:admin/widget/home_page.dart';
import 'package:admin/widget/login_page.dart';
import 'package:admin/widget/notification_page.dart';
import 'package:admin/widget/widget/add_product.dart';
import 'package:admin/widget/widget/detailOrder.dart';
import 'package:admin/widget/widget/order_status.dart';
import 'package:admin/widget/widget/productDetail.dart';
import 'package:admin/widget/widget/replyFeedBack.dart';
import 'package:admin/widget/widget/updateCategory.dart';
import 'package:admin/widget/widget/updateProduct.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 // await FirebaseApi().initNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: MaterialApp(navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Flutter ',
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/home_page': (context) => const HomePage(),
            '/productDetail': (context) => const ProductDetail(),
            '/addProduct': (context) => const AddProduct(),
            '/editProduct': (context) => const EditProduct(),
            '/editCategory': (context) => const UpdateCategory(),
            '/order_status': (context) => const OrderStatusPage(),
            '/orderDetail': (context) => const DetailOrder(),
            '/replyFeedBack': (context) => const Replyfeedback(),
         //   '/notiScreen': (context) => const NotificationPage(),
          },
        ),
      ),
    );
  }
}
