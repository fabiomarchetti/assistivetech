import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attivita.dart';
import '../providers/providers.dart';

class ActivityCardLarge extends ConsumerWidget {
  const ActivityCardLarge({
    super.key,
    required this.attivita,
    required this.onDelete,
    required this.onReplace,
  });

  final Attivita attivita;
  final VoidCallback onDelete;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _speakPhrase(ref),
      child: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header con solo menu azioni
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'delete':
                            onDelete();
                            break;
                          case 'replace':
                            onReplace();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'replace',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz),
                              SizedBox(width: 8),
                              Text('Sostituisci'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Elimina'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Immagine a schermo pieno
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Costruisce il widget immagine appropriato per la piattaforma
  Widget _buildImage() {
    try {
      if (attivita.filePath.startsWith('data:')) {
        // Dati base64
        final base64String = attivita.filePath.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } else if (attivita.filePath.startsWith('http')) {
        // URL remoto
        return Image.network(
          attivita.filePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } else if (!kIsWeb) {
        // File locale (solo mobile)
        return Image.file(
          File(attivita.filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } else {
        // Su web, file path non valido
        return _buildErrorWidget();
      }
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  /// Widget di errore quando l'immagine non può essere caricata
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade100,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Immagine non disponibile',
            style: TextStyle(color: Colors.grey),
          ),
        ],
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
}
