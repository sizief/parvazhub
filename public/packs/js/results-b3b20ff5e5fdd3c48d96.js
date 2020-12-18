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
/******/ 	return __webpack_require__(__webpack_require__.s = "./app/javascript/packs/results.jsx");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./app/javascript/packs/results.jsx":
/*!******************************************!*\
  !*** ./app/javascript/packs/results.jsx ***!
  \******************************************/
/*! no static exports found */
/***/ (function(module, exports) {

throw new Error("Module build failed (from ./node_modules/babel-loader/lib/index.js):\nSyntaxError: /home/ali/projects/parvazhub/app/javascript/packs/results.jsx: JSX value should be either an expression or a quoted JSX text (8:29)\n\n   6 | document.addEventListener('DOMContentLoaded', () => {\n   7 |   ReactDOM.render(\n>  8 |     <SearchResult parameters=window.location.pathname />,\n     |                              ^\n   9 |     document.body.appendChild(document.createElement('div')),\n  10 |   )\n  11 | })\n    at Object._raise (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:748:17)\n    at Object.raiseWithData (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:741:17)\n    at Object.raise (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:735:17)\n    at Object.jsxParseAttributeValue (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4593:20)\n    at Object.jsxParseAttribute (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4632:44)\n    at Object.jsxParseOpeningElementAfterName (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4652:28)\n    at Object.jsxParseOpeningElementAt (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4645:17)\n    at Object.jsxParseElementAt (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4677:33)\n    at Object.jsxParseElement (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4751:17)\n    at Object.parseExprAtom (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4758:19)\n    at Object.parseExprSubscripts (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10150:23)\n    at Object.parseUpdate (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10130:21)\n    at Object.parseMaybeUnary (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10119:17)\n    at Object.parseExprOps (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9989:23)\n    at Object.parseMaybeConditional (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9963:23)\n    at Object.parseMaybeAssign (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9926:21)\n    at /home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9893:39\n    at Object.allowInAnd (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11547:12)\n    at Object.parseMaybeAssignAllowIn (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9893:17)\n    at Object.parseExprListItem (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11309:18)\n    at Object.parseCallExpressionArguments (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10350:22)\n    at Object.parseCoverCallAndAsyncArrowHead (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10258:29)\n    at Object.parseSubscript (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10194:19)\n    at Object.parseSubscripts (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10167:19)\n    at Object.parseExprSubscripts (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10156:17)\n    at Object.parseUpdate (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10130:21)\n    at Object.parseMaybeUnary (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10119:17)\n    at Object.parseExprOps (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9989:23)\n    at Object.parseMaybeConditional (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9963:23)\n    at Object.parseMaybeAssign (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9926:21)");

/***/ })

/******/ });
//# sourceMappingURL=results-b3b20ff5e5fdd3c48d96.js.map