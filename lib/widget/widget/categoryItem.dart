import 'package:admin/models/product_model.dart';
import 'package:admin/provider/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CategoryItem extends StatefulWidget {
  static const String route = '/categoryItem';
  String categoryId;
  CategoryItem({super.key, required this.categoryId});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).resetCheckBox();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          Consumer<ProductProvider>(
            builder: (context, provider, child) => IconButton(
              icon:
                  Icon(provider.isTrue ? Icons.cancel_outlined : Icons.delete),
              onPressed: () {
                if (provider.isTrue == true) {
                  provider.clearSelectedItems();
                }
                provider.toggleCheckBoxVisible();
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: productProvider.streamProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No categories available',
              ),
            );
          } else {
            final products = snapshot.data
                    ?.where(
                        (product) => product.categoryId == widget.categoryId)
                    .toList() ??
                [];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/productDetail',
                        arguments: products[index].id,
                      );
                    },
                    child: Row(
                      children: [
                        Consumer<ProductProvider>(
                          builder: (context, provider, child) => Visibility(
                            visible: provider.isTrue,
                            child: Checkbox(
                              value:
                                  provider.selectedItems[products[index].id] ??
                                      false,
                              onChanged: (bool? value) {
                                provider.toggleSelection(products[index].id);
                                provider.selectedItems[products[index].id] =
                                    value!;
                              },
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  products[index].phoneImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(products[index].phoneName),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Consumer<ProductProvider>(
        builder: (context, provider, child) => Visibility(
          visible: provider.isTrue,
          child: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    provider.deleteSelectedProducts();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
