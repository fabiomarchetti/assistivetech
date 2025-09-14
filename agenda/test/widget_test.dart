import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the app loads
    expect(find.text('Seleziona un\'agenda'), findsOneWidget);
    
    // Verify that menu icons exist (could be in AppBar and FloatingActionButton)
    expect(find.byIcon(Icons.menu), findsAtLeastNWidgets(1));
  });
}