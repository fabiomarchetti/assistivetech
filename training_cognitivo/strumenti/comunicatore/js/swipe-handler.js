/**
 * Gestore swipe e longclick per navigazione touch
 * Supporta desktop (mouse) e mobile (touch)
 */

class SwipeHandler {
    constructor(element, callbacks = {}) {
        this.element = element;
        this.callbacks = {
            onSwipeLeft: callbacks.onSwipeLeft || (() => {}),
            onSwipeRight: callbacks.onSwipeRight || (() => {}),
            onLongClick: callbacks.onLongClick || (() => {}),
            onTap: callbacks.onTap || (() => {})
        };

        // Stato touch
        this.touchStartX = 0;
        this.touchStartY = 0;
        this.touchStartTime = 0;
        this.longClickTimer = null;
        this.longClickThreshold = 800; // ms per longclick
        this.swipeThreshold = 50; // pixel minimo per swipe
        this.isLongClick = false;

        this.init();
    }

    /**
     * Inizializza event listeners
     */
    init() {
        // Touch events (mobile)
        this.element.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: false });
        this.element.addEventListener('touchmove', this.handleTouchMove.bind(this), { passive: false });
        this.element.addEventListener('touchend', this.handleTouchEnd.bind(this), { passive: false });

        // Mouse events (desktop)
        this.element.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.element.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.element.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.element.addEventListener('mouseleave', this.handleMouseLeave.bind(this));

        // Keyboard events (frecce)
        document.addEventListener('keydown', this.handleKeyDown.bind(this));
    }

    // ========== TOUCH EVENTS ==========

    handleTouchStart(e) {
        const touch = e.touches[0];
        this.touchStartX = touch.clientX;
        this.touchStartY = touch.clientY;
        this.touchStartTime = Date.now();
        this.isLongClick = false;

        // Avvia timer longclick
        this.longClickTimer = setTimeout(() => {
            this.isLongClick = true;
            this.vibrate(50); // Feedback tattile
            this.callbacks.onLongClick(e);
            this.clearLongClickTimer();
        }, this.longClickThreshold);

        // Aggiungi classe visual feedback
        this.element.classList.add('touching');
    }

    handleTouchMove(e) {
        // Se si muove troppo, annulla longclick
        const touch = e.touches[0];
        const deltaX = Math.abs(touch.clientX - this.touchStartX);
        const deltaY = Math.abs(touch.clientY - this.touchStartY);

        if (deltaX > 10 || deltaY > 10) {
            this.clearLongClickTimer();
        }
    }

    handleTouchEnd(e) {
        this.element.classList.remove('touching');

        // Se era longclick, non fare altro
        if (this.isLongClick) {
            this.clearLongClickTimer();
            return;
        }

        // Altrimenti, gestisci swipe o tap
        this.clearLongClickTimer();

        const touch = e.changedTouches[0];
        const deltaX = touch.clientX - this.touchStartX;
        const deltaY = touch.clientY - this.touchStartY;
        const deltaTime = Date.now() - this.touchStartTime;

        // Swipe se movimento > threshold e veloce
        if (Math.abs(deltaX) > this.swipeThreshold && deltaTime < 300) {
            if (deltaX > 0) {
                this.callbacks.onSwipeRight(e);
            } else {
                this.callbacks.onSwipeLeft(e);
            }
        }
        // Altrimenti è un tap
        else if (Math.abs(deltaX) < 10 && Math.abs(deltaY) < 10 && deltaTime < 300) {
            this.callbacks.onTap(e);
        }
    }

    // ========== MOUSE EVENTS (desktop) ==========

    handleMouseDown(e) {
        this.touchStartX = e.clientX;
        this.touchStartY = e.clientY;
        this.touchStartTime = Date.now();
        this.isLongClick = false;

        // Avvia timer longclick
        this.longClickTimer = setTimeout(() => {
            this.isLongClick = true;
            this.callbacks.onLongClick(e);
            this.clearLongClickTimer();
        }, this.longClickThreshold);

        this.element.classList.add('touching');
    }

    handleMouseMove(e) {
        const deltaX = Math.abs(e.clientX - this.touchStartX);
        const deltaY = Math.abs(e.clientY - this.touchStartY);

        if (deltaX > 10 || deltaY > 10) {
            this.clearLongClickTimer();
        }
    }

    handleMouseUp(e) {
        this.element.classList.remove('touching');

        if (this.isLongClick) {
            this.clearLongClickTimer();
            return;
        }

        this.clearLongClickTimer();

        const deltaX = e.clientX - this.touchStartX;
        const deltaY = e.clientY - this.touchStartY;
        const deltaTime = Date.now() - this.touchStartTime;

        // Swipe se movimento > threshold
        if (Math.abs(deltaX) > this.swipeThreshold && deltaTime < 300) {
            if (deltaX > 0) {
                this.callbacks.onSwipeRight(e);
            } else {
                this.callbacks.onSwipeLeft(e);
            }
        }
        // Click normale
        else if (Math.abs(deltaX) < 10 && Math.abs(deltaY) < 10 && deltaTime < 300) {
            this.callbacks.onTap(e);
        }
    }

    handleMouseLeave(e) {
        this.clearLongClickTimer();
        this.element.classList.remove('touching');
    }

    // ========== KEYBOARD EVENTS ==========

    handleKeyDown(e) {
        switch (e.key) {
            case 'ArrowLeft':
                e.preventDefault();
                this.callbacks.onSwipeRight(e);
                break;
            case 'ArrowRight':
                e.preventDefault();
                this.callbacks.onSwipeLeft(e);
                break;
            case 'Enter':
                e.preventDefault();
                this.callbacks.onLongClick(e);
                break;
        }
    }

    // ========== UTILITY ==========

    clearLongClickTimer() {
        if (this.longClickTimer) {
            clearTimeout(this.longClickTimer);
            this.longClickTimer = null;
        }
    }

    vibrate(duration = 50) {
        if ('vibrate' in navigator) {
            navigator.vibrate(duration);
        }
    }

    /**
     * Aggiorna callbacks
     */
    setCallbacks(callbacks) {
        this.callbacks = {
            ...this.callbacks,
            ...callbacks
        };
    }

    /**
     * Distruggi handler
     */
    destroy() {
        this.clearLongClickTimer();
        // Rimuovi event listeners (non implementato per semplicità)
    }
}

