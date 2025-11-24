/**
 * Client API REST per comunicazione con backend Sequenze colori
 */

class ApiClient {
    constructor(baseUrl = null) {
        // Auto-rileva baseUrl in base all'HOSTNAME (più affidabile del pathname)
        if (!baseUrl) {
            const isLocal = (
                window.location.hostname === 'localhost' ||
                window.location.hostname === '127.0.0.1' ||
                window.location.hostname.startsWith('192.168.') ||
                window.location.hostname.startsWith('10.0.')
            );
            
            if (isLocal) {
                // MAMP locale
                this.baseUrl = '/Assistivetech/training_cognitivo/strumenti/sequenze_colori/api';
                console.log('📡 Ambiente: LOCALE (MAMP)');
            } else {
                // Aruba o produzione
                this.baseUrl = '/training_cognitivo/strumenti/sequenze_colori/api';
                console.log('📡 Ambiente: PRODUZIONE (Aruba)');
            }
        } else {
            this.baseUrl = baseUrl;
        }
        
        console.log('📡 API BaseURL:', this.baseUrl);
    }

    /**
     * Fetch wrapper con gestione errori
     */
    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;

        try {
            console.log(`📡 API Request: ${url}`);
            
            const response = await fetch(url, {
                ...options,
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                }
            });

            console.log(`📡 Response status: ${response.status} ${response.statusText}`);

            // Leggi il testo della risposta
            const text = await response.text();
            
            // Prova a parsare come JSON
            let data;
            try {
                data = JSON.parse(text);
            } catch (jsonError) {
                // Non è JSON - probabilmente HTML di errore
                console.error('❌ Risposta non è JSON:', text.substring(0, 500));
                throw new Error(`Server ha restituito HTML invece di JSON. Probabilmente c'è un errore PHP. Apri: ${url}`);
            }

            if (!data.success) {
                throw new Error(data.message || 'Errore sconosciuto');
            }

            return data.data;

        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    // ========== PAGINE ==========

    /**
     * Crea nuova pagina
     */
    async createPagina(nome_pagina, id_paziente, id_educatore, descrizione = '') {
        return this.request('/pagine.php?action=create', {
            method: 'POST',
            body: JSON.stringify({
                nome_pagina,
                id_paziente,
                id_educatore,
                descrizione
            })
        });
    }

    /**
     * Lista pagine di un paziente
     */
    async listPagine(id_paziente) {
        return this.request(`/pagine.php?action=list&id_paziente=${id_paziente}`);
    }

    /**
     * Dettagli pagina con items
     */
    async getPagina(id_pagina) {
        return this.request(`/pagine.php?action=get&id_pagina=${id_pagina}`);
    }

    /**
     * Aggiorna pagina
     */
    async updatePagina(id_pagina, updates) {
        return this.request(`/pagine.php?action=update`, {
            method: 'PUT',
            body: JSON.stringify({
                id_pagina,
                ...updates
            })
        });
    }

    /**
     * Elimina pagina
     */
    async deletePagina(id_pagina) {
        return this.request(`/pagine.php?action=delete&id_pagina=${id_pagina}`, {
            method: 'DELETE'
        });
    }

    /**
     * Riordina pagine
     */
    async reorderPagine(ordini) {
        return this.request('/pagine.php?action=reorder', {
            method: 'POST',
            body: JSON.stringify({ ordini })
        });
    }

    // ========== ITEMS ==========

    /**
     * Crea nuovo item
     */
    async createItem(itemData) {
        return this.request('/items.php?action=create', {
            method: 'POST',
            body: JSON.stringify(itemData)
        });
    }

    /**
     * Lista items di una pagina
     */
    async listItems(id_pagina) {
        return this.request(`/items.php?action=list&id_pagina=${id_pagina}`);
    }

    /**
     * Dettagli item
     */
    async getItem(id_item) {
        return this.request(`/items.php?action=get&id_item=${id_item}`);
    }

    /**
     * Aggiorna item
     */
    async updateItem(id_item, updates) {
        return this.request(`/items.php?action=update`, {
            method: 'PUT',
            body: JSON.stringify({
                id_item,
                ...updates
            })
        });
    }

    /**
     * Elimina item
     */
    async deleteItem(id_item) {
        return this.request(`/items.php?action=delete&id_item=${id_item}`, {
            method: 'DELETE'
        });
    }

    /**
     * Log utilizzo item
     */
    async logItem(id_item, id_paziente, sessione) {
        return this.request('/items.php?action=log', {
            method: 'POST',
            body: JSON.stringify({
                id_item,
                id_paziente,
                sessione
            })
        });
    }

    // ========== UPLOAD ==========

    /**
     * Upload immagine
     */
    async uploadImage(file) {
        const formData = new FormData();
        formData.append('image', file);

        try {
            const url = `${this.baseUrl}/upload_image.php`;
            const response = await fetch(url, {
                method: 'POST',
                body: formData
            });

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.message || 'Errore upload');
            }

            return data.data;

        } catch (error) {
            console.error('Upload Error:', error);
            throw error;
        }
    }

    // ========== PAZIENTI (dalla tabella registrazioni) ==========

    /**
     * Lista pazienti (richiede config.php)
     */
    async listPazienti() {
        try {
            const pdo = await getDbConnection();
            const stmt = pdo.prepare("SELECT id_registrazione, username FROM registrazioni WHERE ruolo = 'paziente' ORDER BY username");
            const result = await stmt.execute();
            return result.fetchAll();
        } catch (error) {
            console.error('Errore caricamento pazienti:', error);
            return [];
        }
    }
}

