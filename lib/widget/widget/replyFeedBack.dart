import 'package:admin/provider/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Replyfeedback extends StatefulWidget {
  const Replyfeedback({super.key});
  static String routeName = '/replyFeedBack';
  @override
  State<Replyfeedback> createState() => _ReplyfeedbackState();
}

class _ReplyfeedbackState extends State<Replyfeedback> {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;
    final feedBack = data['feedBack'];
    final id = data['productId'];
    TextEditingController reply = TextEditingController();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.keyboard_backspace,
            color: Color.fromRGBO(203, 89, 128, 1),
          ),
        ),
        title: const Text(
          'Trả lời đánh giá',
          style: TextStyle(
            color: Color.fromRGBO(203, 89, 128, 1),
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(
                  feedBack.vote,
                  (index) => const Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
            Text(feedBack.feedBackText),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 100,
              child: TextField(
                controller: reply,
                maxLength: 50,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          final feedbackText = reply.text;

          Provider.of<ProductProvider>(context, listen: false).replyFeedBack(
            id,
            feedbackText,
            feedBack.id,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Phản hồi đã được gửi!"),
            ),
          );
          Future.delayed(
            const Duration(seconds: 2000),
          );
          Navigator.pop(context);
        },
        child: const Text("Gửi Phản Hồi"),
      ),
    );
  }
}
