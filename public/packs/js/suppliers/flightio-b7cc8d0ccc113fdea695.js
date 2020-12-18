/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/packs/";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./app/javascript/packs/suppliers/flightio.js");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./app/javascript/packs/suppliers/flightio.js":
/*!****************************************************!*\
  !*** ./app/javascript/packs/suppliers/flightio.js ***!
  \****************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

throw new Error("Module build failed (from ./node_modules/babel-loader/lib/index.js):\nSyntaxError: /home/ali/projects/parvazhub/app/javascript/packs/suppliers/flightio.js: Unexpected token (5:8)\n\n  3 | \n  4 | export default class Flightio extends Base{\n> 5 |   const supplier_name = 'flightio'\n    |         ^\n  6 | \n  7 |   delay (ms) {\n  8 |     return new Promise(res => setTimeout(res, ms));\n    at Object._raise (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:748:17)\n    at Object.raiseWithData (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:741:17)\n    at Object.raise (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:735:17)\n    at Object.unexpected (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9101:16)\n    at Object.parseClassMemberWithIsStatic (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12642:12)\n    at Object.parseClassMember (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12535:10)\n    at /home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12480:14\n    at Object.withTopicForbiddingContext (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11516:14)\n    at Object.parseClassBody (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12457:10)\n    at Object.parseClass (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12430:22)\n    at Object.parseExportDefaultExpression (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12877:19)\n    at Object.parseExport (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12798:31)\n    at Object.parseStatementContent (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11782:27)\n    at Object.parseStatement (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11676:17)\n    at Object.parseBlockOrModuleBlockBody (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12258:25)\n    at Object.parseBlockBody (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12244:10)\n    at Object.parseTopLevel (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11607:10)\n    at Object.parse (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:13418:10)\n    at parse (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:13471:38)\n    at parser (/home/ali/projects/parvazhub/node_modules/@babel/core/lib/parser/index.js:54:34)\n    at parser.next (<anonymous>)\n    at normalizeFile (/home/ali/projects/parvazhub/node_modules/@babel/core/lib/transformation/normalize-file.js:99:38)\n    at normalizeFile.next (<anonymous>)\n    at run (/home/ali/projects/parvazhub/node_modules/@babel/core/lib/transformation/index.js:31:50)\n    at run.next (<anonymous>)\n    at Function.transform (/home/ali/projects/parvazhub/node_modules/@babel/core/lib/transform.js:27:41)\n    at transform.next (<anonymous>)\n    at step (/home/ali/projects/parvazhub/node_modules/gensync/index.js:261:32)\n    at /home/ali/projects/parvazhub/node_modules/gensync/index.js:273:13\n    at async.call.result.err.err (/home/ali/projects/parvazhub/node_modules/gensync/index.js:223:11)");

/***/ })

/******/ });
//# sourceMappingURL=flightio-b7cc8d0ccc113fdea695.js.map