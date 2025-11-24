import 'package:flutter/material.dart';

void main() {
  runApp(
    // Il nome della classe sarà sostituito prima di scrivere su file
    CLASS_NAME_PLACEHOLDERApp(),
  );
}

class CLASS_NAME_PLACEHOLDERApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$nome_esercizio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: CLASS_NAME_PLACEHOLDERHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CLASS_NAME_PLACEHOLDERHomePage extends StatefulWidget {
  @override
  _CLASS_NAME_PLACEHOLDERHomePageState createState() => _CLASS_NAME_PLACEHOLDERHomePageState();
}

class _CLASS_NAME_PLACEHOLDERHomePageState extends State<CLASS_NAME_PLACEHOLDERHomePage> {
  static const int EXERCISE_ID = $id_esercizio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$nome_esercizio'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              '$nome_esercizio',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Esercizio di Training Cognitivo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _startExercise();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Inizia Esercizio'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showInstructions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Istruzioni'),
            ),
          ],
        ),
      ),
    );
  }

  void _startExercise() {
    // TODO: Implementare logica esercizio
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Esercizio in sviluppo'),
        content: Text('Questa app Flutter è stata generata automaticamente. Implementa qui la logica specifica per l\'esercizio "$nome_esercizio".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Istruzioni'),
        content: Text('Inserisci qui le istruzioni specifiche per l\'esercizio "$nome_esercizio".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Chiudi'),
          ),
        ],
      ),
    );
  }
}