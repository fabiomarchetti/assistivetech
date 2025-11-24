import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/video_educatore.dart';

// Imports condizionali per web
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class YouTubePlayerPage extends StatefulWidget {
  final VideoEducatore video;

  const YouTubePlayerPage({super.key, required this.video});

  @override
  State<YouTubePlayerPage> createState() => _YouTubePlayerPageState();
}

class _YouTubePlayerPageState extends State<YouTubePlayerPage> {
  String? _iframeViewType;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _setupWebIframe();
    }
  }

  void _setupWebIframe() {
    final embedUrl = _getEmbedUrl(widget.video.linkYoutube);
    _iframeViewType = 'youtube-player-${widget.video.idVideo}';

    // Registra l'elemento iframe per la web
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeViewType!,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = embedUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
          ..allowFullscreen = true;

        return iframe;
      },
    );
  }

  String _getEmbedUrl(String originalUrl) {
    // Converte URL YouTube in versione embed
    if (originalUrl.contains('youtube.com/watch')) {
      final videoId = Uri.parse(originalUrl).queryParameters['v'];
      if (videoId != null) {
        return 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1';
      }
    } else if (originalUrl.contains('youtu.be/')) {
      final videoId = originalUrl.split('youtu.be/').last.split('?').first;
      return 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1';
    }
    return originalUrl;
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = _getEmbedUrl(widget.video.linkYoutube);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            // Qualsiasi tasto per tornare indietro
            if (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.backspace) {
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header con titolo e pulsante chiudi
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.nomeVideo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.video.categoria,
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),

              // Video player centrato
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildVideoPlayer(embedUrl),
                    ),
                  ),
                ),
              ),

              // Istruzioni per chiudere
              Container(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.keyboard, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Premi un tasto qualsiasi per tornare indietro',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String embedUrl) {
    if (kIsWeb && _iframeViewType != null) {
      // Versione web con iframe YouTube reale
      return HtmlElementView(
        viewType: _iframeViewType!,
      );
    } else {
      // Fallback per mobile o debug
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              widget.video.nomeVideo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'URL: ${widget.video.linkYoutube}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              kIsWeb
                ? 'Caricamento video YouTube...'
                : 'Su dispositivo mobile apri il link sopra',
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}