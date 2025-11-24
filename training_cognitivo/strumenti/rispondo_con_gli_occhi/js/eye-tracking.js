/**
 * Modulo Eye Tracking con MediaPipe Face Mesh
 * Combina Iris Tracking e Head Pose Estimation
 */

class EyeTrackingService {
    constructor() {
        // Configurazione
        this.videoElement = null;
        this.canvasElement = null;
        this.canvasCtx = null;
        this.faceMesh = null;
        this.camera = null;
        
        // Stato rilevamento
        this.isInitialized = false;
        this.isFaceDetected = false;
        this.currentGaze = { x: 0, y: 0 };
        this.headRotation = { yaw: 0, pitch: 0, roll: 0 };
        this.gazeDirection = 'center'; // 'left', 'center', 'right'
        
        // Callbacks
        this.onGazeUpdate = null;
        this.onFaceDetection = null;
        
        // Calibrazione
        this.centroCalibrato = parseFloat(localStorage.getItem('eyeTracking_calibratoX')) || 0.5;
        
        // Performance
        this.lastFrameTime = Date.now();
        this.fps = 0;
        
        // Calibrazione
        this.calibration = {
            leftThreshold: -0.15,
            rightThreshold: 0.15,
            centerZone: 0.1
        };
        
        // Smoothing (media mobile per ridurre jitter)
        this.gazeHistory = [];
        this.historySize = 5;
    }
    
    /**
     * Inizializza MediaPipe Face Mesh e webcam
     */
    async init(videoElement, canvasElement) {
        try {
            this.videoElement = videoElement;
            this.canvasElement = canvasElement;
            this.canvasCtx = canvasElement.getContext('2d');
            
            // Inizializza MediaPipe Face Mesh
            this.faceMesh = new FaceMesh({
                locateFile: (file) => {
                    return `https://cdn.jsdelivr.net/npm/@mediapipe/face_mesh/${file}`;
                }
            });
            
            // Configurazione Face Mesh
            this.faceMesh.setOptions({
                maxNumFaces: 1,
                refineLandmarks: true, // Abilita iris tracking
                minDetectionConfidence: 0.5,
                minTrackingConfidence: 0.5
            });
            
            // Callback per risultati
            this.faceMesh.onResults((results) => this.onResults(results));
            
            // Inizializza camera
            this.camera = new Camera(this.videoElement, {
                onFrame: async () => {
                    await this.faceMesh.send({ image: this.videoElement });
                },
                width: 640,
                height: 480
            });
            
            await this.camera.start();
            
            this.isInitialized = true;
            console.log('✅ Eye Tracking inizializzato con successo');
            
            return true;
            
        } catch (error) {
            console.error('❌ Errore inizializzazione Eye Tracking:', error);
            return false;
        }
    }
    
    /**
     * Processa i risultati di Face Mesh
     */
    onResults(results) {
        // Aggiorna FPS
        this.updateFPS();
        
        // Pulisci canvas
        this.canvasCtx.save();
        this.canvasCtx.clearRect(0, 0, this.canvasElement.width, this.canvasElement.height);
        
        // Imposta dimensioni canvas uguali al video
        this.canvasElement.width = this.videoElement.videoWidth;
        this.canvasElement.height = this.videoElement.videoHeight;
        
        // Controlla se il volto è rilevato
        if (results.multiFaceLandmarks && results.multiFaceLandmarks.length > 0) {
            this.isFaceDetected = true;
            const landmarks = results.multiFaceLandmarks[0];
            
            // Disegna landmarks (opzionale, per debug)
            this.drawLandmarks(landmarks);
            
            // 🎯 NUOVO: Calcola direzione basata sulla posizione del naso
            const noseTip = landmarks[1];
            const noseX = noseTip.x; // Coordinata normalizzata (0-1)
            
            // Usa centro calibrato invece di 0.5 fisso
            const centro = this.centroCalibrato;
            
            // Calcola distanze dal centro calibrato
            const distanzaSinistra = noseX - centro;    // Negativo se a sinistra del centro
            const distanzaDestra = centro - noseX;      // Negativo se a destra del centro
            
            // Determina direzione (INVERTITA per effetto specchio webcam)
            let direction = 'center';
            const minThreshold = 0.08; // 8% della larghezza del frame
            const differenza = Math.abs(distanzaSinistra + distanzaDestra); // Distanza totale dal centro
            
            if (Math.abs(noseX - centro) > minThreshold) {
                if (noseX < centro) {
                    // Naso a sinistra del centro → guarda a DESTRA (effetto specchio!)
                    direction = 'right';
                } else {
                    // Naso a destra del centro → guarda a SINISTRA (effetto specchio!)
                    direction = 'left';
                }
            }
            
            // Calcola iris tracking (per compatibilità e debug)
            const gazeData = this.calculateIrisTracking(landmarks);
            
            // Calcola head pose estimation (per compatibilità e debug)
            const headPose = this.calculateHeadPose(landmarks);
            
            // Sovrascrivi headPose.yaw con il valore del naso per coerenza
            headPose.yaw = (noseX - 0.5) * 100; // Converti in gradi per visualizzazione
            
            // Aggiorna stato
            this.currentGaze = gazeData;
            this.headRotation = headPose;
            this.gazeDirection = direction;
            
            // Prepara landmark per il monitor
            const leftEye = landmarks[33];
            const rightEye = landmarks[263];
            
            // Callback con debug info e landmarks
            if (this.onGazeUpdate) {
                this.onGazeUpdate({
                    gaze: this.currentGaze,
                    headPose: this.headRotation,
                    direction: this.gazeDirection,
                    fps: this.fps,
                    debug: {
                        noseX: noseTip.x,
                        distanzaSinistra: Math.abs(distanzaSinistra),
                        distanzaDestra: Math.abs(distanzaDestra),
                        differenza: Math.abs(noseX - centro),
                        centroCalibrato: centro
                    },
                    landmarks: {
                        nose: { x: noseTip.x, y: noseTip.y },
                        leftEye: { x: leftEye.x, y: leftEye.y },
                        rightEye: { x: rightEye.x, y: rightEye.y }
                    }
                });
            }
            
        } else {
            this.isFaceDetected = false;
        }
        
        // Callback rilevamento volto
        if (this.onFaceDetection) {
            this.onFaceDetection(this.isFaceDetected);
        }
        
        this.canvasCtx.restore();
    }
    
