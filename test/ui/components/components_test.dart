import 'package:ascend/ui/components/angled_card.dart';
import 'package:ascend/ui/components/ascend_button.dart';
import 'package:ascend/ui/components/ascend_chip.dart';
import 'package:ascend/ui/components/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AscendButton', () {
    testWidgets('cada variante usa su botón Material y responde', (t) async {
      var taps = 0;
      await t.pumpApp(
        Scaffold(
          body: Column(
            children: [
              for (final v in AscendButtonVariant.values)
                AscendButton(
                  label: v.name,
                  variant: v,
                  onPressed: () => taps++,
                ),
            ],
          ),
        ),
      );
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      for (final v in AscendButtonVariant.values) {
        await t.tap(find.text(v.name));
      }
      expect(taps, 3);
      expect(
        t.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('expanded ocupa todo el ancho', (t) async {
      await t.pumpApp(
        Scaffold(
          body: AscendButton(label: 'x', expanded: true, onPressed: () {}),
        ),
      );
      expect(t.getSize(find.byType(FilledButton)).width, 800);
    });
  });

  group('AscendChip', () {
    testWidgets('alterna la selección y la anuncia sin depender del color', (
      t,
    ) async {
      final handle = t.ensureSemantics();
      bool? last;
      await t.pumpApp(
        Scaffold(
          body: AscendChip(
            label: '5+',
            semanticLabel: 'RIR 5 o más',
            selected: true,
            onSelected: (s) => last = s,
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        find.semantics.byLabel('RIR 5 o más'),
        isSemantics(isSelected: true, isButton: true),
      );
      await t.tap(find.text('5+'));
      expect(last, isFalse);
      expect(
        t.getSize(find.byType(AscendChip)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });

  group('StatTile', () {
    testWidgets('se lee como una sola frase', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpApp(
        const Scaffold(
          body: StatTile(label: 'Racha', value: '42', unit: 'días'),
        ),
      );
      expect(find.semantics.byLabel('Racha, 42, días'), findsOne);
      handle.dispose();
    });
  });

  group('AngledCornerBorder', () {
    test('corta la esquina superior derecha', () {
      const border = AngledCornerBorder(cut: 20, radius: 0);
      final path = border.getOuterPath(const Rect.fromLTWH(0, 0, 100, 60));
      expect(path.contains(const Offset(99, 1)), isFalse, reason: 'cortada');
      expect(path.contains(const Offset(1, 1)), isTrue);
      expect(path.contains(const Offset(99, 59)), isTrue);
    });

    test('el corte nunca supera la mitad del lado menor', () {
      const border = AngledCornerBorder(cut: 500, radius: 0);
      final path = border.getOuterPath(const Rect.fromLTWH(0, 0, 100, 40));
      expect(path.contains(const Offset(10, 30)), isTrue);
    });

    test('lerp, scale y copyWith', () {
      const a = AngledCornerBorder(cut: 10, radius: 2);
      const b = AngledCornerBorder(cut: 30);
      final mid = b.lerpFrom(a, 0.5)! as AngledCornerBorder;
      expect(mid.cut, 20);
      expect(mid.radius, 4);
      expect((a.scale(2) as AngledCornerBorder).cut, 20);
      expect(a.copyWith(cut: 5).cut, 5);
      expect(a, const AngledCornerBorder(cut: 10, radius: 2));
    });

    testWidgets('AngledCard responde al toque', (t) async {
      var taps = 0;
      await t.pumpApp(
        Scaffold(
          body: AngledCard(onTap: () => taps++, child: const Text('c')),
        ),
      );
      await t.tap(find.text('c'));
      expect(taps, 1);
    });
  });
}
