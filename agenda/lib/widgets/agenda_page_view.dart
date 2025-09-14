import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/providers.dart';
import '../models/attivita.dart';
import '../services/tts_service.dart';
import 'activity_card_large.dart';

class AgendaPageView extends ConsumerStatefulWidget {
  const AgendaPageView({super.key});

  @override
  ConsumerState<AgendaPageView> createState() => _AgendaPageViewState();
}

class _AgendaPageViewState extends ConsumerState<AgendaPageView> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _ttsTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ttsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeAgenda = ref.watch(agendaSelezionataProvider);
    if (nomeAgenda == null) {
      return const Center(child: Text('Seleziona o crea un\'agenda dal menu'));
    }

    final asyncAttivita = ref.watch(attivitaPerAgendaProvider);
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final lista = asyncAttivita.value ?? [];
          if (lista.isEmpty) return KeyEventResult.ignored;

          if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
              _currentPage > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
              _currentPage < lista.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: asyncAttivita.when(
        data: (lista) {
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
                      if (attivita.fraseVocale.isNotEmpty) {
                        print(
                          '🎙️ TTS: Pronuncio "${attivita.fraseVocale}" per ${attivita.nomePittogramma}',
                        );
                        await TtsService().speak(attivita.fraseVocale);
                      } else {
                        // Fallback: usa il nome del pittogramma
                        print(
                          '🎙️ TTS: Pronuncio "${attivita.nomePittogramma}" (fallback)',
                        );
                        await TtsService().speak(attivita.nomePittogramma);
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
              // Controlli navigazione
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 20,
                    ),
                    Text(
                      lista[_currentPage].nomePittogramma,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      onPressed: _currentPage < lista.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_ios),
                      iconSize: 20,
                    ),
                  ],
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