    /**
     * Calcola iris tracking (direzione dello sguardo)
     */
    calculateIrisTracking(landmarks) {
        // Indici landmark per iris (MediaPipe Face Mesh)
        // Left iris: 468-472 (center: 468)
        // Right iris: 473-477 (center: 473)
        // Left eye corners: 33 (inner), 133 (outer)
        // Right eye corners: 362 (inner), 263 (outer)
        
        const leftIrisCenter = landmarks[468];
        const rightIrisCenter = landmarks[473];
        
        const leftEyeInner = landmarks[133];
        const leftEyeOuter = landmarks[33];
        const rightEyeInner = landmarks[362];
        const rightEyeOuter = landmarks[263];
        
        // Calcola posizione relativa iris nell'occhio (0 = centro, -1 = sinistra, +1 = destra)
        const leftEyeWidth = Math.abs(leftEyeOuter.x - leftEyeInner.x);
        const rightEyeWidth = Math.abs(rightEyeOuter.x - rightEyeInner.x);
        
        const leftEyeCenter = (leftEyeOuter.x + leftEyeInner.x) / 2;
        const rightEyeCenter = (rightEyeOuter.x + rightEyeInner.x) / 2;
        
        const leftIrisRelativeX = (leftIrisCenter.x - leftEyeCenter) / (leftEyeWidth / 2);
        const rightIrisRelativeX = (rightIrisCenter.x - rightEyeCenter) / (rightEyeWidth / 2);
        
        // Media dei due occhi
        const gazeX = (leftIrisRelativeX + rightIrisRelativeX) / 2;
        
        // Calcola anche asse Y (su/giù)
        const leftEyeTop = landmarks[159];
        const leftEyeBottom = landmarks[145];
        const leftEyeHeight = Math.abs(leftEyeTop.y - leftEyeBottom.y);
        const leftEyeCenterY = (leftEyeTop.y + leftEyeBottom.y) / 2;
        const leftIrisRelativeY = (leftIrisCenter.y - leftEyeCenterY) / (leftEyeHeight / 2);
        
        const rightEyeTop = landmarks[386];
        const rightEyeBottom = landmarks[374];
        const rightEyeHeight = Math.abs(rightEyeTop.y - rightEyeBottom.y);
        const rightEyeCenterY = (rightEyeTop.y + rightEyeBottom.y) / 2;
        const rightIrisRelativeY = (rightIrisCenter.y - rightEyeCenterY) / (rightEyeHeight / 2);
        
        const gazeY = (leftIrisRelativeY + rightIrisRelativeY) / 2;
        
        // Applica smoothing
        return this.applySmoothingToGaze({ x: gazeX, y: gazeY });
    }
    
    /**
     * Calcola head pose (rotazione della testa)
     */
    calculateHeadPose(landmarks) {
        // Usa landmark chiave per calcolare rotazione
        // Nose tip: 1
        // Left eye: 33
        // Right eye: 263
        // Chin: 152
        
        const noseTip = landmarks[1];
        const leftEye = landmarks[33];
        const rightEye = landmarks[263];
        const chin = landmarks[152];
        const forehead = landmarks[10];
        
        // Calcola YAW (rotazione sinistra/destra)
        const eyeMidpoint = {
            x: (leftEye.x + rightEye.x) / 2,
            y: (leftEye.y + rightEye.y) / 2
        };
        
        const yaw = (noseTip.x - eyeMidpoint.x) * 100; // Normalizzato
        
        // Calcola PITCH (rotazione su/giù)
        const verticalDistance = forehead.y - chin.y;
        const noseVerticalPos = (noseTip.y - forehead.y) / verticalDistance;
        const pitch = (noseVerticalPos - 0.5) * 100;
        
        // Calcola ROLL (inclinazione laterale)
        const eyeAngle = Math.atan2(rightEye.y - leftEye.y, rightEye.x - leftEye.x);
        const roll = eyeAngle * (180 / Math.PI);
        
        return { yaw, pitch, roll };
    }
    
