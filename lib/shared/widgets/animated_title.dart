import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Renders a title string with a staggered per-character bounce-in animation.
/// Re-animates every time [text] changes.
class AnimatedTitle extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const AnimatedTitle({super.key, required this.text, this.style});

  @override
  State<AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle> {
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
  }

  @override
  void didUpdateWidget(AnimatedTitle old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      setState(() => _displayText = widget.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ??
        Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _displayText.split('').asMap().entries.map((entry) {
        final i = entry.key;
        final char = entry.value;

        // Spaces get a thin spacer — no animation needed
        if (char == ' ') {
          return SizedBox(width: style?.fontSize != null ? style!.fontSize! * 0.3 : 12);
        }

        return Text(char, style: style)
            .animate(key: ValueKey('$_displayText-$i'))
            .slideY(
              begin: -0.6,
              end: 0,
              duration: 400.ms,
              delay: (i * 45).ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(
              duration: 200.ms,
              delay: (i * 45).ms,
            );
      }).toList(),
    );
  }
}
