/*********************************************************************
*
* Name: user.js | brainfucksec
* Descr.: Mozilla Firefox configuration file: `user.js`
* Version: 0.24.3
* Date: 2025-08-17
* URL: https://gist.github.com/brainfucksec/68e79da1c965aeaa4782914afd8f7fa2
* Maintainer: brainf+ck
*
* Info:
* Set preferences for the selected profile when Firefox start.
* Copy this file on Firefox Profile folder.  You should create a new profile
* to be used with this file.
*
* See:
* Create, remove or switch Firefox profiles:
* https://support.mozilla.org/en-US/kb/profile-manager-create-remove-switch-firefox-profiles?redirectslug=profile-manager-create-and-remove-firefox-profiles&redirectlocale=en-US
*
* Back up and restore information in Firefox profiles:
* https://support.mozilla.org/en-US/kb/back-and-restore-information-firefox-profiles
*
* For more information how to use this file see:
* https://kb.mozillazine.org/User.js_file
* https://github.com/arkenfox/user.js/wiki/1.1-Overview
*
* For "about:config" entries see:
* https://searchfox.org/mozilla-release/source/modules/libpref/init/all.js
*
* Thanks to:
* arkenfox/user.js: https://github.com/arkenfox/user.js
* LibreWolf: https://librewolf.net/
*
**********************************************************************/

/*********************************************************************
 *
 * Variable format:
 *   user_pref("<entry>", <boolean> || <number> || "<string>");
 *
 * Keywords used in comments:
 *   - [Windows], [Linux], [macOS]  - The option is valid only for the indicated operating system.
 *   - [Non-Windows]                - The option is valid for all operating systems other than Windows
 *   - [HIDDEN PREF]                - Option that must be enabled in order to change its default value or to be used.
 *
 * NOTE: Settings with default values, like `[Default: false]`, are not present (with some exceptions for clarity).
 *
 * INDEX:
 *   - STARTUP SETTINGS
 *   - GEOLOCATION
 *   - LANGUAGE / LOCALE
 *   - RECOMMENDATIONS
 *   - TELEMETRY
 *   - STUDIES
 *   - CRASH REPORTS
 *   - CAPTIVE PORTAL DETECTION / NETWORK CHECKS
 *   - SAFE BROWSING
 *   - NETWORK: DNS, PROXY, NETWORK CHECKS
 *   - SEARCH BAR: SUGGESTIONS, AUTOFILL, FORMS
 *   - PASSWORDS
 *   - DISK CACHE / MEMORY
 *   - HTTPS / SSL/TLS / OSCP / CERTS
 *   - HEADERS / REFERERS
 *   - AUDIO/VIDEO: WEBRTC, WEBGL
 *   - DOWNLOADS
 *   - COOKIES
 *   - UI FEATURES
 *   - EXTENSIONS
 *   - SHUTDOWN SETTINGS & SANITIZING
 *   - FINGERPRINTING (RFP)
 *
 *********************************************************************/

/*********************************************************************
 * STARTUP SETTINGS
 *********************************************************************/

// Disable about:config warning
user_pref("browser.aboutConfig.showWarning", false);

// Disable default browser check
//user_pref("browser.shell.checkDefaultBrowser", false);

/* Set startup home page:
 * 0 = blank
 * 1 = home
 * 2 = last visited page
 * 3 = resume previous session */
user_pref("browser.startup.page",  1);

/* Set Home + New Window page:
 * about:home = Firefox Home (default)
 * about:blank = custom URL */
user_pref("browser.startup.homepage", "about:home");

/* Set NEWTAB page:
 * true = Firefox Home (default), false = blank page */
user_pref("browser.newtabpage.enabled", false);

// Disable sponsored content on Firefox Home (Activity Stream)
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// Sponsored shortcuts: clear default topsites
user_pref("browser.newtabpage.activity-stream.default.sites", "");

/*********************************************************************
 * GEOLOCATION
 *********************************************************************/

// Disable using the OS’s geolocation service
// user_pref("geo.provider.ms-windows-location", false); // [Windows]
// user_pref("geo.provider.use_corelocation", false);    // [macOS]
user_pref("geo.provider.use_geoclue", false);         // [Linux]

/*********************************************************************
 * LANGUAGE / LOCALE
 *********************************************************************/

