import 'package:admin/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
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

  void toggleSelection(String id) {
    _selectedItems[id] = !(_selectedItems[id] ?? false);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    _isLoading = true;
    notifyListeners();

    final categoriesRef =
        FirebaseFirestore.instance.collection('categories').doc(category.id);
    await categoriesRef.set(category.toMap());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> editItem(Category category) async {
    _isLoading = true;
    notifyListeners();
    final productRef =
        FirebaseFirestore.instance.collection('categories').doc(category.id);
    await productRef.update(category.toMap());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSelectedCategories() async {
    _isLoading = true;
    notifyListeners();

    final selectedIds = _selectedItems.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    for (var id in selectedIds) {
      deleteCategoryWithProducts(id);
      _selectedItems.remove(id);
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

  Future<void> deleteCategoryWithProducts(String categoryId) async {
    _isLoading = true;
    notifyListeners();
    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    for (var doc in querySnapshot.docs) {
      await firestore.collection('products').doc(doc.id).delete();

      await FirebaseStorage.instance
          .ref()
          .child('products/${doc.id}.jpg')
          .delete();
    }

    FirebaseStorage.instance.ref().child('categories/$categoryId.jpg').delete();
    await firestore.collection('categories').doc(categoryId).delete();
    _isLoading = false;
    notifyListeners();
  }

  Stream<List<Category>> streamCategories() {
    return FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Category.fromMap(doc.data());
            } catch (e) {
              debugPrint('Bỏ qua doc không hợp lệ: ${doc.id}');
              return null;
            }
          })
          .whereType<Category>()
          .toList(); // Bỏ null
    });
  }
}
