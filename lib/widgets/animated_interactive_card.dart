import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AnimatedInteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const AnimatedInteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(30.0),
    this.margin,
  });

  @override
  State<AnimatedInteractiveCard> createState() => _AnimatedInteractiveCardState();
}

class _AnimatedInteractiveCardState extends State<AnimatedInteractiveCard> 
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          margin: widget.margin,
          transform: Matrix4.translationValues(0, _isHovered ? -4.0 : 0, 0)
            ..scale(_isHovered ? 1.01 : 1.0),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppColors.plum.withAlpha((0.15 * 255).toInt()),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? AppColors.hoverShadowColor() 
                    : AppColors.cardShadowColor(),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 6 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Accent
              Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMedium - 1),
                  ),
                ),
              ),
              Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}