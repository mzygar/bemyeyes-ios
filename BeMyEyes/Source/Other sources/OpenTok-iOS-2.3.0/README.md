OpenTok iOS SDK
================

The OpenTok iOS SDK 2.3.0 lets you use OpenTok-powered video sessions in apps
you build for iPad, iPhone, and iPod touch devices.

This SDK interoperates with apps that use the following client SDKs:

* [OpenTok.js 2.2](http://tokbox.com/opentok/libraries/client/js/)

* [OpenTok Android SDK
  2.2+](http://tokbox.com/opentok/libraries/client/android/)

Using the SDK
-------------

The OpenTok.framework directory contains the OpenTok iOS SDK.

The OpenTok iOS SDK 2.3.0 requires Xcode 5+.

See the [release notes](release-notes.md) for information on the latest version of the SDK and for a list of known issues.

See [this document](http://tokbox.com/opentok/libraries/client/ios/background-state.html)
for information on using the SDK in apps running in the background mode.

System requirements
-------------------

The OpenTok iOS SDK is supported on the following devices:

* iPhone 4S / 5
* iPod Touch 5+
* iPad 2 / 3 / 4 / Mini

The OpenTok iOS SDK is supported in iOS 6+.

The OpenTok iOS SDK is supported on Wi-Fi and 4G/LTE connections.

The OpenTok iOS SDK 2.2 supports one published audio-video stream, one
subscribed audio-video stream, and up to three additional subscribed
audio-only streams simultaneously. (This is the baseline support on
an iPhone 4S.) To connect more than two clients in a session using the
OpenTok iOS SDK, create a session that uses the OpenTok Media Router
(a session with the media mode set to routed). See
[The OpenTok Media Router and media
modes](http://tokbox.com/opentok/tutorials/create-session/#media-mode).

Sample apps
-----------

The samples subdirectory of the SDK includes sample code, which is also at the
[opentok-ios-sdk-samples repo at github](https://github.com/opentok/opentok-ios-sdk-samples).

Documentation
-------------

Reference documentation is included in the docs subdirectory of the SDK and at
<http://www.tokbox.com/opentok/libraries/client/ios/reference/index.html>.

More information
-----------------

For a list of API and changes and user interface changes from version 2.1.7 of
the OpenTok iOS SDK, see [Migrating to version 2.2 of the OpenTok
SDK](http://tokbox.com/opentok/libraries/client/ios/migrating-to-version-2.2.html).

For a list of new features and known issues, see the [release notes](release_notes.md).
