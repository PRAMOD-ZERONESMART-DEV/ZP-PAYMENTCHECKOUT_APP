import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;
    List<String> parts = newText.split('.');

    if (parts.length == 2 && parts[1].length > decimalRange) {
      // Truncate to desired decimalRange
      newText = '${parts[0]}.${parts[1].substring(0, decimalRange)}';
    }

    return TextEditingValue(
      text: newText,
      selection: updateCursorPosition(oldValue, newValue),
      composing: TextRange.empty,
    );
  }

  TextSelection updateCursorPosition(TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    final int cursorPosition = newValue.selection.baseOffset;
    final int oldTextLength = oldValue.text.length;
    final int cursorPositionDelta = newTextLength - oldTextLength;

    // If the cursor is at the end or within the integer part, keep it at the same position
    if (cursorPosition == newTextLength || cursorPosition <= newTextLength - decimalRange - 1) {
      return newValue.selection;
    }

    // If the cursor is in or after the decimal part, keep it at the end of the decimal part
    return newValue.selection.copyWith(
      baseOffset: newTextLength - decimalRange,
      extentOffset: newTextLength - decimalRange,
    );
  }
}

