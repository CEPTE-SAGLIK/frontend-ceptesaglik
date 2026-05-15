import 'package:flutter/material.dart';
import 'package:health_asistants/core/error/app_error.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';

class ErrorStateWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final ErrorStateStyle style;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.style = ErrorStateStyle.fullPage,
  });

  factory ErrorStateWidget.fromMessage(
    String message, {
    VoidCallback? onRetry,
    ErrorStateStyle style = ErrorStateStyle.fullPage,
  }) {
    return ErrorStateWidget(
      error: AppError.fromString(message),
      onRetry: onRetry,
      style: style,
    );
  }

  factory ErrorStateWidget.network({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      error: AppError.network(),
      onRetry: onRetry,
    );
  }

  factory ErrorStateWidget.server({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      error: AppError.server(),
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      ErrorStateStyle.fullPage => _buildFullPage(),
      ErrorStateStyle.card => _buildCard(),
      ErrorStateStyle.inline => _buildInline(),
    };
  }

  Widget _buildFullPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconContainer(size: 100),
            const SizedBox(height: AppSpacing.xl),
            _buildMessage(fontSize: 16),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildRetryButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: error.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(size: 64),
          const SizedBox(height: AppSpacing.md),
          _buildMessage(),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildRetryButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildInline() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: error.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: error.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(error.icon, color: error.color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              error.message,
              style: TextStyle(
                fontSize: 13,
                color: error.color,
                height: 1.4,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Tekrar Dene',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: error.color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconContainer({double size = 80}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: error.color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(error.icon, size: size * 0.5, color: error.color),
    );
  }

  Widget _buildMessage({double fontSize = 15}) {
    return Text(
      error.message,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildRetryButton() {
    return FilledButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Tekrar Dene'),
      style: FilledButton.styleFrom(
        backgroundColor: error.color,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

enum ErrorStateStyle { fullPage, card, inline }
