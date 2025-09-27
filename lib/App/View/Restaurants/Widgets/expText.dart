import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';




class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final Color readMoreColor;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLines = 3,
    this.readMoreColor = const Color(0xFF37B6AF), 
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final words = widget.text.split(' ');

    final preview = words.length > 30
        ? words.take(30).join(' ') + '...'
        : widget.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: _expanded ? widget.text : preview,
          fontSize: 14,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: CustomText(
            text: _expanded ? 'Show Less' : 'Read More..',
            fontSize: 14,
            color: widget.readMoreColor,
          ),
        ),
      ],
    );
  }
}
