import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final int? maxLines;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool showValidationIcon;
  final bool autoValidate;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.showValidationIcon = true,
    this.autoValidate = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  String? _errorText;
  bool _hasInteracted = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.autoValidate && _hasInteracted && widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.controller?.text);
        _isValid = _errorText == null && 
                   widget.controller?.text.isNotEmpty == true;
      });
    }
  }

  Widget? _buildSuffixIcon() {
    // If custom suffix icon is provided, use it
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    // Show validation icon if enabled and field has been interacted with
    if (widget.showValidationIcon && 
        _hasInteracted && 
        widget.controller?.text.isNotEmpty == true &&
        widget.validator != null) {
      if (_isValid) {
        return const Icon(
          Icons.check_circle,
          color: AppTheme.successGreen,
          size: 20,
        );
      } else if (_errorText != null) {
        return const Icon(
          Icons.error,
          color: AppTheme.dangerRed,
          size: 20,
        );
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLines: widget.maxLines,
      autovalidateMode: widget.autoValidate && _hasInteracted
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      onChanged: (value) {
        if (!_hasInteracted) {
          setState(() {
            _hasInteracted = true;
          });
        }
        widget.onChanged?.call(value);
      },
      onTap: () {
        if (!_hasInteracted) {
          setState(() {
            _hasInteracted = true;
          });
        }
        if (widget.onTap != null && widget.readOnly) {
          widget.onTap!();
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: _buildSuffixIcon(),
        // Enhanced error styling
        errorStyle: const TextStyle(
          color: AppTheme.dangerRed,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 2,
        // Red border when there's an error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.dangerRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.dangerRed, width: 2),
        ),
      ),
    );
  }
}
