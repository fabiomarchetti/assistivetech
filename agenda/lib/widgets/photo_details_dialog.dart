import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Dialog per inserire nome e frase vocale per una foto selezionata
class PhotoDetailsDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final String initialName;

  const PhotoDetailsDialog({
    super.key,
    required this.imageBytes,
    required this.initialName,
  });

  @override
  State<PhotoDetailsDialog> createState() => _PhotoDetailsDialogState();
}

class _PhotoDetailsDialogState extends State<PhotoDetailsDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phraseController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phraseController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dettagli Foto'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Anteprima immagine
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo nome
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome immagine',
                    hintText: 'Inserisci un nome per l\'immagine',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Il nome è obbligatorio';
                    }
                    if (value.trim().length < 2) {
                      return 'Il nome deve essere di almeno 2 caratteri';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo frase vocale
                TextFormField(
                  controller: _phraseController,
                  decoration: const InputDecoration(
                    labelText: 'Frase da pronunciare',
                    hintText: 'Inserisci la frase che sarà pronunciata',
                    prefixIcon: Icon(Icons.record_voice_over),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La frase vocale è obbligatoria';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop({
                'name': _nameController.text.trim(),
                'phrase': _phraseController.text.trim(),
              });
            }
          },
          child: const Text('Conferma'),
        ),
      ],
    );
  }
}
