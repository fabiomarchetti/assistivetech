import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../pages/add_activity_page.dart';
import '../models/attivita.dart';

class AgendaFloatingActionButtons extends ConsumerWidget {
  const AgendaFloatingActionButtons({super.key, required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _AddActivityButton(),
        const SizedBox(height: 12),
        _MenuButton(onPressed: onMenuPressed),
        if (!kIsWeb) ...[const SizedBox(height: 12), const _ExportButton()],
      ],
    );
  }
}

class _AddActivityButton extends ConsumerWidget {
  const _AddActivityButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: 'add',
      onPressed: () => _handleAddActivity(context, ref),
      tooltip: 'Aggiungi attività',
      child: const Icon(Icons.add),
    );
  }

  Future<void> _handleAddActivity(BuildContext context, WidgetRef ref) async {
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

      if (data == null || !context.mounted) return;

      final nomeUtente = ref.read(utenteSelezionatoProvider);
      if (nomeUtente == null) {
        if (context.mounted) {
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
        filePath =
            'temp_path'; // Sarà sostituito dal provider con il path reale
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

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Attività aggiunta')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore aggiunta attività: $e')));
      }
    }
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'menu',
      onPressed: onPressed,
      tooltip: 'Apri menu',
      child: const Icon(Icons.menu),
    );
  }
}

class _ExportButton extends ConsumerWidget {
  const _ExportButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: 'export',
      onPressed: () => _handleExport(context, ref),
      tooltip: 'Esporta agenda in JSON',
      child: const Icon(Icons.file_upload_outlined),
    );
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export non supportato nella versione web')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore export: $e')));
      }
    }
  }
}
