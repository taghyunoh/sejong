/* allCare PWA service worker
 * Strategy: "installable + cache static assets only"
 *  - HTML / *.do / *.jsp / navigation  -> always network (keep existing no-store strategy)
 *  - same-origin <base>/asset/ static files (css/js/fonts/images) -> stale-while-revalidate
 *  - everything else (external CDN, etc.) -> not handled (browser default)
 *
 * BASE is derived from this sw.js location. e.g. /app/sw.js -> BASE = /app/
 * So it works under root or any context path (e.g. /app) with no code change.
 *
 * To force-refresh the static cache on deploy, bump CACHE_VERSION.
 */
const CACHE_VERSION = 'allcare-static-v1';
const BASE = new URL('./', self.location).pathname;   // e.g. '/app/' or '/'

const PRECACHE_URLS = [
  BASE + 'offline.html',
  BASE + 'asset/images/pwa/icon-192.png',
  BASE + 'asset/images/pwa/icon-512.png',
  BASE + 'manifest.webmanifest'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION)
      .then((cache) => cache.addAll(PRECACHE_URLS).catch(() => {}))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_VERSION).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

function isStaticAsset(url) {
  // only same-origin <base>/asset/ files are cacheable
  return url.origin === self.location.origin && url.pathname.startsWith(BASE + 'asset/');
}

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return; // ignore non-GET (POST, etc.)

  const url = new URL(req.url);

  // 1) navigation / HTML / dynamic (.do, .jsp) -> always network. offline page only on failure.
  const isDynamic =
    req.mode === 'navigate' ||
    url.pathname.endsWith('.do') ||
    url.pathname.endsWith('.jsp') ||
    (req.headers.get('accept') || '').includes('text/html');

  if (isDynamic) {
    event.respondWith(
      fetch(req).catch(() => caches.match(BASE + 'offline.html'))
    );
    return;
  }

  // 2) same-origin static asset -> stale-while-revalidate
  if (isStaticAsset(url)) {
    event.respondWith(
      caches.open(CACHE_VERSION).then((cache) =>
        cache.match(req).then((cached) => {
          const network = fetch(req).then((res) => {
            if (res && res.status === 200) cache.put(req, res.clone());
            return res;
          }).catch(() => cached);
          return cached || network;
        })
      )
    );
    return;
  }

  // 3) otherwise: not handled (browser default)
});
