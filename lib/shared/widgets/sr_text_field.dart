import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class SrTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool showTogglePassword;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final String? prefixText;
  final Widget? suffixIcon;
  final bool enabled;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const SrTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showTogglePassword = false,
    this.inputFormatters,
    this.maxLines = 1,
    this.prefixText,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  State<SrTextField> createState() => _SrTextFieldState();
}

class _SrTextFieldState extends State<SrTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: SrColors.textPrimary,
          ),
        ),
        const SizedBox(height: SrSpacing.xs),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscure,
          inputFormatters: widget.inputFormatters,
          maxLines: _obscure ? 1 : widget.maxLines,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          focusNode: widget.focusNode,
          style: const TextStyle(fontSize: 14, color: SrColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixText: widget.prefixText,
            suffixIcon: _buildSuffix(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffix() {
    if (widget.showTogglePassword) {
      return IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: SrColors.textMuted,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    return widget.suffixIcon;
  }
}

class SrNikField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const SrNikField({super.key, this.controller, this.validator});

  @override
  State<SrNikField> createState() => _SrNikFieldState();
}

class _SrNikFieldState extends State<SrNikField> {
  bool _showFull = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('No. KTP (NIK)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SrColors.textPrimary)),
        const SizedBox(height: SrSpacing.xs),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: TextInputType.number,
          obscureText: !_showFull,
          maxLength: 16,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 14, color: SrColors.textPrimary),
          decoration: InputDecoration(
            hintText: '1234 **** **** ****',
            counterText: '',
            suffixIcon: TextButton(
              onPressed: () {
                setState(() => _showFull = true);
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) setState(() => _showFull = false);
                });
              },
              child: const Text('Tampilkan', style: TextStyle(fontSize: 12)),
            ),
          ),
        ),
        const SizedBox(height: SrSpacing.xs),
        const Row(
          children: [
            Icon(Icons.lock_outline, size: 12, color: SrColors.textMuted),
            SizedBox(width: 4),
            Text('NIK dienkripsi, tidak ditampilkan penuh di aplikasi',
                style: TextStyle(fontSize: 11, color: SrColors.textMuted)),
          ],
        ),
      ],
    );
  }
}
