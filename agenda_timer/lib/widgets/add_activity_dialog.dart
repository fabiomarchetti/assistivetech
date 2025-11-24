import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../providers/providers.dart';
import '../models/attivita.dart';
import '../services/web_file_picker.dart';
import 'arasaac_image.dart';
import 'photo_details_dialog.dart';

// Dialog per aggiungere una nuova attività: tab Pittogramma e Foto
class AddActivityDialog extends ConsumerStatefulWidget {
  const AddActivityDialog({super.key});

  @override
  ConsumerState<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends ConsumerState<AddActivityDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeAgenda = ref.watch(agendaSelezionataProvider);
    return AlertDialog(
      title: const Text('Aggiungi attività'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height:
            MediaQuery.of(context).size.height * 0.65, // Ridotto da 0.7 a 0.65
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.image_outlined), text: 'Pittogramma'),
                Tab(icon: Icon(Icons.folder_open), text: 'Immagine'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ArasaacTab(
                    queryController: _queryController,
                    onSelected: (data) async {
                      if (nomeAgenda == null) return;
                      Navigator.of(context).pop(data);
                    },
                  ),
                  _ImageTab(
                    onSelected: (data) {
                      if (nomeAgenda == null) return;
                      Navigator.of(context).pop(data);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }
}

// Dato restituito dal dialog: dati grezzi per creare Attivita
class NewActivityData {
  NewActivityData({
    required this.nomeUtente,
    required this.nomePittogramma,
    required this.tipo,
    required this.bytes,
    this.fraseVocale = '',
  });

  final String nomeUtente;
  final String nomePittogramma;
  final TipoAttivita tipo;
  final Uint8List bytes;
  final String fraseVocale;
}

class _ArasaacTab extends ConsumerWidget {
  const _ArasaacTab({required this.queryController, required this.onSelected});

  final TextEditingController queryController;
  final void Function(NewActivityData data) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(arasaacSearchProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: queryController,
            decoration: const InputDecoration(
              labelText: 'Cerca pittogrammi ARASAAC',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              ref.read(arasaacSearchProvider.notifier).search(value);
            },
          ),
        ),
        Expanded(
          child: search.when(
            data: (lista) {
              if (lista.isEmpty) {
                return const Center(child: Text('Nessun risultato'));
              }
              final crossAxisCount = 4; // Fisso a 4 colonne per tablet
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8, // Più spazio verticale per il testo
                ),
                itemCount: lista.length,
                itemBuilder: (context, index) {
                  final item = lista[index];
                  final int? id = item['id'] as int?;
                  if (id == null) return const SizedBox.shrink();
                  // Scegli nome in italiano dalle keywords
                  String name = 'pittogramma';
                  final kws =
                      (item['keywords'] as List?)?.cast<dynamic>() ?? const [];
                  final it = kws
                      .whereType<Map>()
                      .where(
                        (k) =>
                            (k['language']?.toString().toLowerCase() ?? '') ==
                            'it',
                      )
                      .cast<Map<String, dynamic>>()
                      .toList();
                  if (it.isNotEmpty) {
                    it.sort(
                      (a, b) => (a['keyword'] as String).length.compareTo(
                        (b['keyword'] as String).length,
                      ),
                    );
                    name = it.first['keyword'] as String? ?? 'pittogramma';
                  } else if (kws.isNotEmpty && kws.first is Map) {
                    name =
                        (kws.first as Map)['keyword'] as String? ??
                        'pittogramma';
                  }
                  final String thumb = item['thumbnail'] as String;
                  final String url = item['url'] as String;
                  return InkWell(
                    onTap: () async {
                      final res = await http.get(Uri.parse(url));
                      if (res.statusCode == 200) {
                        _createPictogramWithDetails(
                          context,
                          name,
                          res.bodyBytes,
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: ArasaacImage(
                              url: thumb,
                              fallbackUrl: url,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText.rich(
                TextSpan(
                  text: 'Errore: ',
                  style: const TextStyle(color: Colors.red),
                  children: [TextSpan(text: e.toString())],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _createPictogramWithDetails(
    BuildContext context,
    String initialName,
    Uint8List bytes,
  ) async {
    // Mostra il dialog per inserire nome e frase
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>
          PhotoDetailsDialog(imageBytes: bytes, initialName: initialName),
    );

    if (result != null) {
      onSelected(
        NewActivityData(
          nomeUtente: 'educatore',
          nomePittogramma: result['name']!,
          tipo: TipoAttivita.pittogramma,
          bytes: bytes,
          fraseVocale: result['phrase']!,
        ),
      );
    }
  }
}

class _ImageTab extends ConsumerWidget {
  const _ImageTab({required this.onSelected});

  final void Function(NewActivityData data) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Seleziona un\'immagine dal dispositivo',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              print('🗂️ Tentativo di aprire file picker...');
              try {
                if (kIsWeb) {
                  // Su web, usa il nostro WebFilePicker personalizzato
                  print('🌐 Usando WebFilePicker per web');
                  final result = await WebFilePicker.pickImage();

                  if (result == null) {
                    print('❌ Nessun file selezionato');
                    return;
                  }

                  print(
                    '✅ File selezionato: ${result.name}, size: ${result.size} bytes',
                  );
                  _createActivityWithUpload(context, result.name, result.bytes);
                } else {
                  // Su mobile, usa FilePicker standard
                  print('📱 Usando FilePicker standard per mobile');
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: false,
                    withData: true,
                  );

                  if (result == null || result.files.isEmpty) {
                    print('❌ Nessun file selezionato');
                    return;
                  }

                  final file = result.files.first;
                  print(
                    '✅ File selezionato: ${file.name}, size: ${file.size} bytes',
                  );

                  if (file.bytes != null) {
                    _createActivityWithUpload(context, file.name, file.bytes!);
                  } else if (file.path != null) {
                    final fileData = await File(file.path!).readAsBytes();
                    _createActivityWithUpload(context, file.name, fileData);
                  } else {
                    throw Exception('Impossibile leggere il file');
                  }
                }
              } catch (e, stackTrace) {
                print('❌ ERRORE file picker: $e');
                print('Stack trace: $stackTrace');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore durante il caricamento: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.folder_open, size: 24),
            label: const Text('Scegli immagine'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _createActivityWithUpload(
    BuildContext context,
    String fileName,
    Uint8List bytes,
  ) async {
    // Estrai il nome del file senza estensione per il pittogramma
    final initialName = fileName.split('.').first;

    // Mostra il dialog per inserire nome e frase
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>
          PhotoDetailsDialog(imageBytes: bytes, initialName: initialName),
    );

    if (result != null) {
      onSelected(
        NewActivityData(
          nomeUtente: 'educatore',
          nomePittogramma: result['name']!,
          tipo: TipoAttivita.foto,
          bytes: bytes,
          fraseVocale: result['phrase']!,
        ),
      );
    }
  }
}
