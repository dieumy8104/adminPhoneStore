import 'dart:io';
import 'package:admin/models/category_model.dart';
import 'package:admin/provider/category.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateCategory extends StatefulWidget {
  static String route = '/editCategory';
  const UpdateCategory({super.key});

  @override
  State<UpdateCategory> createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  final TextEditingController categoryController = TextEditingController();
  XFile? _pickedImage;
  final ImagePicker picker = ImagePicker();
  String? categoryImageUrl;

  Future<void> _pickImageCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _pickImageGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void uploadImage() async {
    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageCamera();
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageGallery();
              },
              child: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(imagePath);
      await storageRef.delete();
      print('Xóa ảnh thành công');
    } catch (e) {
      print('Lỗi khi xóa ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var categoriesProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final data = ModalRoute.of(context)!.settings.arguments as Category;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload A New Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
           Column(
              children: [
                _pickedImage == null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          data.categoryImage,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_pickedImage!.path),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                TextButton(
                  onPressed: uploadImage,
                  child: const Text('Change A New Image'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          if (_pickedImage != null) {
            await deleteImage('products/${data.id}.jpg');
            final path = 'products/${data.id}.jpg';
            final ref = FirebaseStorage.instance.ref().child(path);
            await ref.putFile(File(_pickedImage!.path));
            categoryImageUrl = await ref.getDownloadURL();
          }
          final category = Category(
            id: data.id,
            categoryImage:
                _pickedImage != null ? categoryImageUrl! : data.categoryImage,
            categoryName: categoryController.text.trim().isNotEmpty
                ? categoryController.text.trim()
                : data.categoryName,
          );
          categoriesProvider.editItem(category);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tải lên thành công!')));
          Navigator.pop(context);
        },
        child: const Icon(Icons.upload_rounded, color: Colors.white),
      ),
    );
  }
}
