import 'dart:async';
import 'dart:math' as math;

import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Selector numérico −/+ para kg, reps, etc.
///
/// - Toque en −/+: un paso ([step]).
/// - Mantener presionado: repite y acelera.
/// - Toque en el número: entrada directa con teclado numérico.
/// - Háptica en cada paso; vibración más fuerte al llegar a un límite.
/// - Lector de pantalla: control ajustable (deslizar arriba/abajo).
class NumberStepper extends StatefulWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
    this.step = 1,
    this.min = 0,
    this.max = 9999,
    this.unit,
    this.fractionDigits,
  }) : assert(step > 0, 'step debe ser positivo'),
       assert(min <= max, 'min debe ser ≤ max');

  final double value;
  final ValueChanged<double> onChanged;

  /// Nombre del valor para el lector de pantalla y el diálogo («Carga»).
  final String label;
  final double step;
  final double min;
  final double max;
  final String? unit;

  /// Decimales a mostrar; por defecto, los del [step] (2.5 → 1).
  final int? fractionDigits;

  /// Intervalo inicial al mantener presionado.
  static const initialRepeat = Duration(milliseconds: 350);

  /// Intervalo mínimo al que acelera.
  static const fastestRepeat = Duration(milliseconds: 50);

  /// Factor de aceleración por repetición.
  static const acceleration = 0.8;

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  int get _digits {
    if (widget.fractionDigits != null) return widget.fractionDigits!;
    final text = widget.step.toString();
    final dot = text.indexOf('.');
    if (dot < 0) return 0;
    final decimals = text.substring(dot + 1).replaceAll(RegExp(r'0+$'), '');
    return decimals.length;
  }

  double _round(double v) => double.parse(v.toStringAsFixed(_digits));

  double _clamp(double v) => v.clamp(widget.min, widget.max);

  bool get _canDecrease => widget.value > widget.min;
  bool get _canIncrease => widget.value < widget.max;

  String _format(double v) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final f = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = _digits;
    return f.format(v);
  }

  /// Aplica un paso. Devuelve `false` si ya está en el límite.
  bool _step(int direction) {
    final next = _clamp(_round(widget.value + direction * widget.step));
    if (next == widget.value) {
      unawaited(HapticFeedback.heavyImpact());
      return false;
    }
    unawaited(HapticFeedback.selectionClick());
    widget.onChanged(next);
    return true;
  }

  Future<void> _editDirectly() async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _DirectEntryDialog(
        label: widget.label,
        initial: _format(widget.value),
        min: widget.min,
        max: widget.max,
        format: _format,
        unit: widget.unit,
      ),
    );
    if (result != null && mounted) {
      final next = _clamp(_round(result));
      if (next != widget.value) widget.onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.ascendColors;
    final valueText = _format(widget.value);
    final withUnit = widget.unit == null
        ? valueText
        : '$valueText ${widget.unit}';

    String? adjusted(int direction) {
      final next = _clamp(_round(widget.value + direction * widget.step));
      if (next == widget.value) return null;
      final t = _format(next);
      return widget.unit == null ? t : '$t ${widget.unit}';
    }

    return Semantics(
      container: true,
      label: widget.label,
      value: withUnit,
      increasedValue: adjusted(1),
      decreasedValue: adjusted(-1),
      onIncrease: _canIncrease ? () => _step(1) : null,
      onDecrease: _canDecrease ? () => _step(-1) : null,
      child: Row(
        children: [
          _RepeatButton(
            icon: Icons.remove,
            tooltip: l10n.stepperDecrease(widget.label),
            enabled: _canDecrease,
            onStep: () => _step(-1),
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: l10n.stepperEditHint,
              excludeSemantics: true,
              onTap: _editDirectly,
              child: InkWell(
                onTap: _editDirectly,
                borderRadius: BorderRadius.circular(AscendShapes.radius),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AscendShapes.minTouch + AscendSpacing.sm,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AscendSpacing.xs,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            valueText,
                            style: theme.textTheme.displaySmall,
                            maxLines: 1,
                          ),
                        ),
                        if (widget.unit != null)
                          Text(
                            widget.unit!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _RepeatButton(
            icon: Icons.add,
            tooltip: l10n.stepperIncrease(widget.label),
            enabled: _canIncrease,
            onStep: () => _step(1),
          ),
        ],
      ),
    );
  }
}

/// Botón −/+ que repite y acelera mientras se mantiene presionado.
class _RepeatButton extends StatefulWidget {
  const new({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onStep,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;

  /// Devuelve `false` cuando ya no se puede seguir (límite alcanzado).
  final bool Function() onStep;

  @override
  State<_RepeatButton> createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<_RepeatButton> {
  Timer? _timer;
  bool _pressed = false;

  void _startRepeating() {
    _stop();
    setState(() => _pressed = true);
    if (!widget.onStep()) return;
    _schedule(NumberStepper.initialRepeat);
  }

  void _schedule(Duration interval) {
    _timer = Timer(interval, () {
      if (!mounted || !widget.onStep()) return _stop();
      final nextMs = math.max(
        NumberStepper.fastestRepeat.inMilliseconds,
        (interval.inMilliseconds * NumberStepper.acceleration).round(),
      );
      _schedule(Duration(milliseconds: nextMs));
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (mounted && _pressed) setState(() => _pressed = false);
  }

  @override
  void didUpdateWidget(_RepeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.ascendColors;
    final enabled = widget.enabled;
    return Tooltip(
      message: widget.tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.tooltip,
        onTap: enabled ? widget.onStep : null,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onStep : null,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: (_) => _stop(),
          onTapCancel: _stop,
          onLongPressStart: enabled ? (_) => _startRepeating() : null,
          onLongPressEnd: (_) => _stop(),
          onLongPressCancel: _stop,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: AscendShapes.minTouch + AscendSpacing.sm,
            height: AscendShapes.minTouch + AscendSpacing.sm,
            decoration: BoxDecoration(
              color: _pressed ? scheme.primary : colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AscendShapes.radius),
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              widget.icon,
              color: !enabled
                  ? colors.textMuted.withValues(alpha: 0.5)
                  : _pressed
                  ? scheme.onPrimary
                  : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectEntryDialog extends StatefulWidget {
  const new({
    required this.label,
    required this.initial,
    required this.min,
    required this.max,
    required this.format,
    this.unit,
  });

  final String label;
  final String initial;
  final double min;
  final double max;
  final String Function(double) format;
  final String? unit;

  @override
  State<_DirectEntryDialog> createState() => _DirectEntryDialogState();
}

class _DirectEntryDialogState extends State<_DirectEntryDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.initial.length,
        );
  String? _error;

  /// Acepta coma o punto como separador decimal.
  static double? parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final value = parse(_controller.text);
    if (value == null || value < widget.min || value > widget.max) {
      setState(() {
        _error = l10n.stepperOutOfRange(
          widget.format(widget.min),
          widget.format(widget.max),
        );
      });
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.label),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))],
        style: Theme.of(context).textTheme.headlineMedium,
        decoration: InputDecoration(
          suffixText: widget.unit,
          errorText: _error,
          errorMaxLines: 3,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionAccept)),
      ],
    );
  }
}
