/**
 * Database Locale - IndexedDB per funzionamento offline PWA
 * Gestisce utenti, pagine e items in locale
 */

class LocalDatabase {
    constructor() {
        this.dbName = 'comunicatore_local_db';
        this.version = 1;
        this.db = null;
    }

    /**
     * Inizializza database IndexedDB
     */
    async init() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, this.version);

            request.onerror = () => reject(request.error);
            request.onsuccess = () => {
                this.db = request.result;
                console.log('✅ Database locale inizializzato');
                resolve(this.db);
            };

            request.onupgradeneeded = (event) => {
                const db = event.target.result;

                // Store Utenti
                if (!db.objectStoreNames.contains('utenti')) {
                    const utentiStore = db.createObjectStore('utenti', { 
                        keyPath: 'id', 
                        autoIncrement: true 
                    });
                    utentiStore.createIndex('nome', 'nome', { unique: true });
                }

                // Store Pagine
                if (!db.objectStoreNames.contains('pagine')) {
                    const pagineStore = db.createObjectStore('pagine', { 
                        keyPath: 'id_pagina', 
                        autoIncrement: true 
                    });
                    pagineStore.createIndex('id_utente', 'id_utente', { unique: false });
                    pagineStore.createIndex('numero_ordine', 'numero_ordine', { unique: false });
                }

                // Store Items
                if (!db.objectStoreNames.contains('items')) {
                    const itemsStore = db.createObjectStore('items', { 
                        keyPath: 'id_item', 
                        autoIncrement: true 
                    });
                    itemsStore.createIndex('id_pagina', 'id_pagina', { unique: false });
                    itemsStore.createIndex('posizione_griglia', 'posizione_griglia', { unique: false });
                }

                console.log('📦 Database locale creato');
            };
        });
    }

    /**
     * Helper per transazioni
     */
    async transaction(storeName, mode, callback) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(storeName, mode);
            const store = tx.objectStore(storeName);

            tx.oncomplete = () => resolve();
            tx.onerror = () => reject(tx.error);

            callback(store);
        });
    }

    // ========== UTENTI ==========

    /**
     * Crea/Aggiorna utente locale
     */
    async saveUtente(nome) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('utenti', 'readwrite');
            const store = tx.objectStore('utenti');
            const index = store.index('nome');

            // Verifica se esiste già
            const getRequest = index.get(nome);

            getRequest.onsuccess = () => {
                if (getRequest.result) {
                    // Già esistente
                    resolve(getRequest.result);
                } else {
                    // Crea nuovo
                    const utente = {
                        nome: nome,
                        data_creazione: new Date().toISOString()
                    };

                    const addRequest = store.add(utente);
                    addRequest.onsuccess = () => {
                        utente.id = addRequest.result;
                        resolve(utente);
                    };
                    addRequest.onerror = () => reject(addRequest.error);
                }
            };

            getRequest.onerror = () => reject(getRequest.error);
        });
    }

    /**
     * Lista tutti gli utenti locali
     */
    async listUtenti() {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('utenti', 'readonly');
            const store = tx.objectStore('utenti');
            const request = store.getAll();

            request.onsuccess = () => resolve(request.result || []);
            request.onerror = () => reject(request.error);
        });
    }

    /**
     * Ottieni utente per ID
     */
    async getUtente(id) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('utenti', 'readonly');
            const store = tx.objectStore('utenti');
            const request = store.get(id);

            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    // ========== PAGINE ==========

    /**
     * Crea pagina locale
     */
    async createPagina(paginaData) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('pagine', 'readwrite');
            const store = tx.objectStore('pagine');

            const pagina = {
                ...paginaData,
                data_creazione: new Date().toISOString(),
                stato: 'attiva'
            };

            const request = store.add(pagina);

            request.onsuccess = () => {
                pagina.id_pagina = request.result;
                resolve(pagina);
            };
            request.onerror = () => reject(request.error);
        });
    }

    /**
     * Lista pagine di un utente
     */
    async listPagine(idUtente) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('pagine', 'readonly');
            const store = tx.objectStore('pagine');
            const index = store.index('id_utente');
            const request = index.getAll(idUtente);

            request.onsuccess = () => {
                const pagine = (request.result || [])
                    .filter(p => p.stato === 'attiva')
                    .sort((a, b) => a.numero_ordine - b.numero_ordine);
                resolve(pagine);
            };
            request.onerror = () => reject(request.error);
        });
    }

    /**
     * Ottieni pagina con items
     */
    async getPagina(idPagina) {
        if (!this.db) await this.init();

        const pagina = await new Promise((resolve, reject) => {
            const tx = this.db.transaction('pagine', 'readonly');
            const store = tx.objectStore('pagine');
            const request = store.get(idPagina);

            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });

        if (pagina) {
            pagina.items = await this.listItems(idPagina);
        }

        return pagina;
    }

    /**
     * Aggiorna pagina
     */
    async updatePagina(idPagina, updates) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('pagine', 'readwrite');
            const store = tx.objectStore('pagine');
            const getRequest = store.get(idPagina);

            getRequest.onsuccess = () => {
                const pagina = getRequest.result;
                if (!pagina) {
                    reject(new Error('Pagina non trovata'));
                    return;
                }

                Object.assign(pagina, updates, {
                    data_modifica: new Date().toISOString()
                });

                const putRequest = store.put(pagina);
                putRequest.onsuccess = () => resolve(pagina);
                putRequest.onerror = () => reject(putRequest.error);
            };

            getRequest.onerror = () => reject(getRequest.error);
        });
    }

    /**
     * Elimina pagina
     */
    async deletePagina(idPagina) {
        if (!this.db) await this.init();

        // Soft delete
        return this.updatePagina(idPagina, { stato: 'archiviata' });
    }

    /**
     * Riordina pagine
     * @param {Array} ordini - Array di oggetti {id_pagina, numero_ordine}
     */
    async reorderPagine(ordini) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('pagine', 'readwrite');
            const store = tx.objectStore('pagine');
            let completed = 0;

            for (const item of ordini) {
                const getRequest = store.get(item.id_pagina);

                getRequest.onsuccess = () => {
                    const pagina = getRequest.result;
                    if (pagina) {
                        pagina.numero_ordine = item.numero_ordine;
                        pagina.data_modifica = new Date().toISOString();

                        const putRequest = store.put(pagina);
                        putRequest.onsuccess = () => {
                            completed++;
                            if (completed === ordini.length) {
                                resolve();
                            }
                        };
                        putRequest.onerror = () => reject(putRequest.error);
                    } else {
                        completed++;
                        if (completed === ordini.length) {
                            resolve();
                        }
                    }
                };

                getRequest.onerror = () => reject(getRequest.error);
            }

            if (ordini.length === 0) {
                resolve();
            }
        });
    }

    // ========== ITEMS ==========

    /**
     * Crea item locale
     */
    async createItem(itemData) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('items', 'readwrite');
            const store = tx.objectStore('items');

            const item = {
                ...itemData,
                data_creazione: new Date().toISOString(),
                stato: 'attivo'
            };

            const request = store.add(item);

            request.onsuccess = () => {
                item.id_item = request.result;
                resolve(item);
            };
            request.onerror = () => reject(request.error);
        });
    }

    /**
     * Lista items di una pagina
     */
    async listItems(idPagina) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('items', 'readonly');
            const store = tx.objectStore('items');
            const index = store.index('id_pagina');
            const request = index.getAll(idPagina);

            request.onsuccess = () => {
                const items = (request.result || [])
                    .filter(i => i.stato === 'attivo')
                    .sort((a, b) => a.posizione_griglia - b.posizione_griglia);
                resolve(items);
            };
            request.onerror = () => reject(request.error);
        });
    }

    /**
     * Ottieni item
     */
    async getItem(idItem) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('items', 'readonly');
            const store = tx.objectStore('items');
            const request = store.get(idItem);

            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    /**
     * Aggiorna item
     */
    async updateItem(idItem, updates) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction('items', 'readwrite');
            const store = tx.objectStore('items');
            const getRequest = store.get(idItem);

            getRequest.onsuccess = () => {
                const item = getRequest.result;
                if (!item) {
                    reject(new Error('Item non trovato'));
                    return;
                }

                Object.assign(item, updates, {
                    data_modifica: new Date().toISOString()
                });

                const putRequest = store.put(item);
                putRequest.onsuccess = () => resolve(item);
                putRequest.onerror = () => reject(putRequest.error);
            };

            getRequest.onerror = () => reject(getRequest.error);
        });
    }

    /**
     * Elimina item
     */
    async deleteItem(idItem) {
        if (!this.db) await this.init();

        // Soft delete
        return this.updateItem(idItem, { stato: 'nascosto' });
    }

    // ========== UTILITY ==========

    /**
     * Esporta tutti i dati (backup)
     */
    async exportData() {
        if (!this.db) await this.init();

        const utenti = await this.listUtenti();
        const allPagine = [];
        const allItems = [];

        for (const utente of utenti) {
            const pagine = await this.listPagine(utente.id);
            allPagine.push(...pagine);

            for (const pagina of pagine) {
                const items = await this.listItems(pagina.id_pagina);
                allItems.push(...items);
            }
        }

        return {
            version: this.version,
            exported_at: new Date().toISOString(),
            utenti,
            pagine: allPagine,
            items: allItems
        };
    }

    /**
     * Importa dati (restore)
     */
    async importData(data) {
        if (!this.db) await this.init();

        // Importa utenti
        for (const utente of data.utenti || []) {
            await this.saveUtente(utente.nome);
        }

        // Importa pagine
        for (const pagina of data.pagine || []) {
            await this.createPagina(pagina);
        }

        // Importa items
        for (const item of data.items || []) {
            await this.createItem(item);
        }

        console.log('✅ Dati importati con successo');
    }

    /**
     * Pulisci database
     */
    async clearAll() {
        if (!this.db) await this.init();

        const stores = ['utenti', 'pagine', 'items'];
        
        for (const storeName of stores) {
            await new Promise((resolve, reject) => {
                const tx = this.db.transaction(storeName, 'readwrite');
                const store = tx.objectStore(storeName);
                const request = store.clear();

                request.onsuccess = () => resolve();
                request.onerror = () => reject(request.error);
            });
        }

        console.log('🗑️ Database locale pulito');
    }
}

// Istanza globale
const localDB = new LocalDatabase();

