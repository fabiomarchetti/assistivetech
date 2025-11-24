/**
 * Servizio Text-to-Speech (TTS)
 * Utilizza Web Speech API nativa del browser
 */

const TTSService = {
    // Istanza SpeechSynthesis
    synthesis: window.speechSynthesis,

    // Stato TTS
    isPlaying: false,
    currentUtterance: null,

    /**
     * Pronuncia una frase
     * @param {string} testo - Testo da pronunciare
     * @param {object} options - Opzioni (lingua, velocità, volume, pitch)
     */
    speak: function(testo, options = {}) {
        // Se è già in riproduzione, ferma prima
        if (this.isPlaying) {
            this.stop();
        }

        if (!testo || testo.trim() === '') {
            console.warn('TTS: Testo vuoto');
            return;
        }

        // Crea utterance (frase da parlare)
        this.currentUtterance = new SpeechSynthesisUtterance(testo);

        // Applica opzioni
        this.currentUtterance.lang = options.language || 'it-IT';  // Italiano di default
        this.currentUtterance.rate = options.rate || 0.9;          // Velocità (0.1 - 10, default 1)
        this.currentUtterance.pitch = options.pitch || 1;          // Intonazione (0 - 2, default 1)
        this.currentUtterance.volume = options.volume || 1;        // Volume (0 - 1, default 1)

        // Event listeners
        this.currentUtterance.onstart = () => {
            this.isPlaying = true;
            console.log('TTS: Inizio pronuncia');
            if (options.onStart) options.onStart();
        };

        this.currentUtterance.onend = () => {
            this.isPlaying = false;
            console.log('TTS: Fine pronuncia');
            if (options.onEnd) options.onEnd();
        };

        this.currentUtterance.onerror = (event) => {
            this.isPlaying = false;
            console.error('TTS: Errore pronuncia', event.error);
            if (options.onError) options.onError(event.error);
        };

        // Avvia pronuncia
        this.synthesis.speak(this.currentUtterance);
        console.log('TTS: Pronuncia avviata:', testo);
    },

    /**
     * Ferma la pronuncia in corso
     */
    stop: function() {
        if (this.isPlaying) {
            this.synthesis.cancel();
            this.isPlaying = false;
            console.log('TTS: Pronuncia interrotta');
        }
    },

    /**
     * Pausa la pronuncia (non tutti i browser supportano)
     */
    pause: function() {
        if (this.synthesis.pause && this.isPlaying) {
            this.synthesis.pause();
            console.log('TTS: Pronuncia in pausa');
        }
    },

    /**
     * Riprende la pronuncia in pausa (non tutti i browser supportano)
     */
    resume: function() {
        if (this.synthesis.resume && !this.isPlaying) {
            this.synthesis.resume();
            console.log('TTS: Pronuncia ripresa');
        }
    },

    /**
     * Verifica se il browser supporta TTS
     */
    isSupported: function() {
        return 'speechSynthesis' in window;
    }
};

// Export per uso in Node.js (se necessario)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = TTSService;
}
