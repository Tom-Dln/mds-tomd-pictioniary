// ignore_for_file: must_be_immutable
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextFiled extends StatefulWidget {
  IconData icon;
  String hintText;
  bool isPassword;
  TextEditingController controller;

  MyTextFiled(
      {super.key, required this.icon,
      required this.hintText,
      required this.isPassword,
      required this.controller});

  @override
  State<MyTextFiled> createState() => _MyTextFiledState();
}

class _MyTextFiledState extends State<MyTextFiled> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon),
          hintText: widget.hintText,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}

class MyTextFiledWithIconAction extends StatefulWidget {
  IconData icon;
  String hintText;
  bool isPassword;
  TextEditingController controller;
  Function() onPressed;

  MyTextFiledWithIconAction(
      {super.key, required this.icon,
      required this.hintText,
      required this.isPassword,
      required this.controller,
      required this.onPressed});

  @override
  State<MyTextFiledWithIconAction> createState() =>
      _MyTextFiledWithIconActionState();
}

class _MyTextFiledWithIconActionState extends State<MyTextFiledWithIconAction> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: IconButton(
            icon: Icon(widget.icon),
            onPressed: widget.onPressed,
          ),
        ),
      ),
    );
  }
}
