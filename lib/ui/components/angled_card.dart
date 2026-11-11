import 'dart:math' as math;

import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';

/// Borde con la esquina superior derecha cortada en diagonal y las demás
/// redondeadas (§7.1, principio 3: el ángulo evoca la flecha de Ascend).
@immutable
class AngledCornerBorder extends OutlinedBorder {
  const new({
    super.side,
    this.cut = AscendShapes.cut,
    this.radius = AscendShapes.radius,
  }) : assert(cut >= 0, 'cut no puede ser negativo'),
       assert(radius >= 0, 'radius no puede ser negativo');

  /// Lado del triángulo que se corta en la esquina superior derecha.
  final double cut;

  /// Radio de las otras tres esquinas.
  final double radius;

  Path _path(Rect rect, double cut, double radius) {
    final maxCorner = math.min(rect.width, rect.height) / 2;
    final c = math.min(cut, maxCorner);
    final r = math.min(radius, maxCorner);
    final arc = Radius.circular(r);
    return Path()
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - c, rect.top)
      ..lineTo(rect.right, rect.top + c)
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(Offset(rect.right - r, rect.bottom), radius: arc)
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - r), radius: arc)
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: arc)
      ..close();
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, cut, radius);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final inset = side.strokeInset;
    return _path(
      rect.deflate(inset),
      math.max(0, cut - inset),
      math.max(0, radius - inset),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    // Trazo centrado en el borde interior para no salirse del widget.
    final half = side.width / 2;
    canvas.drawPath(
      _path(
        rect.deflate(half),
        math.max(0, cut - half),
        math.max(0, radius - half),
      ),
      side.toPaint(),
    );
  }

  @override
  AngledCornerBorder copyWith({BorderSide? side, double? cut, double? radius}) {
    return AngledCornerBorder(
      side: side ?? this.side,
      cut: cut ?? this.cut,
      radius: radius ?? this.radius,
    );
  }

  @override
  ShapeBorder scale(double t) =>
      AngledCornerBorder(side: side.scale(t), cut: cut * t, radius: radius * t);

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is AngledCornerBorder) {
      return AngledCornerBorder(
        side: BorderSide.lerp(a.side, side, t),
        cut: lerpDouble(a.cut, cut, t),
        radius: lerpDouble(a.radius, radius, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is AngledCornerBorder) {
      return AngledCornerBorder(
        side: BorderSide.lerp(side, b.side, t),
        cut: lerpDouble(cut, b.cut, t),
        radius: lerpDouble(radius, b.radius, t),
      );
    }
    return super.lerpTo(b, t);
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) =>
      other is AngledCornerBorder &&
      other.side == side &&
      other.cut == cut &&
      other.radius == radius;

  @override
  int get hashCode => Object.hash(side, cut, radius);
}

/// Tarjeta destacada con esquina cortada. Con [accent] el borde es rojo.
class AngledCard extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.onTap,
    this.accent = false,
    this.padding = const EdgeInsets.all(AscendSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ascendColors;
    final shape = AngledCornerBorder(
      side: BorderSide(
        color: accent ? colors.primaryText : colors.border,
        width: accent ? 1.5 : 1,
      ),
    );
    return Material(
      color: theme.colorScheme.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
