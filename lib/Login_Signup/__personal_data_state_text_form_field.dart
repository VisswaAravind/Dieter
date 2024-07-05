import 'package:flutter/material.dart';

class PersonalDataStateTextFormField extends StatelessWidget {
  const PersonalDataStateTextFormField(
      {super.key,
      required this.controller,
      required this.title,
      required this.type,
      this.validator,
      this.appear});

  final TextEditingController controller;
  final String title;
  final bool type;
  final validator;
  final appear;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: appear,
      readOnly: type,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: title,
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
    );
  }
}
