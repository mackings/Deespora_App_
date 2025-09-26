import 'package:flutter/material.dart';

class PinInputFields extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final double fieldWidth;
  final double fieldHeight;
  final TextStyle? textStyle;
  final Color borderColor;
  final Color focusedBorderColor;
  final bool obscureText;

  const PinInputFields({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.fieldWidth = 50,
    this.fieldHeight = 60,
    this.textStyle,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = Colors.teal,
    this.obscureText = false,
  });

  @override
  State<PinInputFields> createState() => _PinInputFieldsState();
}

class _PinInputFieldsState extends State<PinInputFields> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // keep only the last character
      _controllers[index].text = value.substring(value.length - 1);
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    String currentPin = _controllers.map((c) => c.text).join();
    if (currentPin.length == widget.length) {
      widget.onCompleted(currentPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: widget.fieldWidth,
          height: widget.fieldHeight,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: widget.textStyle ?? const TextStyle(fontSize: 24),
            obscureText: widget.obscureText,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.borderColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.focusedBorderColor,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) => _onChanged(index, value),
          ),
        );
      }),
    );
  }
}
