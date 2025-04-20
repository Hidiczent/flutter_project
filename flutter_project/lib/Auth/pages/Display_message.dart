// import 'package:app_present/page/Shoppage/Hompage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/Showchat.dart';
import 'package:flutter_project/models/UserContract.dart';
import 'package:intl/intl.dart';

class Displaymenu extends StatefulWidget {
  const Displaymenu({super.key});

  @override
  State<Displaymenu> createState() => _DisplaymenuState();
}

class _DisplaymenuState extends State<Displaymenu> {
  int _index = 0;
  List<Contract> messages = [
    Contract(
      name: "Somsanit",
      time: DateTime.now(),
      photo: "images/ChatContract/Nit.jpg",
    ),
    Contract(
      name: "Big",
      time: DateTime.now(),
      photo: "images/ChatContract/Big.jpg",
    ),
    Contract(
      name: "Palame",
      time: DateTime.now(),
      photo: "images/ChatContract/Palame.jpg",
    ),
    Contract(
      name: "Souk",
      time: DateTime.now(),
      photo: "images/ChatContract/Souk.jpg",
    ),
    Contract(
      name: "Som",
      time: DateTime.now(),
      photo: "images/ChatContract/Som.jpg",
    ),
    Contract(
      name: "Noy",
      time: DateTime.now(),
      photo: "images/ChatContract/Noy.jpg",
    ),
    Contract(
      name: "Tadam",
      time: DateTime.now(),
      photo: "images/ChatContract/tadam.jpg",
    ),
    Contract(
      name: "Pe",
      time: DateTime.now(),
      photo: "images/ChatContract/Pe.jpg",
    ),
  ];
  int? hoveredCardIndex;
  double opacityValue = 0.2; // Initial opacity value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Remove the unnecessary MaterialPageRoute
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note, color: Colors.purple),
            onPressed: () {},
          ),
        ],
        title: const Text("Message"),
      ),
      // drawer: Drawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final chat = messages[index];
          return MouseRegion(
            onEnter: (_) {
              setState(() {
                hoveredCardIndex = index;
                opacityValue = 0.1;
              });
            },
            onExit: (_) {
              setState(() {
                hoveredCardIndex = null;
                opacityValue = 0.1;
              });
            },
            child: Card(
              margin: const EdgeInsets.all(0),
              color:
                  hoveredCardIndex == index
                      ? Colors.grey.withOpacity(
                        opacityValue,
                      ) // Color when hovered
                      : const Color.fromARGB(255, 244, 241, 241),
              child: ListTile(
                isThreeLine: true,
                leading: CircleAvatar(
                  backgroundImage: AssetImage(chat.photo),
                  radius: 30,
                ),
                title: Text(
                  chat.name,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 5, 5, 5),
                  ),
                ),
                subtitle: Text(
                  DateFormat.Hm().format(chat.time),
                  style: const TextStyle(color: Color.fromARGB(255, 4, 4, 4)),
                ),
                trailing: const Icon(
                  Icons.notifications,
                  size: 20,
                  color: Color.fromARGB(255, 2, 2, 2),
                ),
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => const ShowChat(),
                  );
                  Navigator.of(context).push(route);
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF084886),
        items: const [
          BottomNavigationBarItem(
            icon: Badge(
              label: Text("12", style: TextStyle(color: Colors.white)),
              child: Icon(Icons.chat_bubble),
            ),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text("9", style: TextStyle(color: Colors.white)),
              child: Icon(Icons.call),
            ),
            label: "Call",
          ),
        ],
        selectedFontSize: 16,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
            if (index == 0) {
              Navigator.push(
                context,
                (MaterialPageRoute(builder: (context) => const Displaymenu())),
              );

              print("Messages");
            } else if (index == 1) {}
          });
        },
      ),
    );
  }
}
// Columບໍ່ສາມາດສະກໍເອົາຂໍ້ມູນມາສະແດງໄດ້