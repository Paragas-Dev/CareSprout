// public/js/firebase-config.js

const firebaseConfig = {
    apiKey: "AIzaSyA3zAXTNwFi9lYAago4EFwE0tIhWQNgRj4",
    authDomain: "caresprout-71e11.firebaseapp.com",
    databaseURL: "https://caresprout-71e11-default-rtdb.firebaseio.com",
    projectId: "caresprout-71e11",
    storageBucket: "caresprout-71e11.firebasestorage.app",
    messagingSenderId: "8378246898",
    appId: "1:8378246898:web:3854c2e8370efd7e96926b"
  };

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const s = document.createElement('script');
      s.src = src;
      s.async = true;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  // Initialize Firebase only if not yet initialized
  (async function initFirebase() {
    try {
      if (typeof firebase === 'undefined' || !firebase.auth || !firebase.firestore) {
        await loadScript('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
        await loadScript('https://www.gstatic.com/firebasejs/8.10.1/firebase-auth.js');
        await loadScript('https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js');
        await loadScript('https://www.gstatic.com/firebasejs/8.10.1/firebase-database.js');
      }

      if (!firebase.apps.length) {
        firebase.initializeApp(firebaseConfig);
      }

      window.auth = firebase.auth();
      window.firebase = firebase;
      window.db = firebase.firestore();

      auth.onAuthStateChanged((user) => {
        window.auth = auth;
        window.db = db;
        window.firebase = firebase;
        window.currentUser = user;

        window.dispatchEvent(new CustomEvent('firebaseReady'));
      });

    } catch (error) {
      console.error('Firebase initialization error:', error);
    }
  })
  ();

// const _0x122b3b = _0x3efe;
// function _0x3efe(_0x1c1e6a, _0x5e8459) {
//     const _0x42ec09 = _0x3f73();
//     return (
//         (_0x3efe = function (_0x93e7e5, _0x43cb9a) {
//             _0x93e7e5 = _0x93e7e5 - 0x89;
//             let _0x3f7335 = _0x42ec09[_0x93e7e5];
//             return _0x3f7335;
//         }),
//         _0x3efe(_0x1c1e6a, _0x5e8459)
//     );
// }
// (function (_0x2d9786, _0x139b71) {
//     const _0x28e8b5 = _0x3efe,
//         _0x3c499b = _0x2d9786();
//     while (!![]) {
//         try {
//             const _0x9c952e =
//                 -parseInt(_0x28e8b5(0x91)) / 0x1 +
//                 parseInt(_0x28e8b5(0xb3)) / 0x2 +
//                 (-parseInt(_0x28e8b5(0x99)) / 0x3) *
//                     (-parseInt(_0x28e8b5(0x8b)) / 0x4) +
//                 -parseInt(_0x28e8b5(0xa3)) / 0x5 +
//                 (-parseInt(_0x28e8b5(0x94)) / 0x6) *
//                     (-parseInt(_0x28e8b5(0x9b)) / 0x7) +
//                 (parseInt(_0x28e8b5(0xae)) / 0x8) *
//                     (-parseInt(_0x28e8b5(0xa1)) / 0x9) +
//                 (-parseInt(_0x28e8b5(0xa4)) / 0xa) *
//                     (parseInt(_0x28e8b5(0xa9)) / 0xb);
//             if (_0x9c952e === _0x139b71) break;
//             else _0x3c499b["push"](_0x3c499b["shift"]());
//         } catch (_0x497a8b) {
//             _0x3c499b["push"](_0x3c499b["shift"]());
//         }
//     }
// })(_0x3f73, 0x66009);
// const firebaseConfig = {
//     apiKey: _0x122b3b(0x95),
//     authDomain: _0x122b3b(0x8d),
//     databaseURL: _0x122b3b(0x90),
//     projectId: _0x122b3b(0xa8),
//     storageBucket: _0x122b3b(0xb2),
//     messagingSenderId: _0x122b3b(0x8f),
//     appId: _0x122b3b(0x8e),
// };
// function _0x3f73() {
//     const _0x5c0160 = [
//         "1:8378246898:web:3854c2e8370efd7e96926b",
//         "8378246898",
//         "https://caresprout-71e11-default-rtdb.firebaseio.com",
//         "442853NSqIpX",
//         "dispatchEvent",
//         "debu",
//         "36684sxfXPb",
//         "AIzaSyA3zAXTNwFi9lYAago4EFwE0tIhWQNgRj4",
//         "init",
//         "length",
//         "input",
//         "3eXawLd",
//         "auth",
//         "826vQDHUc",
//         "Firebase\x20initialization\x20error:",
//         "appendChild",
//         "https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js",
//         "src",
//         "\x5c+\x5c+\x20*(?:[a-zA-Z_$][0-9a-zA-Z_$]*)",
//         "72909JgmWHX",
//         "https://www.gstatic.com/firebasejs/8.10.1/firebase-auth.js",
//         "693210cKOKEE",
//         "203420QHdLNm",
//         "constructor",
//         "gger",
//         "string",
//         "caresprout-71e11",
//         "154sZXXPv",
//         "apply",
//         "action",
//         "onload",
//         "test",
//         "568BNMRkf",
//         "createElement",
//         "firestore",
//         "stateObject",
//         "caresprout-71e11.firebasestorage.app",
//         "864302mrNJEc",
//         "apps",
//         "firebaseReady",
//         "counter",
//         "https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js",
//         "while\x20(true)\x20{}",
//         "2822608CIXxHX",
//         "firebase",
//         "caresprout-71e11.firebaseapp.com",
//     ];
//     _0x3f73 = function () {
//         return _0x5c0160;
//     };
//     return _0x3f73();
// }
// function loadScript(_0x1e47a8) {
//     return new Promise((_0xc8924, _0x356381) => {
//         const _0x18ca14 = _0x3efe,
//             _0x5c800b = document[_0x18ca14(0xaf)]("script");
//         (_0x5c800b[_0x18ca14(0x9f)] = _0x1e47a8),
//             (_0x5c800b["async"] = !![]),
//             (_0x5c800b[_0x18ca14(0xac)] = _0xc8924),
//             (_0x5c800b["onerror"] = _0x356381),
//             document["head"][_0x18ca14(0x9d)](_0x5c800b);
//     });
// }
// (async function initFirebase() {
//     const _0x420d8e = _0x122b3b,
//         _0x3cd1f2 = (function () {
//             let _0x2bbff3 = !![];
//             return function (_0x4f0abd, _0x1de4ea) {
//                 const _0x5e8168 = _0x2bbff3
//                     ? function () {
//                           const _0x7a0b28 = _0x3efe;
//                           if (_0x1de4ea) {
//                               const _0x2cb0b9 = _0x1de4ea[_0x7a0b28(0xaa)](
//                                   _0x4f0abd,
//                                   arguments
//                               );
//                               return (_0x1de4ea = null), _0x2cb0b9;
//                           }
//                       }
//                     : function () {};
//                 return (_0x2bbff3 = ![]), _0x5e8168;
//             };
//         })();
//     (function () {
//         _0x3cd1f2(this, function () {
//             const _0x4c5e5b = _0x3efe,
//                 _0x3c9f2 = new RegExp("function\x20*\x5c(\x20*\x5c)"),
//                 _0x126e1f = new RegExp(_0x4c5e5b(0xa0), "i"),
//                 _0x100c44 = _0x93e7e5(_0x4c5e5b(0x96));
//             !_0x3c9f2[_0x4c5e5b(0xad)](_0x100c44 + "chain") ||
//             !_0x126e1f[_0x4c5e5b(0xad)](_0x100c44 + _0x4c5e5b(0x98))
//                 ? _0x100c44("0")
//                 : _0x93e7e5();
//         })();
//     })();
//     try {
//         (typeof firebase === "undefined" ||
//             !firebase["auth"] ||
//             !firebase[_0x420d8e(0xb0)]) &&
//             (await loadScript(_0x420d8e(0x9e)),
//             await loadScript(_0x420d8e(0xa2)),
//             await loadScript(_0x420d8e(0x89)),
//             await loadScript(
//                 "https://www.gstatic.com/firebasejs/8.10.1/firebase-database.js"
//             )),
//             !firebase[_0x420d8e(0xb4)]["length"] &&
//                 firebase["initializeApp"](firebaseConfig),
//             (window["auth"] = firebase[_0x420d8e(0x9a)]()),
//             (window["firebase"] = firebase),
//             (window["db"] = firebase[_0x420d8e(0xb0)]()),
//             auth["onAuthStateChanged"]((_0x1e4c05) => {
//                 const _0x5890b6 = _0x420d8e;
//                 (window[_0x5890b6(0x9a)] = auth),
//                     (window["db"] = db),
//                     (window[_0x5890b6(0x8c)] = firebase),
//                     (window["currentUser"] = _0x1e4c05),
//                     window[_0x5890b6(0x92)](new CustomEvent(_0x5890b6(0xb5)));
//             });
//     } catch (_0x4663f2) {
//         console["error"](_0x420d8e(0x9c), _0x4663f2);
//     }
// })();
// function _0x93e7e5(_0x3d223d) {
//     function _0x1927e0(_0x4f66ae) {
//         const _0x29ac58 = _0x3efe;
//         if (typeof _0x4f66ae === _0x29ac58(0xa7))
//             return function (_0x1873f8) {}
//                 ["constructor"](_0x29ac58(0x8a))
//                 [_0x29ac58(0xaa)](_0x29ac58(0xb6));
//         else
//             ("" + _0x4f66ae / _0x4f66ae)[_0x29ac58(0x97)] !== 0x1 ||
//             _0x4f66ae % 0x14 === 0x0
//                 ? function () {
//                       return !![];
//                   }
//                       [_0x29ac58(0xa5)](_0x29ac58(0x93) + _0x29ac58(0xa6))
//                       ["call"](_0x29ac58(0xab))
//                 : function () {
//                       return ![];
//                   }
//                       ["constructor"](_0x29ac58(0x93) + _0x29ac58(0xa6))
//                       ["apply"](_0x29ac58(0xb1));
//         _0x1927e0(++_0x4f66ae);
//     }
//     try {
//         if (_0x3d223d) return _0x1927e0;
//         else _0x1927e0(0x0);
//     } catch (_0x3edf62) {}
// }
