import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import '../models/attivita.dart';

/// Database locale per gestire utenti, agende e attività
class LocalDatabase {
  static const _dbName = 'agenda.db';
  static const _dbVersion = 1; // Reset completo - database completamente nuovo

  Database? _db;
  static bool _initialized = false;

  /// Inizializza il database factory per la piattaforma corrente
  static void _initializeDatabaseFactory() {
    if (_initialized) return;
    
    if (kIsWeb) {
      // Per il web, usa sqflite_common_ffi
      databaseFactory = databaseFactoryFfi;
      print('🌐 Database factory inizializzato per WEB');
    } else {
      // Per piattaforme native, usa sqflite standard
      print('📱 Database factory standard per piattaforme native');
    }
    
    _initialized = true;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    
    // Inizializza il database factory per la piattaforma corrente
    _initializeDatabaseFactory();
    
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // Tabella utenti
        await db.execute('''
          CREATE TABLE utenti (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL UNIQUE,
            created_at TEXT,
            updated_at TEXT,
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Tabella agende (ora con riferimento all'utente)
        await db.execute('''
          CREATE TABLE agende (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            nome_utente TEXT NOT NULL,
            created_at TEXT,
            updated_at TEXT,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
          )
        ''');

        // Indice UNIQUE parziale per permettere riuso nomi agende eliminate
        await db.execute('''
          CREATE UNIQUE INDEX idx_agende_active_unique 
          ON agende (nome, nome_utente) 
          WHERE is_deleted = 0
        ''');

        // Tabella attività
        await db.execute('''
          CREATE TABLE attivita (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome_utente TEXT NOT NULL,
            nome_pittogramma TEXT NOT NULL,
            nome_agenda TEXT NOT NULL,
            posizione INTEGER NOT NULL,
            tipo TEXT NOT NULL,
            file_path TEXT NOT NULL,
            frase_vocale TEXT NOT NULL DEFAULT '',
            created_at TEXT,
            updated_at TEXT,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE,
            FOREIGN KEY (nome_agenda, nome_utente) REFERENCES agende (nome, nome_utente) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Aggiunta campo frase_vocale per versione 2
          await db.execute('''
            ALTER TABLE attivita ADD COLUMN frase_vocale TEXT NOT NULL DEFAULT ''
          ''');
        }

        if (oldVersion < 3) {
          // Migrazione per supportare multiutenza (versione 3)

          // 1. Crea tabella utenti
          await db.execute('''
            CREATE TABLE utenti (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL UNIQUE,
              created_at TEXT,
              updated_at TEXT,
              is_deleted INTEGER NOT NULL DEFAULT 0
            )
          ''');

          // 2. Crea un utente predefinito per i dati esistenti
          await db.execute(
            '''
            INSERT INTO utenti (nome, created_at, updated_at, is_deleted)
            VALUES ('Utente Predefinito', ?, ?, 0)
          ''',
            [
              DateTime.now().toIso8601String(),
              DateTime.now().toIso8601String(),
            ],
          );

          // 3. Crea nuova tabella agende con supporto multiutente
          await db.execute('''
            CREATE TABLE agende_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              nome_utente TEXT NOT NULL,
              created_at TEXT,
              updated_at TEXT,
              is_deleted INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
            )
          ''');

          // 4. Migra i dati esistenti
          await db.execute('''
            INSERT INTO agende_new (nome, nome_utente, created_at, updated_at, is_deleted)
            SELECT nome, 'Utente Predefinito', created_at, updated_at, is_deleted
            FROM agende
          ''');

          // 5. Sostituisci la tabella vecchia
          await db.execute('DROP TABLE agende');
          await db.execute('ALTER TABLE agende_new RENAME TO agende');

          // 5.1. Aggiungi l'indice UNIQUE parziale per record attivi
          await db.execute('''
            CREATE UNIQUE INDEX idx_agende_active_unique 
            ON agende (nome, nome_utente) 
            WHERE is_deleted = 0
          ''');

          // 6. Aggiorna la tabella attività per puntare all'utente predefinito
          await db.execute('''
            UPDATE attivita SET nome_utente = 'Utente Predefinito' WHERE nome_utente != 'Utente Predefinito'
          ''');
        }

        if (oldVersion < 4) {
          // Migrazione per permettere riuso nomi agende eliminate (versione 4)

          // 1. Crea nuova tabella agende senza constraint UNIQUE
          await db.execute('''
            CREATE TABLE agende_v4 (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              nome_utente TEXT NOT NULL,
              created_at TEXT,
              updated_at TEXT,
              is_deleted INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
            )
          ''');

          // 2. Migra i dati esistenti
          await db.execute('''
            INSERT INTO agende_v4 (id, nome, nome_utente, created_at, updated_at, is_deleted)
            SELECT id, nome, nome_utente, created_at, updated_at, is_deleted
            FROM agende
          ''');

          // 3. Sostituisci la tabella vecchia
          await db.execute('DROP TABLE agende');
          await db.execute('ALTER TABLE agende_v4 RENAME TO agende');

          // 4. Crea l'indice UNIQUE parziale per record attivi
          await db.execute('''
            CREATE UNIQUE INDEX idx_agende_active_unique 
            ON agende (nome, nome_utente) 
            WHERE is_deleted = 0
          ''');
        }

        if (oldVersion < 5) {
          // Migrazione per spostare dati da "educatore" a "Utente Predefinito" (versione 5)

          // 1. Migra le agende da "educatore" a "Utente Predefinito"
          await db.execute('''
            UPDATE agende 
            SET nome_utente = 'Utente Predefinito' 
            WHERE nome_utente = 'educatore'
          ''');

          // 2. Migra le attività da "educatore" a "Utente Predefinito"
          await db.execute('''
            UPDATE attivita 
            SET nome_utente = 'Utente Predefinito' 
            WHERE nome_utente = 'educatore'
          ''');

          print(
            '🔄 Migrazione completata: dati spostati da "educatore" a "Utente Predefinito"',
          );
        }

        if (oldVersion < 6) {
          // Migrazione per spostare dati da "Utente Predefinito" a "Fabio" (versione 6)

          // 1. Crea l'utente "Fabio" se non esiste
          await db.execute(
            '''
            INSERT OR IGNORE INTO utenti (nome, created_at, updated_at, is_deleted)
            VALUES ('Fabio', ?, ?, 0)
          ''',
            [
              DateTime.now().toIso8601String(),
              DateTime.now().toIso8601String(),
            ],
          );

          // 2. Migra le agende da "Utente Predefinito" a "Fabio"
          await db.execute('''
            UPDATE agende 
            SET nome_utente = 'Fabio' 
            WHERE nome_utente = 'Utente Predefinito'
          ''');

          // 3. Migra le attività da "Utente Predefinito" a "Fabio"
          await db.execute('''
            UPDATE attivita 
            SET nome_utente = 'Fabio' 
            WHERE nome_utente = 'Utente Predefinito'
          ''');

          print(
            '🔄 Migrazione completata: dati spostati da "Utente Predefinito" a "Fabio"',
          );
        }

        if (oldVersion < 7) {
          // Migrazione per pulire completamente il database (versione 7)

          print('🧹 Inizio pulizia completa del database...');

          // 1. Elimina tutte le attività
          await db.delete('attivita');
          print('🗑️ Eliminate tutte le attività');

          // 2. Elimina tutte le agende
          await db.delete('agende');
          print('🗑️ Eliminate tutte le agende');

          // 3. Elimina tutti gli utenti
          await db.delete('utenti');
          print('🗑️ Eliminati tutti gli utenti');

          // 4. Ricrea l'utente predefinito
          await db.execute(
            '''
            INSERT INTO utenti (nome, created_at, updated_at, is_deleted)
            VALUES ('Utente Predefinito', ?, ?, 0)
          ''',
            [
              DateTime.now().toIso8601String(),
              DateTime.now().toIso8601String(),
            ],
          );
          print('✅ Ricreato utente predefinito');

          print('🧹 Pulizia completa del database terminata');
        }

        if (oldVersion < 8) {
          // Migrazione per pulizia profonda e reset completo (versione 8)

          print('🔥 PULIZIA PROFONDA: Eliminazione completa del database...');

          // 1. Chiudi il database corrente
          if (_db != null) {
            await _db!.close();
            _db = null;
          }

          // 2. Elimina completamente il file del database
          final dbPath = await getDatabasesPath();
          final fullPath = p.join(dbPath, _dbName);
          final dbFile = File(fullPath);
          if (await dbFile.exists()) {
            await dbFile.delete();
            print('🗑️ File database eliminato: $fullPath');
          }

          // 3. Ricrea il database da zero
          print('🔄 Ricreazione database da zero...');
          final newDbPath = await getDatabasesPath();
          final newFullPath = p.join(newDbPath, _dbName);
          _db = await openDatabase(
            newFullPath,
            version: _dbVersion,
            onCreate: (db, version) async {
              // Tabella utenti
              await db.execute('''
                CREATE TABLE utenti (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  nome TEXT NOT NULL UNIQUE,
                  created_at TEXT,
                  updated_at TEXT,
                  is_deleted INTEGER NOT NULL DEFAULT 0
                )
              ''');

              // Tabella agende
              await db.execute('''
                CREATE TABLE agende (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  nome TEXT NOT NULL,
                  nome_utente TEXT NOT NULL,
                  created_at TEXT,
                  updated_at TEXT,
                  is_deleted INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
                )
              ''');

              // Indice UNIQUE parziale per record attivi
              await db.execute('''
                CREATE UNIQUE INDEX idx_agende_active_unique 
                ON agende (nome, nome_utente) 
                WHERE is_deleted = 0
              ''');

              // Tabella attività
              await db.execute('''
                CREATE TABLE attivita (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  nome_utente TEXT NOT NULL,
                  nome_pittogramma TEXT NOT NULL,
                  nome_agenda TEXT NOT NULL,
                  posizione INTEGER NOT NULL,
                  tipo TEXT NOT NULL,
                  file_path TEXT NOT NULL,
                  frase_vocale TEXT,
                  created_at TEXT,
                  updated_at TEXT,
                  is_deleted INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
                )
              ''');
            },
          );

          print('✅ Database completamente ricreato e pulito');

          // 4. Pulisci anche la cache dell'app
          await _clearAppCache();
        }

        if (oldVersion < 9) {
          // Migrazione per forzare pulizia completa (versione 9)
          // Questa migrazione viene sempre eseguita per garantire pulizia

          print('🚨 FORZATURA PULIZIA: Eliminazione forzata del database...');

          // 1. Chiudi il database corrente
          if (_db != null) {
            await _db!.close();
            _db = null;
          }

          // 2. Elimina TUTTI i file database possibili
          final dbPath = await getDatabasesPath();
          final fullPath = p.join(dbPath, _dbName);
          final dbFile = File(fullPath);
          if (await dbFile.exists()) {
            await dbFile.delete();
            print('🗑️ File database eliminato: $fullPath');
          }

          // 3. Elimina anche eventuali file di backup
          final backupFiles = [
            '${_dbName}.backup',
            '${_dbName}.old',
            '${_dbName}.tmp',
          ];
          for (final backupFile in backupFiles) {
            final backupPath = p.join(dbPath, backupFile);
            final backupFileObj = File(backupPath);
            if (await backupFileObj.exists()) {
              await backupFileObj.delete();
              print('🗑️ File backup eliminato: $backupPath');
            }
          }

          // 4. Ricrea il database da zero
          print('🔄 Ricreazione database da zero...');
          _db = await openDatabase(
            fullPath,
            version: _dbVersion,
            onCreate: (db, version) async {
              // Tabella utenti
              await db.execute('''
                CREATE TABLE utenti (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  nome TEXT NOT NULL UNIQUE,
                  created_at TEXT,
                  updated_at TEXT,
                  is_deleted INTEGER NOT NULL DEFAULT 0
                )
              ''');

              // Tabella agende
              await db.execute('''
                CREATE TABLE agende (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  nome TEXT NOT NULL,
                  nome_utente TEXT NOT NULL,
                  created_at TEXT,
                  updated_at TEXT,
                  is_deleted INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
                )
              ''');

              // Indice UNIQUE parziale per record attivi
              await db.execute('''
                CREATE UNIQUE INDEX idx_agende_active_unique 
                ON agende (nome, nome_utente) 
                WHERE is_deleted = 0
              ''');

              // Tabella attività
              await db.execute('''
                CREATE TABLE attivita (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  nome_utente TEXT NOT NULL,
                  nome_pittogramma TEXT NOT NULL,
                  nome_agenda TEXT NOT NULL,
                  posizione INTEGER NOT NULL,
                  tipo TEXT NOT NULL,
                  file_path TEXT NOT NULL,
                  frase_vocale TEXT,
                  created_at TEXT,
                  updated_at TEXT,
                  is_deleted INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
                )
              ''');
            },
          );

          print('✅ Database forzatamente ricreato e pulito');

          // 5. Pulisci anche la cache dell'app
          await _clearAppCache();
        }
      },
    );
    return _db!;
  }

  // --- GESTIONE UTENTI ---

  /// Restituisce tutti i nomi utenti non eliminati
  Future<List<String>> fetchUserNames() async {
    final db = await database;

    // Debug: controlla tutti gli utenti nel database
    final allUsers = await db.query('utenti');
    print('👥 Tutti gli utenti nel database:');
    for (final user in allUsers) {
      print('  - Nome: "${user['nome']}", Eliminato: ${user['is_deleted']}');
    }

    final rows = await db.query(
      'utenti',
      columns: ['nome'],
      where: 'is_deleted = 0',
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    final userNames = rows.map((e) => e['nome'] as String).toList();
    print('👥 Utenti attivi: $userNames');
    return userNames;
  }

  /// Inserisce un nuovo utente
  Future<void> insertUser(String nome) async {
    final db = await database;
    print('➕ Tentativo di creare utente: "$nome"');

    try {
      await db.insert('utenti', {
        'nome': nome,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      print('✅ Utente "$nome" creato con successo');
    } catch (e) {
      print('❌ Errore creazione utente "$nome": $e');
      rethrow;
    }
  }

  /// Soft delete utente per nome (elimina anche tutte le agende e attività)
  Future<void> softDeleteUser(String nome) async {
    final db = await database;
    await db.update(
      'utenti',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'nome = ?',
      whereArgs: [nome],
    );
  }

  // --- GESTIONE AGENDE ---

  /// Restituisce tutti i nomi delle agende per un utente specifico (non eliminate)
  Future<List<String>> fetchAgendaNames(String nomeUtente) async {
    final db = await database;
    final rows = await db.query(
      'agende',
      columns: ['nome'],
      where: 'is_deleted = 0 AND nome_utente = ?',
      whereArgs: [nomeUtente],
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    return rows.map((e) => e['nome'] as String).toList();
  }

  /// Versione legacy per compatibilità - usa utente predefinito
  Future<List<String>> fetchAgendaNamesLegacy() async {
    return fetchAgendaNames('Utente Predefinito');
  }

  /// Inserisce una nuova agenda per un utente specifico (nome univoco per utente)
  Future<void> insertAgenda(String nome, String nomeUtente) async {
    final db = await database;
    await db.insert('agende', {
      'nome': nome,
      'nome_utente': nomeUtente,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': 0,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  /// Versione legacy per compatibilità
  Future<void> insertAgendaLegacy(String nome) async {
    return insertAgenda(nome, 'Utente Predefinito');
  }

  /// Soft delete agenda per nome e utente
  Future<void> softDeleteAgenda(String nome, String nomeUtente) async {
    final db = await database;
    await db.update(
      'agende',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'nome = ? AND nome_utente = ?',
      whereArgs: [nome, nomeUtente],
    );
  }

  /// Versione legacy per compatibilità
  Future<void> softDeleteAgendaLegacy(String nome) async {
    return softDeleteAgenda(nome, 'Utente Predefinito');
  }

  /// Pulisce le agende orfane (senza directory corrispondente)
  Future<int> cleanOrphanedAgendas(
    String nomeUtente,
    List<String> existingAgendaDirs,
  ) async {
    final db = await database;

    // Trova tutte le agende attive per l'utente
    final rows = await db.query(
      'agende',
      columns: ['nome'],
      where: 'is_deleted = 0 AND nome_utente = ?',
      whereArgs: [nomeUtente],
    );

    int deletedCount = 0;

    for (final row in rows) {
      final agendaName = row['nome'] as String;
      if (!existingAgendaDirs.contains(agendaName)) {
        // Agenda non ha directory corrispondente, eliminala
        await softDeleteAgenda(agendaName, nomeUtente);
        deletedCount++;
      }
    }

    return deletedCount;
  }

  // --- Attività ---

  /// Elenco attività per agenda e utente (non eliminate), ordinate per posizione crescente
  Future<List<Attivita>> fetchAttivitaByAgenda(
    String nomeAgenda,
    String nomeUtente,
  ) async {
    final db = await database;

    print('🔍 Query database per agenda: "$nomeAgenda", utente: "$nomeUtente"');

    // Prima controlliamo tutte le attività per questo utente
    final allRows = await db.query(
      'attivita',
      where: 'nome_utente = ?',
      whereArgs: [nomeUtente],
    );
    print('📊 Tutte le attività per utente "$nomeUtente": ${allRows.length}');
    for (final row in allRows) {
      print(
        '  - Agenda: "${row['nome_agenda']}", Eliminata: ${row['is_deleted']}, Pittogramma: "${row['nome_pittogramma']}"',
      );
    }

    // Poi facciamo la query specifica
    final rows = await db.query(
      'attivita',
      where: 'is_deleted = 0 AND nome_agenda = ? AND nome_utente = ?',
      whereArgs: [nomeAgenda, nomeUtente],
      orderBy: 'posizione ASC',
    );

    print('🎯 Attività trovate per "$nomeAgenda": ${rows.length}');

    return rows
        .map(
          (e) => Attivita(
            id: e['id'] as int?,
            nomeUtente: e['nome_utente'] as String,
            nomePittogramma: e['nome_pittogramma'] as String,
            nomeAgenda: e['nome_agenda'] as String,
            posizione: e['posizione'] as int,
            tipo: (e['tipo'] as String) == 'foto'
                ? TipoAttivita.foto
                : TipoAttivita.pittogramma,
            filePath: e['file_path'] as String,
            fraseVocale: (e['frase_vocale'] as String?) ?? '',
            createdAt: (e['created_at'] as String?) != null
                ? DateTime.tryParse(e['created_at'] as String)
                : null,
            updatedAt: (e['updated_at'] as String?) != null
                ? DateTime.tryParse(e['updated_at'] as String)
                : null,
            isDeleted: (e['is_deleted'] as int) == 1,
          ),
        )
        .toList();
  }

  /// Versione legacy per compatibilità
  Future<List<Attivita>> fetchAttivitaByAgendaLegacy(String nomeAgenda) async {
    return fetchAttivitaByAgenda(nomeAgenda, 'Utente Predefinito');
  }

  // Inserisce nuova attività alla posizione successiva disponibile
  Future<void> insertAttivita(Attivita attivita) async {
    final db = await database;
    await db.insert('attivita', {
      'nome_utente': attivita.nomeUtente,
      'nome_pittogramma': attivita.nomePittogramma,
      'nome_agenda': attivita.nomeAgenda,
      'posizione': attivita.posizione,
      'tipo': attivita.tipo == TipoAttivita.foto ? 'foto' : 'pittogramma',
      'file_path': attivita.filePath,
      'frase_vocale': attivita.fraseVocale,
      'created_at': attivita.createdAt?.toIso8601String(),
      'updated_at': attivita.updatedAt?.toIso8601String(),
      'is_deleted': attivita.isDeleted ? 1 : 0,
    });
  }

  // Elimina (soft) attività per id e ricompatta posizioni
  Future<void> softDeleteAttivitaById(int id, String nomeAgenda) async {
    final db = await database;
    await db.update(
      'attivita',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _compactPositions(nomeAgenda);
  }

  // Ricompatta le posizioni (1..N) per una agenda
  Future<void> _compactPositions(String nomeAgenda) async {
    final db = await database;
    final rows = await db.query(
      'attivita',
      columns: ['id'],
      where: 'is_deleted = 0 AND nome_agenda = ?',
      whereArgs: [nomeAgenda],
      orderBy: 'posizione ASC',
    );
    int pos = 1;
    for (final row in rows) {
      await db.update(
        'attivita',
        {'posizione': pos++, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  // Sostituisce contenuti di un'attività mantenendo posizione e agenda
  Future<void> replaceAttivitaContent({
    required int id,
    required String nomePittogramma,
    required String filePath,
    required String tipo,
  }) async {
    final db = await database;
    await db.update(
      'attivita',
      {
        'nome_pittogramma': nomePittogramma,
        'file_path': filePath,
        'tipo': tipo,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Aggiorna le posizioni con l'ordine fornito (lista di id in nuovo ordine)
  Future<void> updateAttivitaPositions(
    String nomeAgenda,
    List<int> orderedIds,
  ) async {
    final db = await database;
    int pos = 1;
    for (final id in orderedIds) {
      await db.update(
        'attivita',
        {'posizione': pos++, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ? AND nome_agenda = ?',
        whereArgs: [id, nomeAgenda],
      );
    }
  }

  /// Elimina tutte le attività (soft) di un'agenda per un utente specifico
  Future<void> softDeleteAllInAgenda(
    String nomeAgenda,
    String nomeUtente,
  ) async {
    final db = await database;
    await db.update(
      'attivita',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'nome_agenda = ? AND nome_utente = ? AND is_deleted = 0',
      whereArgs: [nomeAgenda, nomeUtente],
    );
  }

  /// Versione legacy per compatibilità
  Future<void> softDeleteAllInAgendaLegacy(String nomeAgenda) async {
    return softDeleteAllInAgenda(nomeAgenda, 'Utente Predefinito');
  }

  /// Riordina le attività aggiornando le posizioni nel database
  Future<void> reorderAttivita(
    String nomeAgenda,
    String nomeUtente,
    int oldIndex,
    int newIndex,
  ) async {
    final db = await database;

    // Ottieni tutte le attività ordinate per posizione
    final attivita = await fetchAttivitaByAgenda(nomeAgenda, nomeUtente);

    if (oldIndex < 0 ||
        oldIndex >= attivita.length ||
        newIndex < 0 ||
        newIndex >= attivita.length) {
      throw Exception('Indici non validi per il riordino');
    }

    // Sposta l'elemento nella nuova posizione
    final movedItem = attivita.removeAt(oldIndex);
    attivita.insert(newIndex, movedItem);

    // Aggiorna tutte le posizioni nel database
    for (int i = 0; i < attivita.length; i++) {
      await db.update(
        'attivita',
        {'posizione': i + 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [attivita[i].id],
      );
    }

    print(
      '🔄 Riordinamento completato: ${attivita.length} attività aggiornate',
    );
  }

  /// Pulisce la cache dell'app eliminando file temporali
  Future<void> _clearAppCache() async {
    try {
      print('🧹 Pulizia cache dell\'app...');

      // Pulisci la cache di Flutter
      final tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        final flutterCacheDir = Directory(
          p.join(tempDir.path, 'flutter_cache'),
        );
        if (await flutterCacheDir.exists()) {
          await flutterCacheDir.delete(recursive: true);
          print('🗑️ Cache Flutter eliminata');
        }
      }

      print('✅ Cache dell\'app pulita');
    } catch (e) {
      print('⚠️ Errore pulizia cache: $e');
    }
  }
}