    /**
     * 🎯 NUOVO ALGORITMO: Determina direzione basandosi sulla punta del naso
     * Calcola distanza naso-bordo_destro vs naso-bordo_sinistro
     */
    determineGazeDirection(gazeData, headPose) {
        // Ottieni la coordinata X della punta del naso (normalizzata 0-1)
        // Nota: this.currentGaze non contiene il naso, lo prendiamo da headPose calculation
        // O meglio, lo calcoliamo direttamente qui
        
        // Per ora usiamo headPose.yaw come proxy della posizione del naso
        // Ma per essere più precisi, dovremmo passare i landmarks direttamente
        
        // FALLBACK: Usa l'algoritmo combinato esistente ma con threshold più ampi
        const combinedX = (gazeData.x * 0.7) + (headPose.yaw / 100 * 0.3);
        
        // Determina direzione con threshold più sensibili
        if (combinedX < -0.08) {  // Era -0.15, ora più sensibile
            return 'left';
        } else if (combinedX > 0.08) {  // Era 0.15, ora più sensibile
            return 'right';
        } else {
            return 'center';
        }
    }
    
    /**
     * Applica smoothing alla posizione dello sguardo
     */
    applySmoothingToGaze(gaze) {
        this.gazeHistory.push(gaze);
        
        if (this.gazeHistory.length > this.historySize) {
            this.gazeHistory.shift();
        }
        
        // Media mobile
        const avgX = this.gazeHistory.reduce((sum, g) => sum + g.x, 0) / this.gazeHistory.length;
        const avgY = this.gazeHistory.reduce((sum, g) => sum + g.y, 0) / this.gazeHistory.length;
        
        return { x: avgX, y: avgY };
    }
    
    /**
     * Disegna landmarks sul canvas (per debug)
     */
    drawLandmarks(landmarks) {
        // Disegna solo punti chiave
        const keyPoints = [
            1,   // Nose tip
            33, 133,  // Left eye
            362, 263, // Right eye
            468, // Left iris
            473, // Right iris
            152, // Chin
            10   // Forehead
        ];
        
        this.canvasCtx.fillStyle = 'rgba(0, 255, 0, 0.7)';
        keyPoints.forEach(index => {
            const point = landmarks[index];
            const x = point.x * this.canvasElement.width;
            const y = point.y * this.canvasElement.height;
            this.canvasCtx.beginPath();
            this.canvasCtx.arc(x, y, 3, 0, 2 * Math.PI);
            this.canvasCtx.fill();
        });
        
        // Disegna linea direzione sguardo
        const noseTip = landmarks[1];
        const noseX = noseTip.x * this.canvasElement.width;
        const noseY = noseTip.y * this.canvasElement.height;
        
        const gazeLineLength = 50;
        const gazeEndX = noseX + (this.currentGaze.x * gazeLineLength);
        const gazeEndY = noseY + (this.currentGaze.y * gazeLineLength);
        
        this.canvasCtx.strokeStyle = 'rgba(255, 0, 0, 0.8)';
        this.canvasCtx.lineWidth = 3;
        this.canvasCtx.beginPath();
        this.canvasCtx.moveTo(noseX, noseY);
        this.canvasCtx.lineTo(gazeEndX, gazeEndY);
        this.canvasCtx.stroke();
    }
    
    /**
     * Aggiorna FPS
     */
    updateFPS() {
        const now = Date.now();
        const delta = now - this.lastFrameTime;
        this.fps = Math.round(1000 / delta);
        this.lastFrameTime = now;
    }
    
    /**
     * Calibra centro personalizzato
     */
    calibrate(centroCalibrato) {
        this.centroCalibrato = centroCalibrato;
        localStorage.setItem('eyeTracking_calibratoX', centroCalibrato);
        console.log(`✅ Centro calibrato: ${centroCalibrato.toFixed(3)}`);
    }
    
    /**
     * Reset calibrazione
     */
    resetCalibration() {
        this.centroCalibrato = 0.5;
        localStorage.removeItem('eyeTracking_calibratoX');
        console.log('🔄 Calibrazione resettata');
    }
    
    /**
     * Stop tracking
     */
    stop() {
        if (this.camera) {
            this.camera.stop();
        }
        if (this.faceMesh) {
            this.faceMesh.close();
        }
        this.isInitialized = false;
    }
    
    /**
     * Ottieni stato corrente
     */
    getState() {
        return {
            isInitialized: this.isInitialized,
            isFaceDetected: this.isFaceDetected,
            gaze: this.currentGaze,
            headPose: this.headRotation,
            direction: this.gazeDirection,
            fps: this.fps
        };
    }
}

// Esporta istanza globale
const eyeTrackingService = new EyeTrackingService();

