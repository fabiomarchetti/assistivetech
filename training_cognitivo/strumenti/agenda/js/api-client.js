/**
 * Client API REST per comunicazione con backend
 */

class ApiClient {
    constructor(baseUrl = null) {
        // Auto-rileva baseUrl in base all'HOSTNAME
        if (!baseUrl) {
            const isLocal = (
                window.location.hostname === 'localhost' ||
                window.location.hostname === '127.0.0.1' ||
                window.location.hostname.startsWith('192.168.') ||
                window.location.hostname.startsWith('10.0.')
            );
            
            if (isLocal) {
                // MAMP locale
                this.baseUrl = '/Assistivetech/training_cognitivo/strumenti/agenda/api';
                console.log('📡 Ambiente: LOCALE (MAMP)');
            } else {
                // Aruba o produzione
                this.baseUrl = '/training_cognitivo/strumenti/agenda/api';
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
            const response = await fetch(url, {
                ...options,
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                }
            });

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.message || 'Errore sconosciuto');
            }

            return data.data;

        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    // ========== AGENDE ==========

    /**
     * Crea nuova agenda
     */
    async createAgenda(nome_agenda, id_paziente, id_educatore, id_agenda_parent = null) {
        return this.request('/agende.php?action=create', {
            method: 'POST',
            body: JSON.stringify({
                nome_agenda,
                id_paziente,
                id_educatore,
                id_agenda_parent
            })
        });
    }

    /**
     * Lista agende di un paziente
     */
    async listAgende(id_paziente, solo_principali = false, id_agenda_parent = null) {
        let url = `/agende.php?action=list&id_paziente=${id_paziente}`;
        if (solo_principali) {
            url += '&solo_principali=true';
        } else if (id_agenda_parent !== null) {
            url += `&id_agenda_parent=${id_agenda_parent}`;
        }
        return this.request(url);
    }

    /**
     * Dettagli agenda
     */
    async getAgenda(id_agenda) {
        return this.request(`/agende.php?action=get&id_agenda=${id_agenda}`);
    }

    /**
     * Aggiorna agenda
     */
    async updateAgenda(id_agenda, nome_agenda) {
        return this.request(`/agende.php?action=update&id_agenda=${id_agenda}`, {
            method: 'PUT',
            body: JSON.stringify({ nome_agenda })
        });
    }

    /**
     * Elimina agenda
     */
    async deleteAgenda(id_agenda) {
        return this.request(`/agende.php?action=delete&id_agenda=${id_agenda}`, {
            method: 'DELETE'
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
     * Lista item di un'agenda
     */
    async listItems(id_agenda) {
        return this.request(`/items.php?action=list&id_agenda=${id_agenda}`);
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
        return this.request(`/items.php?action=update&id_item=${id_item}`, {
            method: 'PUT',
            body: JSON.stringify(updates)
        });
    }

    /**
     * Riordina items
     */
    async reorderItems(items) {
        return this.request('/items.php?action=reorder', {
            method: 'PUT',
            body: JSON.stringify({ items })
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

    // ========== UPLOAD ==========

    /**
     * Upload immagine (file o base64)
     */
    async uploadImage(imageData, isBase64 = false) {
        if (isBase64) {
            // Upload base64
            const formData = new FormData();
            formData.append('image_base64', imageData);

            const response = await fetch(`${this.baseUrl}/upload_image.php`, {
                method: 'POST',
                body: formData
            });

            const data = await response.json();
            if (!data.success) {
                throw new Error(data.message);
            }
            return data.data;

        } else {
            // Upload file
            const formData = new FormData();
            formData.append('image', imageData);

            const response = await fetch(`${this.baseUrl}/upload_image.php`, {
                method: 'POST',
                body: formData
            });

            const data = await response.json();
            if (!data.success) {
                throw new Error(data.message);
            }
            return data.data;
        }
    }
}

// Istanza globale
const apiClient = new ApiClient();