// Set language for displaying web pages:
user_pref("intl.accept_languages", "en-US, en");
user_pref("javascript.use_us_english_locale", true); // [HIDDEN PREF]

/*********************************************************************
 * RECOMMENDATIONS
 *********************************************************************/

// Disable recommendation pane in about:addons (use Google Analytics)
user_pref("extensions.getAddons.showPane", false); // [HIDDEN PREF]

// Disable recommendations in about:addons Extensions and Themes panes
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);

// Disable personalized Extension Recommendations in about:addons
user_pref("browser.discovery.enabled", false);

/*********************************************************************
 * TELEMETRY
 *********************************************************************/

// Disable Firefox Home (Activity Stream) telemetry
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);

// Disable new data submission
user_pref("datareporting.policy.dataSubmissionEnabled", false);

// Disable Health Reports
user_pref("datareporting.healthreport.uploadEnabled", false);

// Disable telemetry
user_pref("toolkit.telemetry.enabled", false); // [Default: false]
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false); // bhr = Background Hang Reporter
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true); // [HIDDEN PREF]
user_pref("toolkit.coverage.opt-out", true); // [HIDDEN PREF]
user_pref("toolkit.coverage.endpoint.base", "");

/*********************************************************************
 * STUDIES
 *********************************************************************/

// Disable studies
user_pref("app.shield.optoutstudies.enabled", false);

// Disable normandy/shield (telemetry system), https://mozilla.github.io/normandy/
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");

/*********************************************************************
 * CRASH REPORTS
 *********************************************************************/

// Disable crash reports
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);

/*********************************************************************
 * SAFE BROWSING
 *********************************************************************/

// // Disable safe browsing service
// user_pref("browser.safebrowsing.malware.enabled", false);
// user_pref("browser.safebrowsing.phishing.enabled", false);
//
// // Disable list of blocked URI
// user_pref("browser.safebrowsing.blockedURIs.enabled", false);
//
// // Disable fetch of updates
// user_pref("browser.safebrowsing.provider.google4.gethashURL", "");
// user_pref("browser.safebrowsing.provider.google4.updateURL", "");
// user_pref("browser.safebrowsing.provider.google.gethashURL", "");
// user_pref("browser.safebrowsing.provider.google.updateURL", "");
// user_pref("browser.safebrowsing.provider.google4.dataSharingURL", "");
//
// // Disable checks for downloads
// user_pref("browser.safebrowsing.downloads.enabled", false);
// user_pref("browser.safebrowsing.downloads.remote.enabled", false);
// user_pref("browser.safebrowsing.downloads.remote.url", "");
//
// // Disable checks for unwanted software
// user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
// user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);
//
// // Disable bypasses the block of safe browsing with a click for current session
// user_pref("browser.safebrowsing.allowOverride", false);

/*********************************************************************
 * NETWORK: DNS, PROXY, NETWORK CHECKS
 *********************************************************************/

// Disable link prefetching
user_pref("network.prefetch-next", false);

// Disable DNS prefetching
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);

// Disable predictor
user_pref("network.predictor.enabled", false);

// Disable link-mouseover opening connection to linked server
user_pref("network.http.speculative-parallel-limit", 0);

// Disable mousedown speculative connections on bookmarks and history
user_pref("browser.places.speculativeConnect.enabled", false);

/* Disable "GIO" protocols as a potential proxy bypass vectors
 * https://en.wikipedia.org/wiki/GVfs
 * https://en.wikipedia.org/wiki/GIO_(software) */
user_pref("network.gio.supported-protocols", ""); // [HIDDEN PREF]

// Disable using UNC (Uniform Naming Convention) paths (prevent proxy bypass)
user_pref("network.file.disable_unc_paths", true); // [HIDDEN PREF]

// Remove special permissions for certain mozilla domains
user_pref("permissions.manager.defaultsUrl", "");

// Use Punycode in Internationalized Domain Names to eliminate possible spoofing
user_pref("network.IDN_show_punycode", true);

// Disable captive portal detection
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false);

// Disable network connections checks
user_pref("network.connectivity-service.enabled", false);

/*********************************************************************
 * SEARCH BAR: SUGGESTIONS, AUTOFILL, FORMS
 *********************************************************************/

// Disable location bar making speculative connections
user_pref("browser.urlbar.speculativeConnect.enabled", false);

// Disable location bar contextual suggestions
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);

