import 'package:flutter/material.dart';

import '../utils/responsive/app_design_tokens.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.size,
    this.iconColor,
    this.isLoading = false,
    this.enabled = true,
  });

  final bool isFavorite;
  final double? size;
  final Color? iconColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  // New cards should display their supplied state without starting an animation.
  bool _hasFavoriteChanged = false;

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _hasFavoriteChanged = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize =
        widget.size ?? AppIconSizes.productFavoriteAction(context);
    final Color offColor =
        widget.iconColor ?? Theme.of(context).colorScheme.onSurface;
    const Color onColor = Colors.red;
    final isFav = widget.isFavorite;
    final finalColor = isFav ? onColor : offColor;

    final popKey = ValueKey<bool>(isFav);

    return TweenAnimationBuilder<double>(
      key: popKey,
      tween: Tween<double>(begin: _hasFavoriteChanged ? 1.2 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              begin: _hasFavoriteChanged
                  ? (isFav ? offColor : onColor)
                  : finalColor,
              end: finalColor,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, animatedColor, __) {
              return IconButton(
                onPressed: () async {
                  widget.enabled && !widget.isLoading
                      ? widget.onPressed.call()
                      : () {};
                },
                splashRadius: iconSize * 0.9,
                iconSize: iconSize,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    );
                  },
                  child: SizedBox(
                    height: iconSize,
                    width: iconSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey<bool>(isFav),
                          color: animatedColor,
                        ),
                        if (widget.isLoading)
                          SizedBox.square(
                            dimension: iconSize * 0.7,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: iconSize * 0.08,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
