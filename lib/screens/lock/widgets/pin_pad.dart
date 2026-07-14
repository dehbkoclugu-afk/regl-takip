import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kilit ekranı ve PIN kurulumu aynı tuş takımını kullanır.
class PinPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final bool enabled;

  const PinPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.enabled = true,
  });

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: _rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) return const SizedBox(width: 72);
                if (key == 'del') {
                  return Semantics(
                    button: true,
                    label:
                        MaterialLocalizations.of(context).deleteButtonTooltip,
                    child: _PinPadButton(
                      onTap: enabled ? onDelete : null,
                      child: const Icon(Icons.backspace_rounded,
                          color: Colors.white, size: 24),
                    ),
                  );
                }
                return _PinPadButton(
                  onTap: enabled ? () => onDigit(key) : null,
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PinPadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PinPadButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        borderRadius: BorderRadius.circular(36),
        splashColor: Colors.white24,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: enabled ? 0.1 : 0.04),
          ),
          child: Center(
            child: Opacity(opacity: enabled ? 1 : 0.4, child: child),
          ),
        ),
      ),
    );
  }
}

/// Girilen hane sayısını gösteren noktalar. Ekran okuyucuya tek bir
/// canlı bölge olarak duyurulur ("2/4"), noktalar tek tek okunmaz.
class PinDots extends StatelessWidget {
  final int filled;
  final int length;
  final bool isError;

  const PinDots({
    super.key,
    required this.filled,
    this.length = 4,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$filled/$length',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(length, (i) {
            final isFilled = i < filled;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: isFilled ? 18 : 14,
              height: isFilled ? 18 : 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError
                    ? Colors.yellow.shade200
                    : isFilled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                border: !isFilled
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 2)
                    : null,
              ),
            );
          }),
        ),
      ),
    );
  }
}
