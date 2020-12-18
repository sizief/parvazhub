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
/******/ 	return __webpack_require__(__webpack_require__.s = "./app/javascript/packs/search-results.jsx");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./app/javascript/packs/search-results.jsx":
/*!*************************************************!*\
  !*** ./app/javascript/packs/search-results.jsx ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

throw new Error("Module build failed (from ./node_modules/babel-loader/lib/index.js):\nSyntaxError: /home/ali/projects/parvazhub/app/javascript/packs/search-results.jsx: Unexpected token, expected \",\" (21:4)\n\n  19 |   return(\n  20 |     <div>searching for {props.origin} to {props.destination} for {props.date}</div>\n> 21 |     {results.map(res=>(\n     |     ^\n  22 |       <div>\n  23 |       { res.supplier }\n  24 |       { res.price }\n    at Object._raise (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:748:17)\n    at Object.raiseWithData (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:741:17)\n    at Object.raise (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:735:17)\n    at Object.unexpected (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9101:16)\n    at Object.expect (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9087:28)\n    at Object.parseParenAndDistinguishExpression (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10736:14)\n    at Object.parseExprAtom (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10470:21)\n    at Object.parseExprAtom (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4763:20)\n    at Object.parseExprSubscripts (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10150:23)\n    at Object.parseUpdate (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10130:21)\n    at Object.parseMaybeUnary (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10119:17)\n    at Object.parseExprOps (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9989:23)\n    at Object.parseMaybeConditional (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9963:23)\n    at Object.parseMaybeAssign (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9926:21)\n    at Object.parseExpressionBase (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9871:23)\n    at /home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9865:39\n    at Object.allowInAnd (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11547:12)\n    at Object.parseExpression (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:9865:17)\n    at Object.parseReturnStatement (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12045:28)\n    at Object.parseStatementContent (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11724:21)\n    at Object.parseStatement (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11676:17)\n    at Object.parseBlockOrModuleBlockBody (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12258:25)\n    at Object.parseBlockBody (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12244:10)\n    at Object.parseBlock (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:12228:10)\n    at Object.parseFunctionBody (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11221:24)\n    at Object.parseArrowExpression (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:11193:10)\n    at Object.parseExprAtom (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10428:25)\n    at Object.parseExprAtom (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:4763:20)\n    at Object.parseExprSubscripts (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10150:23)\n    at Object.parseUpdate (/home/ali/projects/parvazhub/node_modules/@babel/parser/lib/index.js:10130:21)");

/***/ })

/******/ });
//# sourceMappingURL=search-results-2bb495a172034381e901.js.map