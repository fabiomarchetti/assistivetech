// Service Worker per Cerca il Colore Corrispondente PWA
// AssistiveTech.it - Training Cognitivo

const CACHE_NAME = 'cerca-colore-corrispondente-v1.0';
const urlsToCache = [
  './',
  './setup.html',
  './index.html',
  './manifest.json',
  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
  'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css',
  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js'
];

// Installazione Service Worker
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installazione...');

  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Service Worker] Cache aperta');
        return cache.addAll(urlsToCache);
      })
      .catch((error) => {
        console.error('[Service Worker] Errore caching:', error);
      })
  );

  // Forza l'attivazione immediata
  self.skipWaiting();
});

// Attivazione Service Worker
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Attivazione...');

  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('[Service Worker] Rimozione cache vecchia:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );

  // Prendi controllo immediato
  return self.clients.claim();
});

// Intercetta richieste di rete
self.addEventListener('fetch', (event) => {
  // Skip richieste API ARASAAC e DB - devono essere sempre online
  if (event.request.url.includes('api.arasaac.org') ||
      event.request.url.includes('/api/')) {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Restituisci dalla cache se disponibile
        if (response) {
          return response;
        }

        // Altrimenti fetch dalla rete
        return fetch(event.request)
          .then((response) => {
            // Verifica risposta valida
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Clona la risposta
            const responseToCache = response.clone();

            // Aggiungi alla cache
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });

            return response;
          })
          .catch((error) => {
            console.error('[Service Worker] Fetch fallito:', error);
          });
      })
  );
});

// Gestione messaggi
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
