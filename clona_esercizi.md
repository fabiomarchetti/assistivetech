## Guida rapida: clonare la vista Risultati per nuovi esercizi

Questa guida elenca i file chiave e i passaggi per duplicare la pagina risultati (con filtri e tabella) e riutilizzarla per altre aree/obiettivi (frutta, animali, numeri, lettere, colori, ecc.).

### File chiave (da conoscere/riusare)
- `risultati/index.html`
  - UI dei filtri: `Educatore`, `Paziente`, `Categoria`, `Esercizio`, `Items`, `Da data`, `A data`, bottoni `Mattina`/`Pomeriggio`.
  - Logiche: auto-caricamento iniziale, auto-filtraggio con debounce, pre-selezione automatica dell’educatore loggato, pannello di debug API, render tabella (`Data`, `Orario`, `Item`, `Items`, `Latenza (s)`).
- `api/api_risultati_esercizi.php`
  - Endpoint dati: `get_results`, `get_distinct`, `get_statistics`.
  - Flusso sessione: `start_session`, `save_result`, `end_session`.
  - Gestione timezone (default `Europe/Rome`, variabile `APP_TZ`), normalizzazione campi data/ora e fallback.
- `risultati/istogramma.html`
  - Istogrammi per sessione corrente, selettore “Vista” (Percentuali vs Dettaglio Item), uso coerente di `items_totali_utilizzati` e orari.
- (Opzionali come template di viste alternative): `risultati/items.html`, `risultati/scatter.html`, `risultati/trend.html`.
- Origine dati dalle pagine esercizio (solo per registrazione, non per visualizzazione):
  - `training_cognitivo/categorizzazione/*/index.html` e `training_cognitivo/causa_effetto/*/index.html` invocano `start_session`/`save_result`/`end_session`.

### Struttura e logiche riutilizzabili
- Auto-preselezione Educatore: lettura da `localStorage.getItem('user')` e match su nome/cognome; per sviluppatore mostra “Sviluppatore/Anonimo” come default.
- Filtri reattivi: al `change` dei controlli parte la ricerca con debounce (nessun click “Cerca” necessario).
- Filtro fasce orarie: bottoni `Mattina (08:00–13:59)` e `Pomeriggio (14:00–20:59)` impostano i vincoli di orario.
- Compatibilità colonne: l’API seleziona solo colonne esistenti e calcola fallback (es. `items_totali_utilizzati`, date/ore derivate) per retrocompatibilità.
- Debug integrato: pulsante che mostra richiesta/risposta API e, con `debug=1`, dettaglio di SQL e dati campione.

### Come clonare per un nuovo obiettivo/esercizio
1. Duplica la vista risultati
   - Copia `risultati/index.html` in una nuova pagina, es.: `risultati/<categoria>_<vista>.html` (es. `risultati/categorizzazione_frutta.html`).
2. Imposta default dei filtri (facoltativo)
   - Preimposta `Categoria`/`Esercizio` coerenti con la nuova pagina (lascia comunque modificabili dall’utente).
3. Mantieni auto-preselezione Educatore
   - Riusa la logica che legge l’utente loggato da `localStorage` e seleziona l’educatore corrispondente.
4. Conserva l’auto-filtraggio
   - Associa `change` dei filtri a `search()` con debounce; evita pulsanti di submit superflui.
5. Pannello debug
   - Mantieni il toggle debug: utile per diagnosticare rapidamente problemi di dati/SQL.
6. Colonne tabella
   - Mantieni “Data”, “Orario”, “Item”, “Items”, “Latenza (s)”. Aggiungi/rimuovi colonne solo se strettamente necessario.
7. Rimozione voci non valide
   - Filtra client-side l’eventuale “trova frutti” dalla tendina degli esercizi se non pertinente.
8. Backend
   - Non creare nuovi endpoint: riutilizza `api/api_risultati_esercizi.php` con `get_results`/`get_distinct`/`get_statistics`.
9. Verifiche
   - Controlla che le date/ore compaiano (usando i fallback API) e che i filtri (educatore/paziente/categoria/esercizio/items/data/fasce) rispondano subito.

### Note operative e best practice
- Timezone: assicurarsi che l’API giri con `date_default_timezone_set('Europe/Rome')` o variabile `APP_TZ` configurata in hosting.
- Date/ore: l’API calcola `data_esecuzione`/`ora_inizio_esercizio`/`ora_fine_esercizio` anche da campi legacy (`started_at`, `timestamp_inizio`, `created_at`, `__data_esercizio_ts`).
- Prestazioni: usa `limit` adeguato e ordina per tempo di inizio (o `id_risultato`) quando necessario.
- Sicurezza: rispetta la visibilità per Ruolo (Sviluppatore, Direttore/CaseManager, Educatore) lato UI e, se richiesto, lato API.

### Checklist rapida (per ogni nuova pagina)
- [ ] Pagina duplicata da `risultati/index.html` e rinominata correttamente.
- [ ] Educatore loggato preselezionato automaticamente.
- [ ] Filtri attivi e auto-filtraggio con debounce funzionante.
- [ ] Bottoni `Mattina`/`Pomeriggio` operativi.
- [ ] Dropdown `Esercizio` ripulito da voci non pertinenti (es. “trova frutti”).
- [ ] Tabella con colonne minime: `Data`, `Orario`, `Item`, `Items`, `Latenza (s)`.
- [ ] Pannello debug visibile e utile in caso di problemi.
- [ ] Dati coerenti in arrivo da `api/api_risultati_esercizi.php` con date/ore valorizzate.



