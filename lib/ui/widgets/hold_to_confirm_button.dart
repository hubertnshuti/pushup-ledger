import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';

/// A pill that must be held down until its fill reaches the right edge.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    required this.label,
    required this.labelColor,
    required this.onConfirmed,
    super.key,
  });

  final String label;

  /// Label color before the orange fill passes over it.
  final Color labelColor;
  final VoidCallback onConfirmed;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: AppMotion.holdToConfirm,
    )..addStatusListener(_onStatus);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _confirm();
    }
  }

  void _confirm() {
    if (_isConfirmed) {
      return;
    }
    _isConfirmed = true;
    HapticFeedback.mediumImpact();
    widget.onConfirmed();
  }

  void _start() {
    if (!_isConfirmed) {
      _progress.forward();
    }
  }

  void _reset() {
    if (!_isConfirmed) {
      _progress.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      onLongPress: _confirm,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _reset(),
        onPointerCancel: (_) => _reset(),
        child: ClipPath(
          clipper: const ShapeBorderClipper(shape: StadiumBorder()),
          child: DecoratedBox(
            decoration: const ShapeDecoration(
              shape: StadiumBorder(
                side: BorderSide(
                  color: AppColors.orange,
                  width: AppSizes.ringStroke,
                ),
              ),
            ),
            child: SizedBox(
              height: AppSizes.primaryButton,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    _Label(text: widget.label, color: widget.labelColor),
                    ClipRect(
                      clipper: _SweepClipper(_progress.value),
                      child: ColoredBox(
                        color: AppColors.orange,
                        child: _Label(text: widget.label, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: AppTypography.bodyStrong.copyWith(color: color)),
    );
  }
}

class _SweepClipper extends CustomClipper<Rect> {
  const _SweepClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_SweepClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
