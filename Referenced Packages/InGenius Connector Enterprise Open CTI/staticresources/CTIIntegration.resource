<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- 2012 Copyright InGenius Software, Inc. -->
<html>
<head>
    <title>ICE Resiliency</title>
    <script type="text/javascript">

        
        var JSON; if (!JSON) { JSON = {} } (function () { function f(n) { return n < 10 ? "0" + n : n } if (typeof Date.prototype.toJSON !== "function") { Date.prototype.toJSON = function (key) { return isFinite(this.valueOf()) ? this.getUTCFullYear() + "-" + f(this.getUTCMonth() + 1) + "-" + f(this.getUTCDate()) + "T" + f(this.getUTCHours()) + ":" + f(this.getUTCMinutes()) + ":" + f(this.getUTCSeconds()) + "Z" : null }; String.prototype.toJSON = Number.prototype.toJSON = Boolean.prototype.toJSON = function (key) { return this.valueOf() } } var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g, escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g, gap, indent, meta = { "\b": "\\b", "\t": "\\t", "\n": "\\n", "\f": "\\f", "\r": "\\r", '"': '\\"', "\\": "\\\\" }, rep; function quote(string) { escapable.lastIndex = 0; return escapable.test(string) ? '"' + string.replace(escapable, function (a) { var c = meta[a]; return typeof c === "string" ? c : "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4) }) + '"' : '"' + string + '"' } function str(key, holder) { var i, k, v, length, mind = gap, partial, value = holder[key]; if (value && typeof value === "object" && typeof value.toJSON === "function") { value = value.toJSON(key) } if (typeof rep === "function") { value = rep.call(holder, key, value) } switch (typeof value) { case "string": return quote(value); case "number": return isFinite(value) ? String(value) : "null"; case "boolean": case "null": return String(value); case "object": if (!value) { return "null" } gap += indent; partial = []; if (Object.prototype.toString.apply(value) === "[object Array]") { length = value.length; for (i = 0; i < length; i += 1) { partial[i] = str(i, value) || "null" } v = partial.length === 0 ? "[]" : gap ? "[\n" + gap + partial.join(",\n" + gap) + "\n" + mind + "]" : "[" + partial.join(",") + "]"; gap = mind; return v } if (rep && typeof rep === "object") { length = rep.length; for (i = 0; i < length; i += 1) { if (typeof rep[i] === "string") { k = rep[i]; v = str(k, value); if (v) { partial.push(quote(k) + (gap ? ": " : ":") + v) } } } } else { for (k in value) { if (Object.prototype.hasOwnProperty.call(value, k)) { v = str(k, value); if (v) { partial.push(quote(k) + (gap ? ": " : ":") + v) } } } } v = partial.length === 0 ? "{}" : gap ? "{\n" + gap + partial.join(",\n" + gap) + "\n" + mind + "}" : "{" + partial.join(",") + "}"; gap = mind; return v } } if (typeof JSON.stringify !== "function") { JSON.stringify = function (value, replacer, space) { var i; gap = ""; indent = ""; if (typeof space === "number") { for (i = 0; i < space; i += 1) { indent += " " } } else { if (typeof space === "string") { indent = space } } rep = replacer; if (replacer && typeof replacer !== "function" && (typeof replacer !== "object" || typeof replacer.length !== "number")) { throw new Error("JSON.stringify") } return str("", { "": value }) } } if (typeof JSON.parse !== "function") { JSON.parse = function (text, reviver) { var j; function walk(holder, key) { var k, v, value = holder[key]; if (value && typeof value === "object") { for (k in value) { if (Object.prototype.hasOwnProperty.call(value, k)) { v = walk(value, k); if (v !== undefined) { value[k] = v } else { delete value[k] } } } } return reviver.call(holder, key, value) } text = String(text); cx.lastIndex = 0; if (cx.test(text)) { text = text.replace(cx, function (a) { return "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4) }) } if (/^[\],:{}\s]*$/.test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, "@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, "]").replace(/(?:^|:|,)(?:\s*\[)+/g, ""))) { j = eval("(" + text + ")"); return typeof reviver === "function" ? walk({ "": j }, "") : j } throw new SyntaxError("JSON.parse") } } }());
        var _f_ = function () { }; window.console = window.console || { log: _f_, error: _f_, info: _f_, debug: _f_, warn: _f_, trace: _f_, dir: _f_, dirxml: _f_, group: _f_, groupEnd: _f_, time: _f_, timeEnd: _f_, assert: _f_, profile: _f_ };
        function Exists(object) { return (typeof (object) != "undefined" && object !== null); }

        var InGeniusCTIExtensions =
        {
            // Constants

            INTERACTION_API: "interactionApi/",

            LOCAL_STORAGE_KEY_IFRAME_HEIGHT: "dbdfa0bd-ea02-46e3-bcc6-36b702c469c3_IFRAME_HEIGHT",
            LOCAL_STORAGE_KEY_IFRAME_WIDTH: "dbdfa0bd-ea02-46e3-bcc6-36b702c469c3_IFRAME_WIDTH",
            LOCAL_STORAGE_KEY_IFRAME_HEIGHT_DESKTOP: "dbdfa0bd-ea02-46e3-bcc6-36b702c469c3_IFRAME_HEIGHT_DESKTOP",
            LOCAL_STORAGE_KEY_IFRAME_WIDTH_DESKTOP: "dbdfa0bd-ea02-46e3-bcc6-36b702c469c3_IFRAME_WIDTH_DESKTOP",

            CLASS_NORMAL: "normalBgrd bgrd boxRound",
            CLASS_WARNING: "warningBgrd bgrd boxRound",
            CLASS_ERROR: "errorBgrd bgrd boxRound",

            APEX_NAMESPACE_DEFAULT: "ingenius",
            APEX_CLASS_DEFAULT: "CTIExtensions",

            intitialize: function ()
            {
                console.log("ICE.Resiliency.initialize ... ");

                // Query String Parameters

                this.ClientIP = "";
                this.SfdcOrigin = "";
                this.IFrameOrigin = "";
                this.Nonce = "";
                this.Debug = false;
                this.LogLevel = "";
                this.InConsole = false;
                this.AdjustWidth = true;
                this.AdjustHeight = true;

                // Call Center Parameters
                this.OpenCTI_ERROR = "";

                this.CALL_CENTER_PROFILE = "DEFAULT";

                this.IP_REGEX_PATTERN = ".*"; // all IPs are good to go

                this.ICE_URL_A = "";
                this.ICE_URL_B = "";
                this.HEART_BEAT_TIMEOUT = 10;   // in seconds
                this.BASE_RETRY_INTERVAL = 10;  // in seconds
                this.MAX_RETRY_SHIFT = 4;       // 10,20,40,80,160 // max 4 gives 160 seconds
                this.ICE_VERSION = "1";           // Version of ICE

                this.ICEURLQueryString = "";

                // State Variables 

                this.State = "INITIALIZING";   // INITIALIZING, DETECTING_INITIAL, DETECTING, DETECTING_ALTERNATE, BACKINGOFF, CONNECTED
                this.Await = { "inConsole": true, "getSessionInfo":true, "getCallCenterSettings":true };

                this.CurrentURL = "";

                this.ActionStart = 0;
                this.RetryShift = 0;
                this.Timeout = 0;

                // UI

                this.IFRAME_ELEMENT = null;
                this.MESSAGE_DIV = null;
                this.MESSAGE_TEXT = null;
                this.PROGRESS_DIV = null,
                this.SLIDER = null;

                var params = this.parseUrlQueryString(location.search);
                if (!params["clientIP"] || !params["sfdcIFrameOrigin"] || !params["nonce"]) { return; }

                this.AdjustWidth = true;
                if (params["adjustWidth"])  { this.AdjustWidth = (params["adjustWidth"] === "false") ? false : true; }
                this.AdjustHeight = true;
                if (params["adjustHeight"]) { this.AdjustHeight = (params["adjustHeight"] === "false") ? false : true; }

                this.ClientIP = params["clientIP"];

                this.SfdcOrigin = params["sfdcIFrameOrigin"];

                this.ApexNamespace = params["apexNamespace"];

                if (!Exists(this.ApexNamespace)) {
                    this.ApexNamespace = this.APEX_NAMESPACE_DEFAULT;
                }

                this.ApexClass = params["apexClass"];

                if (!Exists(this.ApexClass)) {
                    this.ApexClass = this.APEX_CLASS_DEFAULT;
                }

                this.Nonce = params["nonce"];
                this.ICEURLQueryString = this.buildQueryString({ "sfdcIFrameOrigin": this.getOriginFromUrl(window.location.href), "nonce": this.Nonce });

                if (window.addEventListener) { var self = this; window.addEventListener("message", function (e) { self.processPostMessage(self, e); }, false); }
                else if (window.attachEvent) { var self = this; window.attachEvent("onmessage", function (e) { self.processPostMessage(self, e); }); }

                this.MESSAGE_DIV = document.getElementById('MESSAGE');
                this.MESSAGE_TEXT = document.getElementById('MESSAGE_TEXT');
                this.PROGRESS_DIV = document.getElementById('PROGRESS');
                this.SLIDER = document.getElementById('SLIDER');

                window.parent.postMessage(this.INTERACTION_API + this.buildQueryString({ "method": "isInConsole_0", "nonce": this.Nonce }), this.SfdcOrigin);
                window.parent.postMessage(this.INTERACTION_API + this.buildQueryString({ "method": "runApex_0", "apexClass": this.ApexNamespace + (this.ApexNamespace !== ""? "." : "") + this.ApexClass, "methodName": "getSessionInfo", "methodParams": null, "nonce": this.Nonce }), this.SfdcOrigin);
                window.parent.postMessage(this.INTERACTION_API + this.buildQueryString({ "method": "getCallCenterSettings_0", "nonce": this.Nonce }), this.SfdcOrigin);

                if (window.addEventListener) { var self = this; window.addEventListener("storage", function (e) { self.processLocalStorageEvent(self, e); }, false); }
                else if (window.attachEvent) { var self = this; window.attachEvent("onstorage", function (e) { self.processLocalStorageEvent(self, e); }); }

                if (("onstorage" in document) && (document.attachEvent))
                {
                    this.IE8_IFRAME_HEIGHT_DESKTOP = localStorage.getItem(this.LOCAL_STORAGE_KEY_IFRAME_HEIGHT_DESKTOP);
                    this.IE8_IFRAME_WIDTH_DESKTOP = localStorage.getItem(this.LOCAL_STORAGE_KEY_IFRAME_WIDTH_DESKTOP);
                    this.IE8_IFRAME_HEIGHT = localStorage.getItem(this.LOCAL_STORAGE_KEY_IFRAME_HEIGHT);
                    this.IE8_IFRAME_WIDTH = localStorage.getItem(this.LOCAL_STORAGE_KEY_IFRAME_WIDTH);

                    var self = this;

                    document.attachEvent("onstorage", function (e)
                    {
                        if (!e) { e = window.event; }

                        var iframeHeightDesktop = localStorage.getItem(self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT_DESKTOP);
                        var iframeWidthDesktop = localStorage.getItem(self.LOCAL_STORAGE_KEY_IFRAME_WIDTH_DESKTOP);
                        var iframeHeight = localStorage.getItem(self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT);
                        var iframeWidth = localStorage.getItem(self.LOCAL_STORAGE_KEY_IFRAME_WIDTH);

                        if (iframeHeightDesktop !== null && iframeHeightDesktop !== self.IE8_IFRAME_HEIGHT_DESKTOP)
                        {
                            self.IE8_IFRAME_HEIGHT_DESKTOP = iframeHeightDesktop;
                            e.key = self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT_DESKTOP;
                            e.newValue = iframeHeightDesktop;
                        }
                        else if (iframeWidthDesktop !== null && iframeWidthDesktop !== self.IE8_IFRAME_WIDTH_DESKTOP)
                        {
                            self.IE8_IFRAME_WIDTH_DESKTOP = iframeWidthDesktop;
                            e.key = self.LOCAL_STORAGE_KEY_IFRAME_WIDTH_DESKTOP;
                            e.newValue = iframeWidthDesktop;
                        }
                        else if (iframeHeight !== null && iframeHeight !== self.IE8_IFRAME_HEIGHT)
                        {
                            self.IE8_IFRAME_HEIGHT = iframeHeight;
                            e.key = self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT;
                            e.newValue = iframeHeight;
                        }
                        else if (iframeWidth !== null && iframeWidth !== self.IE8_IFRAME_WIDTH)
                        {
                            self.IE8_IFRAME_WIDTH = iframeWidth;
                            e.key = self.LOCAL_STORAGE_KEY_IFRAME_WIDTH;
                            e.newValue = iframeWidth;
                        }
                        self.processLocalStorageEvent.call(this, self, e);
                    });
                }
            },
            processLocalStorageEvent: function(self, e)
            {
                if (!e) { e = window.event; }

                if (self.InConsole)
                {
                    switch (e.key)
                    {
                        case self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT_DESKTOP:
                            var height = e.newValue.substr(e.newValue.indexOf(":") + 1);
                            if (self.IFRAME_ELEMENT.style.height !== height) { self.IFRAME_ELEMENT.style.height = height; }
                            if (self.AdjustHeight) { window.parent.postMessage(self.INTERACTION_API + self.buildQueryString({ "method": "setSoftphoneHeight_0", "height": self.IFRAME_ELEMENT.style.height, "nonce": self.Nonce }), self.SfdcOrigin); }
                            if (self.AdjustWidth)  { window.parent.postMessage(self.INTERACTION_API + self.buildQueryString({ "method": "setSoftphoneWidth_0", "width": self.IFRAME_ELEMENT.style.width, "nonce": self.Nonce }), self.SfdcOrigin); }
                            break;
                        case self.LOCAL_STORAGE_KEY_IFRAME_WIDTH_DESKTOP:
                            var width = e.newValue.substr(e.newValue.indexOf(":") + 1);
                            if (self.IFRAME_ELEMENT.style.width !== width) { self.IFRAME_ELEMENT.style.width = width; }
                            if (self.AdjustHeight) { window.parent.postMessage(self.INTERACTION_API + self.buildQueryString({ "method": "setSoftphoneHeight_0", "height": self.IFRAME_ELEMENT.style.height, "nonce": self.Nonce }), self.SfdcOrigin); }
                            if (self.AdjustWidth) { window.parent.postMessage(self.INTERACTION_API + self.buildQueryString({ "method": "setSoftphoneWidth_0", "width": self.IFRAME_ELEMENT.style.width, "nonce": self.Nonce }), self.SfdcOrigin); }
                            break;
                   }
                }
                else
                {
                    switch (e.key)
                    {
                        case self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT:
                            var height = e.newValue.substr(e.newValue.indexOf(":") + 1);
                            if (self.IFRAME_ELEMENT.style.height !== height) { self.IFRAME_ELEMENT.style.height = height; }
                            break;
                        case self.LOCAL_STORAGE_KEY_IFRAME_WIDTH:
                            var width = e.newValue.substr(e.newValue.indexOf(":") + 1);
                            if (self.IFRAME_ELEMENT.style.width !== width) { self.IFRAME_ELEMENT.style.width = width; }
                            break;
                    }
                }
            },
            setSoftphoneHeight: function (height)
            {
                window.parent.postMessage(this.buildQueryString({ "method": "setSoftphoneHeight_0", "height": height.toString(), "nonce": this.Nonce }), this.SfdcOrigin);
            },
            setSoftphoneWidth: function (width)
            {
                window.parent.postMessage(this.buildQueryString({ "method": "setSoftphoneWidth_0", "width": width.toString(), "nonce": this.Nonce }), this.SfdcOrigin);
            },
            parseUrlQueryString: function (queryString)
            {
                var params = {};
                if (typeof queryString !== 'string')
                {
                    return params;
                }

                if (queryString.charAt(0) === '?')
                {
                    queryString = queryString.slice(1);
                }

                if (queryString.length === 0)
                {
                    return params;
                }

                var pairs = queryString.split('&');
                for (var i = 0; i < pairs.length; i++)
                {
                    var pair = pairs[i].split('=');
                    params[pair[0]] = !!pair[1] ? decodeURIComponent(pair[1]) : '';
                }
                return params;
            },
            buildQueryString: function (params)
            {
                var qs = "";
                for (var key in params)
                {
                    if (params.hasOwnProperty(key))
                    {
                        qs += key + "=" + encodeURIComponent(params[key]) + "&";
                    }
                }
                qs = qs.length > 0 ? qs.substr(0, qs.length - 1) : qs;
                return qs;
            },
            buildUrl: function (url, queryString)
            {
               // url may have a query string arguments in itself
               var parts = url.split("?");
               if (parts.length == 2)
               {
                   var qs = parts[1];
                   var hashParts = qs.split("#");
                   return parts[0] + "?" + hashParts[0] + "&" + queryString + ((hashParts.length == 2) ? "#" + hashParts[1] : "");
               }
               else
               {
                   return url + "?" + queryString;
               }
            },
            getOriginFromUrl: function (str)
            {
                var re = new RegExp("^((?:f|ht)tp(?:s)?://)([^/]+)", "im");
                var match = str.match(re);
                if (match)
                {
                    return match[1].toString() + match[2].toString().toLowerCase();
                }
                else
                {
                    return str;
                }
            },

            updateState: function (self, e)
            {
                var noResiliency = (self.ICE_URL_A === self.ICE_URL_B);
                var now = new Date().getTime();
                var previousState = self.State;
                if (self.Debug)
                {
                    console.log("ICE.Resiliency.updateState:\n" +
                        "   TIME:        " + now + "\n" +
                        "   State:       " + self.State + "\n" +
                        "   RetryShift:  " + self.RetryShift + "\n" +
                        "   Event:       " + e + "\n" +
                        "   CurrentURL:  " + self.CurrentURL + "\n" +
                        "   Timeout in : " + Math.ceil((self.Timeout - now) / 1000) + " seconds");
                }

                // DO TRANSITIONS

                switch (self.State)
                {
                    case "INITIALIZING":
                        self.RetryShift = 0;
                        self.IFrameOrigin = self.getOriginFromUrl(self.CurrentURL);

                        var iframe = document.createElement('iframe');
                        iframe.id = "ICE_IFRAME";
                        iframe.frameBorder = "0";
                        iframe.allowtransparency = "true";
                        iframe.style.cssText = "position: absolute; top: 0; left: 0; width: 200px; height: 1000px;";
                        iframe.src = self.buildUrl(self.CurrentURL, self.ICEURLQueryString);
                        document.body.appendChild(iframe);

                        self.IFRAME_ELEMENT = document.getElementById('ICE_IFRAME');

                        self.ActionStart = now;
                        self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                        self.State = "DETECTING_INITIAL";
                        break;
                    case "DETECTING_INITIAL":
                        if (e === "HEARTBEAT")
                        {
                            self.ActionStart = now;
                            self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                            localStorage.setItem('InGeniusCTIExtensions.LastGoodConnection', self.CurrentURL);
                            self.State = "CONNECTED";
                        }
                        else if (self.Timeout < now)
                        {
                            self.IFrameOrigin = self.getOriginFromUrl(self.CurrentURL);
                            self.IFRAME_ELEMENT.src = self.buildUrl(self.CurrentURL, self.ICEURLQueryString);
                            self.ActionStart = now;
                            self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                            self.State = "DETECTING";
                        }
                        break;
                    case "DETECTING":
                        if (e === "HEARTBEAT")
                        {
                            self.ActionStart = now;
                            self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                            localStorage.setItem('InGeniusCTIExtensions.LastGoodConnection', self.CurrentURL);
                            self.State = "CONNECTED";
                        }
                        else if (self.Timeout < now)
                        {
                            // No heartbeat detected
                            if (noResiliency || (self.RetryShift > 0))
                            {
                                self.ActionStart = now;
                                self.Timeout = (now + Math.floor(Math.random() * (self.BASE_RETRY_INTERVAL << self.RetryShift) * 1000));  // random delay to within in the back off window
                                self.State = "BACKINGOFF";
                            }
                            else
                            {
                                self.CurrentURL = (self.CurrentURL === self.ICE_URL_A) ? self.ICE_URL_B : self.ICE_URL_A;
                                self.IFrameOrigin = self.getOriginFromUrl(self.CurrentURL);
                                self.IFRAME_ELEMENT.src = self.buildUrl(self.CurrentURL, self.ICEURLQueryString);
                                self.ActionStart = now;
                                self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                                self.State = "DETECTING_ALTERNATE";
                            }
                        }
                        break;
                    case "DETECTING_ALTERNATE":
                        if (e === "HEARTBEAT")
                        {
                            self.ActionStart = now;
                            self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                            localStorage.setItem('InGeniusCTIExtensions.LastGoodConnection', self.CurrentURL);
                            self.State = "CONNECTED";
                        }
                        else if (self.Timeout < now)
                        {
                            self.ActionStart = now;
                            self.Timeout = (now + Math.floor(Math.random() * (self.BASE_RETRY_INTERVAL << self.RetryShift) * 1000));  // random delay to within in the back off window
                            self.State = "BACKINGOFF";
                        }
                        break;
                    case "BACKINGOFF":
                        if (self.Timeout < now)
                        {
                            // Back off delay completed
                            if (self.RetryShift < self.MAX_RETRY_SHIFT) { self.RetryShift++; }
                            self.CurrentURL = (self.CurrentURL === self.ICE_URL_A) ? self.ICE_URL_B : self.ICE_URL_A;
                            self.IFrameOrigin = self.getOriginFromUrl(self.CurrentURL);
                            self.IFRAME_ELEMENT.src = self.buildUrl(self.CurrentURL, self.ICEURLQueryString);
                            self.ActionStart = now;
                            self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                            self.State = "DETECTING";
                        }
                        break;
                    case "CONNECTED":
                        if (e === "HEARTBEAT")
                        {
                            self.ActionStart = now;
                            self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                        }
                        else if (e === "UNLOADING")
                        {
                            self.State = "UNLOADING";
                        }
                        else if ((self.Timeout < now) ||
                                 (e === "UNLOAD") || // for 1.x compatibility
                                 (e === "RELOAD"))
                        {
                            if (e === "TIMER") { console.error("!! ICE heartbeat lost !!"); }
                            // Connection Lost
                            self.RetryShift = 0;
                            self.IFrameOrigin = self.getOriginFromUrl(self.CurrentURL);
                            self.IFRAME_ELEMENT.src = self.buildUrl(self.CurrentURL, self.ICEURLQueryString);
                            self.ActionStart = now;
                            self.Timeout = (now + (self.HEART_BEAT_TIMEOUT * 1000));
                            self.State = "DETECTING";
                        }
                        break;
                    case "UNLOADING":
                        if ((self.ICE_VERSION !== "1") && (e === "HEARTBEAT"))
                        {
                            self.State = "CONNECTED"; // bfcache reload
                        }
                        break;
                    case "ERROR":
                        break;
                }

                // DO UI

                var maxSeconds = Math.ceil((self.Timeout - self.ActionStart) / 1000);
                var secondsToTimeout = Math.ceil((self.Timeout - now) / 1000);

                switch (self.State)
                {
                    case "DETECTING_INITIAL":
                        self.uiSetDisplay(self, "none", "none"); // hide all
                        break;

                    case "DETECTING":
                    case "DETECTING_ALTERNATE":
                        self.PROGRESS_DIV.title = "Waited " + (maxSeconds - secondsToTimeout) + " of " + maxSeconds + " second" + (maxSeconds === 1 ? "" : "s");
                        if (self.State != previousState)
                        {
                            var retryMessage = (noResiliency) ? "Trying to connect..." : "Trying server {0}...";
                            self.uiSetProgressSlider(self, 0, 0); // reset back to 0 width
                            setTimeout(function () { self.uiSetProgressSlider(self, 100, maxSeconds) }, 0); // slide to 100% width during maxSeconds time interval
                            self.MESSAGE_DIV.className = self.CLASS_WARNING;
                            self.MESSAGE_TEXT.innerHTML = retryMessage.replace("{0}", (self.CurrentURL === self.ICE_URL_A) ? "A" : "B");
                            self.uiSetDisplay(self, "block", "none"); // show msg
                            self.setSoftphoneHeight(100);
                            self.setSoftphoneWidth(200);
                        }
                        break;

                    case "BACKINGOFF":
                        self.PROGRESS_DIV.title = "Waited " + (maxSeconds - secondsToTimeout) + " of " + maxSeconds + " second" + (maxSeconds === 1 ? "" : "s");
                        if (self.State != previousState)
                        {
                            var failedMessage = (noResiliency) ?
                                "Failed to connect to server.<br/>Waiting to retry..." :
                                "Failed to connect to server {0}.<br/>Waiting to retry...";
                            self.uiSetProgressSlider(self, 0, 0); // reset back to 0 width
                            setTimeout(function () { self.uiSetProgressSlider(self, 100, maxSeconds) }, 0); // slide to 100% width during maxSeconds time interval
                            self.MESSAGE_DIV.className = self.CLASS_ERROR;
                            self.MESSAGE_TEXT.innerHTML = failedMessage
                                .replace("{0}", (self.CurrentURL === self.ICE_URL_A) ? "A" : "B")
                                .replace("{1}", (self.CurrentURL != self.ICE_URL_A) ? "A" : "B");
                            self.uiSetDisplay(self, "block", "none"); // show msg
                            self.setSoftphoneHeight(100);
                            self.setSoftphoneWidth(200);
                        }
                        break;

                    case "CONNECTED":
                        var successMessage = (noResiliency) ?
                                "Connected to the server<br/>Next heartbeat in: {1} seconds" :
                                "Connected to server {0}<br/>Next heartbeat in: {1} seconds";
                        self.MESSAGE_TEXT.innerHTML = successMessage
                            .replace("{0}", (self.CurrentURL === self.ICE_URL_A) ? "A" : "B")
                            .replace("{1}", secondsToTimeout);
                        if (self.State != previousState)
                        {
                            self.uiSetDisplay(self, "none", "block"); // show iframe
                        }
                        break;

                    case "UNLOADING":
                        if (self.Debug && self.State != previousState)
                        {
                            self.uiSetProgressSlider(self, 0, 0); // reset back to 0 width
                            setTimeout(function () { self.uiSetProgressSlider(self, 100, 2) }, 0); // slide to 100% width during 2 second time interval
                            self.MESSAGE_DIV.className = self.CLASS_WARNING;
                            self.MESSAGE_TEXT.innerHTML = "Unloading ..."
                            self.uiSetDisplay(self, "block", "none"); // show msg
                            // DO NOT SET SIZE HERE
                        }
                        break;
                    case "ERROR":
                        if (self.State != previousState)
                        {
                            self.MESSAGE_DIV.className = self.CLASS_ERROR;
                            self.MESSAGE_TEXT.innerHTML = "Error: Open CTI API not responding";
                            self.MESSAGE_TEXT.title = self.OpenCTI_ERROR;
                            self.uiSetDisplay(self, "block", "none"); // show msg
                            self.PROGRESS_DIV.style.display = "none";
                            self.setSoftphoneHeight(100);
                            self.setSoftphoneWidth(200);
                        }
                        break;
                }

                if (e === "TIMER" && self.State !== "UNLOADING")
                {
                    setTimeout(function () { self.updateState(self, "TIMER") }, 1000);
                }
            },

            uiSetProgressSlider: function (self, width, seconds)
            {
                for (var p in { "-webkit-transition-duration": 0, "-moz-transition-duration": 0, "-ms-transition-duration": 0, "-o-transition-duration": 0, "transition-duration": 0 })
                {
                    self.SLIDER.style[p] = seconds + "s";
                }
                if (self.SLIDER.filters) // IE
                {
                    self.SLIDER.style.filter = "progid:DXImageTransform.Microsoft.Stretch(bands='1',stretchStyle='hide',duration=" + seconds + ")";
                    self.SLIDER.style.width = "0";
                    self.SLIDER.filters[0].Apply();
                }
                self.SLIDER.style.width = width + "%";
                if (self.SLIDER.filters) // IE
                {
                    self.SLIDER.filters[0].Play();
                }
            },

            uiSetDisplay: function (self, messageDisplay, iFrameDisplay)
            {
                self.PROGRESS_DIV.style.display = messageDisplay;
                self.MESSAGE_DIV.style.display = messageDisplay;
                self.IFRAME_ELEMENT.style.display = iFrameDisplay;
            },

            processPostMessage: function (self, e)
            {
                if (!e) { e = window.event; }

                if (self.Debug)
                {
                    console.log("ICE.Resiliency.processPostMessage:\n   e.data: " + e.data + "\n   e.origin: " + e.origin + "; ");
                }
                if (e.origin.toLowerCase() == self.SfdcOrigin.toLowerCase())
                {
                    if (self.State === "CONNECTED")
                    {
                        self.IFRAME_ELEMENT.contentWindow.postMessage(e.data, self.IFrameOrigin);
                    }
                    else if (self.State === "INITIALIZING")
                    {
                        if (e.data.indexOf(self.INTERACTION_API) === 0)
                        {
                            var params = self.parseUrlQueryString(e.data.replace(self.INTERACTION_API, ""));
                            if ((params.method) && (params.method == "isInConsole_0"))
                            {
                                self.Await.inConsole = false;
                                if (params.result)
                                {
                                    self.InConsole = (params.result === 'true');
                                    console.log("ICE.Resiliency.CTIExtensions.isInConsole: " + self.InConsole);
                                }
                                else
                                {
                                    console.log("ICE.Resiliency.CTIExtensions.isInConsole ERROR:\n    " + params.error);
                                    if (self.State !== "ERROR") { self.OpenCTI_ERROR = "isInConsole: " + params.error; }
                                    self.State = "ERROR";
                                    self.updateState(self, "TIMER"); // all data arrived, fake timer to start state machine
                                }
                            }
                            else if ((params.method) && (params.method == "runApex_0"))
                            {
                                self.Await.getSessionInfo = false;
                                if (params.result)
                                {
                                    var data = JSON.parse(params.result);
                                    console.log("ICE.Resiliency.CTIExtensions.SessionInfo:\n" +
                                        "   VERSION:       " + data.Version + "\n" +
                                        "   ORG ID:        " + data.OrgID + "\n" +
                                        "   ORG NAME:      " + data.OrgName + "\n" +
                                        "   USER ID:       " + data.UserID + "\n" +
                                        "   USER NAME:     " + data.UserName + "\n" +
                                        "   USER LOCALE:   " + data.UserLocale + "\n" +
                                        "   USER LANGUAGE: " + data.UserLanguage + "\n" +
                                        "   SESSION ID:    " + data.SessionID);
                                }
                                else
                                {
                                    console.log("ICE.Resiliency.CTIExtensions.SessionInfo ERROR:\n    " + params.error);
                                    if (self.State !== "ERROR") { self.OpenCTI_ERROR = "SessionInfo: " + params.error; }
                                    self.State = "ERROR";
                                    self.updateState(self, "TIMER"); // all data arrived, fake timer to start state machine
                                }
                            }
                            else if ((params.method) && (params.method == "getCallCenterSettings_0"))
                            {
                                self.Await.getCallCenterSettings = false;
                                if (params.result)
                                {
                                    var data = JSON.parse(params.result);
                                    if (data["/profileConfiguration/profileName"])
                                    {
                                        var parts = data["/profileConfiguration/profileName"].split("|");
                                        self.CALL_CENTER_PROFILE = parts[0];
                                        if (parts.length == 2)
                                        {
                                            self.Debug = true;
                                            self.LogLevel = parts[1];
                                        }
                                    }

                                    if (data["/availabilityConfiguration/ipRegex"])
                                    {
                                        if (data["/availabilityConfiguration/ipRegex"].replace(/^\s+/, "").replace(/\s+$/, "").length != 0)
                                        {
                                            self.IP_REGEX_PATTERN = data["/availabilityConfiguration/ipRegex"];
                                        }
                                    }

                                    if (data["/resiliencyConfiguration/iceVersion"])
                                    {
                                        self.ICE_VERSION = data["/resiliencyConfiguration/iceVersion"];
                                    }
                                    if (data["/resiliencyConfiguration/resiliencyIceUrlA"])
                                    {
                                        self.ICE_URL_A = data["/resiliencyConfiguration/resiliencyIceUrlA"];
                                        self.ICE_URL_B = data["/resiliencyConfiguration/resiliencyIceUrlA"];
                                    }
                                    if (data["/resiliencyConfiguration/resiliencyIceUrlB"])
                                    {
                                        self.ICE_URL_B = data["/resiliencyConfiguration/resiliencyIceUrlB"];
                                    }
                                    if (data["/resiliencyConfiguration/resiliencyHeartbeatTimeout"])
                                    {
                                        var resiliencyHeartbeatTimeout = parseInt(data["/resiliencyConfiguration/resiliencyHeartbeatTimeout"]);
                                        if (isFinite(resiliencyHeartbeatTimeout)) { self.HEART_BEAT_TIMEOUT = resiliencyHeartbeatTimeout; }
                                    }
                                    if (data["/resiliencyConfiguration/resiliencyBaseRetryInterval"])
                                    {
                                        var resiliencyBaseRetryInterval = parseInt(data["/resiliencyConfiguration/resiliencyBaseRetryInterval"]);
                                        if (isFinite(resiliencyBaseRetryInterval)) { self.BASE_RETRY_INTERVAL = resiliencyBaseRetryInterval; }
                                    }
                                    if (data["/resiliencyConfiguration/resiliencyMaxRetryShift"])
                                    {
                                        var resiliencyMaxRetryShift = parseInt(data["/resiliencyConfiguration/resiliencyMaxRetryShift"]);
                                        if (isFinite(resiliencyMaxRetryShift)) { self.MAX_RETRY_SHIFT = resiliencyMaxRetryShift; }
                                    }
                                    console.log("ICE.Resiliency.Settings:\n" +
                                            "   ICE_VERSION:          " + self.ICE_VERSION + "\n" +
                                            "   CALL_CENTER_PROFILE:  " + self.CALL_CENTER_PROFILE + "\n" +
                                            "   IP_REGEX_PATTERN:     " + self.IP_REGEX_PATTERN + "\n" +
                                            "   ICE_URL_A :           " + self.ICE_URL_A + "\n" +
                                            "   ICE_URL_B :           " + self.ICE_URL_B + "\n" +
                                            "   HEART_BEAT_TIMEOUT :  " + self.HEART_BEAT_TIMEOUT + "\n" +
                                            "   BASE_RETRY_INTERVAL : " + self.BASE_RETRY_INTERVAL + "\n" +
                                            "   MAX_RETRY_SHIFT :     " + self.MAX_RETRY_SHIFT + "\n" +
                                            "   DEBUG :               " + self.Debug + "\n" +
                                            "   LOG_LEVEL :           " + self.LogLevel);
                                    self.CurrentURL = self.ICE_URL_A;

                                    if (localStorage.getItem('InGeniusCTIExtensions.LastGoodConnection'))
                                    {
                                        if (localStorage.getItem('InGeniusCTIExtensions.LastGoodConnection') == self.ICE_URL_B)
                                        {
                                            self.CurrentURL = self.ICE_URL_B;
                                        }
                                    }

                                    console.log("ICE.Resiliency.Settings:\n   CurrentURL : " + self.CurrentURL);

                                    try
                                    {
                                        var ip_regex = new RegExp(self.IP_REGEX_PATTERN, "i");
                                        if (!ip_regex.test(self.ClientIP))
                                        {
                                            self.MESSAGE_TEXT.innerHTML = "CTI not available at this location";
                                            self.MESSAGE_DIV.className = self.CLASS_NORMAL;
                                            self.PROGRESS_DIV.style.display = "none";
                                            self.MESSAGE_DIV.style.display = "block";
                                            self.setSoftphoneHeight(50);
                                            self.setSoftphoneWidth(200);
                                            return;
                                        }
                                    }
                                    catch (err)
                                    {
                                        console.warn("ICE.IP_REGEX_PATTERN is invalid. Trying to load CTI integration.");
                                    }

                                    var heartbeatInterval = Math.floor(self.HEART_BEAT_TIMEOUT * 0.7);
                                    console.log("ICE.Resiliency.HeartBeatInterval set to 70% of HEART_BEAT_TIMEOUT (" + heartbeatInterval + ")");
                                    self.ICEURLQueryString = self.buildQueryString({ "resiliency": heartbeatInterval, "inConsole": self.InConsole, "config": self.CALL_CENTER_PROFILE, "sfdcIFrameOrigin": self.getOriginFromUrl(window.location.href), "nonce": self.Nonce, "debug": self.Debug.toString(), "loglevel": self.LogLevel, "apexNamespace": self.ApexNamespace, "apexClass" : self.ApexClass });
                                }
                                else 
                                {
                                    console.log("ICE.Resiliency.getCallCenterSettings ERROR:\n    " + params.error);
                                    if (self.State !== "ERROR") { self.OpenCTI_ERROR = "getCallCenterSettings: " + params.error; }
                                    self.State = "ERROR";
                                    self.updateState(self, "TIMER"); // all data arrived, fake timer to start state machine
                                }
                            }
                            if (!self.Await.inConsole && !self.Await.getSessionInfo && !self.Await.getCallCenterSettings)
                            {
                                self.updateState(self, "TIMER"); // all data arrived, fake timer to start state machine
                            }
                        }
                    }
                }
                else if (e.origin.toLowerCase() == self.IFrameOrigin.toLowerCase())
                {
                    var eventData = e.data;

                    if (e.data.indexOf(self.INTERACTION_API) === 0)
                    {
                        if (self.ICE_VERSION === "1") { self.updateState(self, "HEARTBEAT"); }

                        var params = self.parseUrlQueryString(e.data.replace(self.INTERACTION_API, ""));
                        if (params && params["method"] && (params["method"].indexOf("setSoftphoneHeight") === 0))
                        {
                            if (params["height"])
                            {
                                var h = parseInt(params["height"], 10);
                                if (isFinite(h))
                                {
                                    self.IFRAME_ELEMENT.style.height = h.toString() + "px";
                                    if (self.InConsole)
                                    {
                                        localStorage.setItem(self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT_DESKTOP, new Date().getTime() + ":" + h.toString() + "px");
                                    }
                                    else
                                    {
                                        localStorage.setItem(self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT, new Date().getTime() + ":" + h.toString() + "px");
                                    }
                                    params["height"] = (h).toString();   // adjust height here to account for additional visible elements
                                    eventData = self.INTERACTION_API + self.buildQueryString(params);
                                }
                            }
                        }
                        else if (params && params["method"] && (params["method"].indexOf("setSoftphoneWidth") === 0))
                        {
                            if (params["width"])
                            {
                                var w = parseInt(params["width"], 10);
                                if (isFinite(w))
                                {
                                    self.IFRAME_ELEMENT.style.width = w.toString() + "px";
                                    if (self.InConsole)
                                    {
                                        localStorage.setItem(self.LOCAL_STORAGE_KEY_IFRAME_WIDTH_DESKTOP, new Date().getTime() + ":" + w.toString() + "px");
                                    }
                                    else
                                    {
                                        localStorage.setItem(self.LOCAL_STORAGE_KEY_IFRAME_WIDTH, new Date().getTime() + ":" + w.toString() + "px");
                                    }
                                    params["width"] = (w).toString();   // adjust height here to account for additional visible elements
                                    eventData = self.INTERACTION_API + self.buildQueryString(params);
                                }
                            }
                        }
                        window.parent.postMessage(eventData, self.SfdcOrigin);
                    }
                    else
                    {
                        var params = self.parseUrlQueryString(eventData);

                        if (params)
                        {
                            if (params["ICE"] && (params["ICE"].indexOf("Unloading") === 0))
                            {
                                self.updateState(self, "UNLOADING");
                            }
                            else if (params["ICE"] && (params["ICE"].indexOf("Reload") === 0))
                            {
                                self.updateState(self, "RELOAD");
                            }
                            else if (params["ICE"] && (params["ICE"].indexOf("Heartbeat") === 0))
                            {
                                self.updateState(self, "HEARTBEAT");
                            }
                            else if (self.ICE_VERSION === "1")
                            {
                                self.updateState(self, "HEARTBEAT");
                            }

                            if (!params["ICE"])
                            {
                                if (params && params["method"] && (params["method"].indexOf("setSoftphoneHeight") === 0))
                                {
                                    if (params["height"])
                                    {
                                        var h = parseInt(params["height"], 10);
                                        if (isFinite(h))
                                        {
                                            self.IFRAME_ELEMENT.style.height = h.toString() + "px";
                                            if (self.InConsole)
                                            {
                                                localStorage.setItem(self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT_DESKTOP, new Date().getTime() + ":" + h.toString() + "px");
                                            }
                                            else
                                            {
                                                localStorage.setItem(self.LOCAL_STORAGE_KEY_IFRAME_HEIGHT, new Date().getTime() + ":" + h.toString() + "px");
                                            }
                                            params["height"] = (h).toString();   // adjust height here to account for additional visible elements
                                            eventData = self.buildQueryString(params);
                                        }
                                    }
                                }
                                else if (params && params["method"] && (params["method"].indexOf("setSoftphoneWidth") === 0))
                                {
                                    if (params["width"])
                                    {
                                        var w = parseInt(params["width"], 10);
                                        if (isFinite(w))
                                        {
                                            self.IFRAME_ELEMENT.style.width = w.toString() + "px";
                                            if (self.InConsole)
                                            {
                                                localStorage.setItem(self.LOCAL_STORAGE_KEY_IFRAME_WIDTH_DESKTOP, new Date().getTime() + ":" + w.toString() + "px");
                                            }
                                            else
                                            {
                                                localStorage.setItem(self.LOCAL_STORAGE_KEY_IFRAME_WIDTH, new Date().getTime() + ":" + w.toString() + "px");
                                            }
                                            params["width"] = (w).toString();   // adjust width here to account for additional visible elements
                                            eventData = self.buildQueryString(params);
                                        }
                                    }
                                }
                                window.parent.postMessage(eventData, self.SfdcOrigin);
                            }
                        }
                    }
                }
            }
        };

        window.onload = function ()
        {
            InGeniusCTIExtensions.intitialize();
        };

    </script>
    <style type='text/css'>
        * {
            -moz-box-sizing: border-box;
            -webkit-box-sizing: border-box;
            box-sizing: border-box;
        }
        body {
            overflow: hidden;
            font-family: Arial, Helvetica, sans-serif;
            font-size: 75%;
        }
        .boxRound {
            -webkit-border-radius: 7px;
            border-radius: 7px;
            -webkit-background-clip: padding-box;
            -moz-background-clip: padding;
            background-clip: padding-box;
        }
        .bgrd {
            position: absolute;
            top: 0;
            left: 0;
            padding: 10px 10px 10px 10px;
            height: 100%;
            width: 100%;
            z-index: 0;
            width: 200px;
        }
        .normalBgrd, .warningBgrd, .errorBgrd {
            background-color: #cfeef8;
            color: #214b76;
        }
        .warningBgrd {
            /*background-color: #f5b77e; #ef8d34;*/
        }
        .errorBgrd {
            /*background-color: #c76363;*/
            /*color: #a33a3a;*/
            padding: 10px;
            text-indent: 0px;
        }
        #MESSAGE {
            position: absolute;
            z-index: 1;
            text-align: center;
        }
        #MESSAGE_TEXT { display: block; padding-top: 7px; }
        .meter { 
            width:100px;
            height: 8px;
            position:relative;
            margin: 15px 0 0 40px;
            background: #add2f8;
            border: solid 1px #78b5f2;
            -webkit-border-radius: 5px;
               -moz-border-radius: 5px;
                    border-radius: 5px;
            padding: 0;
            -webkit-box-shadow: inset 0 -1px 1px rgba(255,255,255,0.3);
               -moz-box-shadow: inset 0 -1px 1px rgba(255,255,255,0.3);
                    box-shadow: inset 0 -1px 1px rgba(255,255,255,0.3);
        }
        .meter > span {
            display: block;
            height: 100%;
            width: 0;
            position: relative;
            overflow: hidden;
            -webkit-border-radius: 5px;
               -moz-border-radius: 5px;
                    border-radius: 5px;
               -webkit-border-top-right-radius: 3px;
                   -moz-border-radius-topright: 3px;
                       border-top-right-radius: 3px;
            -webkit-border-bottom-right-radius: 3px;
                -moz-border-radius-bottomright: 3px;
                    border-bottom-right-radius: 3px;
            background-color: #0482ff;
            background-image: -webkit-gradient(linear, left top, left bottom, from(#359aff), to(#0482ff));
            background-image: -webkit-linear-gradient(top, #359aff, #0482ff);
            background-image:    -moz-linear-gradient(top, #359aff, #0482ff);
            background-image:     -ms-linear-gradient(top, #359aff, #0482ff);
            background-image:      -o-linear-gradient(top, #359aff, #0482ff);
            background-image:         linear-gradient(to bottom, #359aff, #0482ff);
            -webkit-box-shadow: inset 0 2px 9px  rgba(255,255,255,0.3), inset 0 -2px 6px rgba(0,0,0,0.4);
               -moz-box-shadow: inset 0 2px 9px  rgba(255,255,255,0.3), inset 0 -2px 6px rgba(0,0,0,0.4);
                    box-shadow: inset 0 2px 9px  rgba(255,255,255,0.3), inset 0 -2px 6px rgba(0,0,0,0.4);
            -webkit-transition: 0.5s ease-out;
               -moz-transition: 0.5s ease-out;
                -ms-transition: 0.5s ease-out;
                 -o-transition: 0.5s ease-out;
                    transition: 0.5s ease-out;
            filter: progid:DXImageTransform.Microsoft.Stretch(bands='1',stretchStyle='hide',duration=1);
        }
        .meter > span:after, .animate > span > span {
            content: "";
            position: absolute;
            top: 0; left: 0; bottom: 0; right: 0;
            overflow: hidden;
            background-image: 
               -webkit-gradient(linear, 0 0, 100% 100%, 
                  color-stop(.25, rgba(255, 255, 255, .3)), 
                  color-stop(.25, transparent), color-stop(.5, transparent), 
                  color-stop(.5,  rgba(255, 255, 255, .3)), 
                  color-stop(.75, rgba(255, 255, 255, .3)), 
                  color-stop(.75, transparent), to(transparent)
               );
            background-image: 
                -moz-linear-gradient(
                  -45deg, 
                  rgba(255, 255, 255, .3) 25%, 
                  transparent 25%, 
                  transparent 50%, 
                  rgba(255, 255, 255, .3) 50%, 
                  rgba(255, 255, 255, .3) 75%, 
                  transparent 75%, 
                  transparent
               );
            background-image: 
                -o-linear-gradient(
                  -45deg, 
                  rgba(255, 255, 255, .3) 25%, 
                  transparent 25%, 
                  transparent 50%, 
                  rgba(255, 255, 255, .3) 50%, 
                  rgba(255, 255, 255, .3) 75%, 
                  transparent 75%, 
                  transparent
               );
            -webkit-background-size: 30px 30px;
                -ms-background-size: 30px 30px;
                 -o-background-size: 30px 30px;
                    background-size: 30px 30px;
            -webkit-animation: moveFrames 2s linear infinite;
               -moz-animation: moveFrames 2s linear infinite;
                -ms-animation: moveFrames 2s linear infinite;
                 -o-animation: moveFrames 2s linear infinite;
            -webkit-border-radius: 5px;
               -moz-border-radius: 5px;
                    border-radius: 5px;
               -webkit-border-top-right-radius: 3px;
                   -moz-border-radius-topright: 3px;
                       border-top-right-radius: 3px;
            -webkit-border-bottom-right-radius: 3px;
                -moz-border-radius-bottomright: 3px;
                    border-bottom-right-radius: 3px;
        }
        .animate > span:after { display: none; }
        @-webkit-keyframes moveFrames {
            0% { background-position: 0 0; }
            100% { background-position: 30px 30px; }
        }
        @-moz-keyframes moveFrames {
            0% { background-position: 0 0; }
            100% { background-position: 30px 30px; }
        }
        @-ms-keyframes moveFrames {
            0% { background-position: 0 0; }
            100% { background-position: 30px 30px; }
        }
        @-o-keyframes moveFrames {
            0% { background-position: 0 0; }
            100% { background-position: 30px 30px; }
        }
    </style>
</head>
<body>
    <div id="MESSAGE" class="bgrd normalBgrd boxRound" style="display: none">
        <div id="PROGRESS" class="meter animate"><span id="SLIDER"><span></span></span></div>
        <span id="MESSAGE_TEXT">Fetching call center settings...</span>
    </div>
</body>
</html>
