import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// 6-box OTP input. Auto-advances on each digit, auto-submits via [onCompleted]
/// when the last box is filled, and supports paste-of-6 by listening on the
/// first box's onChanged.
class OtpBoxes extends StatefulWidget {
  /// Called when the user enters all 6 digits. The argument is the joined OTP.
  final ValueChanged<String> onCompleted;

  /// Called on every keystroke with the in-progress code.
  final ValueChanged<String>? onChanged;

  final bool enabled;

  const OtpBoxes({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  static const _length = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _nodes = List.generate(_length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _handleChange(int index, String value) {
    // Paste support — first box receives the entire string at once.
    if (index == 0 && value.length == _length) {
      for (int i = 0; i < _length; i++) {
        _controllers[i].text = value[i];
      }
      _nodes[_length - 1].unfocus();
      widget.onChanged?.call(_code);
      widget.onCompleted(_code);
      return;
    }

    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
    }

    if (value.isNotEmpty && index < _length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }

    widget.onChanged?.call(_code);
    if (_code.length == _length && !_code.contains(RegExp(r'\D'))) {
      widget.onCompleted(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_length, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _nodes[index],
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: index == 0 ? _length : 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.titleLarge(context).copyWith(
              fontWeight: AppTypography.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: AppColors.surfaceContainerOf(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primaryOf(context),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (v) => _handleChange(index, v),
          ),
        );
      }),
    );
  }
}
