import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String kUrl = 'https://www.photopea.com';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhotoPeaApp());
}

class PhotoPeaApp extends StatelessWidget {
  const PhotoPeaApp({super.key});
  @override
  Widget build(BuildContext c) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PhotoPeaScreen(),
      );
}

class PhotoPeaScreen extends StatefulWidget {
  const PhotoPeaScreen({super.key});
  @override
  State<PhotoPeaScreen> createState() => _PhotoPeaScreenState();
}

class _PhotoPeaScreenState extends State<PhotoPeaScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1A1A1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p / 100),
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (e) {
            setState(() => _loading = false);
            _showError(e.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(kUrl));
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Load error: $msg')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_loading)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress == 0 ? null : _progress,
                      backgroundColor: const Color(0xFF2A2A2A),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6C5CE7)),
                      minHeight: 3,
                    ),
                    if (_progress < 0.9)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: const Color(0xFF6C5CE7),
          onPressed: () => _controller.reload(),
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}