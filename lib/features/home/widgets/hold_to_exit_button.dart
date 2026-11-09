import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import '../../../core/theme/app_theme.dart';

class HoldToExitButton extends StatefulWidget {
  const HoldToExitButton({super.key});

  @override
  State<HoldToExitButton> createState() => _HoldToExitButtonState();
}

class _HoldToExitButtonState extends State<HoldToExitButton>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // 3-second hold progress controller (0.0 -> 1.0)
  late AnimationController _holdController;

  // Continuous looping heartbeat pulse controller (~900ms per beat)
  late AnimationController _pulseController;

  Timer? _heartbeatHapticTimer;

  bool _isPinned = false;
  StreamSubscription<KioskMode>? _kioskSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1. Hold timer (3 seconds required to exit)
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _holdController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        _stopHeartbeat();
        HapticFeedback.heavyImpact();

        // Release OS screen pinning / kiosk mode
        try {
          await stopKioskMode();
        } catch (_) {}

        // Quit the application cleanly
        await SystemNavigator.pop();
      }
    });

    _holdController.addListener(() {
      setState(() {});
    });

    // 2. Heartbeat expand-and-fade animation loop
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController.addListener(() {
      setState(() {});
    });

    // 3. Check and monitor kiosk / pinning state
    _updateKioskStatus();
    _kioskSubscription = watchKioskMode().listen((mode) {
      if (mounted) {
        setState(() {
          _isPinned = mode == KioskMode.enabled;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When returning from Android's native "Pin this app?" system dialog
    if (state == AppLifecycleState.resumed) {
      _updateKioskStatus();
    }
  }

  Future<void> _updateKioskStatus() async {
    try {
      final mode = await getKioskMode();
      if (mounted) {
        setState(() {
          _isPinned = mode == KioskMode.enabled;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _kioskSubscription?.cancel();
    _stopHeartbeat();
    _holdController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startHeartbeat() {
    _heartbeatHapticTimer?.cancel();
    HapticFeedback.selectionClick();

    // Rhythmic haptic pulses synchronized with the heartbeat
    _heartbeatHapticTimer = Timer.periodic(
      const Duration(milliseconds: 450),
      (_) => HapticFeedback.selectionClick(),
    );

    _pulseController.repeat();
    _holdController.forward();
  }

  void _stopHeartbeat() {
    _heartbeatHapticTimer?.cancel();
    _heartbeatHapticTimer = null;
    if (_pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _cancelHold() {
    _stopHeartbeat();
    if (_holdController.isAnimating) {
      _holdController.reverse();
    }
  }

  Future<void> _handlePinTap() async {
    HapticFeedback.mediumImpact();
    try {
      await startKioskMode();
      await Future.delayed(const Duration(milliseconds: 500));
      await _updateKioskStatus();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isHolding = _holdController.value > 0;
    
    // Dynamic styling based on pinning state
    final activeColor = _isPinned
        ? Color.lerp(
            AppColors.softCoral,
            AppColors.goldenSunbeam,
            _holdController.value,
          )!
        : AppColors.softSky;

    final buttonIcon = _isPinned
        ? Icons.power_settings_new_rounded
        : Icons.push_pin_rounded;

    final buttonLabel = _isPinned ? 'Hold to Exit' : 'Pin App';

    return GestureDetector(
      onTap: !_isPinned ? _handlePinTap : null,
      onTapDown: _isPinned ? (_) => _startHeartbeat() : null,
      onTapUp: _isPinned ? (_) => _cancelHold() : null,
      onTapCancel: _isPinned ? () => _cancelHold() : null,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ── Heartbeat Expand-and-Fade Ripples ────────────────────────
                // Shown while holding to exit
                if (_isPinned && isHolding) ...[
                  _HeartbeatRippleWave(
                    progress: _pulseController.value,
                    holdProgress: _holdController.value,
                    phaseOffset: 0.0,
                    activeColor: activeColor,
                  ),
                  _HeartbeatRippleWave(
                    progress: _pulseController.value,
                    holdProgress: _holdController.value,
                    phaseOffset: 0.45,
                    activeColor: activeColor,
                  ),
                ],

                // ── Outer Unobstructed Progress Halo ─────────────────────────
                // Diameter 76px sits well outside the finger contact zone (~48px)
                if (_isPinned && isHolding)
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      value: _holdController.value,
                      color: activeColor,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      strokeWidth: 4.5,
                      strokeCap: StrokeCap.round,
                    ),
                  ),

                // ── Central Button ──────────────────────────────────────────
                Transform.scale(
                  scale: (_isPinned && isHolding)
                      ? 1.0 + (0.08 * (1.0 - (_pulseController.value * 2 - 1).abs()))
                      : 1.0,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isPinned
                                  ? AppColors.softCoral
                                  : AppColors.softSky)
                              .withValues(
                            alpha: (_isPinned && isHolding) ? 0.45 : 0.2,
                          ),
                          blurRadius: (_isPinned && isHolding) ? 14 : 8,
                          spreadRadius: (_isPinned && isHolding) ? 2 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      buttonIcon,
                      color: _isPinned ? AppColors.softCoral : AppColors.softSky,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            buttonLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A radiant ripple ring that expands outward from behind the button and fades out.
class _HeartbeatRippleWave extends StatelessWidget {
  final double progress;
  final double holdProgress;
  final double phaseOffset;
  final Color activeColor;

  const _HeartbeatRippleWave({
    required this.progress,
    required this.holdProgress,
    required this.phaseOffset,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgress = (progress + phaseOffset) % 1.0;
    final curved = Curves.easeOutQuad.transform(effectiveProgress);

    // Expands outward from 52px (button edge) to 125px (far outside finger)
    final size = 52.0 + (curved * 73.0);
    // Smoothly fades from 0.7 down to 0.0 as it reaches maximum radius
    final opacity = (1.0 - effectiveProgress).clamp(0.0, 1.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: activeColor.withValues(alpha: 0.18 * opacity),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.55 * opacity),
          width: 2.0 * (1.0 - curved * 0.4),
        ),
      ),
    );
  }
}