// Disable live search suggestions
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);

// Disable urlbar trending search suggestions
user_pref("browser.urlbar.trending.featureGate", false);

// Disable urlbar suggestions
user_pref("browser.urlbar.addons.featureGate", false);
user_pref("browser.urlbar.mdn.featureGate", false); // [HIDDEN PREF]
user_pref("browser.urlbar.yelp.featureGate", false);

// Disable search and form history
user_pref("browser.formfill.enable", false);

// Disable Form Autofill
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

/*********************************************************************
 * PASSWORDS
 *********************************************************************/

// Disable saving passwords
user_pref("signon.rememberSignons", false);

// Disable autofill login and passwords
user_pref("signon.autofillForms", false);

// Disable formless login capture for Password Manager
user_pref("signon.formlessCapture.enabled", false);

/* Hardens against potential credentials phishing:
 * 0 = don't allow sub-resources to open HTTP authentication credentials dialogs
 * 1 = don't allow cross-origin sub-resources to open HTTP authentication credentials dialogs
 * 2 = allow sub-resources to open HTTP authentication credentials dialogs (default) */
user_pref("network.auth.subresource-http-auth-allow", 1);

/*********************************************************************
 * DISK CACHE / MEMORY
 *********************************************************************/

// Disable disk cache
user_pref("browser.cache.disk.enable", false);

// Disable media cache from writing to disk in Private Browsing
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);
user_pref("media.memory_cache_max_size", 65536);

/* Disable storing extra session data (cookies, POST data, etc.):
 * 0 = everywhere
 * 1 = unencrypted sites
 * 2 = nowhere */
user_pref("browser.sessionstore.privacy_level", 2);

// Disable resuming session from crash
user_pref("browser.sessionstore.resume_from_crash", false);

// Disable automatic Firefox start and session restore after reboot [Windows]
user_pref("toolkit.winRegisterApplicationRestart", false);

// Disable favicons in shortcuts [Windows]
user_pref("browser.shell.shortcutFavicons", false);

// Disable page thumbnail collection
user_pref("browser.pagethumbnails.capturing_disabled", true); // [HIDDEN PREF]

// Delete temporary files opened from non-Private Browsing windows with external apps
// user_pref("browser.download.start_downloads_in_tmp_dir", true);
// user_pref("browser.helperApps.deleteTempFileOnExit", true);

/*********************************************************************
 * HTTPS (SSL/TLS, OSC, CERTS)
 *********************************************************************/

// Disable TLS 1.3 0-RTT (round-trip time)
user_pref("security.tls.enable_0rtt_data", false);

// Set OCSP to terminate the connection when a CA isn't validate
user_pref("security.OCSP.require", true);

// Display advanced information on Insecure Connection warning pages
user_pref("browser.xul.error_pages.expert_bad_cert", true);

/* HPKP (HTTP Public Key Pinning) Enable strict PKP (Public Key Pinning):
 * 0 = disabled
 * 1 = allow user MiTM (i.e. your Antivirus)
 * 2 = strict */
user_pref("security.cert_pinning.enforcement_level", 2);

/* Enable CRLite
 * 0 = disabled
 * 1 = consult CRLite but only collect telemetry
 * 2 = consult CRLite and enforce both "Revoked" and "Not Revoked" results
 * 3 = consult CRLite and enforce "Not Revoked" results, but defer to OCSP for "Revoked" (default) */
user_pref("security.remote_settings.crlite_filters.enabled", true);
user_pref("security.pki.crlite_mode", 2);

// Enable HTTPS-Only mode in all windows
user_pref("dom.security.https_only_mode", true);

// Disable sending HTTP request for checking HTTPS support by the server
user_pref("dom.security.https_only_mode_send_http_background_request", false);

/*********************************************************************
 * HEADERS / REFERERS
 *********************************************************************/

/* Control the amount of information to send:
 * 0 = send full URI (default):  https://example.com:8888/foo/bar.html?id=1234
 * 1 = scheme+host+port+path:    https://example.com:8888/foo/bar.html
 * 2 = scheme+host+port:         https://example.com:8888 */
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

/*********************************************************************
 * AUDIO/VIDEO: WebRTC, WebGL
 *********************************************************************/

// Force WebRTC inside the proxy
user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);

