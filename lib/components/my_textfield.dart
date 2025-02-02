
import 'package:flutter/material.dart';


class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final String labelText;
  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.labelText =""
    });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
        ),
        labelText: labelText.isEmpty ? null : labelText,        
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        hintText: hintText,
      ),
      obscureText: obscureText,

    );
  }
}