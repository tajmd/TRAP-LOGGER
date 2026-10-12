/* TRAP LOGGER service worker: keeps the app working with no signal.
   Change CACHE when you upload a new version so phones fetch the new files. */
var CACHE = "trap-logger-6.1.0";
var SHELL = ["./", "index.html", "config.js", "supabase.js", "manifest.webmanifest", "apple-touch-icon.png", "icon-192.png", "icon-512.png", "icon-maskable-512.png"];

self.addEventListener("install", function (e) {
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(SHELL); }).then(function () { return self.skipWaiting(); }));
});
self.addEventListener("activate", function (e) {
  e.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.filter(function (k) { return k !== CACHE; }).map(function (k) { return caches.delete(k); }));
  }).then(function () { return self.clients.claim(); }));
});
self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;
  if (req.mode === "navigate") {
    /* newest page when online (3 second limit), saved page when not */
    e.respondWith(new Promise(function (resolve) {
      var done = false;
      var fallback = function () { caches.match("index.html").then(function (r) { if (!done) { done = true; resolve(r || Response.error()); } }); };
      var timer = setTimeout(fallback, 3000);
      fetch(req).then(function (res) {
        clearTimeout(timer);
        if (res && res.ok) { var copy = res.clone(); caches.open(CACHE).then(function (c) { c.put("index.html", copy); }); }
        if (!done) { done = true; resolve(res); }
      }).catch(function () { clearTimeout(timer); fallback(); });
    }));
    return;
  }
  /* settings file: newest when online, saved copy when not */
  if (/\/config\.js$/.test(new URL(req.url).pathname)) {
    e.respondWith(fetch(req).then(function (res) {
      if (res && res.ok) { var copy = res.clone(); caches.open(CACHE).then(function (c) { c.put(req, copy); }); }
      return res;
    }).catch(function () { return caches.match(req); }));
    return;
  }
  e.respondWith(caches.match(req).then(function (hit) {
    return hit || fetch(req).then(function (res) {
      if (res && res.ok) { var copy = res.clone(); caches.open(CACHE).then(function (c) { c.put(req, copy); }); }
      return res;
    });
  }));
});
