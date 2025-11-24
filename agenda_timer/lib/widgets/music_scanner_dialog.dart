import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/providers.dart';
import '../models/video_educatore.dart';
import 'youtube_player_page.dart';

class MusicScannerDialog extends ConsumerStatefulWidget {
  const MusicScannerDialog({super.key});

  @override
  ConsumerState<MusicScannerDialog> createState() => _MusicScannerDialogState();
}

class _MusicScannerDialogState extends ConsumerState<MusicScannerDialog> {
  int _currentIndex = 0;
  Timer? _scanTimer;
  Timer? _ttsTimer;
  List<VideoEducatore> _musicVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMusicVideos();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _ttsTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMusicVideos() async {
    try {
      // Ottieni l'agenda corrente per filtrare i video
      final agendaCorrente = ref.read(agendaSelezionataProvider);
      final utenteCorrente = ref.read(utenteSelezionatoProvider);

      if (agendaCorrente == null || utenteCorrente == null) {
        print('❌ MUSICA: Agenda o utente non selezionato');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🎵 CARICO VIDEO per agenda: "$agendaCorrente", utente: "$utenteCorrente"');

      // Carica i video con categoria "Musica" E dell'agenda corrente
      final allVideos = await ref.read(videoEducatoreProvider.future);

      print('🎵 TOTALI VIDEO NEL DB: ${allVideos.length}');
      for (int i = 0; i < allVideos.length; i++) {
        final v = allVideos[i];
        print('🎵 VIDEO $i: nome="${v.nomeVideo}", categoria="${v.categoria}", agenda="${v.nomeAgenda}", utente="${v.nomeUtente}"');
      }

      final musicVideos = allVideos.where((video) {
        final categoriaMatch = video.categoria.toLowerCase().contains('musica') ||
                              video.categoria.toLowerCase().contains('music') ||
                              video.categoria.toLowerCase().contains('canzon') ||
                              video.categoria.toLowerCase().contains('brano');
        final agendaMatch = video.nomeAgenda == agendaCorrente;
        final utenteMatch = video.nomeUtente == utenteCorrente;

        print('🎵 FILTRO "${video.nomeVideo}": categoria=$categoriaMatch, agenda=$agendaMatch, utente=$utenteMatch');

        return categoriaMatch && agendaMatch && utenteMatch;
      }).toList();

      print('🎵 TROVATI ${musicVideos.length} video musicali per questa agenda/utente');

      setState(() {
        _musicVideos = musicVideos;
        _isLoading = false;
      });

      if (musicVideos.isNotEmpty) {
        _startScanning();
      }
    } catch (e) {
      print('Errore caricamento video musicali: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startScanning() {
    if (_musicVideos.isEmpty) return;

    // Pronuncia immediatamente il primo brano
    _speakCurrentSong();

    // Avvia scansione automatica ogni 3 secondi
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentIndex = (_currentIndex + 1) % _musicVideos.length;
      });

      _speakCurrentSong();
    });
  }

  Future<void> _speakCurrentSong() async {
    if (_musicVideos.isEmpty || _currentIndex >= _musicVideos.length) return;

    final video = _musicVideos[_currentIndex];
    final ttsService = ref.read(ttsProvider);

    print('🎵 TTS: Pronuncio brano "${video.nomeVideo}"');

    try {
      await ttsService.speak(video.nomeVideo);
    } catch (e) {
      print('❌ TTS Error: $e');
    }
  }

  void _selectCurrentSong() {
    if (_musicVideos.isEmpty || _currentIndex >= _musicVideos.length) return;

    final selectedVideo = _musicVideos[_currentIndex];

    // Ferma la scansione
    _scanTimer?.cancel();
    _ttsTimer?.cancel();

    // Chiudi il dialog
    Navigator.of(context).pop();

    // Apri la pagina YouTube
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YouTubePlayerPage(video: selectedVideo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            // Stessi switch delle pagine - frecce sinistra/destra per selezione
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowRight) {
              print('🎵 SWITCH: Brano selezionato - ${_musicVideos[_currentIndex].nomeVideo}');
              _selectCurrentSong();
              return KeyEventResult.handled;
            }
            // Escape per chiudere
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Titolo
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.yellow, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Scegli un Brano',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.yellow),
                  ),
                )
              else if (_musicVideos.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.music_off, color: Colors.grey, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'Nessun brano musicale trovato',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Aggiungi video con categoria "Musica"',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Lista brani con scansione
                Expanded(
                  child: ListView.builder(
                    itemCount: _musicVideos.length,
                    itemBuilder: (context, index) {
                      final video = _musicVideos[index];
                      final isSelected = index == _currentIndex;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                            ? Border.all(color: Colors.yellow, width: 2)
                            : null,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.yellow : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isSelected ? Icons.play_arrow : Icons.music_note,
                              color: isSelected ? Colors.black : Colors.white,
                              size: isSelected ? 32 : 24,
                            ),
                          ),
                          title: Text(
                            video.nomeVideo,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSelected ? 18 : 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            video.categoria,
                            style: TextStyle(
                              color: isSelected ? Colors.yellow : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                            _selectCurrentSong();
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // Istruzioni
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard_arrow_left, color: Colors.white),
                        Text(' / ', style: TextStyle(color: Colors.white)),
                        Icon(Icons.keyboard_arrow_right, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Premi per selezionare',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ESC per chiudere',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}