/* Force a single network interface for ICE candidates generation
 * https://wiki.mozilla.org/Media/WebRTC/Privacy */
user_pref("media.peerconnection.ice.default_address_only", true);

// Force exclusion of private IPs from ICE candidates
user_pref("media.peerconnection.ice.no_host", true);

// Disable WebGL (Web Graphics Library):
user_pref("webgl.disabled", true);

/*********************************************************************
 * DOWNLOADS
 *********************************************************************/

// Always ask you where to save files:
user_pref("browser.download.useDownloadDir", false);

// Disable adding downloads to system's "recent documents" list
user_pref("browser.download.manager.addToRecentDocs", false);

// Enable user interaction for security by always asking how to handle new mimetypes:
user_pref("browser.download.always_ask_before_handling_new_types", true);

/*********************************************************************
 * COOKIES
 *********************************************************************/

/*
 * Enable ETP (Enhanced Tracking Protection)
 * ETP strict mode enables Total Cookie Protection (TCP)
 */
user_pref("browser.contentblocking.category", "strict"); // [HIDDEN PREF]

/*********************************************************************
 * UI FEATURES
 *********************************************************************/

// Limit events that can cause a popup
user_pref("dom.popup_allowed_events", "click dblclick mousedown pointerdown");

// Disable PDFJS scripting
user_pref("pdfjs.enableScripting", false);

/* Enable Containers and show the UI settings
 * https://wiki.mozilla.org/Security/Contextual_Identity_Project/Containers */
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);

/*********************************************************************
 * EXTENSIONS
 *********************************************************************/

/* Limit allowed extension directories:
 * 1 = profile
 * 2 = user
 * 4 = application
 * 8 = system
 * 16 = temporary
 * 31 = all
 * The pref value represents the sum: e.g. 5 would be profile and application directories. */
user_pref("extensions.enabledScopes", 5); // [HIDDEN PREF]

// Display always the installation prompt
user_pref("extensions.postDownloadThirdPartyPrompt", false);

/*********************************************************************
 * SHUTDOWN SETTINGS & SANITIZING
 *********************************************************************/

// Clear history, cookies and site data when Firefox closes
// user_pref("privacy.sanitize.sanitizeOnShutdown", true);
// user_pref("privacy.clearOnShutdown.cookies", true); // Cookies
// user_pref("privacy.clearOnShutdown.offlineApps", true); // Site data
// user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", true); // Cookies, Site data, Active Logins
// user_pref("privacy.clearOnShutdown_v2.downloads", true);
// user_pref("privacy.clearOnShutdown_v2.formdata", true);

/* Set Time range to clear for "Clear Data" and "Clear History"
 * 0 = everything
 * 1 = last hour
 * 2 = last two hours
 * 3 = last four hours
 * 4 = today
 * NOTE: Values 5 (last 5 minutes) and 6 (last 24 hours) are not listed in the dropdown */
// user_pref("privacy.sanitize.timeSpan", 0);

/*********************************************************************
 * FINGERPRINTING (RFP)
 *********************************************************************/

/* RFP (Resist Fingerprinting):
 * RFP can cause some website breakage: mainly canvas, use a site exception via
 * the urlbar.
 *
 * RFP also has a few side effects: mainly timezone is UTC0, and websites will
 * prefer light theme.
 * See: https://bugzilla.mozilla.org/418986
 * https://support.mozilla.org/en-US/kb/firefox-protection-against-fingerprinting */

// Enable RFP
user_pref("privacy.resistFingerprinting", true);

// Increase the size of new RFP windows for better usability
user_pref("privacy.window.maxInnerWidth", 1600);
user_pref("privacy.window.maxInnerHeight", 900);
user_pref("privacy.resistFingerprinting.letterboxing", false);

// Disable mozAddonManager Web API
user_pref("privacy.resistFingerprinting.block_mozAddonManager", true);

/* Disable RFP spoof english prompt:
    * 0 = prompt
    * 1 = disabled
    * 2 = enabled */
user_pref("privacy.spoof_english", 1);

// Disable using system colors
user_pref("browser.display.use_system_colors", false); // [Default false Non-Windows]

// Disable using system accent colors
user_pref("widget.non-native-theme.use-theme-accent", false); // [Default false Windows]

// Set all open window methods to abide by "browser.link.open_newwindow"
user_pref("browser.link.open_newwindow.restriction", 0);
