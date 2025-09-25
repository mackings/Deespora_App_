import 'dart:async';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


Future<void> showOtpModalSheet({
  required BuildContext context,
  required ValueChanged<String> onCompleted,
  VoidCallback? onResend,

  Duration resendCooldown = const Duration(seconds: 30),
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _OtpSheet(
        onCompleted: onCompleted,
        onResend: onResend,
        resendCooldown: resendCooldown,
      ),
    ),
  );
}

class _OtpSheet extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final VoidCallback? onResend;
  final Duration resendCooldown;

  const _OtpSheet({
    required this.onCompleted,
    this.onResend,
    required this.resendCooldown,
  });

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  static const int length = 5;

  final List<TextEditingController> _controllers = List.generate(
    length,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(length, (_) => FocusNode());

  bool _isVerified = false;
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  String _error = '';
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
    if (widget.onResend != null) _startTimer(widget.resendCooldown);
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  void _startTimer(Duration d) {
    _timer?.cancel();
    setState(() => _secondsRemaining = d.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining <= 1) {
        t.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  void _onChanged(String v, int i) {
    if (v.length > 1) return _handlePaste(v);
    if (v.isNotEmpty && i < length - 1) {
      _focusNodes[i + 1].requestFocus();
    }
    _checkComplete();
  }

  void _handlePaste(String paste) {
    final digits = paste.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    if (digits.length < length) {
      _focusNodes[digits.length].requestFocus();
    } else {
      _focusNodes[length - 1].unfocus();
    }
    _checkComplete();
  }

  void _onKey(RawKeyEvent e, int i) {
    if (e is RawKeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _focusNodes[i - 1].requestFocus();
      _controllers[i - 1].clear();
    }
  }

  void _checkComplete() {
    if (_controllers.every((c) => c.text.isNotEmpty)) {
     // setState(() => _isVerified = true);
    //  widget.onCompleted(_controllers.map((c) => c.text).join());
    }
  }

  void _onReset() {
    if (_newPass.text.isEmpty || _confirmPass.text.isEmpty) {
      setState(() => _error = 'Please fill in both fields');
      return;
    }
    if (_newPass.text != _confirmPass.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() => _error = '');
    print('✅ Reset with: ${_newPass.text}');
    // Navigator.pop(context);
  }

  Widget _field(int i) => SizedBox(
    width: 55,
    height: 65,
    child: RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (e) => _onKey(e, i),
      child: TextField(
        controller: _controllers[i],
        focusNode: _focusNodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        onChanged: (v) => _onChanged(v, i),
      ),
    ),
  );

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

              SizedBox(height: 20,),

            Row(
              children: [
                CustomText(text: "Enter Token",title: true,fontSize: 20,),
              ],
            ),
            SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(length, _field),
            ),
            const SizedBox(height: 20),

           // const SizedBox(height: 24),

            CustomTextField(
              title: "New Password",
              hintText: "Enter new password",
              controller: _newPass,
              isPassword: true,
              // Optionally disable until verified
              // enabled: _isVerified,
            ),
            const SizedBox(height: 16),



            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CustomText(
                  text: _error,
                  fontSize: 13,
                  color: Colors.red,
                ),
              ),

            const SizedBox(height: 20),
            CustomBtn(text: "Reset Password", onPressed: _onReset),

             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
