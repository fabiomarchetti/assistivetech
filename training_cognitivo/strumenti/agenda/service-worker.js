/**
 * Service Worker per PWA Offline
 */

const CACHE_NAME = 'agenda-strumenti-v2';
const ASSETS_TO_CACHE = [
    './',
    './agenda.html',
    './gestione.html',
    './manifest.json',
    './css/agenda.css',
    './css/educatore.css',
    './js/agenda-app.js',
    './js/educatore-app.js',
    './js/api-client.js',
    './js/arasaac-service.js',
    './js/youtube-service.js',
    './js/swipe-handler.js',
    './js/db-manager.js',
    './js/tts-service.js',
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
    'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css',
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js',
    'https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js'
];

// Installazione Service Worker
self.addEventListener('install', (event) => {
    console.log('[SW] Installazione...');

    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => {
                console.log('[SW] Caching assets');
                return cache.addAll(ASSETS_TO_CACHE);
            })
            .then(() => {
                console.log('[SW] Assets cached');
                return self.skipWaiting();
            })
            .catch((error) => {
                console.error('[SW] Errore caching:', error);
            })
    );
});

// Attivazione Service Worker
self.addEventListener('activate', (event) => {
    console.log('[SW] Attivazione...');

    event.waitUntil(
        caches.keys()
            .then((cacheNames) => {
                return Promise.all(
                    cacheNames.map((cacheName) => {
                        if (cacheName !== CACHE_NAME) {
                            console.log('[SW] Rimozione cache vecchia:', cacheName);
                            return caches.delete(cacheName);
                        }
                    })
                );
            })
            .then(() => {
                console.log('[SW] Service Worker attivo');
                return self.clients.claim();
            })
    );
});

// Fetch - Strategia Cache First per risorse statiche, Network First per API
self.addEventListener('fetch', (event) => {
    const { request } = event;
    
    // 🛡️ IGNORA richieste non-HTTP (chrome-extension, data:, blob:, ecc.)
    if (!request.url.startsWith('http')) {
        return; // Lascia gestire al browser
    }
    
    const url = new URL(request.url);

    // API requests - Network First
    if (url.pathname.includes('/api/') || url.pathname.includes('arasaac.org') || url.pathname.includes('youtube.com')) {
        event.respondWith(
            fetch(request)
                .then((response) => {
                    // Clona la risposta per cache
                    const responseClone = response.clone();

                    // Solo risposte OK vanno in cache
                    if (response.status === 200) {
                        caches.open(CACHE_NAME).then((cache) => {
                            cache.put(request, responseClone);
                        });
                    }

                    return response;
                })
                .catch(() => {
                    // Fallback a cache se network fail
                    return caches.match(request)
                        .then((cachedResponse) => {
                            if (cachedResponse) {
                                return cachedResponse;
                            }

                            // Se nemmeno in cache, ritorna risposta offline
                            return new Response(
                                JSON.stringify({
                                    success: false,
                                    message: 'Nessuna connessione disponibile',
                                    offline: true
                                }),
                                {
                                    headers: { 'Content-Type': 'application/json' }
                                }
                            );
                        });
                })
        );
        return;
    }

    // Static assets - Cache First
    event.respondWith(
        caches.match(request)
            .then((cachedResponse) => {
                if (cachedResponse) {
                    return cachedResponse;
                }

                return fetch(request)
                    .then((response) => {
                        // Clona per cache
                        const responseClone = response.clone();

                        if (response.status === 200) {
                            caches.open(CACHE_NAME).then((cache) => {
                                cache.put(request, responseClone);
                            });
                        }

                        return response;
                    });
            })
            .catch((error) => {
                console.error('[SW] Fetch error:', error);

                // Fallback per navigazione HTML
                if (request.mode === 'navigate') {
                    return caches.match('./agenda.html');
                }

                return new Response('Offline', { status: 503 });
            })
    );
});

// Background Sync (opzionale - per sincronizzazione dati)
self.addEventListener('sync', (event) => {
    console.log('[SW] Background Sync:', event.tag);

    if (event.tag === 'sync-data') {
        event.waitUntil(
            // Qui implementeresti la logica di sincronizzazione
            syncData()
        );
    }
});

/**
 * Sincronizza dati con server
 */
async function syncData() {
    try {
        // Logica sincronizzazione
        console.log('[SW] Sincronizzazione dati...');

        // Esempio: invia pending changes al server
        // const pendingChanges = await getLocalPendingChanges();
        // await sendToServer(pendingChanges);

        console.log('[SW] Sincronizzazione completata');

    } catch (error) {
        console.error('[SW] Errore sincronizzazione:', error);
        throw error; // Retry sync
    }
}

// Push Notifications (opzionale - per notifiche)
self.addEventListener('push', (event) => {
    const options = {
        body: event.data ? event.data.text() : 'Nuova notifica',
        icon: './assets/icons/icon-192.png',
        badge: './assets/icons/icon-192.png',
        vibrate: [200, 100, 200],
        tag: 'agenda-notification'
    };

    event.waitUntil(
        self.registration.showNotification('Agenda Strumenti', options)
    );
});

// Notification Click
self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    event.waitUntil(
        clients.openWindow('./agenda.html')
    );
});
