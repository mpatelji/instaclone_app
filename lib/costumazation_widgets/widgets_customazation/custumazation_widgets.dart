import 'package:flutter/material.dart';

mixin WidgetCustomization {
  Widget viewTextField(
      String name,
      TextEditingController controller,
      {Widget? prefixIcon,
        FormFieldValidator<String>? validator, bool? obscureText,Widget? suffixIcon}
      ) {
    return Container(
      width: double.infinity,
      child: Card(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: Colors.white,
        child: TextFormField(
          controller: controller,
          obscureText: obscureText ?? false,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            suffixIcon:suffixIcon,
            hintText: name,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          validator: validator, // Add validator here
        ),
      ),
    );
  }

  Widget viewButton(String name, {required void Function()? onPressed}) {
    return MaterialButton(
      height: 50,
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.blue,
      child: Text(
        name,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      onPressed: onPressed,
    );
  }
}
