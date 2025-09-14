import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database_adapter.dart';
import 'providers/providers.dart';
import 'widgets/agenda_drawer.dart';
import 'widgets/activity_list.dart';
import 'widgets/agenda_page_view.dart';
import 'widgets/floating_action_buttons.dart';
import 'widgets/user_selector.dart';

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
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final container = ProviderScope.containerOf(context);
    final utenti = await container.read(utentiProvider.future);

    if (utenti.isEmpty) {
      try {
        await container
            .read(utentiProvider.notifier)
            .createUser('Utente Predefinito');
      } catch (e) {
        // Utente già esiste, ignora
      }
    }

    // Seleziona il primo utente se nessuno è selezionato
    final utenteSelezionato = container.read(utenteSelezionatoProvider);
    if (utenteSelezionato == null && utenti.isNotEmpty) {
      container.read(utenteSelezionatoProvider.notifier).select(utenti.first);
    } else if (utenteSelezionato == null) {
      container
          .read(utenteSelezionatoProvider.notifier)
          .select('Utente Predefinito');
    }
  }

  // Apre il menu laterale sinistro (Drawer)
  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();


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
          IconButton(onPressed: _openDrawer, icon: const Icon(Icons.menu)),
        ],
      ),
      drawer: const AgendaDrawer(),
      body: _selectedIndex == 0 ? const ActivityList() : const AgendaPageView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista'),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_carousel),
            label: 'Pagine',
          ),
        ],
      ),
      floatingActionButton: AgendaFloatingActionButtons(
        onMenuPressed: _openDrawer,
      ),
    );
  }
}
