import 'package:flutter/material.dart';
import 'package:flutter_project/models/Message.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class ShowChat extends StatefulWidget {
  const ShowChat({super.key});

  @override
  State<ShowChat> createState() => _ShowChatState();
}

class _ShowChatState extends State<ShowChat> {
  TextEditingController messageController = TextEditingController();
  List<Message> messages =
      [
        Message(
          text: "ຂໍກ່າຍແນ່",
          date: DateTime.now().subtract(const Duration(minutes: 1)),
          isSentByMe: false,
        ),
        Message(
          text: "ວຽກບ້ານອາຈານແລ້ວລະຫວາ",
          date: DateTime.now().subtract(const Duration(days: 3, minutes: 3)),
          isSentByMe: false,
        ),
        Message(
          text: "ຈິ່ມ",
          date: DateTime.now().subtract(const Duration(days: 3, minutes: 4)),
          isSentByMe: false,
        ),
      ].reversed.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: const Color(0xFF084886),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Remove the unnecessary MaterialPageRoute
          },
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.call),
                color: Colors.purple,
                onPressed: () {},
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(Icons.video_call, color: Colors.purple),
                onPressed: () {},
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(Icons.report, color: Colors.purple),
                onPressed: () {
                  // Add the functionality you want when the icon is pressed
                },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: GroupedListView<Message, DateTime>(
                padding: const EdgeInsets.all(8),
                reverse: true,
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                floatingHeader: true,
                elements: messages,
                groupBy:
                    (message) => DateTime(
                      message.date.year,
                      message.date.month,
                      message.date.day,
                    ),
                groupHeaderBuilder:
                    (Message message) => Container(
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat.yMMMd().format(message.date),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                itemBuilder:
                    (context, Message message) => Align(
                      alignment:
                          message.isSentByMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: Card(
                        elevation: 8,
                        color:
                            message.isSentByMe
                                ? Colors.purple.shade700
                                : Colors.grey.shade800,
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color:
                                  message.isSentByMe
                                      ? Colors.white
                                      : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
              ),
            ),
            Container(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          hintText: "Type your message here...",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(
                          color:
                              messages.isNotEmpty && messages.last.isSentByMe
                                  ? Colors.white
                                  : Colors.grey.shade300,
                        ),
                        onSubmitted: (text) {
                          final newMessage = Message(
                            text: text,
                            date: DateTime.now(),
                            isSentByMe: true,
                          );
                          setState(() {
                            messages.add(newMessage);
                            messageController.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.purple,
                      ),
                      onPressed: () {
                        // Add emoji functionality
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up),
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class Message {
//   final String text;
//   final DateTime date;
//   final bool isSentByMe;

//   Message({
//     required this.text,
//     required this.date,
//     required this.isSentByMe,
//   });
// }
