import '../l10n/app_localizations.dart';

/// Utilities per validazione input
class InputValidators {
  /// Valida nome agenda
  static String? validateAgendaName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.nameCannotBeEmpty;
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length < 2) {
      return AppLocalizations.nameTooShort;
    }
    
    if (trimmed.length > 50) {
      return AppLocalizations.nameTooLong;
    }
    
    // Controlla caratteri non permessi (quelli problematici per filesystem)
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(trimmed)) {
      return AppLocalizations.invalidCharacters;
    }
    
    // Controlla se inizia o finisce con spazio o punto (prima del trim)
    if (value.startsWith(' ') || value.endsWith(' ') ||
        trimmed.startsWith('.') || trimmed.endsWith('.')) {
      return AppLocalizations.cannotStartEndWithSpaceDot;
    }
    
    return null; // Valido
  }
  
  /// Valida nome pittogramma/attività
  static String? validateActivityName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.activityNameCannotBeEmpty;
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length > 100) {
      return AppLocalizations.activityNameTooLong;
    }
    
    return null; // Valido
  }
  
  /// Pulisce e normalizza nome per uso sicuro come filename
  static String sanitizeForFilename(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Solo lettere, numeri, spazi, trattini
        .replaceAll(RegExp(r'\s+'), '_')      // Spazi -> underscore
        .replaceAll(RegExp(r'_+'), '_')       // Multipli underscore -> singolo
        .replaceAll(RegExp(r'^_|_$'), '');    // Rimuovi underscore inizio/fine
  }
}