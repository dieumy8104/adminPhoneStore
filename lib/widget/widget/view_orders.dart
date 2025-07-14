// import 'package:admin/provider/category.dart';
// import 'package:admin/provider/order.dart';
// import 'package:admin/widget/widget/categoryItem.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ViewOrders extends StatefulWidget {
//   const ViewOrders({super.key});

//   @override
//   State<ViewOrders> createState() => _ViewOrdersState();
// }

// class _ViewOrdersState extends State<ViewOrders> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<OrderProvider>(context, listen: false).resetCheckBox();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var ordersProvider =
//         Provider.of<OrderProvider>(context, listen: false);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin'),
//         actions: [
//           Consumer<OrderProvider>(
//             builder: (context, provider, child) => IconButton(
//               icon:
//                   Icon(provider.isTrue ? Icons.cancel_outlined : Icons.delete),
//               onPressed: () {
//                 if (provider.isTrue == true) {
//                   //  provider.clearSelectedItems();
//                 }
//                 provider.toggleCheckBoxVisible();
//               },
//             ),
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//         stream: ordersProvider.streamOrder(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: Center(child: CircularProgressIndicator()),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No order available',
//               ),
//             );
//           } else {
//             final orders = snapshot.data!;
//             return ListView.builder(
//               itemCount: orders.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (BuildContext context) {
//                         return CategoryItem(
//                           categoryId: orders[index].id,
//                         );
//                       }),
//                     );
//                   },
//                   child: Row(
//                     children: [
//                       Consumer<OrderProvider>(
//                         builder: (context, provider, child) => Visibility(
//                           visible: provider.isTrue,
//                           child: Checkbox(
//                             value:
//                                 provider.selectedItems[orders[index].id] ??
//                                     false,
//                             onChanged: (bool? value) {
//                               provider.toggleSelection(orders[index].id);
//                               provider.selectedItems[orders[index].id] =
//                                   value!;
//                             },
//                             activeColor: Colors.blue,
//                             checkColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Card(
//                           child: ListTile(
//                             leading:
//                                 Image.network(orders[index].),
//                             title: Text(orders[index].or),
//                             trailing: PopupMenuButton<String>(
//                               onSelected: (value) {
//                                 if (value == 'edit') {
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/editCategory',
//                                     arguments: orders[index],
//                                   );
//                                 }  
//                               },
//                               itemBuilder: (BuildContext context) =>
//                                   <PopupMenuEntry<String>>[
//                                 const PopupMenuItem<String>(
//                                   value: 'edit',
//                                   child: Text('Chỉnh sửa'),
//                                 ),
//                                 const PopupMenuItem<String>(
//                                   value: 'delete',
//                                   child: Text('Xoá'),
//                                 ),
//                               ],
//                               icon: const Icon(Icons.more_vert),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//       // bottomNavigationBar: Consumer<OrderProvider>(
//       //   builder: (context, provider, child) => Visibility(
//       //     visible: provider.isTrue,
//       //     child: BottomAppBar(
//       //       child: Row(
//       //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       //         children: [
//       //           TextButton(
//       //             child: const Text('Delete'),
//       //             onPressed: () {
//       //               showDialog(
//       //                 context: context,
//       //                 barrierDismissible: false,
//       //                 builder: (context) => const Center(
//       //                   child: CircularProgressIndicator(),
//       //                 ),
//       //               );
             
//       //               Navigator.pop(context);
//       //             },
//       //           ),
//       //         ],
//       //       ),
//       //     ),
//       //   ),
//       // ),
//     );
//   }
// }
