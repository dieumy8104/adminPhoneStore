import 'dart:io';
import 'package:admin/provider/product.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';

class EditProduct extends StatefulWidget {
  static String route = '/editProduct';
  const EditProduct({super.key});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final TextEditingController productController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController phoneQController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? _pickedImage;
  String? userImg;
  List<DropdownMenuItem<String>> items = [];
  bool _isUploading = false;
  // Hàm chọn ảnh
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
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi khi xóa ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context, listen: false);
    final data = ModalRoute.of(context)!.settings.arguments as Product;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Update A Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Column(
                children: [
                  _pickedImage == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            data.phoneImage,
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
                controller: productController,
                maxLength: 80,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: data.phoneName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      maxLength: 80,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: data.phonePrice.toString(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      maxLength: 2,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      controller: discountController,
                      decoration: InputDecoration(
                        labelText: data.phoneDiscount.toString(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      maxLength: 10,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: data.phoneQuantity.toString(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: data.phoneDescription,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _isUploading
            ? null
            : () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                try {
                  if (_pickedImage != null) {
                    await deleteImage('products/${data.id}.jpg');
                    final path = 'products/${data.id}.jpg';
                    final ref = FirebaseStorage.instance.ref().child(path);
                    await ref.putFile(File(_pickedImage!.path));
                    userImg = await ref.getDownloadURL();
                  }

                  final product = Product(
                    id: data.id,
                    categoryId: data.categoryId,
                    phoneImage:
                        _pickedImage != null ? userImg! : data.phoneImage,
                    phoneName: productController.text.trim().isNotEmpty
                        ? productController.text.trim()
                        : data.phoneName,
                    phonePrice: priceController.text.trim().isNotEmpty
                        ? double.parse(priceController.text.trim())
                        : data.phonePrice,
                    phoneDiscount: discountController.text.trim().isNotEmpty
                        ? double.parse(discountController.text.trim())
                        : data.phoneDiscount,
                    phoneQuantity: quantityController.text.trim().isNotEmpty
                        ? int.parse(quantityController.text.trim())
                        : data.phoneQuantity,
                    phoneDescription:
                        descriptionController.text.trim().isNotEmpty
                            ? descriptionController.text.trim()
                            : data.phoneDescription,
                    feedBack: data.feedBack
                  );
                  productProvider.editItem(product);

                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tải lên thành công!'),
                      ),
                    );
                    const Duration(seconds: 1);
                    Navigator.pop(context);
                  }
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
