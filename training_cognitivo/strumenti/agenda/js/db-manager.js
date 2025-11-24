/**
 * Database Manager per SQLite locale (offline PWA)
 * Utilizza sql.js (SQLite compilato in WebAssembly)
 * Docs: https://sql.js.org/
 */

class DBManager {
    constructor() {
        this.db = null;
        this.isInitialized = false;
        this.dbName = 'agende_strumenti_db';
    }

    /**
     * Inizializza database SQLite
     */
    async init() {
        if (this.isInitialized) {
            return;
        }

        try {
            // Carica sql.js library da CDN
            const SQL = await initSqlJs({
                locateFile: file => `https://sql.js.org/dist/${file}`
            });

            // Prova a caricare DB da localStorage
            const savedDb = localStorage.getItem(this.dbName);

            if (savedDb) {
                // Carica DB esistente
                const buffer = this.base64ToBuffer(savedDb);
                this.db = new SQL.Database(buffer);
                console.log('Database caricato da localStorage');
            } else {
                // Crea nuovo DB
                this.db = new SQL.Database();
                await this.createTables();
                console.log('Nuovo database creato');
            }

            this.isInitialized = true;

        } catch (error) {
            console.error('Errore inizializzazione DB:', error);
            throw error;
        }
    }

    /**
     * Crea tabelle SQLite
     */
    async createTables() {
        const sql = `
            -- Tabella agende
            CREATE TABLE IF NOT EXISTS agende_strumenti_local (
                id_agenda INTEGER PRIMARY KEY AUTOINCREMENT,
                id_server INTEGER,
                nome_agenda TEXT NOT NULL,
                id_paziente INTEGER NOT NULL,
                id_educatore INTEGER NOT NULL,
                id_agenda_parent INTEGER,
                tipo_agenda TEXT DEFAULT 'principale',
                data_creazione TEXT,
                stato TEXT DEFAULT 'attiva',
                sync_status TEXT DEFAULT 'pending'
            );

            -- Tabella items
            CREATE TABLE IF NOT EXISTS agende_items_local (
                id_item INTEGER PRIMARY KEY AUTOINCREMENT,
                id_server INTEGER,
                id_agenda INTEGER NOT NULL,
                tipo_item TEXT NOT NULL,
                titolo TEXT NOT NULL,
                posizione INTEGER DEFAULT 0,
                tipo_immagine TEXT DEFAULT 'nessuna',
                id_arasaac INTEGER,
                url_immagine TEXT,
                id_agenda_collegata INTEGER,
                video_youtube_id TEXT,
                video_youtube_title TEXT,
                video_youtube_thumbnail TEXT,
                data_creazione TEXT,
                stato TEXT DEFAULT 'attivo',
                sync_status TEXT DEFAULT 'pending',
                FOREIGN KEY (id_agenda) REFERENCES agende_strumenti_local(id_agenda) ON DELETE CASCADE
            );

            -- Indici
            CREATE INDEX IF NOT EXISTS idx_agenda_local ON agende_items_local(id_agenda);
            CREATE INDEX IF NOT EXISTS idx_paziente_local ON agende_strumenti_local(id_paziente);
            CREATE INDEX IF NOT EXISTS idx_sync_agenda ON agende_strumenti_local(sync_status);
            CREATE INDEX IF NOT EXISTS idx_sync_item ON agende_items_local(sync_status);
        `;

        this.db.run(sql);
        await this.save();
    }

    /**
     * Salva DB in localStorage
     */
    async save() {
        try {
            const buffer = this.db.export();
            const base64 = this.bufferToBase64(buffer);
            localStorage.setItem(this.dbName, base64);
        } catch (error) {
            console.error('Errore salvataggio DB:', error);
        }
    }

    /**
     * Esegue query SELECT
     * @param {string} sql - Query SQL
     * @param {Array} params - Parametri
     * @returns {Array} Array di oggetti risultato
     */
    query(sql, params = []) {
        try {
            const stmt = this.db.prepare(sql);
            stmt.bind(params);

            const results = [];
            while (stmt.step()) {
                const row = stmt.getAsObject();
                results.push(row);
            }
            stmt.free();

            return results;

        } catch (error) {
            console.error('Errore query:', error);
            throw error;
        }
    }

    /**
     * Esegue query INSERT/UPDATE/DELETE
     * @param {string} sql - Query SQL
     * @param {Array} params - Parametri
     * @returns {number} Last insert ID o affected rows
     */
    async execute(sql, params = []) {
        try {
            const stmt = this.db.prepare(sql);
            stmt.bind(params);
            stmt.step();
            stmt.free();

            await this.save();

            // Ritorna last insert ID
            const lastId = this.query('SELECT last_insert_rowid() as id');
            return lastId[0]?.id || 0;

        } catch (error) {
            console.error('Errore execute:', error);
            throw error;
        }
    }

    /**
     * Inizia transazione
     */
    beginTransaction() {
        this.db.run('BEGIN TRANSACTION');
    }

    /**
     * Commit transazione
     */
    async commit() {
        this.db.run('COMMIT');
        await this.save();
    }

    /**
     * Rollback transazione
     */
    rollback() {
        this.db.run('ROLLBACK');
    }

    // ========== METODI SPECIFICI AGENDE ==========

    /**
     * Crea agenda locale
     */
    async createAgendaLocal(nome_agenda, id_paziente, id_educatore, id_agenda_parent = null) {
        const sql = `
            INSERT INTO agende_strumenti_local
            (nome_agenda, id_paziente, id_educatore, id_agenda_parent, tipo_agenda, data_creazione, stato, sync_status)
            VALUES (?, ?, ?, ?, ?, ?, 'attiva', 'pending')
        `;

        const tipo = id_agenda_parent ? 'sottomenu' : 'principale';
        const data = new Date().toLocaleString('it-IT');

        return await this.execute(sql, [nome_agenda, id_paziente, id_educatore, id_agenda_parent, tipo, data]);
    }

