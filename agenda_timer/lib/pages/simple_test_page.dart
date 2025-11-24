import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/simple_providers.dart';
import '../models/attivita.dart';

class SimpleTestPage extends ConsumerWidget {
  const SimpleTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sistema JSON + Assets'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sezione Utenti
            _buildUsersSection(ref),
            const SizedBox(height: 20),
            
            // Sezione Agende
            _buildAgendasSection(ref),
            const SizedBox(height: 20),
            
            // Sezione Attività
            _buildActivitiesSection(ref),
            const SizedBox(height: 20),
            
            // Test aggiunta attività da ARASAAC
            _buildTestSection(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersSection(WidgetRef ref) {
    final usersAsync = ref.watch(usersNotifierProvider);
    final selectedUser = ref.watch(selectedUserProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👤 Utenti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            usersAsync.when(
              data: (users) => Column(
                children: [
                  DropdownButton<String>(
                    value: selectedUser,
                    hint: const Text('Seleziona utente'),
                    isExpanded: true,
                    items: users.map((user) => DropdownMenuItem(
                      value: user,
                      child: Text(user),
                    )).toList(),
                    onChanged: (user) => ref.read(selectedUserProvider.notifier).state = user,
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () => _showAddUserDialog(context, ref),
                      child: const Text('Aggiungi Utente'),
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Errore: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendasSection(WidgetRef ref) {
    final agendasAsync = ref.watch(agendasNotifierProvider);
    final selectedAgenda = ref.watch(selectedAgendaProvider);
    final selectedUser = ref.watch(selectedUserProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📚 Agende', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (selectedUser == null)
              const Text('⚠️ Seleziona prima un utente')
            else
              agendasAsync.when(
                data: (agendas) => Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedAgenda,
                      hint: const Text('Seleziona agenda'),
                      isExpanded: true,
                      items: agendas.map((agenda) => DropdownMenuItem(
                        value: agenda,
                        child: Text(agenda),
                      )).toList(),
                      onChanged: (agenda) => ref.read(selectedAgendaProvider.notifier).state = agenda,
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () => _showAddAgendaDialog(context, ref),
                        child: const Text('Aggiungi Agenda'),
                      ),
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text('Errore: $error'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesSection(WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesNotifierProvider);
    final selectedUser = ref.watch(selectedUserProvider);
    final selectedAgenda = ref.watch(selectedAgendaProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 Attività', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (selectedUser == null || selectedAgenda == null)
              const Text('⚠️ Seleziona utente e agenda')
            else
              activitiesAsync.when(
                data: (activities) => activities.isEmpty
                    ? const Text('📋 Nessuna attività')
                    : SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            return ListTile(
                              leading: Image.network(
                                activity.filePath,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                              title: Text(activity.nomePittogramma),
                              subtitle: Text(activity.fraseVocale),
                              trailing: Text('Pos: ${activity.posizione}'),
                            );
                          },
                        ),
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text('Errore: $error'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧪 Test', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _testAddActivity(ref),
              child: const Text('Test: Aggiungi "Mangiare" da ARASAAC'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddUserDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo Utente'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome utente'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(usersNotifierProvider.notifier).addUser(result);
    }
  }

  Future<void> _showAddAgendaDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuova Agenda'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome agenda'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(agendasNotifierProvider.notifier).addAgenda(result);
    }
  }

  Future<void> _testAddActivity(WidgetRef ref) async {
    try {
      // Test semplificato: aggiungi direttamente senza scaricare
      final selectedUser = ref.read(selectedUserProvider);
      final selectedAgenda = ref.read(selectedAgendaProvider);
      
      if (selectedUser == null) {
        print('❌ Seleziona prima un utente');
        return;
      }
      if (selectedAgenda == null) {
        print('❌ Seleziona prima un\'agenda');
        return;
      }
      
      // Usa direttamente l'URL ARASAAC
      final service = ref.read(jsonDataServiceProvider);
      await service.addActivity(
        userName: selectedUser,
        agendaName: selectedAgenda,
        activityName: 'mangiare',
        imageUrl: 'https://api.arasaac.org/api/pictograms/2457',
        type: TipoAttivita.pittogramma,
        phrase: 'È ora di mangiare!',
      );
      
      // Ricarica la lista invalidando il provider
      ref.invalidate(activitiesNotifierProvider);
      
      print('✅ Attività di test aggiunta con successo');
    } catch (e) {
      print('❌ Errore aggiunta attività: $e');
    }
  }
}