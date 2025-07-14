import 'package:admin/models/cart.dart';
import 'package:admin/models/order.dart';
import 'package:admin/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  final List<Product> _items = [];
  List<Product> get items => [..._items];

  final List<Product> _products = [];
  List<Product> get products => [..._products];

  Stream<List<UserOrder>> streamOrder() {
    return FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      List<UserOrder> orders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Bỏ qua nếu document không có data hoặc không có trường UserOrder
        if (!data.containsKey('orderUser')) continue;

        final userOrderField = data['orderUser'];

        // Bỏ qua nếu UserOrder không phải là List
        if (userOrderField is! List) continue;

        for (var order in userOrderField) {
          try {
            if (order is Map<String, dynamic>) {
              orders.add(UserOrder.fromMap(order));
            } else if (order is Map) {
              orders.add(UserOrder.fromMap(Map<String, dynamic>.from(order)));
            }
          } catch (e) {
            print('Lỗi parse UserOrder: $e');
            // Nếu lỗi parse thì bỏ qua order này
          }
        }
      }

      return orders;
    });
  }

  Stream<List<Cart>> getOrder() {
    return FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      List<Cart> orders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Bỏ qua nếu document không có data hoặc không có trường UserOrder
        if (!data.containsKey('orderUser')) continue;

        final userOrderField = data['orderUser'];

        // Bỏ qua nếu UserOrder không phải là List
        if (userOrderField is! List) continue;

        for (var order in userOrderField) {
          try {
            if (order is Map<String, dynamic>) {
              orders.add(Cart.fromMap(order));
            } else if (order is Map) {
              orders.add(Cart.fromMap(Map<String, dynamic>.from(order)));
            }
          } catch (e) {
            print('Lỗi parse UserOrder: $e');
            // Nếu lỗi parse thì bỏ qua order này
          }
        }
      }

      return orders;
    });
  }

  Stream<List<Product>> getProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
      (snapshot) {
        final products = snapshot.docs
            .map((snapshot) {
              try {
                return Product.fromMap(snapshot.data(), snapshot.id);
              } catch (e) {
                print('Bỏ qua doc không hợp lệ: ${snapshot.id}');
              }
            })
            .whereType<Product>()
            .toList();
        _items.clear();
        _items.addAll(products);
        return products;
      },
    );
  }
}
