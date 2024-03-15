import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String color = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Visual",
                    style: TextStyle(
                        color: Color.fromARGB(255, 10, 61, 103),
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Ear",
                    style: TextStyle(
                        color: Color.fromARGB(255, 248, 129, 169),
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 10, 61, 103),
                    borderRadius: BorderRadius.circular(7)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 35,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Activity Mode",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    color = "C";
                  });
                },
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(125),
                    color: color == "C"
                        ? Color.fromARGB(255, 248, 126, 167)
                        : Color.fromARGB(255, 255, 170, 199),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Start",
                        style: TextStyle(
                            color: Color.fromARGB(255, 10, 61, 103),
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 140,
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 10, 61, 103),
                    borderRadius: BorderRadius.circular(7)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "My Result",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
