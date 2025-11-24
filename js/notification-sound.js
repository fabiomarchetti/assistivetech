// Sistema di notifiche sonore per AssistiveTech.it
// Utilizza Web Audio API per generare suoni di notifica

class NotificationSound {
    constructor() {
        this.audioContext = null;
        this.enabled = true;
        this.volume = 0.3; // Volume predefinito (30%)

        // Inizializza AudioContext al primo uso per evitare problemi di policy
        this.initializeAudio();
    }

    initializeAudio() {
        try {
            // Crea AudioContext solo quando necessario
            if (!this.audioContext) {
                this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            }
        } catch (error) {
            console.warn('Web Audio API non supportata:', error);
            this.enabled = false;
        }
    }

    // Suono di notifica base - beep breve
    async playNotification() {
        if (!this.enabled) return;

        try {
            await this.initializeAudio();

            // Riprendi AudioContext se sospeso (policy browser)
            if (this.audioContext.state === 'suspended') {
                await this.audioContext.resume();
            }

            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();

            // Configura oscillator (tono)
            oscillator.type = 'sine';
            oscillator.frequency.setValueAtTime(800, this.audioContext.currentTime); // 800Hz

            // Configura volume con fade in/out
            gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
            gainNode.gain.linearRampToValueAtTime(this.volume, this.audioContext.currentTime + 0.05);
            gainNode.gain.linearRampToValueAtTime(0, this.audioContext.currentTime + 0.3);

            // Connessioni audio
            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);

            // Riproduzione
            oscillator.start(this.audioContext.currentTime);
            oscillator.stop(this.audioContext.currentTime + 0.3);

        } catch (error) {
            console.warn('Errore riproduzione suono:', error);
        }
    }

    // Suono di conferma - doppio beep
    async playConfirmation() {
        if (!this.enabled) return;

        await this.playNotification();

        // Secondo beep dopo 150ms
        setTimeout(async () => {
            await this.playNotification();
        }, 150);
    }

    // Suono di successo - tono ascendente
    async playSuccess() {
        if (!this.enabled) return;

        try {
            await this.initializeAudio();

            if (this.audioContext.state === 'suspended') {
                await this.audioContext.resume();
            }

            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();

            oscillator.type = 'sine';
            // Tono che sale da 600 a 900Hz
            oscillator.frequency.setValueAtTime(600, this.audioContext.currentTime);
            oscillator.frequency.linearRampToValueAtTime(900, this.audioContext.currentTime + 0.2);

            gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
            gainNode.gain.linearRampToValueAtTime(this.volume, this.audioContext.currentTime + 0.05);
            gainNode.gain.linearRampToValueAtTime(0, this.audioContext.currentTime + 0.4);

            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);

            oscillator.start(this.audioContext.currentTime);
            oscillator.stop(this.audioContext.currentTime + 0.4);

        } catch (error) {
            console.warn('Errore riproduzione suono successo:', error);
        }
    }

    // Suono di errore - tono discendente
    async playError() {
        if (!this.enabled) return;

        try {
            await this.initializeAudio();

            if (this.audioContext.state === 'suspended') {
                await this.audioContext.resume();
            }

            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();

            oscillator.type = 'square'; // Tono più aspro per errori
            // Tono che scende da 400 a 200Hz
            oscillator.frequency.setValueAtTime(400, this.audioContext.currentTime);
            oscillator.frequency.linearRampToValueAtTime(200, this.audioContext.currentTime + 0.5);

            gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
            gainNode.gain.linearRampToValueAtTime(this.volume, this.audioContext.currentTime + 0.05);
            gainNode.gain.linearRampToValueAtTime(0, this.audioContext.currentTime + 0.6);

            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);

            oscillator.start(this.audioContext.currentTime);
            oscillator.stop(this.audioContext.currentTime + 0.6);

        } catch (error) {
            console.warn('Errore riproduzione suono errore:', error);
        }
    }

    // Attiva/disattiva suoni
    toggle() {
        this.enabled = !this.enabled;
        return this.enabled;
    }

    // Imposta volume (0-1)
    setVolume(volume) {
        this.volume = Math.max(0, Math.min(1, volume));
    }

    // Test di tutti i suoni
    async testSounds() {
        console.log('🔊 Test notifiche sonore...');
        console.log('AudioContext stato:', this.audioContext?.state);
        console.log('Audio abilitato:', this.enabled);

        if (this.audioContext?.state === 'suspended') {
            await this.audioContext.resume();
            console.log('AudioContext riattivato');
        }

        await this.playNotification();
        setTimeout(async () => {
            await this.playSuccess();
        }, 800);
        setTimeout(async () => {
            await this.playError();
        }, 1600);
        setTimeout(async () => {
            await this.playConfirmation();
        }, 2400);
    }

    // Debug info
    getStatus() {
        return {
            enabled: this.enabled,
            contextState: this.audioContext?.state,
            volume: this.volume,
            contextExists: !!this.audioContext
        };
    }
}

// Istanza globale
window.notificationSound = new NotificationSound();

// Funzioni helper globali
window.playNotificationBeep = () => window.notificationSound.playNotification();
window.playConfirmationBeep = () => window.notificationSound.playConfirmation();
window.playSuccessBeep = () => window.notificationSound.playSuccess();
window.playErrorBeep = () => window.notificationSound.playError();

// Auto-attivazione al primo clic/touch per policy browser
document.addEventListener('DOMContentLoaded', function() {
    // Mostra pulsante test audio
    const testButton = document.createElement('button');
    testButton.innerHTML = '🔊 Attiva Audio';
    testButton.className = 'btn btn-outline-secondary btn-sm position-fixed';
    testButton.style.cssText = 'top: 10px; right: 10px; z-index: 9999;';
    testButton.onclick = function() {
        window.notificationSound.testSounds();
        testButton.style.display = 'none';
    };
    document.body.appendChild(testButton);

    // Auto-rimuovi dopo 10 secondi
    setTimeout(() => {
        if (testButton.parentNode) {
            testButton.style.display = 'none';
        }
    }, 10000);
});

// Forza attivazione su qualsiasi click
document.addEventListener('click', function enableAudio() {
    if (window.notificationSound && window.notificationSound.audioContext) {
        if (window.notificationSound.audioContext.state === 'suspended') {
            window.notificationSound.audioContext.resume().then(() => {
                console.log('🔊 Audio context attivato!');
                // Test rapido
                setTimeout(() => window.notificationSound.playNotification(), 100);
            });
        }
    }
}, { once: true });