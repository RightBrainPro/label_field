import 'package:flutter/material.dart';


/// The animation duration value.
/// 
/// Extracted from:
/// https://github.com/material-components/material-components-android/blob/master/lib/java/com/google/android/material/textfield/TextInputLayout.java
/// 
/// See also:
/// 
///  * [InputDecorator], where the behavior of this widget was taken from.
///  * `material/input_decorator.dart`
const _kTransitionDuration = Duration(milliseconds: 167);

const _kTransitionCurve = Curves.fastOutSlowIn;

const _kFinalLabelScale = 0.75;


/// A widget to show the label text above the field widget.
class LabelField extends StatefulWidget
{
  /// The text to show.
  /// 
  /// If [text] changes from `null` to some value and vice versa, it appears and
  /// hides with animation.
  final String? text;

  /// The style of the [text].
  /// 
  /// If not specified, `Theme.of(context).textTheme.titleMedium` is used.
  final TextStyle? textStyle;

  /// Whether the input field is enabled.
  ///
  /// Defaults to `true`.
  final bool isEnabled;

  /// Whether the input field has focus.
  ///
  /// Defaults to `false`.
  final bool isFocused;

  /// Whether the input field is being hovered over by a mouse pointer.
  ///
  /// Defaults to `false`.
  final bool isHovering;

  /// Whether the field has to show an error.
  /// 
  /// Defaults to `false`.
  final bool hasError;

  const LabelField({
    super.key,
    this.text,
    this.textStyle,
    this.isEnabled = true,
    this.isFocused = false,
    this.isHovering = false,
    this.hasError = false,
  });

  @override
  State<LabelField> createState() => _LabelFieldState();
}


class _LabelFieldState extends State<LabelField>
  with SingleTickerProviderStateMixin
{
  Set<WidgetState> get widgetState => <WidgetState>{
    if (!widget.isEnabled) WidgetState.disabled,
    if (widget.isFocused) WidgetState.focused,
    if (widget.isHovering) WidgetState.hovered,
    if (widget.hasError) WidgetState.error,
  };

  @override
  void initState()
  {
    super.initState();
    _text = widget.text ?? '';
    _shouldShowLabel = widget.text != null;
    _shakingLabelController = AnimationController(
      duration: _kTransitionDuration,
      vsync: this,
    );
  }

  @override
  void dispose()
  {
    _shakingLabelController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant final LabelField oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakingLabelController
        ..value = 0.0
        ..forward();
    }
    if (widget.text != oldWidget.text) {
      _text = widget.text ?? _text;
      _shouldShowLabel = widget.text != null;
    }
  }

  @override
  Widget build(final BuildContext context)
  {
    final theme = Theme.of(context);
    final defaults = theme.useMaterial3
      ? _InputDecoratorDefaultsM3(context)
      : _InputDecoratorDefaultsM2(context);
    final textStyle = _getFloatingLabelStyle(theme, defaults);
    return MatrixTransition(
      animation: _shakingLabelController,
      onTransform: (value) {
        final shakeOffset = switch (value) {
          <= 0.25 => -value,
          < 0.75 => value - 0.5,
          _ => (1.0 - value) * 4.0,
        };
        // Shakes the label to the left and right when the error first appears.
        return Matrix4.translationValues(shakeOffset * 4.0, 0.0, 0.0);
      },
      child: AnimatedOpacity(
        duration: _kTransitionDuration,
        curve: _kTransitionCurve,
        opacity: _shouldShowLabel ? 1.0 : 0.0,
        child: AnimatedDefaultTextStyle(
          duration: _kTransitionDuration,
          curve: _kTransitionCurve,
          style: textStyle,
          child: Transform.scale(
            scale: _kFinalLabelScale,
            alignment: Alignment.topLeft,
            child: Text(_text),
          ),
        ),
      ),
    );
  }

  TextStyle _getFloatingLabelStyle(
    final ThemeData theme,
    final InputDecorationThemeData defaults,
  )
  {
    var defaultTextStyle = WidgetStateProperty.resolveAs(
      defaults.floatingLabelStyle!,
      widgetState,
    );
    if (widget.hasError) {
      defaultTextStyle = defaultTextStyle.copyWith(
        color: theme.inputDecorationTheme.errorStyle?.color
        ?? theme.colorScheme.error
      );
    }
    defaultTextStyle = defaultTextStyle.merge(widget.textStyle);

    return theme.textTheme.titleMedium!
      .merge(defaultTextStyle)
      .copyWith(height: 1);
  }

  late String _text;
  late bool _shouldShowLabel;

  late final AnimationController _shakingLabelController;
}


class _InputDecoratorDefaultsM2 extends InputDecorationThemeData
{
  final BuildContext context;

  const _InputDecoratorDefaultsM2(this.context)
  : super();

  @override
  TextStyle? get labelStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return TextStyle(color: Theme.of(context).disabledColor);
    }
    return TextStyle(color: Theme.of(context).hintColor);
  });

  @override
  TextStyle? get floatingLabelStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return TextStyle(color: Theme.of(context).disabledColor);
    }
    if (states.contains(WidgetState.error)) {
      return TextStyle(color: Theme.of(context).colorScheme.error);
    }
    if (states.contains(WidgetState.focused)) {
      return TextStyle(color: Theme.of(context).colorScheme.primary);
    }
    return TextStyle(color: Theme.of(context).hintColor);
  });
}


class _InputDecoratorDefaultsM3 extends InputDecorationThemeData
{
  final BuildContext context;

  _InputDecoratorDefaultsM3(this.context)
  : super();

  @override
  TextStyle? get labelStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = _textTheme.bodyLarge ?? const TextStyle();
    if (states.contains(WidgetState.disabled)) {
      return textStyle.copyWith(color: _colors.onSurface.withValues(alpha: 0.38));
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return textStyle.copyWith(color: _colors.error);
      }
      if (states.contains(WidgetState.hovered)) {
        return textStyle.copyWith(color: _colors.onErrorContainer);
      }
      return textStyle.copyWith(color: _colors.error);
    }
    if (states.contains(WidgetState.focused)) {
      return textStyle.copyWith(color: _colors.primary);
    }
    if (states.contains(WidgetState.hovered)) {
      return textStyle.copyWith(color: _colors.onSurfaceVariant);
    }
    return textStyle.copyWith(color: _colors.onSurfaceVariant);
  });

  @override
  TextStyle? get floatingLabelStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = _textTheme.bodyLarge ?? const TextStyle();
    if (states.contains(WidgetState.disabled)) {
      return textStyle.copyWith(color: _colors.onSurface.withValues(alpha: 0.38));
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return textStyle.copyWith(color: _colors.error);
      }
      if (states.contains(WidgetState.hovered)) {
        return textStyle.copyWith(color: _colors.onErrorContainer);
      }
      return textStyle.copyWith(color: _colors.error);
    }
    if (states.contains(WidgetState.focused)) {
      return textStyle.copyWith(color: _colors.primary);
    }
    if (states.contains(WidgetState.hovered)) {
      return textStyle.copyWith(color: _colors.onSurfaceVariant);
    }
    return textStyle.copyWith(color: _colors.onSurfaceVariant);
  });


  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;
}
