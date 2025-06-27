import 'package:flutter/material.dart';

class SSTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType type;
  final String? hintText;
  final bool obscureText;
  final void Function(String)? onSubmitted;

  const SSTextField({
    super.key,
    this.controller,
    this.type = TextInputType.text,
    this.hintText,
    this.onSubmitted,
    this.obscureText = false
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: type,
      obscuringCharacter: "⭒",
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.black45,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            borderSide: BorderSide(color: Colors.white24)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            borderSide: BorderSide(color: Colors.deepPurple, width: 3)
        ),
      ),
    );
  }
}

class SSButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const SSButton({
    super.key,
    this.onPressed,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Colors.deepPurple.shade800, width: 3)
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SSDropdownMenu extends StatelessWidget {
  final TextEditingController? controller;
  final List<DropdownMenuEntry<String>>? items;
  final String? label;
  final String? initialSelection;

  const SSDropdownMenu({
    super.key,
    this.controller,
    this.items,
    this.label,
    this.initialSelection
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      width: double.infinity,
      controller: controller,
      dropdownMenuEntries: items!,
      initialSelection: initialSelection,
      label: Text(label!),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.deepPurpleAccent,
            width: 1
          )
        ),
      ),
    );
  }
}
