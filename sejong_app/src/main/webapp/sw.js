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
const CACHE_VERSION = 'allcare-static-v3';
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
    // [먹통 방지] 네비게이션 / HTML / .do / .jsp 는 서비스워커가 개입하지 않고 브라우저가 직접 처리한다.
    //   삼성인터넷 등 일부 브라우저에서 SW 제어 하의 페이지(로그인 등)가 먹통되는 문제를 회피.
    //   (대가: 오프라인 폴백 offline.html 포기 — 온라인 전용 서비스라 영향 미미)
    return;
  }

  // 2a) CSS/JS -> network-first (배포/수정이 즉시 반영되도록. 캐시는 오프라인 폴백용).
  //     stale-while-revalidate 로 캐시된 옛 css/js 가 배포 후에도 계속 보이던 문제 방지.
  if (isStaticAsset(url) && /\.(css|js)$/i.test(url.pathname)) {
    event.respondWith(
      fetch(req).then((res) => {
        if (res && res.status === 200) {
          const copy = res.clone();
          caches.open(CACHE_VERSION).then((cache) => cache.put(req, copy));
        }
        return res;
      }).catch(() => caches.open(CACHE_VERSION).then((cache) => cache.match(req)))
    );
    return;
  }

  // 2b) 그 외 정적 asset(이미지/폰트) -> stale-while-revalidate
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
