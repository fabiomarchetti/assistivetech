/**
 * Servizio integrazione YouTube Data API v3
 * Docs: https://developers.google.com/youtube/v3/docs
 *
 * NOTA: Richiede API Key da Google Cloud Console
 * 1. Vai su https://console.cloud.google.com/
 * 2. Crea progetto
 * 3. Abilita YouTube Data API v3
 * 4. Crea credenziali (API Key)
 * 5. Inserisci la key qui sotto
 */

class YouTubeService {
    constructor() {
        // API Key Google YouTube Data API v3
        this.apiKey = 'AIzaSyAKrM5EtCxmo_7_kSSN1rpalvb9QfDIan8';
        this.baseUrl = 'https://www.googleapis.com/youtube/v3';
        this.searchCache = new Map();
        this.debounceTimer = null;
    }

    /**
     * Cerca video su YouTube
     * @param {string} query - Query di ricerca
     * @param {number} maxResults - Numero massimo risultati (default 10, max 50)
     * @returns {Promise<Array>} Array di video
     */
    async searchVideos(query, maxResults = 10) {
        query = query.trim();

        if (!query) {
            return [];
        }

        // Controlla cache
        const cacheKey = `${query}:${maxResults}`;
        if (this.searchCache.has(cacheKey)) {
            return this.searchCache.get(cacheKey);
        }

        // Verifica API key
        if (this.apiKey === 'YOUR_YOUTUBE_API_KEY_HERE') {
            console.warn('YouTube API Key non configurata!');
            return this.getMockResults(query); // Mock per test
        }

        try {
            const url = `${this.baseUrl}/search?` + new URLSearchParams({
                part: 'snippet',
                q: query,
                key: this.apiKey,
                type: 'video',
                maxResults: Math.min(maxResults, 50),
                videoEmbeddable: 'true', // Solo video embedabili
                videoSyndicated: 'true'
            });

            const response = await fetch(url);

            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error?.message || `HTTP error ${response.status}`);
            }

            const data = await response.json();

            if (!data.items || !Array.isArray(data.items)) {
                return [];
            }

            // Formatta risultati
            const videos = data.items.map(item => ({
                id: item.id.videoId,
                title: item.snippet.title,
                description: item.snippet.description,
                channelTitle: item.snippet.channelTitle,
                publishedAt: item.snippet.publishedAt,
                thumbnail: {
                    default: item.snippet.thumbnails.default?.url,
                    medium: item.snippet.thumbnails.medium?.url,
                    high: item.snippet.thumbnails.high?.url
                },
                url: `https://www.youtube.com/watch?v=${item.id.videoId}`,
                embedUrl: `https://www.youtube.com/embed/${item.id.videoId}`
            }));

            // Salva in cache
            if (this.searchCache.size > 50) {
                const firstKey = this.searchCache.keys().next().value;
                this.searchCache.delete(firstKey);
            }
            this.searchCache.set(cacheKey, videos);

