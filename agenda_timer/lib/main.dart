import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database_adapter.dart';
import 'providers/providers.dart';
import 'widgets/agenda_drawer.dart';
import 'widgets/activity_list.dart';
import 'widgets/agenda_page_view.dart';
import 'widgets/user_selector.dart';
import 'pages/add_activity_page.dart';
import 'models/attivita.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

// Punto di ingresso dell'applicazione
void main() async {
  // Assicura che i binding di Flutter siano inizializzati
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza il database adapter
  await DatabaseAdapter.instance.initialize();

  // Inizializza Riverpod a livello di app
  runApp(const ProviderScope(child: MyApp()));
}

/// Widget radice dell'app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurazione di base del MaterialApp
    return MaterialApp(
      title: 'Agenda',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(), // App completa
    );
  }
}

/// Pagina unica con Drawer laterale sinistro.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Chiave per controllare lo Scaffold (necessaria per aprire il Drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inizializza l'utente predefinito se non esiste
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaultUser();
    });
  }

  // Inizializza l'utente predefinito per compatibilità con dati esistenti
  Future<void> _initializeDefaultUser() async {
    final utenti = await ref.read(utentiProvider.future);

    if (utenti.isEmpty) {
      try {
        await ref
            .read(utentiProvider.notifier)
            .createUser('Utente Predefinito');
      } catch (e) {
        // Utente già esiste, ignora
      }
    }

    // Seleziona il primo utente se nessuno è selezionato
    final utenteSelezionato = ref.read(utenteSelezionatoProvider);
    if (utenteSelezionato == null && utenti.isNotEmpty) {
      ref.read(utenteSelezionatoProvider.notifier).select(utenti.first);
    } else if (utenteSelezionato == null) {
      ref
          .read(utenteSelezionatoProvider.notifier)
          .select('Utente Predefinito');
    }
  }

  // Gestisce l'aggiunta di una nuova attività
  Future<void> _handleAddActivity() async {
    final nomeAgenda = ref.read(agendaSelezionataProvider);
    if (nomeAgenda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona prima un\'agenda')),
      );
      return;
    }

    try {
      final data = await Navigator.of(context).push<NewActivityData>(
        MaterialPageRoute(builder: (context) => const AddActivityPage()),
      );

      if (data == null || !mounted) return;

      final nomeUtente = ref.read(utenteSelezionatoProvider);
      if (nomeUtente == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seleziona prima un utente')),
          );
        }
        return;
      }

      // Determina il filePath in base al tipo di attività
      String filePath;
      Uint8List? imageBytes;

      if (data.tipo == TipoAttivita.foto) {
        // Per le foto, passa i bytes per l'upload
        imageBytes = data.bytes;
        filePath = 'temp_path'; // Sarà sostituito dal provider con il path reale
      } else {
        // Per i pittogrammi ARASAAC, usa l'URL diretto
        if (kIsWeb) {
          final base64 = base64Encode(data.bytes);
          filePath = 'data:image/png;base64,$base64';
        } else {
          // Su mobile, salva il file normalmente
          final storage = ref.read(fileStorageProvider);
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
      }

      await ref
          .read(attivitaPerAgendaProvider.notifier)
          .addAttivita(
            nomeUtente: nomeUtente,
            nomePittogramma: data.nomePittogramma,
            nomeAgenda: nomeAgenda,
            tipo: data.tipo,
            filePath: filePath,
            fraseVocale: data.fraseVocale,
            imageBytes: imageBytes,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attività aggiunta')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore aggiunta attività: $e')),
        );
      }
    }
  }

  // Gestisce l'esportazione dell'agenda in JSON
  Future<void> _handleExport() async {
    final nomeAgenda = ref.read(agendaSelezionataProvider);
    if (nomeAgenda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona prima un\'agenda')),
      );
      return;
    }

    try {
      await ref
          .read(attivitaPerAgendaProvider.notifier)
          .exportAgendaJson();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export non supportato nella versione web')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore export: $e')),
        );
      }
    }
  }

  // Costruisce la barra di navigazione per le pagine con frecce/altoparlanti
  Widget _buildPageNavigationBar(WidgetRef ref) {
    final asyncAttivita = ref.watch(attivitaPerAgendaProvider);
    final isTimerActive = ref.watch(autoTimerProvider);

    return asyncAttivita.when(
      data: (lista) {
        if (lista.isEmpty) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 2) {
                _handleAddActivity();
              } else {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista'),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_carousel),
                label: 'Pagine',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Aggiungi',
              ),
            ],
          );
        }

        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Freccia sinistra / Altoparlante sinistro
              IconButton(
                onPressed: () => _handleLeftNavigation(ref, lista, isTimerActive),
                icon: Icon(
                  isTimerActive ? Icons.volume_up : Icons.arrow_back_ios,
                  color: isTimerActive ? Colors.blue : null,
                ),
                iconSize: 32,
                tooltip: isTimerActive
                    ? 'Ripeti frase 3 volte'
                    : 'Pagina precedente',
              ),

              // Area centrale con tab navigation normale
              Expanded(
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    if (index == 2) {
                      _handleAddActivity();
                    } else {
                      setState(() {
                        _selectedIndex = index;
                      });
                    }
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista'),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.view_carousel),
                      label: 'Pagine',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: 'Aggiungi',
                    ),
                  ],
                ),
              ),

              // Freccia destra / Altoparlante destro
              IconButton(
                onPressed: () => _handleRightNavigation(ref, lista, isTimerActive),
                icon: Icon(
                  isTimerActive ? Icons.volume_up : Icons.arrow_forward_ios,
                  color: isTimerActive ? Colors.blue : null,
                ),
                iconSize: 32,
                tooltip: isTimerActive
                    ? 'Ripeti frase 3 volte'
                    : 'Pagina successiva',
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }

  // Gestisce la navigazione/ripetizione a sinistra
  void _handleLeftNavigation(WidgetRef ref, List<dynamic> lista, bool isTimerActive) {
    if (isTimerActive) {
      ref.read(pageNavigationProvider.notifier).repeatPhrase();
    } else {
      ref.read(pageNavigationProvider.notifier).navigateLeft();
    }
  }

  // Gestisce la navigazione/ripetizione a destra
  void _handleRightNavigation(WidgetRef ref, List<dynamic> lista, bool isTimerActive) {
    if (isTimerActive) {
      ref.read(pageNavigationProvider.notifier).repeatPhrase();
    } else {
      ref.read(pageNavigationProvider.notifier).navigateRight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(agendaSelezionataProvider);
            final title = selected ?? 'Seleziona un\'agenda';
            return Text(title);
          },
        ),
        actions: [
          const UserSelector(),
        ],
      ),
      drawer: const AgendaDrawer(),
      body: _selectedIndex == 0 ? const ActivityList() : const AgendaPageView(),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          // Solo nella vista pagine mostra i controlli di navigazione
          if (_selectedIndex == 1) {
            return _buildPageNavigationBar(ref);
          }

          // Altrimenti mostra la normale bottom navigation
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 2) {
                _handleAddActivity();
              } else {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista'),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_carousel),
                label: 'Pagine',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Aggiungi',
              ),
            ],
          );
        },
      ),
      floatingActionButton: !kIsWeb ? FloatingActionButton(
        heroTag: 'export',
        onPressed: _handleExport,
        tooltip: 'Esporta agenda in JSON',
        child: const Icon(Icons.file_upload_outlined),
      ) : null,
    );
  }
}
