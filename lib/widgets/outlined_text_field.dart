import 'package:flutter/material.dart';

class OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final double? width;

  const OutlinedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
          labelStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: theme.colorScheme.outline,width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
