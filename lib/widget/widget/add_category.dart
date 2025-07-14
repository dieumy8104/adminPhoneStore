import 'dart:io';
import 'package:admin/models/category_model.dart';
import 'package:admin/provider/category.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final TextEditingController categoryController = TextEditingController();
  XFile? _pickedImage;
  final ImagePicker picker = ImagePicker();
  String? userImageUrl;
  bool _isUploading = false;

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

  // Future<void> uploadCategory() async {
  //   try {

  //     String categoryId = const Uuid().v4(); final path = 'categories/$categoryId.jpg';
  //     final ref = FirebaseStorage.instance.ref().child(path);
  //     await ref.putFile(File(_pickedImage!.path));
  //     userImageUrl = await ref.getDownloadURL();

  //     await FirebaseFirestore.instance
  //         .collection('categories')
  //         .doc(categoryId)
  //         .set({
  //       'id': categoryId,
  //       'categoryImage': userImageUrl,
  //       'categoryName': categoryController.text.trim(),
  //     });
  //   } catch (error) {
  //     debugPrint("Error uploading category: $error");
  //   }
  // }

  @override
  Widget build(BuildContext context) { 
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
                    ? const Icon(Icons.image_outlined, size: 100)
                    : Stack(
                        children: [
                          Container(
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
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _pickedImage = null;
                                });
                              },
                              child: const CircleAvatar(
                                radius: 5,
                                backgroundColor:
                                    Color.fromARGB(255, 74, 74, 74),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                TextButton(
                  onPressed: uploadImage,
                  child: const Text('Pick Category Image'),
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
        onPressed: _isUploading
            ? null
            : () async {
                if (_pickedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn ảnh!')),
                  );
                  return;
                }
                if (categoryController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập tên danh mục!')),
                  );
                  return;
                }

                setState(() {
                  _isUploading = true;
                });

                try {
                  String categoryId = const Uuid().v4();
                  final path = 'categories/$categoryId.jpg';
                  final ref = FirebaseStorage.instance.ref().child(path);
                  await ref.putFile(File(_pickedImage!.path));
                  userImageUrl = await ref.getDownloadURL();

                  final category = Category(
                    id: categoryId,
                    categoryImage: userImageUrl ?? '',
                    categoryName: categoryController.text.trim(),
                  );

                  await Provider.of<CategoryProvider>(context, listen: false)
                      .addCategory(category);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tải lên thành công!')),
                  );
                } catch (e) {
                  debugPrint('Upload error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi tải lên: $e')),
                  );
                } finally {
                  setState(() {
                    _isUploading = false;
                  });
                }
              },
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.upload_rounded, color: Colors.white),
      ),
    );
  }
}