            return videos;

        } catch (error) {
            console.error('Errore ricerca YouTube:', error);
            return [];
        }
    }

    /**
     * Ricerca con debounce (per input in tempo reale)
     * @param {string} query - Query di ricerca
     * @param {Function} callback - Funzione chiamata con risultati
     * @param {number} delay - Ritardo in ms (default 500)
     */
    searchWithDebounce(query, callback, delay = 500) {
        clearTimeout(this.debounceTimer);

        this.debounceTimer = setTimeout(async () => {
            const results = await this.searchVideos(query);
            callback(results);
        }, delay);
    }

    /**
     * Estrae ID video da URL YouTube
     * @param {string} url - URL o ID video
     * @returns {string|null} ID video o null se non valido
     */
    extractVideoId(url) {
        if (!url) return null;

        // Se è già solo l'ID (11 caratteri)
        if (/^[a-zA-Z0-9_-]{11}$/.test(url)) {
            return url;
        }

        // Pattern per vari formati URL
        const patterns = [
            /(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/,
            /youtube\.com\/embed\/([a-zA-Z0-9_-]{11})/,
            /youtube\.com\/v\/([a-zA-Z0-9_-]{11})/
        ];

        for (const pattern of patterns) {
            const match = url.match(pattern);
            if (match && match[1]) {
                return match[1];
            }
        }

        return null;
    }

    /**
     * Ottieni URL thumbnail video
     * @param {string} videoId - ID video
     * @param {string} quality - Qualità (default, medium, high, maxres)
     * @returns {string} URL thumbnail
     */
    getThumbnailUrl(videoId, quality = 'high') {
        const qualityMap = {
            'default': 'default',
            'medium': 'mqdefault',
            'high': 'hqdefault',
            'maxres': 'maxresdefault'
        };

        const qualityCode = qualityMap[quality] || 'hqdefault';
        return `https://img.youtube.com/vi/${videoId}/${qualityCode}.jpg`;
    }

    /**
     * Ottieni URL embed video
     * @param {string} videoId - ID video
     * @param {Object} options - Opzioni embed (autoplay, loop, etc.)
     * @returns {string} URL embed
     */
    getEmbedUrl(videoId, options = {}) {
        const params = new URLSearchParams({
            autoplay: options.autoplay ? '1' : '0',
            loop: options.loop ? '1' : '0',
            controls: options.controls !== false ? '1' : '0',
            modestbranding: options.modestbranding ? '1' : '0',
            rel: options.rel !== false ? '1' : '0'
        });

        return `https://www.youtube.com/embed/${videoId}?${params.toString()}`;
    }

    /**
     * Ottieni dettagli video
     * @param {string} videoId - ID video
     * @returns {Promise<Object>} Dettagli video
     */
    async getVideoDetails(videoId) {
        if (this.apiKey === 'YOUR_YOUTUBE_API_KEY_HERE') {
            console.warn('YouTube API Key non configurata!');
            return null;
        }

        try {
            const url = `${this.baseUrl}/videos?` + new URLSearchParams({
                part: 'snippet,contentDetails,statistics',
                id: videoId,
                key: this.apiKey
            });

            const response = await fetch(url);

            if (!response.ok) {
                throw new Error(`HTTP error ${response.status}`);
            }

            const data = await response.json();

            if (!data.items || data.items.length === 0) {
                return null;
            }

            const item = data.items[0];

            return {
                id: item.id,
                title: item.snippet.title,
                description: item.snippet.description,
                channelTitle: item.snippet.channelTitle,
                publishedAt: item.snippet.publishedAt,
                duration: item.contentDetails.duration,
                viewCount: parseInt(item.statistics.viewCount),
                likeCount: parseInt(item.statistics.likeCount),
                thumbnail: {
                    default: item.snippet.thumbnails.default?.url,
                    medium: item.snippet.thumbnails.medium?.url,
                    high: item.snippet.thumbnails.high?.url,
                    maxres: item.snippet.thumbnails.maxres?.url
                }
            };

        } catch (error) {
            console.error('Errore dettagli video:', error);
            return null;
        }
    }

    /**
     * Risultati mock per test (quando API key non configurata)
     */
    getMockResults(query) {
        return [
            {
                id: 'dQw4w9WgXcQ',
                title: `Risultato mock per: ${query}`,
                description: 'API Key YouTube non configurata. Questi sono risultati di esempio.',
                channelTitle: 'Test Channel',
                publishedAt: new Date().toISOString(),
                thumbnail: {
                    default: this.getThumbnailUrl('dQw4w9WgXcQ', 'default'),
                    medium: this.getThumbnailUrl('dQw4w9WgXcQ', 'medium'),
                    high: this.getThumbnailUrl('dQw4w9WgXcQ', 'high')
                },
                url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                embedUrl: 'https://www.youtube.com/embed/dQw4w9WgXcQ'
            }
        ];
    }

    /**
     * Imposta API Key
     * @param {string} apiKey - API Key di YouTube
     */
    setApiKey(apiKey) {
        this.apiKey = apiKey;
        this.searchCache.clear();
    }

    /**
     * Pulisce cache ricerche
     */
    clearCache() {
        this.searchCache.clear();
    }
}

// Istanza globale
const youtubeService = new YouTubeService();
