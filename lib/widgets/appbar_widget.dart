import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key, this.height = 60, this.title})
      : super(key: key);
  final double height;
  final String? title;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget.title != null
          ? Text(
              '${widget.title}',
              style: TextStyle(
                color: Color.fromARGB(255, 10, 61, 103),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Visual",
                  style: TextStyle(
                    color: Color.fromARGB(255, 10, 61, 103),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Ear",
                  style: TextStyle(
                    color: Color.fromARGB(255, 248, 129, 169),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      // Add other AppBar properties if needed
      centerTitle: widget.title == null ? true : false,
    );
  }
}
