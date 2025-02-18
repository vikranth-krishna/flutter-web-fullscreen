import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

/// The entry point of the application.
void main() {
  runApp(const MyApp());
}

/// A Flutter application that demonstrates integrating an HTML image element,
/// toggling fullscreen via double-click or context menu, and using a custom
/// context menu overlay.
///
/// This application is intended to run on Flutter web.
class MyApp extends StatelessWidget {
  /// Creates an instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}

/// A stateful widget that displays the home page with an image area, URL input,
/// and a floating action button to show a context menu.
class HomePage extends StatefulWidget {
  /// Creates an instance of [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state for [HomePage] that handles image updates, fullscreen toggling, and
/// context menu interactions.
class _HomePageState extends State<HomePage> {
  /// The HTML image element that will be embedded in the Flutter widget tree.
  late html.ImageElement _imageElement;

  /// Controller for the URL input field.
  final TextEditingController _urlController = TextEditingController();

  /// Whether the context menu is currently open.
  bool _isContextMenuOpen = false;

  @override
  void initState() {
    super.initState();

    // Create and configure the HTML image element.
    _imageElement = html.ImageElement()
      ..style.borderRadius = '12px'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    // Listen for double-click events on the image element to toggle fullscreen.
    _imageElement.onDoubleClick.listen((event) {
      toggleFullscreen();
    });

    // Register the view factory for the HtmlElementView.
    // This makes the HTML image element available in the Flutter widget tree.
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('html-image', (int viewId) => _imageElement);
  }

  /// Enters fullscreen mode by requesting fullscreen on the document element.
  void enterFullscreen() {
    html.document.documentElement?.requestFullscreen();
  }

  /// Exits fullscreen mode if the document is currently in fullscreen.
  void exitFullscreen() {
    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen();
    }
  }

  /// Toggles the fullscreen mode. If the document is not in fullscreen, it will
  /// enter fullscreen; otherwise, it will exit fullscreen.
  void toggleFullscreen() {
    if (html.document.fullscreenElement == null) {
      enterFullscreen();
    } else {
      exitFullscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          // Main content: image display and URL input.
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Area that displays the HTML image element.
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: HtmlElementView(viewType: 'html-image'),
                  ),
                ),
                const SizedBox(height: 8),
                // Row with URL input field and button to update the image.
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Update the HTML image element's source when the button is pressed.
                        _imageElement.src = _urlController.text;
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          // Dim the background when the context menu is open.
          if (_isContextMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isContextMenuOpen = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          // Context menu with fullscreen options, positioned above the plus button.
          if (_isContextMenuOpen)
            Positioned(
              bottom: 80,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      enterFullscreen();
                      setState(() {
                        _isContextMenuOpen = false;
                      });
                    },
                    child: const Text('Enter fullscreen'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      exitFullscreen();
                      setState(() {
                        _isContextMenuOpen = false;
                      });
                    },
                    child: const Text('Exit fullscreen'),
                  ),
                ],
              ),
            ),
          // Floating plus button at the bottom-right corner to toggle the context menu.
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isContextMenuOpen = !_isContextMenuOpen;
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
