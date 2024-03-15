import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visualear/constant/colors.dart';
import 'package:visualear/views/activity.dart';
import 'package:visualear/views/maths.dart';
import 'package:visualear/views/science.dart';
import 'package:visualear/views/walking.dart';

import 'constant/string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String color = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      color: primaryColor,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.book_fill,
                            size: 25,
                          ),
                          Text(learningMaths)
                        ],
                      ),
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Container(
                      color: primaryColor,  child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.book_fill,
                            size: 25,
                          ),
                          Text(learningScience)
                        ],
                      ),
                    ))
                  ],
                ),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      color: primaryColor,  child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.book_fill,
                            size: 25,
                          ),
                          Text(mathsActivity)
                        ],
                      ),
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: GestureDetector(onTap: () {
                   Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const WalkingPage()),
  );
                        },
                          child: Container(
                                                color: primaryColor,  child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.book_fill,
                              size: 25,
                            ),
                            Text(walking)
                          ],
                                                ),
                                              ),
                        ))
                  ],
                ),
              ))
        ],
      )),
    );
  }
}
