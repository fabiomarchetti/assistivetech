import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../utils/validators.dart';

class AgendaDrawer extends ConsumerWidget {
  const AgendaDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agende = ref.watch(agendeProvider);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Agende',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            agende.when(
              data: (lista) => Column(
                children: [
                  for (final nome in lista) _AgendaListTile(nome: nome),
                  const _NewAgendaListTile(),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
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
            const Divider(),
            // Controllo velocità TTS
            const _TtsSpeedControl(),
            const Divider(),
            // Condizioni d'uso
            const _TermsOfUseListTile(),
          ],
        ),
      ),
    );
  }
}

class _TtsSpeedControl extends ConsumerWidget {
  const _TtsSpeedControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(ttsSpeedProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, size: 20),
              const SizedBox(width: 8),
              Text(
                'Velocità TTS',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Lenta', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: speed,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: '${(speed * 100).round()}%',
                  onChanged: (value) {
                    ref.read(ttsSpeedProvider.notifier).setSpeed(value);
                  },
                ),
              ),
              const Text('Veloce', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgendaListTile extends ConsumerWidget {
  const _AgendaListTile({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaSelezionata = ref.watch(agendaSelezionataProvider);
    final isSelected = agendaSelezionata == nome;

    return ListTile(
      leading: const Icon(Icons.view_agenda_outlined),
      title: Text(nome),
      selected: isSelected,
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'delete') {
            await _showDeleteConfirmationDialog(context, ref);
          }
        },
        itemBuilder: (context) => [
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
      onTap: () {
        ref.read(agendaSelezionataProvider.notifier).select(nome);
        Navigator.of(context).maybePop();
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare l\'agenda "$nome"?\n\n'
          'Questa azione eliminerà anche tutte le attività associate e non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await ref.read(agendeProvider.notifier).deleteAgenda(nome);

        // Se l'agenda eliminata era quella selezionata, deseleziona
        final currentSelection = ref.read(agendaSelezionataProvider);
        if (currentSelection == nome) {
          ref.read(agendaSelezionataProvider.notifier).select(null);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Agenda "$nome" eliminata')));
          Navigator.of(context).maybePop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nell\'eliminazione: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _NewAgendaListTile extends ConsumerWidget {
  const _NewAgendaListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.add_circle_outline),
      title: const Text('Nuova agenda'),
      onTap: () => _showCreateAgendaDialog(context, ref),
    );
  }

  Future<void> _showCreateAgendaDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crea nuova agenda'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome agenda',
              hintText: 'Es: Attività del mattino',
            ),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            validator: (value) {
              // Prima esegui la validazione di base
              final baseError = InputValidators.validateAgendaName(value);
              if (baseError != null) return baseError;

              // Poi controlla se esiste già un'agenda con questo nome
              final existingAgendas = ref.read(agendeProvider).value ?? [];
              if (existingAgendas.contains(value?.trim())) {
                return 'Esiste già un\'agenda con questo nome';
              }

              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('Crea'),
          ),
        ],
      ),
    );

    if (nome != null && nome.isNotEmpty) {
      try {
        await ref.read(agendeProvider.notifier).createAgenda(nome);
        ref.read(agendaSelezionataProvider.notifier).select(nome);
        if (context.mounted) {
          Navigator.of(context).maybePop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _TermsOfUseListTile extends StatelessWidget {
  const _TermsOfUseListTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Condizioni d\'uso'),
      onTap: () => _showTermsOfUseDialog(context),
    );
  }

  void _showTermsOfUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _TermsOfUseDialog(),
    );
  }
}

class _TermsOfUseDialog extends StatelessWidget {
  const _TermsOfUseDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Condizioni d\'uso ARASAAC',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Licenza Creative Commons',
                      'I pittogrammi e le immagini di ARASAAC sono pubblicati sotto licenza Creative Commons (BY-NC-SA), che permette di scaricare, utilizzare e condividere in qualsiasi tipo di formato, purché non sia a scopo commerciale, si citi la fonte e si condivida con la stessa licenza.',
                    ),
                    _buildSection(
                      'Uso consentito',
                      '• Uso educativo e terapeutico\n• Uso personale e familiare\n• Condivisione con la stessa licenza\n• Modifiche e adattamenti (citando la fonte)',
                    ),
                    _buildSection(
                      'Uso NON consentito',
                      '• Uso commerciale senza autorizzazione\n• Vendita dei materiali\n• Uso senza citare la fonte\n• Rimozione del logo ARASAAC',
                    ),
                    _buildSection(
                      'Attribuzione',
                      'Quando utilizzi i materiali ARASAAC, devi sempre includere:\n"Pittogrammi di ARASAAC - http://www.arasaac.org - Licenza CC (BY-NC-SA)"',
                    ),
                    _buildSection(
                      'Responsabilità',
                      'ARASAAC non si assume alcuna responsabilità per l\'uso improprio dei materiali. L\'utente è responsabile del rispetto delle condizioni di licenza.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Per maggiori informazioni visita: https://arasaac.org/terms-of-use',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Chiudi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
