'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "28f414520a9c2fc9b7dce484e25bca73",
"version.json": "cfb141219d3ccaae6dc177a68e114f62",
"index.html": "eb5f8477bbf70438e6840454847dfc14",
"/": "eb5f8477bbf70438e6840454847dfc14",
"main.dart.js": "c420c5261b90f5a7069a63ba9e770ec7",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "51360f42875d93fc76695c7aa34b6657",
"assets/AssetManifest.json": "9886ded83c68dd83df6c2ef1cda0c9a4",
"assets/NOTICES": "4500134ff5d1d2e1062f8fe89f89a16e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "49a238e3d271fc31298acbf4189b177a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "f9155b6b79ba79176539967ba6dc89ac",
"assets/fonts/MaterialIcons-Regular.otf": "ab7ed171e67915899c7a5d441e879284",
"assets/assets/images/mentorship_connection.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/tech_enthusiast.jpg": "8f06323bd613bf36e5190c5dc04cee92",
"assets/assets/images/AppIcons.zip": "6561ccecb060ebbf2660ec336e34f29b",
"assets/assets/images/john.jpg": "1ed4140da753482fa6760de154c21002",
"assets/assets/images/momocha.jpg": "7cab2ca1fa620a4af6e4070520f426c8",
"assets/assets/images/travel.jpg": "1bff8e11787eb36ef728f97fc7892e06",
"assets/assets/images/space.jpg": "b8defb00faa43721af0f8ba1cdb6d32a",
"assets/assets/images/profile_image.png": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/profile_image.jpg": "ce89cfedaa4a1a1c235922ad938bb805",
"assets/assets/images/OviEdu_logo.png": "3e9ead4de5a7c5fede0a30549201b03f",
"assets/assets/images/inaoba.jpg": "7f5f68aa811a766e2aa50e69236bd3dd",
"assets/assets/images/science_expert.jpg": "182e3804f0e7f6a57109b407eab9105a",
"assets/assets/images/hannah.jpg": "44a5dec2c4a28c1cf76a95121db724a2",
"assets/assets/images/verified.png": "604fcd0c10186fafb41fafe87efe34ef",
"assets/assets/images/swip5.jpg": "ce89cfedaa4a1a1c235922ad938bb805",
"assets/assets/images/mentor_image.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/swip4.jpg": "ce89cfedaa4a1a1c235922ad938bb805",
"assets/assets/images/illustration.png": "c1792a72bad8e19292bf4fb089025565",
"assets/assets/images/swip1.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/swip3.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/swip2.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/quantum.jpg": "da5942ac0fd78b721a68b29dfa3244fe",
"assets/assets/images/man.jpg": "ce89cfedaa4a1a1c235922ad938bb805",
"assets/assets/images/profile_pic.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/mentor_conversation.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/monendro.jpg": "2feed597203c9eb490f731d23ff83be0",
"assets/assets/images/creative_mind.jpg": "d0e08cbc92d3b390d11b86c2f20b6d8d",
"assets/assets/images/professional_network.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/placeholder_profile.png": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/custom_icon.png": "c68c5eb9cd3eecc93a699fd0e823e40c",
"assets/assets/images/programming.jpg": "fc7524d743710cfa01e99ea54a41e360",
"assets/assets/images/job_listings.jpg": "ece43def9e5a93f4fa2b2f00bf2c9ceb",
"assets/assets/images/business_leader.jpg": "1a5a06a7ba48c1c5527ea5de02046809",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
