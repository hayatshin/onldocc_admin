'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "830fd47c81a141c278ce83003134b89a",
"version.json": "1c52bc341e1373ed5485dd8048d70cdd",
"index.html": "cd1c6baa0177d86b0c523a4394c3396c",
"/": "cd1c6baa0177d86b0c523a4394c3396c",
"main.dart.js": "364bfd7d80703f04d0f2457a96619032",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"favicon2.png": "d3bfc108279ddde0e7779c1dc884130d",
"favicon1.png": "aec952d48b263ecdfeb577bbeec212a2",
"favicon.png": "8a74c27dad0a461a95ccd08940f9f89e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "ead79cf63d1bc3153708ce76de926549",
"assets/AssetManifest.json": "b016e4b8b29b940f4f66928a7511ef7b",
"assets/NOTICES": "740fcd618bf2ca92889411b9ea2eab88",
"assets/env": "5a67c56456e9c526afece286a8c6c514",
"assets/FontManifest.json": "9e65a4689e70295b02e2a286fe36a0d1",
"assets/AssetManifest.bin.json": "0bf6aae1d6469a92bb6d41c77c78c892",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/timezone/data/latest_all.tzf": "a3a6cb5d912b5375926e5b027f91cb00",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "04f83c01dded195a11d21c2edf643455",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "0e751781eb4fd34042ab1c4ebd848637",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "17ee8e30dde24e349e70ffcdc0073fb0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "8d688463aad5fc042191c1459a0a458e",
"assets/fonts/MaterialIcons-Regular.otf": "c133a338558104d46840eb86a0ea589f",
"assets/assets/images/total_icon_pink.png": "10f8bc983bc6aa9d84c6e0522af70848",
"assets/assets/images/total_icon_transparent.png": "6e8059d75def4798dd94368d9c8fcdaa",
"assets/assets/images/splash_dark.png": "5ba00f4e061aec66e091331152dd9deb",
"assets/assets/images/main_phone.png": "394424a9dc7e921e0b76546b8e819107",
"assets/assets/images/image_icon.png": "017d6155b544ee895adb6105918f8b4c",
"assets/assets/images/text_icon.png": "5d966bb4892c21ccd959f34071b70afb",
"assets/assets/images/admin.png": "d434e5cc578ae8f46b248ced1eb8e597",
"assets/assets/images/woman_icon.png": "aec952d48b263ecdfeb577bbeec212a2",
"assets/assets/images/splash_light.png": "138f8141d40f3ce78c2c19413918a1fa",
"assets/assets/fonts/GmarketSans-Medium.ttf": "96b4a5b8dfa689a32dd322793d660298",
"assets/assets/fonts/NanumSquareNeoOTF-Eb.otf": "669013195bb11b943952ac23bae56070",
"assets/assets/fonts/Samlip-Outline.otf": "71256646e67755f3d8a896946844e88e",
"assets/assets/fonts/Spoqa-Medium.otf": "c7160a32d3d50ac705392a5f50cc96dd",
"assets/assets/fonts/NanumSquareNeoOTF-Hv.otf": "facd5b49ad23a067a6e894ac983a0405",
"assets/assets/fonts/GmarketSans-Bold.ttf": "7cf85dc71a5acc06eb84b647fcab6103",
"assets/assets/fonts/Spoqa-Light.otf": "9b97934b95a9237af599e2c4a99ad5cf",
"assets/assets/fonts/Samlip-Basic.otf": "082fb353d561662afb09cbfb57739212",
"assets/assets/fonts/Spoqa-Thin.otf": "0e46d96cafdedeeb4b40598ee00f4e7c",
"assets/assets/fonts/NanumSquareNeoOTF-Bd.otf": "ac2c6dd4698f65fb1e799efc81b8d77a",
"assets/assets/fonts/Spoqa-Bold.otf": "8ea1d9004a8f295b800c3c9b89a9c07a",
"assets/assets/fonts/NanumSquareNeoOTF-Lt.otf": "09cca6769e48ef5564154dbfca1a746d",
"assets/assets/fonts/GmarketSans-Light.ttf": "12bd3606ebae38deac6acbad730e4291",
"assets/assets/fonts/NanumSquareNeoOTF-Rg.otf": "4ba733bc5941db853a333f11ee65ba01",
"assets/assets/app_intro/4.png": "404129d0f7175dc5faab3db606bfbc74",
"assets/assets/app_intro/2.png": "cb4f7f2b0ea783d8bb3c3ef1d2867fd4",
"assets/assets/app_intro/3.png": "361ff1a7afe915ddabe61e6569636a10",
"assets/assets/app_intro/1.png": "2c3e8d6585c007ccf417bdc3060d0dad",
"assets/assets/app_screen/ai_chat.png": "3f50755de820a9810c2361aa4bf6dfb9",
"assets/assets/app_screen/today_diary.png": "06ecc64c4275011de447e4235ccd61fa",
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
