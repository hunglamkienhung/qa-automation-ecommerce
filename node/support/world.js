'use strict';

// Wire the shared Cucumber harness to this domain. The World is the core
// Recorder plus the slots this domain's steps fill: the mini-shop DB, an HTTP
// response, and the screen.
require('@portfolio/core/harness/cucumber').install({
  browserTag: '@fe',
  viewport: { width: 1440, height: 900 },
  extendWorld(world) {
    world.shop = null;   // rows read from the mini-shop SQLite
    world.api = null;    // an HTTP response (mini-shop or the live site)
    world.screen = {};   // values read off a page
  },
});
