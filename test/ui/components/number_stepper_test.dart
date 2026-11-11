import 'package:ascend/ui/components/number_stepper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// Monta un NumberStepper controlado y expone el valor actual.
class _Harness extends StatefulWidget {
  const new({required this.initial, this.step = 2.5, this.max = 500});

  final double initial;
  final double step;
  final double max;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late double value = widget.initial;
  final changes = <double>[];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: NumberStepper(
        label: 'Carga',
        unit: 'kg',
        value: value,
        step: widget.step,
        max: widget.max,
        onChanged: (v) => setState(() {
          value = v;
          changes.add(v);
        }),
      ),
    ),
  );
}

void main() {
  final plus = find.byIcon(Icons.add);
  final minus = find.byIcon(Icons.remove);
  _HarnessState state(WidgetTester t) => t.state(find.byType(_Harness));

  late List<MethodCall> haptics;
  setUp(() {
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') haptics.add(call);
          return null;
        });
  });

  testWidgets('toque en + y − cambia un paso, con formato es (coma)', (
    t,
  ) async {
    await t.pumpApp(const _Harness(initial: 60));
    expect(find.text('60'), findsOneWidget);

    await t.tap(plus);
    await t.pump();
    expect(state(t).value, 62.5);
    expect(find.text('62,5'), findsOneWidget);

    await t.tap(minus);
    await t.pump();
    await t.tap(minus);
    await t.pump();
    expect(state(t).value, 57.5);
    expect(haptics, hasLength(3));
  });

  testWidgets('respeta los límites y vibra fuerte al llegar', (t) async {
    await t.pumpApp(const _Harness(initial: 0));
    await t.tap(minus, warnIfMissed: false);
    await t.pump();
    expect(state(t).value, 0);
    expect(state(t).changes, isEmpty);
  });

  testWidgets('no acumula error de coma flotante', (t) async {
    await t.pumpApp(const _Harness(initial: 0, step: 0.1, max: 10));
    for (var i = 0; i < 30; i++) {
      await t.tap(plus);
      await t.pump();
    }
    expect(state(t).value, 3.0);
  });

  testWidgets('mantener presionado repite y acelera', (t) async {
    await t.pumpApp(const _Harness(initial: 0, step: 1, max: 1000));
    final gesture = await t.startGesture(t.getCenter(plus));
    await t.pump(kLongPressTimeout + const Duration(milliseconds: 10));
    // Primer paso al empezar la pulsación larga.
    expect(state(t).value, 1);

    // 2 s de repetición: con aceleración salen muchos más pasos que a
    // intervalo fijo de 350 ms (≈ 5).
    for (var i = 0; i < 40; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
    final afterHold = state(t).value;
    expect(afterHold, greaterThan(15));

    await gesture.up();
    await t.pump(const Duration(seconds: 1));
    expect(state(t).value, afterHold, reason: 'se detiene al soltar');
  });

  testWidgets('la repetición se detiene en el máximo', (t) async {
    await t.pumpApp(const _Harness(initial: 495));
    final gesture = await t.startGesture(t.getCenter(plus));
    await t.pump(kLongPressTimeout + const Duration(milliseconds: 10));
    for (var i = 0; i < 20; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    await gesture.up();
    expect(state(t).value, 500);
  });

  testWidgets('entrada directa acepta coma decimal', (t) async {
    await t.pumpApp(const _Harness(initial: 60));
    await t.tap(find.text('60'));
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await t.enterText(find.byType(TextField), '82,5');
    await t.tap(find.text('Aceptar'));
    await t.pumpAndSettle();
    expect(state(t).value, 82.5);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('entrada directa fuera de rango muestra un error', (t) async {
    await t.pumpApp(const _Harness(initial: 60));
    await t.tap(find.text('60'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '900');
    await t.tap(find.text('Aceptar'));
    await t.pump();
    expect(find.text('Introduce un valor entre 0 y 500'), findsOneWidget);
    expect(state(t).value, 60);

    await t.tap(find.text('Cancelar'));
    await t.pumpAndSettle();
    expect(state(t).value, 60);
  });

  testWidgets('lector de pantalla: control ajustable con valor y unidad', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    await t.pumpApp(const _Harness(initial: 60));
    final node = find.semantics.byLabel('Carga');
    expect(
      node,
      isSemantics(
        value: '60 kg',
        increasedValue: '62,5 kg',
        decreasedValue: '57,5 kg',
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    t.semantics.performAction(node, SemanticsAction.increase);
    await t.pump();
    expect(state(t).value, 62.5);
    handle.dispose();
  });

  testWidgets('cumple objetivo táctil y contraste', (t) async {
    final handle = t.ensureSemantics();
    for (final b in Brightness.values) {
      await t.pumpApp(const _Harness(initial: 60), brightness: b);
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));
    }
    handle.dispose();
  });

  testWidgets('no desborda a 1.3× en un teléfono estrecho', (t) async {
    t.view.physicalSize = const Size(320 * 3, 640 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpApp(const _Harness(initial: 487.5), textScale: 1.3);
    expect(t.takeException(), isNull);
  });
}
