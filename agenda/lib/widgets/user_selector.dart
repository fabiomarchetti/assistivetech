import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../utils/validators.dart';

/// Widget per selezione e gestione utenti
class UserSelector extends ConsumerWidget {
  const UserSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utentiAsync = ref.watch(utentiProvider);
    final utenteSelezionato = ref.watch(utenteSelezionatoProvider);

    return utentiAsync.when(
      data: (utenti) {
        return PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'NEW_USER') {
              await _showCreateUserDialog(context, ref);
            } else if (value.startsWith('DELETE_')) {
              final nomeUtente = value.substring(7);
              await _showDeleteUserDialog(context, ref, nomeUtente);
            } else {
              // Selezione utente
              ref.read(utenteSelezionatoProvider.notifier).select(value);
            }
          },
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 4),
              Text(
                utenteSelezionato ?? 'Seleziona utente',
                style: const TextStyle(fontSize: 14),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (context) {
            final items = <PopupMenuEntry<String>>[];

            // Aggiungi utenti esistenti
            for (final utente in utenti) {
              items.add(
                PopupMenuItem(
                  value: utente,
                  child: Row(
                    children: [
                      Icon(
                        utente == utenteSelezionato 
                          ? Icons.radio_button_checked 
                          : Icons.radio_button_unchecked,
                        size: 16,
                        color: utente == utenteSelezionato 
                          ? Colors.blue 
                          : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(utente)),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteUserDialog(context, ref, utente);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Separatore
            if (utenti.isNotEmpty) {
              items.add(const PopupMenuDivider());
            }

            // Opzione per creare nuovo utente
            items.add(
              const PopupMenuItem(
                value: 'NEW_USER',
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Nuovo utente'),
                  ],
                ),
              ),
            );

            return items;
          },
        );
      },
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, st) => IconButton(
        onPressed: () => ref.refresh(utentiProvider),
        icon: const Icon(Icons.error, color: Colors.red),
      ),
    );
  }

  Future<void> _showCreateUserDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo utente'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome utente',
              hintText: 'Es: Mario Rossi',
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            validator: (value) {
              // Validazione di base
              final baseError = InputValidators.validateAgendaName(value);
              if (baseError != null) return baseError;
              
              // Controlla duplicati
              final existingUsers = ref.read(utentiProvider).value ?? [];
              if (existingUsers.contains(value?.trim())) {
                return 'Esiste già un utente con questo nome';
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
        await ref.read(utentiProvider.notifier).createUser(nome);
        ref.read(utenteSelezionatoProvider.notifier).select(nome);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Utente "$nome" creato con successo')),
          );
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

  Future<void> _showDeleteUserDialog(BuildContext context, WidgetRef ref, String nome) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare l\'utente "$nome"?\n\n'
          'Questa azione eliminerà anche tutte le agende e attività associate e non può essere annullata.',
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
        await ref.read(utentiProvider.notifier).deleteUser(nome);
        
        // Se l'utente eliminato era quello selezionato, deseleziona
        final currentSelection = ref.read(utenteSelezionatoProvider);
        if (currentSelection == nome) {
          ref.read(utenteSelezionatoProvider.notifier).select(null);
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Utente "$nome" eliminato')),
          );
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