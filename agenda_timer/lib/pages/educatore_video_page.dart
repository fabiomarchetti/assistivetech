import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/video_educatore.dart';
import '../widgets/youtube_player_page.dart';

// Imports per YouTube iframe (solo web)
import 'dart:html' as html;

class EducatoreVideoPage extends ConsumerStatefulWidget {
  const EducatoreVideoPage({super.key});

  @override
  ConsumerState<EducatoreVideoPage> createState() => _EducatoreVideoPageState();
}

class _EducatoreVideoPageState extends ConsumerState<EducatoreVideoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _linkController = TextEditingController();
  final _searchController = TextEditingController();
  String _currentSearchQuery = '';
  bool _isSearchOverlayVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _linkController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  void _updateYouTubeSearch(String searchTerm) {
    setState(() {
      _currentSearchQuery = searchTerm.trim();
      _searchController.text = _currentSearchQuery;
      _isSearchOverlayVisible = _currentSearchQuery.isNotEmpty;
    });
  }

  void _closeSearchOverlay() {
    setState(() {
      _isSearchOverlayVisible = false;
      _currentSearchQuery = '';
      _searchController.clear();
    });
  }

  void _openYouTubeInNewWindow(String searchTerm) {
    if (kIsWeb) {
      final url = 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(searchTerm)}';

      // Rileva SOLO dispositivi mobile/tablet per evitare problemi con desktop
      final userAgent = html.window.navigator.userAgent;
      final isMobileDevice = userAgent.contains('iPad') ||
                           userAgent.contains('iPhone') ||
                           userAgent.contains('iPod') ||
                           userAgent.contains('Android');

      print('🔍 USER AGENT: $userAgent');
      print('🔍 isMobileDevice: $isMobileDevice');

      if (isMobileDevice) {
        // SOLO per dispositivi mobile: apri in nuova tab
        print('🔍 Opening YouTube in new tab (Mobile device detected)');
        html.window.open(url, '_blank');

        // Mostra un messaggio di aiuto
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('YouTube si è aperto in una nuova tab. Torna qui per incollare il link del video.'),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        // Per TUTTI gli altri browser desktop: usa popup posizionato
        print('🔍 Opening YouTube in positioned popup (Desktop browser detected)');
        final screenWidth = html.window.screen!.width!;
        final screenHeight = html.window.screen!.height!;
        final leftColumnWidth = (screenWidth * 0.3).round(); // 30% per colonna sinistra
        final appBarHeight = 80; // Altezza approssimativa dell'AppBar

        // Posiziona la finestra nella parte destra
        final left = leftColumnWidth + 50; // Piccolo margine dal bordo
        final top = appBarHeight + 20; // Sotto l'header con margine
        final width = (screenWidth * 0.6).round(); // 60% della larghezza schermo
        final height = (screenHeight * 0.8).round(); // 80% dell'altezza schermo

        final windowFeatures = 'width=$width,height=$height,left=$left,top=$top,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no';
        print('🔍 Window features: $windowFeatures');
        html.window.open(url, '_blank', windowFeatures);
      }
    }
  }


  bool _isValidYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }


  Future<void> _salvaVideo() async {
    if (!_formKey.currentState!.validate()) return;

    final utenteCorrente = ref.read(utenteSelezionatoProvider);
    final agendaCorrente = ref.read(agendaSelezionataProvider);

    if (utenteCorrente == null || agendaCorrente == null) {
      _mostraErrore('Seleziona un utente e un\'agenda prima di salvare');
      return;
    }

    final video = VideoEducatore(
      nomeVideo: _nomeController.text.trim(),
      categoria: _categoriaController.text.trim(),
      linkYoutube: _linkController.text.trim(),
      nomeAgenda: agendaCorrente,
      nomeUtente: utenteCorrente,
      dataCreazione: DateTime.now().toString(),
    );

    try {
      await ref.read(videoEducatoreProvider.notifier).salvaVideo(video);
      _mostraSuccesso('Video salvato con successo!');
      _resetForm();
    } catch (e) {
      _mostraErrore('Errore nel salvataggio: $e');
    }
  }

  void _resetForm() {
    _nomeController.clear();
    _categoriaController.clear();
    _linkController.clear();
  }

  void _mostraErrore(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostraSuccesso(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final utenteCorrente = ref.watch(utenteSelezionatoProvider);
    final agendaCorrente = ref.watch(agendaSelezionataProvider);
    final allVideosList = ref.watch(videoEducatoreProvider);

    // Filtra i video per utente e agenda correnti
    final videoList = allVideosList.when(
      data: (videos) {
        if (utenteCorrente == null || agendaCorrente == null) {
          return AsyncData<List<VideoEducatore>>([]);
        }
        final filteredVideos = videos.where((video) =>
          video.nomeUtente == utenteCorrente &&
          video.nomeAgenda == agendaCorrente
        ).toList();
        return AsyncData(filteredVideos);
      },
      loading: () => const AsyncLoading<List<VideoEducatore>>(),
      error: (error, stack) => AsyncError<List<VideoEducatore>>(error, stack),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Educatore'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Layout principale
          Row(
            children: [
              // COLONNA SINISTRA - Form e controlli (30% larghezza - più stretta)
              Expanded(
                flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            // Sezione info utente/agenda corrente
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video per:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Utente: ${utenteCorrente ?? 'Nessuno selezionato'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.view_agenda, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Agenda: ${agendaCorrente ?? 'Nessuna selezionata'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    if (utenteCorrente != null && agendaCorrente != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'I video salvati saranno visibili solo per questo utente/agenda',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sezione ricerca YouTube integrata
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'Ricerca YouTube',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cerca video su YouTube...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onSubmitted: (value) => _updateYouTubeSearch(value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _openYouTubeInNewWindow(_searchController.text.trim().isNotEmpty
                              ? _searchController.text.trim()
                              : 'musica per bambini'),
                          icon: const Icon(Icons.play_circle_filled, color: Colors.white),
                          label: const Text('YouTube', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bottoni ricerca rapida
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildQuickSearchChip('Musica bambini', 'musica per bambini'),
                        _buildQuickSearchChip('Esercizi motori', 'esercizi motori bambini'),
                        _buildQuickSearchChip('Rilassamento', 'musica rilassante bambini'),
                        _buildQuickSearchChip('Canzoni educative', 'canzoni educative'),
                        _buildQuickSearchChip('Yoga bambini', 'yoga per bambini'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'I risultati appariranno nella colonna destra. Trova il video e copia il link qui sotto.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form dati video
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Salva Video',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Video *',
                          hintText: 'Es: Canzone del mattino',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Inserisci un nome per il video';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _categoriaController,
                        decoration: const InputDecoration(
                          labelText: 'Categoria *',
                          hintText: 'Es: Musica, Esercizi, Relax',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Inserisci una categoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _linkController,
                        decoration: const InputDecoration(
                          labelText: 'Link YouTube *',
                          hintText: 'https://www.youtube.com/watch?v=...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Inserisci il link YouTube';
                          }
                          if (!_isValidYouTubeUrl(value)) {
                            return 'Inserisci un link YouTube valido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: utenteCorrente != null && agendaCorrente != null
                            ? _salvaVideo
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Salva Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),

                      if (utenteCorrente == null || agendaCorrente == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Seleziona un utente e un\'agenda per abilitare il salvataggio',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Lista video salvati
            const Text(
              'Video Salvati',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            videoList.when(
              data: (videos) => videos.isEmpty
                  ? const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nessun video salvato',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: videos.map((video) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.play_circle, color: Colors.red),
                          title: Text(video.nomeVideo),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Categoria: ${video.categoria}'),
                              Text('Utente: ${video.nomeUtente}'),
                              Text('Agenda: ${video.nomeAgenda}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confermaEliminaVideo(video),
                          ),
                          onTap: () => _apriVideo(video.linkYoutube),
                        ),
                      )).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Errore caricamento video: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
                ],
              ),
            ),
          ),

              // SEPARATORE VERTICALE
              Container(
                width: 1,
                color: Colors.grey.shade300,
              ),

              // COLONNA DESTRA - Area pulita (70% larghezza)
              Expanded(
                flex: 7,
                child: _buildEmptyState(),
              ),
            ],
          ),

          // OVERLAY RICERCA - Copre tutta la parte destra quando attivo
          if (_isSearchOverlayVisible)
            Positioned.fill(
              left: MediaQuery.of(context).size.width * 0.3, // Inizia dopo la colonna sinistra
              child: _buildSearchOverlay(),
            ),
        ],
      ),
    );
  }


  Widget _buildQuickSearchChip(String label, String searchTerm) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _updateYouTubeSearch(searchTerm),
      backgroundColor: Colors.red.shade100,
      labelStyle: TextStyle(color: Colors.red.shade700),
      avatar: Icon(Icons.search, size: 16, color: Colors.red.shade700),
    );
  }

  Widget _buildSearchOverlay() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header overlay con pulsante chiusura
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ricerca YouTube: "$_currentSearchQuery"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _closeSearchOverlay,
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Chiudi ricerca',
                ),
              ],
            ),
          ),

          // Contenuto overlay
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Istruzioni compatte e chiare
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade600, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'Come procedere:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildOverlayStep('1', '🎬', 'Clicca il pulsante "YouTube" a sinistra'),
                        _buildOverlayStep('2', '🔍', 'Trova il video che ti piace'),
                        _buildOverlayStep('3', '📋', 'Copia il link del video'),
                        _buildOverlayStep('4', '📝', 'Incolla il link nel form a sinistra'),
                        _buildOverlayStep('5', '✅', 'Salva il video nell\'agenda'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayStep(String number, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          const Text(
            'Cerca video su YouTube',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Usa il campo di ricerca nella colonna di sinistra\nper trovare video su YouTube',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _apriVideo(String url) {
    // Naviga alla pagina YouTube player
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YouTubePlayerPage(
          video: VideoEducatore(
            nomeVideo: 'Video Selezionato',
            categoria: 'YouTube',
            linkYoutube: url,
            nomeAgenda: ref.read(agendaSelezionataProvider) ?? '',
            nomeUtente: ref.read(utenteSelezionatoProvider) ?? '',
          ),
        ),
      ),
    );
  }

  Future<void> _confermaEliminaVideo(VideoEducatore video) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Sei sicuro di voler eliminare il video "${video.nomeVideo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref.read(videoEducatoreProvider.notifier).eliminaVideo(video.idVideo!);
        _mostraSuccesso('Video eliminato');
      } catch (e) {
        _mostraErrore('Errore nell\'eliminazione: $e');
      }
    }
  }
}