// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class NotificationPage extends StatelessWidget {
//   const NotificationPage({super.key});
//   static const String routeName = '/notiScreen';

//   @override
//   Widget build(BuildContext context) {
//     final message =
//         ModalRoute.of(context)!.settings.arguments as RemoteMessage?;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//       ),
//       body: Center(
//         child: message != null && message.notification != null
//             ? Text(
//                 message.notification!.title ?? 'No Title',
//                 style: const TextStyle(fontSize: 18),
//               )
//             : const Text(
//                 'No notification data.',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//       ),
//     );
//   }
// }
