import 'dart:math' show sin;

import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

/// App loading widget with multiple loading states
/// Supports: circular progress, skeleton loaders, custom loaders
class AppLoader extends StatelessWidget {
  final LoaderType type;
  final String? message;
  final double size;

  const AppLoader({
    super.key,
    this.type = LoaderType.circular,
    this.message,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoaderType.circular:
        return _buildCircularLoader(context);
      case LoaderType.skeleton:
        return _buildSkeletonLoader();
      case LoaderType.dots:
        return _buildDotsLoader(context);
      case LoaderType.linear:
        return _buildLinearLoader();
    }
  }

  Widget _buildCircularLoader(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: ClipRRect(
              borderRadius: AppBorderRadius.all12,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppBorderRadius.all12,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotsLoader(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DotLoader(size: size),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinearLoader() {
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        minHeight: 4,
        backgroundColor: AppColors.background,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primary,
        ),
      ),
    );
  }
}

/// Animated dots loader
class _DotLoader extends StatefulWidget {
  final double size;

  const _DotLoader({required this.size});

  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.1;
              final value = (_controller.value - delay) % 1.0;
              final opacity = sin(value * 3.14159) * 0.8 + 0.2;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: opacity),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}


enum LoaderType { circular, skeleton, dots, linear }
