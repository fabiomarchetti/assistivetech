// Service Worker per Schiaccia le Zanzare PWA
// Versione: 1.0.0

const CACHE_NAME = 'schiaccia-zanzare-v1';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './setup.html',
  './gioca.html',
  './manifest.json',
  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
  'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css'
];

// Installazione Service Worker
self.addEventListener('install', (event) => {
  console.log('[SW] Installing Service Worker...');
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[SW] Caching app shell');
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
  self.skipWaiting();
});

// Attivazione Service Worker
self.addEventListener('activate', (event) => {
  console.log('[SW] Activating Service Worker...');
  event.waitUntil(
    caches.keys().then((keyList) => {
      return Promise.all(
        keyList.map((key) => {
          if (key !== CACHE_NAME) {
            console.log('[SW] Removing old cache:', key);
            return caches.delete(key);
          }
        })
      );
    })
  );
  return self.clients.claim();
});

// Strategia di fetch: Network First, fallback su Cache
self.addEventListener('fetch', (event) => {
  // Ignora richieste non-GET e MediaPipe (deve essere sempre online)
  if (event.request.method !== 'GET' || 
      event.request.url.includes('mediapipe') ||
      event.request.url.includes('jsdelivr.net/npm/@mediapipe')) {
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Clona la risposta per salvare in cache
        const responseToCache = response.clone();
        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseToCache);
        });
        return response;
      })
      .catch(() => {
        // Se network fallisce, usa cache
        return caches.match(event.request).then((response) => {
          if (response) {
            return response;
          }
          // Fallback per navigazione
          if (event.request.mode === 'navigate') {
            return caches.match('./index.html');
          }
        });
      })
  );
});

// Gestione messaggi dal client
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
