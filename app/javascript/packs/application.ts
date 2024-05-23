/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import * as Sentry from "@sentry/browser"
import { Integrations } from "@sentry/tracing"
import "bootstrap"
import Analytics from '../src/analytics'

require("@rails/ujs").start()
require("turbolinks").start()


// Window Variables
declare global { 
  interface Window { 
    gon: any, // Setup in <head>
    gtag: any, // Setup in <head>
    fbq: any, // Setup in <head>
    Analytics: Analytics
  } 
}

// Sentry
if (window.gon.sentry_dsn_js) {
  Sentry.init({
    dsn: window.gon.sentry_dsn_js,
    release: window.gon.heroku_release_version,
    integrations: [
      new Integrations.BrowserTracing(),
    ],
    tracesSampleRate: 1.0,
    ignoreErrors: [
      'NS_ERROR_NOT_INITIALIZED',
      "null is not an object (evaluating 'this.doc.createElement')"
    ]
  });
}

// Analytics
window.Analytics = new Analytics()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);
