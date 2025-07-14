import 'dart:io';
import 'package:admin/provider/category.dart';
import 'package:admin/provider/product.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/product_model.dart';

class AddProduct extends StatefulWidget {
  static String route = '/addProduct';
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController productController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController phoneQController = TextEditingController();
  String id = const Uuid().v4();
  String? categoryId;
  final ImagePicker picker = ImagePicker();
  XFile? _pickedImage;
  String? userImg;
  List<DropdownMenuItem<String>> items = [];

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

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Upload A New Category'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                    child: const Text('Pick Product Image'),
                  ),
                ],
              ),
              StreamBuilder(
                  stream: Provider.of<CategoryProvider>(context, listen: false)
                      .streamCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No categories available',
                          style: TextStyle(color: Colors.red));
                    } else {
                      final categories = snapshot.data!;
                      return DropdownButton<String>(
                        hint: const Text('Select Category'),
                        value: categoryId,
                        items: categories.map(
                          (cat) {
                            return DropdownMenuItem<String>(
                              value: cat.id,
                              child: Text(cat.categoryName),
                            );
                          },
                        ).toList(),
                        onChanged: (selectedId) {
                          setState(
                            () {
                              categoryId = selectedId;
                            },
                          );
                        },
                      );
                    }
                  }),
              const SizedBox(height: 10),
              TextField(
                controller: productController,
                maxLength: 80,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Discount',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Decription',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          if (_pickedImage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn ảnh!')));
          } else if (productController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập tên sản phẩm!')));
          } else if (descriptionController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập mô tả sản phẩm!')));
          } else if (priceController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập giá sản phẩm!')));
          } else if (quantityController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Vui lòng nhập số lượng sản phẩm!')));
          } else if (discountController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Vui lòng nhập giảm giá sản phẩm!')));
          } else if (categoryId == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Vui lòng chọn danh mục sản phẩm!')));
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
            final path = 'products/$id.jpg';
            final ref = FirebaseStorage.instance.ref().child(path);
            await ref.putFile(File(_pickedImage!.path));
            userImg = await ref.getDownloadURL();

            final product = Product(
              id: id,
              categoryId: categoryId ?? '',
              phoneImage: userImg ?? '',
              phoneName: productController.text.trim(),
              phonePrice: double.parse(priceController.text.trim()),
              phoneDiscount: double.parse(discountController.text.trim()),
              phoneQuantity: int.parse(quantityController.text.trim()),
              phoneDescription: descriptionController.text.trim(),
              feedBack: []
            );
            Navigator.pop(context);
            productProvider.addItem(product);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tải lên thành công!')));
              const Duration(seconds: 1);
              Navigator.pop(context);
            }
          }
        },
        child: const Icon(Icons.upload_rounded, color: Colors.white),
      ),
    );
  }
}
