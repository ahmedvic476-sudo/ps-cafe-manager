// ============================================================
// PS Cafe Manager — Service Worker
// Version: 1.0.0
// ============================================================
const CACHE_NAME = 'ps-cafe-v1';
const OFFLINE_URL = './index.html';

// Files to cache on install
const PRECACHE_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png'
];

// ============================================================
// INSTALL — cache all static assets
// ============================================================
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(PRECACHE_ASSETS);
    }).then(() => self.skipWaiting())
  );
});

// ============================================================
// ACTIVATE — clean up old caches
// ============================================================
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(key => key !== CACHE_NAME)
          .map(key => caches.delete(key))
      )
    ).then(() => self.clients.claim())
  );
});

// ============================================================
// FETCH — Cache First for assets, Network First for API calls
// ============================================================
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);

  // Skip non-GET requests
  if (event.request.method !== 'GET') return;

  // Skip Supabase API calls — always go to network
  if (url.hostname.includes('supabase.co')) {
    event.respondWith(
      fetch(event.request).catch(() => {
        // Return a JSON error response so app can handle it gracefully
        return new Response(
          JSON.stringify({ error: 'offline', message: 'No network' }),
          { headers: { 'Content-Type': 'application/json' } }
        );
      })
    );
    return;
  }

  // For all app files — Cache First strategy
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;

      return fetch(event.request).then(response => {
        // Cache valid responses
        if (response && response.status === 200 && response.type !== 'opaque') {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        }
        return response;
      }).catch(() => {
        // Offline fallback — return the app shell
        return caches.match(OFFLINE_URL);
      });
    })
  );
});

// ============================================================
// BACKGROUND SYNC — retry queued requests when back online
// ============================================================
self.addEventListener('sync', event => {
  if (event.tag === 'ps-sync') {
    event.waitUntil(
      self.clients.matchAll().then(clients => {
        clients.forEach(client =>
          client.postMessage({ type: 'BACKGROUND_SYNC', tag: 'ps-sync' })
        );
      })
    );
  }
});

// ============================================================
// PUSH NOTIFICATIONS (future use)
// ============================================================
self.addEventListener('push', event => {
  if (!event.data) return;
  const data = event.data.json();
  event.waitUntil(
    self.registration.showNotification(data.title || 'PS Cafe Manager', {
      body: data.body || '',
      icon: './icons/icon-192.png',
      badge: './icons/icon-96.png',
      dir: 'rtl',
      lang: 'ar',
      vibrate: [200, 100, 200],
      data: data
    })
  );
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(
    clients.openWindow('./')
  );
});
