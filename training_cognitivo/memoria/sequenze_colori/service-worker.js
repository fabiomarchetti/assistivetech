/**
 * Service Worker - Sequenze colori PWA
 * Gestisce caching per funzionalità offline
 */

const CACHE_NAME = 'sequenze_colori-v2.4.0';
const CACHE_URLS = [
    './',
    './index.html',
    './sequenze_colori.html',
    './gestione.html',
    './manifest.json',
    './css/sequenze_colori.css',
    './css/educatore.css',
    './js/sequenze_colori-app.js',
    './js/educatore-app.js',
    './js/api-client.js',
    './js/arasaac-service.js',
    './js/db-local.js',
    './js/swipe-handler.js',
    './assets/icons/icon-192.png',
    './assets/icons/icon-512.png',
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
    'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css',
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js'
];

/**
 * Install Event - Precache risorse essenziali
 */
self.addEventListener('install', (event) => {
    console.log('[SW] Installing Service Worker...');

    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log('[SW] Caching app shell');
            return cache.addAll(CACHE_URLS.map(url => new Request(url, { cache: 'reload' })));
        }).catch((error) => {
            console.error('[SW] Cache installation failed:', error);
        })
    );

    // Forza attivazione immediata
    self.skipWaiting();
});

/**
 * Activate Event - Pulisce vecchie cache
 */
self.addEventListener('activate', (event) => {
    console.log('[SW] Activating Service Worker...');

    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames.map((cacheName) => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('[SW] Deleting old cache:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );

    // Prendi controllo immediato
    return self.clients.claim();
});

/**
 * Fetch Event - Strategia Cache-First con Network Fallback
 */
self.addEventListener('fetch', (event) => {
    const { request } = event;
    
    // 🛡️ IGNORA richieste non-HTTP (chrome-extension, data:, blob:, ecc.)
    if (!request.url.startsWith('http')) {
        return; // Lascia gestire al browser
    }
    
    const url = new URL(request.url);

    // Skip non-GET requests
    if (request.method !== 'GET') {
        return;
    }

    // Skip API calls (sempre network)
    if (url.pathname.includes('/api/')) {
        event.respondWith(
            fetch(request).catch(() => {
                return new Response(JSON.stringify({
                    success: false,
                    message: 'Offline - API non disponibile'
                }), {
                    headers: { 'Content-Type': 'application/json' }
                });
            })
        );
        return;
    }

    // Skip ARASAAC API (sempre network con cache fallback)
    if (url.origin === 'https://api.arasaac.org' || url.origin === 'https://static.arasaac.org') {
        event.respondWith(
            caches.open(CACHE_NAME).then((cache) => {
                return fetch(request).then((response) => {
                    // Salva in cache per uso offline
                    cache.put(request, response.clone());
                    return response;
                }).catch(() => {
                    // Fallback a cache se offline
                    return cache.match(request);
                });
            })
        );
        return;
    }

    // Strategia Cache-First per risorse statiche
    event.respondWith(
        caches.match(request).then((cachedResponse) => {
            if (cachedResponse) {
                // Restituisci da cache
                return cachedResponse;
            }

            // Fetch da network e cache
            return fetch(request).then((response) => {
                // Verifica risposta valida
                if (!response || response.status !== 200 || response.type === 'error') {
                    return response;
                }

                // Clona e salva in cache
                const responseToCache = response.clone();
                caches.open(CACHE_NAME).then((cache) => {
                    cache.put(request, responseToCache);
                });

                return response;
            }).catch((error) => {
                console.error('[SW] Fetch failed:', error);

                // Fallback generico per pagine HTML
                if (request.headers.get('accept').includes('text/html')) {
                    return caches.match('./sequenze_colori.html');
                }

                return new Response('Offline', { status: 503 });
            });
        })
    );
});

/**
 * Message Event - Comunicazione con app
 */
self.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }

    if (event.data && event.data.type === 'CACHE_CLEAR') {
        caches.keys().then((cacheNames) => {
            cacheNames.forEach((cacheName) => {
                caches.delete(cacheName);
            });
        });
    }
});

/**
 * Sync Event - Background Sync (opzionale)
 */
self.addEventListener('sync', (event) => {
    if (event.tag === 'sync-logs') {
        event.waitUntil(syncLogs());
    }
});

/**
 * Sincronizza log utilizzo quando torna online
 */
async function syncLogs() {
    try {
        // Placeholder per future implementazioni
        console.log('[SW] Background sync logs...');
    } catch (error) {
        console.error('[SW] Sync failed:', error);
    }
}

/**
 * Push Event - Notifiche Push (opzionale)
 */
self.addEventListener('push', (event) => {
    const options = {
        body: event.data ? event.data.text() : 'Nuova comunicazione disponibile',
        icon: './assets/icons/icon-192.png',
        badge: './assets/icons/icon-192.png',
        vibrate: [200, 100, 200]
    };

    event.waitUntil(
        self.registration.showNotification('Sequenze colori', options)
    );
});

/**
 * Notification Click Event
 */
self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    event.waitUntil(
        clients.openWindow('./sequenze_colori.html')
    );
});

console.log('[SW] Service Worker loaded');
