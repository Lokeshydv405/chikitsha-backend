import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart'; // adjust path as needed

class CustomDatePickerField extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime) onDateSelected;

  const CustomDatePickerField({
    super.key,
    required this.label,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryLight,
              onPrimary: Colors.white,
              onSurface: AppColors.headerLight,
            ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayDate = selectedDate != null
        ? DateFormat('dd MMM yyyy').format(selectedDate!)
        : '';

    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'Select Date',
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.primaryLight),
          ),
          controller: TextEditingController(text: displayDate),
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
