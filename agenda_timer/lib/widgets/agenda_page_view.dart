import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/providers.dart';
import '../models/attivita.dart';
import 'activity_card_large.dart';
import 'music_scanner_dialog.dart';

class AgendaPageView extends ConsumerStatefulWidget {
  const AgendaPageView({super.key});

  @override
  ConsumerState<AgendaPageView> createState() => _AgendaPageViewState();
}

class _AgendaPageViewState extends ConsumerState<AgendaPageView> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _ttsTimer;
  Timer? _autoAdvanceTimer;
  int _repeatCount = 0;
  Timer? _repeatTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ttsTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _repeatTimer?.cancel();
    super.dispose();
  }

  // Avvia il timer automatico per l'avanzamento delle pagine
  void _startAutoTimer(List<Attivita> lista) {
    print('🔍 DEBUG: _startAutoTimer chiamato');
    _autoAdvanceTimer?.cancel();

    final isEnabled = ref.read(autoTimerProvider);
    final interval = ref.read(timerIntervalProvider);

    print(
      '🔍 DEBUG: Timer enabled: $isEnabled, interval: ${interval}s, lista.length: ${lista.length}',
    );

    if (!isEnabled || lista.isEmpty) {
      print('🔍 DEBUG: Timer NON avviato (disabled o lista vuota)');
      return;
    }

    print('🔍 DEBUG: Avvio timer automatico ogni ${interval}s');
    _autoAdvanceTimer = Timer.periodic(Duration(seconds: interval), (timer) {
      if (!mounted) {
        print('🔍 DEBUG: Widget non mounted, cancello timer');
        timer.cancel();
        return;
      }

      print(
        '🔍 DEBUG: Timer automatico scattato - pagina corrente: $_currentPage',
      );

      // Se siamo all'ultima pagina, torna alla prima
      if (_currentPage >= lista.length - 1) {
        print('🔍 DEBUG: Ultima pagina, torno alla prima');
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Altrimenti vai alla prossima pagina
        print('🔍 DEBUG: Vado alla pagina successiva: ${_currentPage + 1}');
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    print('🔍 DEBUG: Timer automatico creato e avviato');
  }

  // Ferma il timer automatico
  void _stopAutoTimer() {
    print('🔍 DEBUG: _stopAutoTimer chiamato');
    if (_autoAdvanceTimer != null) {
      print('🔍 DEBUG: Cancello timer automatico esistente');
      _autoAdvanceTimer?.cancel();
      _autoAdvanceTimer = null;
    } else {
      print('🔍 DEBUG: Nessun timer automatico da cancellare');
    }
  }

  // Ripete 3 volte la frase dell'attività corrente
  Future<void> _repeatCurrentPhrase(List<Attivita> lista) async {
    print('🔍 DEBUG: ===== _repeatCurrentPhrase INIZIATA =====');
    print(
      '🔍 DEBUG: Lista.length: ${lista.length}, currentPage: $_currentPage',
    );

    if (lista.isEmpty || _currentPage >= lista.length) {
      print('❌ TTS: Lista vuota o pagina non valida - ESCO');
      return;
    }

    print('🔁 TTS: FUNZIONE CHIAMATA - _repeatCurrentPhrase');

    // FERMA SOLO IL TIMER LOCALE (non il provider)
    final wasTimerActive = _autoAdvanceTimer != null;
    print('🔍 DEBUG: Timer locale era attivo: $wasTimerActive');

    if (wasTimerActive) {
      print('⏸️ TIMER: Fermo SOLO il timer locale per ripetizione');
      _stopAutoTimer();
    }

    _repeatTimer?.cancel();
    _repeatCount = 0;

    final attivita = lista[_currentPage];
    final phrase = attivita.fraseVocale.isNotEmpty
        ? attivita.fraseVocale
        : attivita.nomePittogramma;

    print('🔁 TTS: Controllo frase per trigger musicale: "$phrase"');
    print('🔍 DEBUG: Attività: ${attivita.nomePittogramma}');
    print('🔍 DEBUG: Frase vocale: "${attivita.fraseVocale}"');

    // 🎵 CONTROLLO PAROLA "MUSICA" SUBITO AL PRIMO CLICK
    if (_containsMusicKeyword(phrase)) {
      print('🎵 MUSICA RILEVATA AL PRIMO CLICK: Apro scanner brani per "$phrase"');

      // Una sola ripetizione della frase prima di aprire il dialog
      print('🎙️ TTS: Ripetizione unica per conferma - "$phrase"');
      try {
        final ttsService = ref.read(ttsProvider);
        await ttsService.speak(phrase);
        print('🔍 DEBUG: TTS completato per conferma musica');
      } catch (e) {
        print('❌ DEBUG: Errore TTS: $e');
      }

      // Pausa prima di aprire il dialog
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MusicScannerDialog(),
        );
      }

      // NON riavvia il timer se abbiamo aperto il dialog musica
      print('🔍 DEBUG: ===== _repeatCurrentPhrase COMPLETATA (con musica) =====');
      return;
    }

    // Se NON c'è "musica", fai le normali 3 ripetizioni
    print('🔁 TTS: Nessuna musica rilevata, procedo con 3 ripetizioni di "$phrase"');

    // Ripeti 3 volte con pause
    for (int i = 1; i <= 3; i++) {
      if (!mounted) {
        print('🔍 DEBUG: Widget non mounted, interrompo ripetizione');
        break;
      }

      print('🎙️ TTS: Ripetizione $i/3 - "$phrase"');
      try {
        // USA IL SINGLETON TTS CON LA VELOCITÀ CORRETTA
        final ttsService = ref.read(ttsProvider);
        await ttsService.speak(phrase);
        print('🔍 DEBUG: TTS completato per ripetizione $i');
      } catch (e) {
        print('❌ DEBUG: Errore TTS: $e');
      }

      // Pausa tra le ripetizioni (tranne dopo l'ultima)
      if (i < 3) {
        print('🔍 DEBUG: Pausa 1.2s prima della prossima ripetizione');
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    }

    print('✅ TTS: Completate 3 ripetizioni (senza trigger musicale)');

    // RIAVVIA IL TIMER LOCALE SE ERA ATTIVO E IL PROVIDER È ANCORA ABILITATO
    if (wasTimerActive && mounted) {
      final isStillEnabled = ref.read(autoTimerProvider);
      if (isStillEnabled) {
        print('▶️ TIMER: Riavvio il timer locale dopo ripetizione');
        _startAutoTimer(lista);
      } else {
        print('🔍 DEBUG: Provider disabilitato, non riavvio timer');
      }
    } else {
      print(
        '🔍 DEBUG: NON riavvio timer - wasTimerActive: $wasTimerActive, mounted: $mounted',
      );
    }

    print('🔍 DEBUG: ===== _repeatCurrentPhrase COMPLETATA =====');
  }

  // 🎵 Controlla se la frase contiene parole chiave musicali
  bool _containsMusicKeyword(String phrase) {
    final lowerPhrase = phrase.toLowerCase();
    final musicKeywords = [
      'musica',
      'music',
      'canzone',
      'canzoni',
      'canzon',
      'brano',
      'brani',
      'cantare',
      'canta',
      'suonare',
      'suona',
      'melodia',
      'ritmo',
      'nota',
      'note',
    ];

    for (final keyword in musicKeywords) {
      if (lowerPhrase.contains(keyword)) {
        print('🎵 KEYWORD TROVATA: "$keyword" in "$phrase"');
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final nomeAgenda = ref.watch(agendaSelezionataProvider);
    if (nomeAgenda == null) {
      return const Center(child: Text('Seleziona o crea un\'agenda dal menu'));
    }

    final asyncAttivita = ref.watch(attivitaPerAgendaProvider);

    // Ascolta i cambiamenti dei provider del timer automatico
    ref.listen<bool>(autoTimerProvider, (previous, isEnabled) {
      print('🔍 DEBUG: autoTimerProvider cambiato da $previous a $isEnabled');
      final lista = asyncAttivita.value ?? [];
      if (isEnabled) {
        print('🔍 DEBUG: Timer abilitato, avvio timer automatico');
        _startAutoTimer(lista);
      } else {
        print('🔍 DEBUG: Timer disabilitato, fermo timer automatico');
        _stopAutoTimer();
      }
    });

    ref.listen<int>(timerIntervalProvider, (previous, interval) {
      print(
        '🔍 DEBUG: timerIntervalProvider cambiato da ${previous}s a ${interval}s',
      );
      final lista = asyncAttivita.value ?? [];
      final isEnabled = ref.read(autoTimerProvider);
      if (isEnabled) {
        print('🔍 DEBUG: Timer abilitato, riavvio con nuovo intervallo');
        _startAutoTimer(lista); // Riavvia con nuovo intervallo
      }
    });

    // Ascolta i comandi di navigazione dal footer
    ref.listen<PageNavigationCommand?>(pageNavigationProvider, (previous, command) {
      if (command == null) return;

      final lista = asyncAttivita.value ?? [];
      if (lista.isEmpty) return;

      switch (command) {
        case PageNavigationCommand.left:
          if (_currentPage > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          break;
        case PageNavigationCommand.right:
          if (_currentPage < lista.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          break;
        case PageNavigationCommand.repeat:
          _repeatCurrentPhrase(lista);
          break;
      }
    });
    return Focus(
      autofocus: true,
      onFocusChange: (hasFocus) {
        print('🔍 DEBUG: Focus cambiato - hasFocus: $hasFocus');
      },
      onKeyEvent: (node, event) {
        print('🔍 DEBUG: KeyEvent ricevuto - ${event.runtimeType}');

        if (event is KeyDownEvent) {
          final lista = asyncAttivita.value ?? [];
          print('🔍 DEBUG: Lista attività - lunghezza: ${lista.length}');

          if (lista.isEmpty) {
            print('🔍 DEBUG: Lista vuota, ignoro evento tastiera');
            return KeyEventResult.ignored;
          }

          final isTimerActive = ref.read(autoTimerProvider);
          print('🔍 DEBUG: Timer attivo: $isTimerActive');
          print('🔍 DEBUG: Pagina corrente: $_currentPage');
          print(
            '🔍 DEBUG: Timer automatico esistente: ${_autoAdvanceTimer != null}',
          );

          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            print('🔍 DEBUG: ===== FRECCIA SINISTRA PREMUTA =====');

            if (isTimerActive) {
              print(
                '⌨️ FRECCIA SINISTRA: Timer attivo - RIPETO FRASE 3x (NO navigazione)',
              );
              _repeatCurrentPhrase(lista);
            } else if (_currentPage > 0) {
              print(
                '⌨️ FRECCIA SINISTRA: Timer disattivo - navigazione normale alla pagina precedente',
              );
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              print(
                '⌨️ FRECCIA SINISTRA: Timer disattivo - già alla prima pagina, nessuna azione',
              );
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            print('🔍 DEBUG: ===== FRECCIA DESTRA PREMUTA =====');

            if (isTimerActive) {
              print(
                '⌨️ FRECCIA DESTRA: Timer attivo - RIPETO FRASE 3x (NO navigazione)',
              );
              _repeatCurrentPhrase(lista);
            } else if (_currentPage < lista.length - 1) {
              print(
                '⌨️ FRECCIA DESTRA: Timer disattivo - navigazione normale alla pagina successiva',
              );
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              print(
                '⌨️ FRECCIA DESTRA: Timer disattivo - già all\'ultima pagina, nessuna azione',
              );
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: asyncAttivita.when(
        data: (lista) {
          // Avvia il timer automatico se abilitato
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('🔍 DEBUG: PostFrameCallback - controllo stato timer');
            final isEnabled = ref.read(autoTimerProvider);
            print('🔍 DEBUG: Timer enabled nel PostFrameCallback: $isEnabled');
            print(
              '🔍 DEBUG: Lista.length nel PostFrameCallback: ${lista.length}',
            );

            if (isEnabled && lista.isNotEmpty) {
              print('🔍 DEBUG: Avvio timer dal PostFrameCallback');
              _startAutoTimer(lista);
            } else {
              print('🔍 DEBUG: Fermo timer dal PostFrameCallback');
              _stopAutoTimer();
            }
          });

          if (lista.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_agenda_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nessuna attività.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aggiungi un pittogramma o una foto con il pulsante +',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Indicatori pagina
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${_currentPage + 1} / ${lista.length}'),
                    const SizedBox(width: 16),
                    // Puntini indicatori
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        lista.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentPage
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // PageView delle attività (orizzontale con swipe)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });

                    // Cancella il timer precedente se esistente
                    _ttsTimer?.cancel();

                    // Attendi 1 secondo poi pronuncia la frase vocale
                    _ttsTimer = Timer(const Duration(seconds: 1), () async {
                      final attivita = lista[page];
                      final ttsService = ref.read(ttsProvider);

                      if (attivita.fraseVocale.isNotEmpty) {
                        print(
                          '🎙️ TTS: Pronuncio "${attivita.fraseVocale}" per ${attivita.nomePittogramma}',
                        );
                        await ttsService.speak(attivita.fraseVocale);
                      } else {
                        // Fallback: usa il nome del pittogramma
                        print(
                          '🎙️ TTS: Pronuncio "${attivita.nomePittogramma}" (fallback)',
                        );
                        await ttsService.speak(attivita.nomePittogramma);
                      }
                    });
                  },
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final attivita = lista[index];
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ActivityCardLarge(
                        attivita: attivita,
                        onDelete: () => _deleteActivity(attivita),
                        onReplace: () => _replaceActivity(attivita),
                      ),
                    );
                  },
                ),
              ),
              // Area centrale mostra solo il nome dell'attività corrente
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  lista[_currentPage].nomePittogramma,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Errore: $e'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteActivity(Attivita attivita) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina attività'),
        content: Text('Vuoi eliminare "${attivita.nomePittogramma}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(attivitaPerAgendaProvider.notifier)
            .deleteById(attivita.id!);

        // Aggiusta la pagina corrente se necessario
        final newList = ref.read(attivitaPerAgendaProvider).value ?? [];
        if (_currentPage >= newList.length && newList.isNotEmpty) {
          setState(() {
            _currentPage = newList.length - 1;
          });
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Attività eliminata')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Errore eliminazione: $e')));
        }
      }
    }
  }

  Future<void> _replaceActivity(Attivita attivita) async {
    // Implementeremo questa funzione se necessario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funzione sostituzione in via di sviluppo')),
    );
  }
}
