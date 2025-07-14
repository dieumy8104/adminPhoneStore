import 'package:admin/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isTrue = false;

  bool get isTrue => _isTrue;
  void toggleCheckBoxVisible() {
    _isTrue = !_isTrue;
    notifyListeners();
  }

  final Map<String, bool> _selectedItems = {};
  Map<String, bool> get selectedItems => {..._selectedItems};
  
  Stream<List<Product>> streamProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Product.fromMap(doc.data(), doc.id);
            } catch (e) {
              debugPrint('Bỏ qua doc không hợp lệ: ${doc.id}');
              return null;
            }
          })
          .whereType<Product>()
          .toList();
    });
  }

  Stream<Product> streamProduct(String id) {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(id)
        .snapshots()
        .map(
      (snapshot) {
        try {
          return Product.fromMap(
              snapshot.data() as Map<String, dynamic>, snapshot.id);
        } catch (e) {
          debugPrint('Bỏ qua doc không hợp lệ: ${snapshot.id}');
          rethrow;
        }
      },
    );
  }

  Future<void> addItem(Product product) async {
    _isLoading = true;
    notifyListeners();

    final productRef =
        FirebaseFirestore.instance.collection('products').doc(product.id);
    await productRef.set(product.toMap());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> editItem(Product product) async {
    _isLoading = true;
    notifyListeners();
    final productRef =
        FirebaseFirestore.instance.collection('products').doc(product.id);
    await productRef.update(product.toMap());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> replyFeedBack(String productId, String reply, String id) async {
    _isLoading = true;
    notifyListeners();

    final productRef =
        FirebaseFirestore.instance.collection('products').doc(productId);
    final productDoc = await productRef.get();

    if (productDoc.exists && productDoc.data()!.containsKey('feedBack')) {
      List<dynamic> existingFeedback =
          List.from(productDoc.data()!['feedBack']);

      for (int i = 0; i < existingFeedback.length; i++) {
        if (existingFeedback[i]['id'] == id && existingFeedback[i]['reply']==null) {
          existingFeedback[i]['reply'] = reply; 
          break;
        }
      }

      await productRef.update({'feedBack': existingFeedback});
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetCheckBox() {
    _isTrue = false;
    clearSelectedItems();
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedItems.clear();
    notifyListeners();
  }

  Future<void> deleteSelectedProducts() async {
    _isLoading = true;
    notifyListeners();

    final selectedIds = _selectedItems.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    for (var id in selectedIds) {
      await FirebaseFirestore.instance.collection('products').doc(id).delete();
      await FirebaseStorage.instance.ref().child('products/$id.jpg').delete();
      _selectedItems.remove(id);
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleSelection(String id) {
    _selectedItems[id] = !(_selectedItems[id] ?? false);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _isLoading = true;
    notifyListeners();
    FirebaseFirestore.instance.collection('products').doc(id).delete();
    FirebaseStorage.instance.ref().child('products/$id.jpg').delete();
    _isLoading = false;
    notifyListeners();
  }
}
