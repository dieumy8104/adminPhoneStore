import 'package:admin/provider/category.dart';
import 'package:admin/widget/widget/categoryItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts({super.key});

  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).resetCheckBox();
    });
  }

  @override
  Widget build(BuildContext context) {
    var categoriesProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          Consumer<CategoryProvider>(
            builder: (context, provider, child) => IconButton(
              icon:
                  Icon(provider.isTrue ? Icons.cancel_outlined : Icons.delete),
              onPressed: () {
                if (provider.isTrue == true) {
                  //  provider.clearSelectedItems();
                }
                provider.toggleCheckBoxVisible();
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: categoriesProvider.streamCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No categories available',
              ),
            );
          } else {
            final categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return CategoryItem(
                          categoryId: categories[index].id,
                        );
                      }),
                    );
                  },
                  child: Row(
                    children: [
                      Consumer<CategoryProvider>(
                        builder: (context, provider, child) => Visibility(
                          visible: provider.isTrue,
                          child: Checkbox(
                            value:
                                provider.selectedItems[categories[index].id] ??
                                    false,
                            onChanged: (bool? value) {
                              provider.toggleSelection(categories[index].id);
                              provider.selectedItems[categories[index].id] =
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
                            leading:
                                Image.network(categories[index].categoryImage),
                            title: Text(categories[index].categoryName),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.pushNamed(
                                    context,
                                    '/editCategory',
                                    arguments: categories[index],
                                  );
                                } else if (value == 'delete') {
                                  categoriesProvider.deleteCategoryWithProducts(
                                      categories[index].id);

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã xóa thành công!'),
                                      ),
                                    );
                                    const Duration(seconds: 1);
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Chỉnh sửa'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Xoá'),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Consumer<CategoryProvider>(
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
                    provider.deleteSelectedCategories();
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
