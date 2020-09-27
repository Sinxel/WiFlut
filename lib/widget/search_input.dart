
import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget{
  final String hint;
  final TextEditingController controller;
  final Function onAction;
  SearchInput(this.hint, this.controller, this.onAction);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
      ),
      controller: controller,
      onEditingComplete: onAction,
      style: TextStyle(color: Colors.white),
    );
  }

}