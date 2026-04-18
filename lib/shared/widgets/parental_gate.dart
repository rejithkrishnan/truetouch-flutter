import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ParentalGate extends StatefulWidget {
  final Widget child;
  final VoidCallback onUnlocked;
  
  // Size of the invisible trigger zone
  final double hitboxSize;
  
  const ParentalGate({
    super.key,
    required this.child,
    required this.onUnlocked,
    this.hitboxSize = 80.0,
  });

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        setState(() => _tapPosition = null);
        widget.onUnlocked();
      }
    });

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    final size = MediaQuery.of(context).size;
    // Check if tap is in bottom-right corner
    if (event.localPosition.dx > size.width - widget.hitboxSize &&
        event.localPosition.dy > size.height - widget.hitboxSize) {
      setState(() => _tapPosition = event.localPosition);
      _controller.forward();
    }
  }

  void _handlePointerUp(PointerEvent event) {
    _cancelHold();
  }

  void _cancelHold() {
    if (_controller.isAnimating) {
      _controller.reset();
      setState(() => _tapPosition = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerUp,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // The underlying content (screens)
          widget.child,

          // Subtle parent lock hint — faint enough kids ignore it
          Positioned(
            right: 24,
            bottom: 24,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.18,
                child: Container(
                  width: widget.hitboxSize,
                  height: widget.hitboxSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.black54,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),

          // Horizontal loading line fills L→R at the bottom while holding
          if (_tapPosition != null && _controller.value > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 6,
              child: IgnorePointer(
                child: Stack(
                  children: [
                    // Track (faint gray background)
                    Container(color: Colors.black12),
                    // Red fill that grows from left to right
                    FractionallySizedBox(
                      widthFactor: _controller.value,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
