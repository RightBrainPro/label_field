import 'package:flutter/material.dart';
import 'package:label_field/label_field.dart';


void main()
{
  runApp(const MainApp());
}

class MainApp extends StatefulWidget
{
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp>
{
  @override
  Widget build(final BuildContext context)
  {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: _useMaterial3),
      darkTheme: ThemeData.dark(useMaterial3: _useMaterial3),
      themeMode: _themeMode,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              spacing: 16.0,
              children: [
                Row(
                  spacing: 32.0,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ToggleButtons(
                      isSelected: [!_useMaterial3, _useMaterial3],
                      onPressed: (index) => setState(() => _useMaterial3 = index == 1),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Material 2'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Material 3'),
                        ),
                      ],
                    ),
                    ToggleButtons(
                      isSelected: [
                        _themeMode == ThemeMode.light,
                        _themeMode == ThemeMode.dark,
                        _themeMode == ThemeMode.system,
                      ],
                      onPressed: (index) => setState(() {
                        _themeMode = switch(index) {
                          0 => ThemeMode.light,
                          1 => ThemeMode.dark,
                          2 => ThemeMode.system,
                          _ => null,
                        };
                      }),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Light'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Dark'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('System'),
                        ),
                      ],
                    ),
                  ],
                ),
                Content(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _useMaterial3 = true;
  ThemeMode? _themeMode = ThemeMode.system;
}


class Content extends StatefulWidget
{
  const Content({super.key});

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content>
{
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: 'Some text');
  }

  @override
  void dispose()
  {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context)
  {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: 8.0,
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: _label,
                  hintText: 'Sample text field',
                  errorText: _error,
                ),
                controller: _textController,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: _label == null ? null : '',
                      hintText: 'Sample text field',
                      errorText: _error,
                      enabledBorder: _error == null ? null : UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    child: SelectableText('Some text', style: theme.textTheme.bodyLarge),
                  ),
                  Positioned(
                    top: theme.useMaterial3 ? 4.0 : 8.0,
                    child: LabelField(
                      text: _label,
                      hasError: _error != null,
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          spacing: 8.0,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => setState(() {
                _label = _label == null ? 'Label text' : null;
              }),
              child: Text('Toggle label text'),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _error = _error == null ? 'Error text' : null;
              }),
              child: Text('Toggle error text'),
            ),
          ],
        ),
      ],
    );
  }

  String? _label;
  String? _error;

  late final TextEditingController _textController;
}
