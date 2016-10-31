/**
 * Copyright (c) 2016-present, FaiChou
 * All rights reserved.
 *
 * @providesModule BigWheel
 * @flow
 */
'use strict';
  
var RCTBigWheelManager = require('NativeModules').BigWheelManager;
var invariant = require('fbjs/lib/invariant');
var processColor = require('processColor');

var BigWheel = {
  /**
   * Display an BigWheel. The `options` object must contain:
   *
   * - `options` (array of strings) - a list of picker items' titles and index of selected item  (required)
   */
  showBigWheelWithOptions(
    options: Object,
    doneCallback: Function
  ) {
    invariant(
      typeof options === 'object' && options !== null,
      'Options must be a valid object'
    );
    invariant(
      typeof doneCallback === 'function',
      'Must provide a valid callback'
    );
    RCTBigWheelManager.showBigWheelWithOptions({...options
      },
      doneCallback
    );
  },
  dismissBigWheel() {
    RCTBigWheelManager.dismissBigWheel();
  },
};

module.exports = BigWheel;