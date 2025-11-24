// Service Worker per "ascolto e rispondo"
const CACHE_NAME = 'ascolto-e-rispondo-v2.0.0';
const urlsToCache = [
  './index.html',
  './css/styles.css',
  './js/app.js',
  './manifest.json',
  './assets/icons/icon-192.png?v=2.0',
  './assets/icons/icon-512.png?v=2.0',
  'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css'
];

// Installazione del Service Worker
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installazione...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Service Worker] Cache aperta');
        return cache.addAll(urlsToCache);
      })
  );
});

// Attivazione del Service Worker
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
});

// Intercettazione delle richieste
self.addEventListener('fetch', (event) => {
  // Salta le richieste all'API
  if (event.request.url.includes('/api/') || event.request.url.includes('youtube.com')) {
    return;
  }
  
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Ritorna dalla cache se disponibile
        if (response) {
          return response;
        }
        
        // Altrimenti fetch dalla rete
        return fetch(event.request).then((response) => {
          // Verifica se è una risposta valida
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response;
          }
          
          // Clone della risposta per la cache
          const responseToCache = response.clone();
          
          caches.open(CACHE_NAME)
            .then((cache) => {
              cache.put(event.request, responseToCache);
            });
          
          return response;
        });
      })
  );
});
