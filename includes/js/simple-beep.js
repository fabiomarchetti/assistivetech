// Sistema di beep semplificato per massima compatibilità browser
// Fallback con multiple strategie per aggirare le policy audio

class SimpleBeep {
    constructor() {
        this.audioContext = null;
        this.unlocked = false;
        this.volume = 0.3;

        // Strategia 1: Web Audio API
        this.initWebAudio();

        // Strategia 2: HTML5 Audio con data URL
        this.initDataAudio();

        // Strategia 3: Speech Synthesis (ultimo fallback)
        this.initSpeechSynth();

        // Auto-attivazione
        this.setupUnlock();
    }

    initWebAudio() {
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
        } catch (e) {
            console.warn('Web Audio API non supportata');
        }
    }

    initDataAudio() {
        // Crea file audio sintetico come data URL
        const sampleRate = 22050;
        const frequency = 800;
        const duration = 0.3;
        const samples = Math.floor(sampleRate * duration);

        const buffer = new ArrayBuffer(44 + samples * 2);
        const view = new DataView(buffer);

        // Header WAV
        this.writeString(view, 0, 'RIFF');
        view.setUint32(4, 36 + samples * 2, true);
        this.writeString(view, 8, 'WAVE');
        this.writeString(view, 12, 'fmt ');
        view.setUint32(16, 16, true);
        view.setUint16(20, 1, true);
        view.setUint16(22, 1, true);
        view.setUint32(24, sampleRate, true);
        view.setUint32(28, sampleRate * 2, true);
        view.setUint16(32, 2, true);
        view.setUint16(34, 16, true);
        this.writeString(view, 36, 'data');
        view.setUint32(40, samples * 2, true);

        // Genera forma d'onda sinusoidale
        for (let i = 0; i < samples; i++) {
            const sample = Math.sin(2 * Math.PI * frequency * i / sampleRate);
            const amplitude = 0.3 * Math.max(0, 1 - i / samples); // Fade out
            view.setInt16(44 + i * 2, amplitude * sample * 32767, true);
        }

        // Converti in blob e URL
        const blob = new Blob([buffer], { type: 'audio/wav' });
        this.audioUrl = URL.createObjectURL(blob);
        this.audioElement = new Audio(this.audioUrl);
        this.audioElement.volume = this.volume;
    }

    writeString(view, offset, string) {
        for (let i = 0; i < string.length; i++) {
            view.setUint8(offset + i, string.charCodeAt(i));
        }
    }

    initSpeechSynth() {
        this.speechSynth = window.speechSynthesis;
    }

    setupUnlock() {
        // Eventi per sbloccare audio
        const events = ['mousedown', 'mousemove', 'keydown', 'touchstart', 'touchend'];
        const unlock = () => {
            events.forEach(event => {
                document.removeEventListener(event, unlock);
            });
            this.unlock();
        };

        events.forEach(event => {
            document.addEventListener(event, unlock, { once: true });
        });
    }

    async unlock() {
        if (this.unlocked) return;

        try {
            // Unlock Web Audio
            if (this.audioContext && this.audioContext.state === 'suspended') {
                await this.audioContext.resume();
            }

            // Test audio element
            if (this.audioElement) {
                this.audioElement.currentTime = 0;
                const playPromise = this.audioElement.play();
                if (playPromise) {
                    await playPromise.then(() => {
                        this.audioElement.pause();
                        this.audioElement.currentTime = 0;
                    }).catch(() => {});
                }
            }

            this.unlocked = true;
            console.log('🔊 Audio sbloccato!');

            // Notifica visiva
            this.showUnlockNotification();

        } catch (e) {
            console.warn('Errore sblocco audio:', e);
        }
    }

    showUnlockNotification() {
        const notification = document.createElement('div');
        notification.innerHTML = '🔊 Audio attivato!';
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #28a745;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            z-index: 9999;
            opacity: 0;
            transition: opacity 0.3s;
        `;
        document.body.appendChild(notification);

        // Animazione
        setTimeout(() => notification.style.opacity = '1', 100);
        setTimeout(() => {
            notification.style.opacity = '0';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 2000);
    }

    // Suono principale
    async beep(freq = 800, duration = 200) {
        if (!this.unlocked) {
            console.warn('Audio non ancora sbloccato');
            return;
        }

        // Strategia 1: Web Audio API
        if (this.audioContext && this.audioContext.state === 'running') {
            try {
                const oscillator = this.audioContext.createOscillator();
                const gainNode = this.audioContext.createGain();

                oscillator.connect(gainNode);
                gainNode.connect(this.audioContext.destination);

                oscillator.frequency.value = freq;
                oscillator.type = 'sine';

                gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
                gainNode.gain.linearRampToValueAtTime(this.volume, this.audioContext.currentTime + 0.01);
                gainNode.gain.linearRampToValueAtTime(0, this.audioContext.currentTime + duration / 1000);

                oscillator.start(this.audioContext.currentTime);
                oscillator.stop(this.audioContext.currentTime + duration / 1000);

                return;
            } catch (e) {
                console.warn('Web Audio fallito, provo HTML5 Audio');
            }
        }

        // Strategia 2: HTML5 Audio
        if (this.audioElement) {
            try {
                this.audioElement.currentTime = 0;
                this.audioElement.volume = this.volume;
                const playPromise = this.audioElement.play();
                if (playPromise) {
                    await playPromise;
                    setTimeout(() => {
                        this.audioElement.pause();
                        this.audioElement.currentTime = 0;
                    }, duration);
                }
                return;
            } catch (e) {
                console.warn('HTML5 Audio fallito, provo Speech Synthesis');
            }
        }

        // Strategia 3: Speech Synthesis (ultimo fallback)
        if (this.speechSynth) {
            const utterance = new SpeechSynthesisUtterance('beep');
            utterance.volume = 0.1;
            utterance.rate = 10;
            utterance.pitch = 2;
            this.speechSynth.speak(utterance);
        }
    }

    // Varianti
    async notification() {
        await this.beep(800, 300);
    }

    async success() {
        await this.beep(600, 150);
        setTimeout(() => this.beep(900, 150), 100);
    }

    async error() {
        await this.beep(400, 200);
        setTimeout(() => this.beep(200, 300), 150);
    }

    async confirmation() {
        await this.beep(800, 150);
        setTimeout(() => this.beep(800, 150), 200);
    }

    // Test completo
    async test() {
        console.log('🧪 Test audio completo...');
        console.log('Stato:', {
            unlocked: this.unlocked,
            webAudio: !!this.audioContext,
            htmlAudio: !!this.audioElement,
            speechSynth: !!this.speechSynth
        });

        await this.notification();
        setTimeout(() => this.success(), 600);
        setTimeout(() => this.error(), 1200);
        setTimeout(() => this.confirmation(), 1800);
    }
}

// Istanza globale
window.simpleBeep = new SimpleBeep();

// Funzioni di convenienza
window.playNotificationBeep = () => window.simpleBeep.notification();
window.playConfirmationBeep = () => window.simpleBeep.confirmation();
window.playSuccessBeep = () => window.simpleBeep.success();
window.playErrorBeep = () => window.simpleBeep.error();

// Pulsante di test sempre visibile
document.addEventListener('DOMContentLoaded', function() {
    const testBtn = document.createElement('button');
    testBtn.innerHTML = '🔊 Test';
    testBtn.className = 'btn btn-sm btn-outline-primary';
    testBtn.style.cssText = 'position: fixed; top: 10px; right: 10px; z-index: 10000; font-size: 12px;';
    testBtn.onclick = () => window.simpleBeep.test();
    document.body.appendChild(testBtn);
});