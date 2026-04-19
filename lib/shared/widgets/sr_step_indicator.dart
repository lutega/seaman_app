import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class SrStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? labels;

  const SrStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) return _buildConnector(i ~/ 2);
        final step = i ~/ 2;
        return _buildStep(step);
      }),
    );
  }

  Widget _buildStep(int step) {
    final isDone = step < currentStep - 1;
    final isCurrent = step == currentStep - 1;
    final color = isDone || isCurrent ? SrColors.primary : SrColors.border;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? SrColors.primary : (isCurrent ? SrColors.primary.withAlpha(20) : SrColors.cardBg),
            border: Border.all(color: color, width: isCurrent ? 2 : 1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: SrColors.white)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? SrColors.primary : SrColors.textMuted,
                    ),
                  ),
          ),
        ),
        if (labels != null && step < labels!.length) ...[
          const SizedBox(height: 4),
          Text(
            labels![step],
            style: TextStyle(
              fontSize: 10,
              color: isCurrent ? SrColors.primary : SrColors.textMuted,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConnector(int afterStep) {
    final isDone = afterStep < currentStep - 1;
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: SrSpacing.md),
        color: isDone ? SrColors.primary : SrColors.border,
      ),
    );
  }
}
