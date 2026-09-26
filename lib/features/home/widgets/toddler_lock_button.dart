import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import '../../../core/theme/app_theme.dart';

class ToddlerLockButton extends StatefulWidget {
  const ToddlerLockButton({super.key});

  @override
  State<ToddlerLockButton> createState() => _ToddlerLockButtonState();
}

class _ToddlerLockButtonState extends State<ToddlerLockButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLocked = false;
  Timer? _vibrationTimer;
  StreamSubscription<KioskMode>? _kioskSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 3-second hold required
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopVibrationLoop();
        _controller.reset();
        HapticFeedback.heavyImpact();
        _toggleLock();
      }
    });

    _controller.addListener(() {
      setState(() {});
    });

    // Check initial state
    _checkInitialState();

    // Listen to OS-level changes (e.g. parent unpins using hardware buttons)
    _kioskSubscription = watchKioskMode().listen((mode) {
      if (mounted) {
        setState(() {
          _isLocked = mode == KioskMode.enabled;
        });
      }
    });
  }

  Future<void> _checkInitialState() async {
    final mode = await getKioskMode();
    if (mounted) {
      setState(() {
        _isLocked = mode == KioskMode.enabled;
      });
    }
  }

  @override
  void dispose() {
    _stopVibrationLoop();
    _controller.dispose();
    _kioskSubscription?.cancel();
    super.dispose();
  }

  void _startVibrationLoop() {
    _vibrationTimer?.cancel();
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      HapticFeedback.selectionClick();
    });
  }

  void _stopVibrationLoop() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  Future<void> _toggleLock() async {
    if (_isLocked) {
      final stopped = await stopKioskMode();
      if (stopped == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Toddler Lock Disabled.')),
        );
      }
    } else {
      final started = await startKioskMode();
      if (started == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toddler Lock Enabled! The app is now pinned.'),
            backgroundColor: AppColors.toggleOn,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _startVibrationLoop();
        _controller.forward();
      },
      onTapUp: (_) => _cancelHold(),
      onTapCancel: () => _cancelHold(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Background ring that fills up
              if (_controller.isAnimating)
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    color: _isLocked ? Colors.redAccent : AppColors.toggleOn,
                    backgroundColor: Colors.black12,
                    strokeWidth: 4,
                  ),
                ),
              
              // Lock Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white, // Opaque
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  _isLocked ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: _isLocked ? AppColors.toggleOn : Colors.grey,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pin Screen',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancelHold() {
    _stopVibrationLoop();
    if (_controller.isAnimating) {
      _controller.reverse(); // Reverse quickly instead of instant reset
    }
  }
}
