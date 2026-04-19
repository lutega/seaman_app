import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum SrButtonVariant { primary, secondary, ghost, danger }

class SrButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SrButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;

  const SrButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SrButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: 44,
        child: _buildButton(context),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final child = _buildChild();

    switch (variant) {
      case SrButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: SrColors.primary,
            foregroundColor: SrColors.white,
          ),
          child: child,
        );
      case SrButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case SrButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(foregroundColor: SrColors.textMuted),
          child: child,
        );
      case SrButtonVariant.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: SrColors.danger,
            foregroundColor: SrColors.white,
          ),
          child: child,
        );
    }
  }

  Widget _buildChild() {
    if (isLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: SrSpacing.sm),
          Text('Memuat...'),
        ],
      );
    }

    if (leadingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, size: 20),
          const SizedBox(width: SrSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}

class SrIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  const SrIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: color ?? SrColors.textPrimary),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