    /**
     * Lista agende locali
     */
    getAgendeLocal(id_paziente, solo_principali = false) {
        let sql = `
            SELECT * FROM agende_strumenti_local
            WHERE id_paziente = ? AND stato = 'attiva'
        `;

        if (solo_principali) {
            sql += ' AND id_agenda_parent IS NULL';
        }

        sql += ' ORDER BY tipo_agenda DESC, data_creazione DESC';

        return this.query(sql, [id_paziente]);
    }

    /**
     * Ottieni agenda locale
     */
    getAgendaLocal(id_agenda) {
        const sql = 'SELECT * FROM agende_strumenti_local WHERE id_agenda = ?';
        const results = this.query(sql, [id_agenda]);
        return results[0] || null;
    }

    /**
     * Aggiorna agenda locale
     */
    async updateAgendaLocal(id_agenda, nome_agenda) {
        const sql = 'UPDATE agende_strumenti_local SET nome_agenda = ?, sync_status = "pending" WHERE id_agenda = ?';
        return await this.execute(sql, [nome_agenda, id_agenda]);
    }

    /**
     * Elimina agenda locale (soft delete)
     */
    async deleteAgendaLocal(id_agenda) {
        const sql = 'UPDATE agende_strumenti_local SET stato = "archiviata", sync_status = "pending" WHERE id_agenda = ?';
        await this.execute(sql, [id_agenda]);

        // Archivia anche item
        const sqlItems = 'UPDATE agende_items_local SET stato = "archiviato", sync_status = "pending" WHERE id_agenda = ?';
        await this.execute(sqlItems, [id_agenda]);
    }

    // ========== METODI SPECIFICI ITEMS ==========

    /**
     * Crea item locale
     */
    async createItemLocal(itemData) {
        const sql = `
            INSERT INTO agende_items_local
            (id_agenda, tipo_item, titolo, posizione, tipo_immagine, id_arasaac, url_immagine,
             id_agenda_collegata, video_youtube_id, video_youtube_title, video_youtube_thumbnail,
             data_creazione, stato, sync_status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'attivo', 'pending')
        `;

        // Calcola posizione
        const posResults = this.query(
            'SELECT COALESCE(MAX(posizione), -1) + 1 as pos FROM agende_items_local WHERE id_agenda = ?',
            [itemData.id_agenda]
        );
        const posizione = posResults[0]?.pos || 0;

        const data = new Date().toLocaleString('it-IT');

        return await this.execute(sql, [
            itemData.id_agenda,
            itemData.tipo_item,
            itemData.titolo,
            posizione,
            itemData.tipo_immagine || 'nessuna',
            itemData.id_arasaac || null,
            itemData.url_immagine || null,
            itemData.id_agenda_collegata || null,
            itemData.video_youtube_id || null,
            itemData.video_youtube_title || null,
            itemData.video_youtube_thumbnail || null,
            data
        ]);
    }

    /**
     * Lista items locali
     */
    getItemsLocal(id_agenda) {
        const sql = `
            SELECT * FROM agende_items_local
            WHERE id_agenda = ? AND stato = 'attivo'
            ORDER BY posizione ASC
        `;
        return this.query(sql, [id_agenda]);
    }

    /**
     * Ottieni item locale
     */
    getItemLocal(id_item) {
        const sql = 'SELECT * FROM agende_items_local WHERE id_item = ?';
        const results = this.query(sql, [id_item]);
        return results[0] || null;
    }

    /**
     * Aggiorna item locale
     */
    async updateItemLocal(id_item, updates) {
        const fields = Object.keys(updates).map(key => `${key} = ?`).join(', ');
        const values = Object.values(updates);
        values.push(id_item);

        const sql = `UPDATE agende_items_local SET ${fields}, sync_status = "pending" WHERE id_item = ?`;
        return await this.execute(sql, values);
    }

    /**
     * Riordina items locali
     */
    async reorderItemsLocal(items) {
        this.beginTransaction();

        try {
            const sql = 'UPDATE agende_items_local SET posizione = ?, sync_status = "pending" WHERE id_item = ?';

            for (const item of items) {
                await this.execute(sql, [item.posizione, item.id_item]);
            }

            await this.commit();

        } catch (error) {
            this.rollback();
            throw error;
        }
    }

    /**
     * Elimina item locale (soft delete)
     */
    async deleteItemLocal(id_item) {
        const sql = 'UPDATE agende_items_local SET stato = "archiviato", sync_status = "pending" WHERE id_item = ?';
        return await this.execute(sql, [id_item]);
    }

    // ========== UTILITY ==========

    /**
     * Converte buffer in base64
     */
    bufferToBase64(buffer) {
        let binary = '';
        const bytes = new Uint8Array(buffer);
        for (let i = 0; i < bytes.byteLength; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        return btoa(binary);
    }

    /**
     * Converte base64 in buffer
     */
    base64ToBuffer(base64) {
        const binary = atob(base64);
        const buffer = new Uint8Array(binary.length);
        for (let i = 0; i < binary.length; i++) {
            buffer[i] = binary.charCodeAt(i);
        }
        return buffer;
    }

    /**
     * Resetta database (ATTENZIONE: cancella tutti i dati!)
     */
    async reset() {
        localStorage.removeItem(this.dbName);
        this.db.close();
        this.isInitialized = false;
        await this.init();
    }
}

// Istanza globale
const dbManager = new DBManager();
