/// Localizations constants - preparazione per i18n futuro
class AppLocalizations {
  // App generale
  static const String appTitle = 'Agenda';
  static const String selectAgenda = 'Seleziona un\'agenda';
  
  // Drawer
  static const String agende = 'Agende';
  static const String newAgenda = 'Nuova agenda';
  
  // Dialog creazione agenda
  static const String createNewAgenda = 'Crea nuova agenda';
  static const String agendaNameLabel = 'Nome agenda';
  static const String agendaNameHint = 'Es: Attività del mattino';
  static const String cancel = 'Annulla';
  static const String create = 'Crea';
  
  // Lista attività
  static const String noActivities = 'Nessuna attività.';
  static const String addInstructionText = 'Aggiungi un pittogramma o una foto con il pulsante +';
  static const String position = 'Posizione';
  
  // Gestione attività
  static const String manageActivity = 'Gestisci attività';
  static const String deleteOrReplaceQuestion = 'Vuoi eliminare o sostituire questa attività?';
  static const String delete = 'Elimina';
  static const String replace = 'Sostituisci';
  
  // Dialog aggiunta attività
  static const String addActivity = 'Aggiungi attività';
  static const String pictogram = 'Pittogramma';
  static const String photo = 'Foto';
  static const String close = 'Chiudi';
  static const String searchPictograms = 'Cerca pittogrammi ARASAAC';
  static const String noResults = 'Nessun risultato';
  static const String takePhoto = 'Scatta foto';
  
  // Tooltips
  static const String addActivityTooltip = 'Aggiungi attività';
  static const String openMenuTooltip = 'Apri menu';
  static const String exportAgendaTooltip = 'Esporta agenda in JSON';
  
  // Messaggi di successo
  static const String activityAdded = 'Attività aggiunta';
  static const String activityDeleted = 'Attività eliminata';
  static const String activityReplaced = 'Attività sostituita';
  static const String exportedTo = 'Esportato in:';
  
  // Errori generali
  static const String error = 'Errore';
  static const String selectAgendaFirst = 'Seleziona prima un\'agenda';
  
  // Errori specifici
  static const String errorCreatingAgenda = 'Errore creazione agenda';
  static const String errorAddingActivity = 'Errore aggiunta attività';
  static const String errorReordering = 'Errore riordino';
  static const String errorReplacing = 'Errore sostituzione';
  static const String errorExport = 'Errore export';
  
  // Validazione
  static const String nameCannotBeEmpty = 'Il nome agenda non può essere vuoto';
  static const String nameTooShort = 'Il nome deve essere almeno 2 caratteri';
  static const String nameTooLong = 'Il nome non può superare 50 caratteri';
  static const String invalidCharacters = 'Caratteri non permessi: < > : " / \\ | ? *';
  static const String cannotStartEndWithSpaceDot = 'Non può iniziare/finire con spazio o punto';
  static const String activityNameCannotBeEmpty = 'Il nome non può essere vuoto';
  static const String activityNameTooLong = 'Il nome non può superare 100 caratteri';
}