import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/attivita.dart';
import '../pages/add_activity_page.dart';

class ActivityList extends ConsumerStatefulWidget {
  const ActivityList({super.key});

  @override
  ConsumerState<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends ConsumerState<ActivityList> {
  @override
  void initState() {
    super.initState();
    // Forza il refresh quando il widget viene inizializzato
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attivitaPerAgendaProvider.notifier).refreshOnReturn();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Forza il refresh ogni volta che il widget viene ricostruito
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attivitaPerAgendaProvider.notifier).refreshOnReturn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nomeAgenda = ref.watch(agendaSelezionataProvider);
    if (nomeAgenda == null) {
      return const Center(child: Text('Seleziona o crea un\'agenda dal menu'));
    }

    final asyncAttivita = ref.watch(attivitaPerAgendaProvider);
    return asyncAttivita.when(
      data: (lista) {
        if (lista.isEmpty) {
          return const _EmptyActivityList();
        }
        return Column(
          children: [
            // Test button per riordinamento
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  print('🧪 Test riordinamento: scambio posizioni 0 e 1');
                  try {
                    await ref
                        .read(attivitaPerAgendaProvider.notifier)
                        .reorder(0, 1);
                    print('✅ Test riordinamento completato');
                  } catch (e) {
                    print('❌ Test riordinamento fallito: $e');
                  }
                },
                child: const Text('Test Riordinamento (0↔1)'),
              ),
            ),
            Expanded(child: _ActivityReorderableList(attivita: lista)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _ErrorDisplay(error: e.toString()),
    );
  }
}

class _EmptyActivityList extends StatelessWidget {
  const _EmptyActivityList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Nessuna attività.'),
          SizedBox(height: 8),
          Text('Aggiungi un pittogramma o una foto con il pulsante +'),
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  const _ErrorDisplay({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SelectableText.rich(
        TextSpan(
          text: 'Errore: ',
          style: const TextStyle(color: Colors.red),
          children: [TextSpan(text: error)],
        ),
      ),
    );
  }
}

class _ActivityReorderableList extends ConsumerWidget {
  const _ActivityReorderableList({required this.attivita});

  final List<Attivita> attivita;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: attivita.length,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.05,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) async {
        print('🔄 Drag & Drop: da posizione $oldIndex a $newIndex');
        try {
          await ref
              .read(attivitaPerAgendaProvider.notifier)
              .reorder(oldIndex, newIndex);
          print('✅ Riordinamento completato con successo');
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Ordine aggiornato!')));
          }
        } catch (e) {
          print('❌ Errore riordinamento: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Errore riordino: $e')));
          }
        }
      },
      itemBuilder: (context, index) {
        final item = attivita[index];
        return ActivityCard(
          key: ValueKey('attivita_${item.id}'),
          attivita: item,
        );
      },
    );
  }
}

class ActivityCard extends ConsumerWidget {
  const ActivityCard({super.key, required this.attivita});

  final Attivita attivita;

  /// Costruisce il widget immagine appropriato per la piattaforma (versione piccola)
  Widget _buildSmallImage(String filePath) {
    try {
      if (filePath.startsWith('data:')) {
        // Dati base64
        final base64String = filePath.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 48),
        );
      } else if (filePath.startsWith('http')) {
        // URL remoto
        return Image.network(
          filePath,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 48),
        );
      } else if (!kIsWeb) {
        // File locale (solo mobile)
        return Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 48),
        );
      } else {
        // Su web, file path non valido
        return const Icon(Icons.broken_image, size: 48);
      }
    } catch (e) {
      return const Icon(Icons.broken_image, size: 48);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icona di drag
            const Icon(Icons.drag_handle, color: Colors.grey, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildSmallImage(attivita.filePath),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attivita.nomePittogramma,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (attivita.fraseVocale.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.record_voice_over, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            attivita.fraseVocale,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.blue,
                                  fontStyle: FontStyle.italic,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Posizione: ${attivita.posizione}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Pulsanti per azioni
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _speakPhrase(ref),
                  icon: const Icon(Icons.volume_up, size: 20),
                  tooltip: 'Ascolta',
                ),
                IconButton(
                  onPressed: () => _showManageActivityDialog(context, ref),
                  icon: const Icon(Icons.more_vert, size: 20),
                  tooltip: 'Gestisci',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Pronuncia la frase vocale dell'attività
  Future<void> _speakPhrase(WidgetRef ref) async {
    final tts = ref.read(ttsProvider);

    // Se presente la frase vocale, usa quella, altrimenti usa il nome del pittogramma
    String textToSpeak = attivita.fraseVocale.isNotEmpty
        ? attivita.fraseVocale
        : attivita.nomePittogramma;

    await tts.speak(textToSpeak);
  }

  Future<void> _showManageActivityDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gestisci attività'),
        content: const Text('Vuoi eliminare o sostituire questa attività?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'elimina'),
            child: const Text('Elimina'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'sostituisci'),
            child: const Text('Sostituisci'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    try {
      if (action == 'elimina') {
        await ref
            .read(attivitaPerAgendaProvider.notifier)
            .deleteById(attivita.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Attività eliminata')));
        }
      } else if (action == 'sostituisci') {
        await _handleReplaceActivity(context, ref);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _handleReplaceActivity(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final data = await Navigator.of(context).push<NewActivityData>(
      MaterialPageRoute(builder: (context) => const AddActivityPage()),
    );

    if (data != null && context.mounted) {
      try {
        String filePath;
        
        if (kIsWeb) {
          // Su web, converte direttamente i bytes in base64
          final base64 = base64Encode(data.bytes);
          filePath = 'data:image/png;base64,$base64';
        } else {
          // Su mobile, salva il file normalmente
          final storage = ref.read(fileStorageProvider);
          final nomeAgenda = ref.read(agendaSelezionataProvider) ?? '';
          final safeName = data.nomePittogramma.toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9_-]+'),
            '_',
          );
          final fileName =
              'attivita_${DateTime.now().millisecondsSinceEpoch}_$safeName.png';
          await storage.saveBytes(
            bytes: data.bytes,
            agendaName: nomeAgenda,
            fileName: fileName,
          );
          filePath = 'assets/images/$fileName';
        }

        await ref
            .read(attivitaPerAgendaProvider.notifier)
            .replace(
              id: attivita.id!,
              nomePittogramma: data.nomePittogramma,
              filePath: filePath,
              tipo: data.tipo,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Attività sostituita')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Errore sostituzione: $e')));
        }
      }
    }
  }
}
