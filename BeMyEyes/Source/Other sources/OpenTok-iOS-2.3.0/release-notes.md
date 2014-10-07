OpenTok iOS SDK 2.3.0 release notes
===================================

New features and changes
------------------------

Version 2.3.0

* This version adds support for armv7s and i386 architectures (in addition to
  armv7). You can now target the iOS Simulator. However, the XCode iOS Simulator
  does not provide access to the camera. When testing in the iOS Simulator, an
  OTPublisher object uses a demo video instead of the camera.

* This version includes a new custom audio driver API. This lets you use
  custom audio streams and define the audio device used to capture and render
  audio data. The following new classes and protocols support the custom audio
  driver API:

  * OTAudioDeviceManager -- Use this class to set the app to specify a custom
  audio device for use in the app.

  * OTAudioDevice -- Defines an audio device for use in a session.

  * OTAudioBus -- The audio bus marshals audio data between the network and
  the audio device.

  * OTAudioFormat -- Defines the format of the audio.

* There are new delegate protocols and messages for getting the audio level of a
  publisher or subscriber. See the `OTPublisherKit.audioLevelDelegate` property
  and the `OTPublisherKitAudioLevelDelegate` protocol, as well as the
  `OTSubscriberKit.audioLevelDelegate` property and the
  `OTSubscriberKitAudioLevelDelegate` protocol.
  
* The new `[OTSubscriberKitDelegate subscriberVideoEnabled:reason:]` message is sent when
  a subscriber's video stream starts (when there previously was no video) or resumes
  (after video was disabled).

* The `reason` parameter has been added to the
  `[OTSubscriberKitDelegate subscriberVideoDisabled:reason:]` message. This parameter
  describes the reason why the subscriber video is being disabled.
  In the previous version, this message was only sent when the video was
  disabled due to changes in the stream quality (in a session that uses the
  OpenTok Media Router). In version 2.3.0, the message is also sent if the
  publisher stops sending a video stream or the subscriber stops subscribing to
  it (and the `reason` parameter value will be set accordingly).

* The new `[OTSubscriberKitDelegate subscriberVideoDisabledWarning:]` message is
  sent when the OpenTok Media Router determines that the stream quality has
  degraded and the video will be disabled if the quality degrades more. The new
  `[OTSubscriberKitDelegate subscriberVideoDisabledWarningLifted:]` message
  is sent when the stream quality improves. This feature is only available in
  sessions that use the OpenTok Media Router (sessions with the
  [media mode](http://tokbox.com/opentok/tutorials/create-session/#media-mode)
  set to routed), not in sessions with the media mode set to relayed.

* This version adds support for armv7s and i386 architectures, in addition to
  armv7. (The SDK does not support arm64.) You can now target the iOS Simulator.
  However, the XCode iOS Simulator does not provide access to the camera. When
  testing in the iOS Simulator, an OTPublisher object uses a demo video instead
  of the camera.

* This version adds support for iOS 8.
  
Version 2.2.1

* Updated to use version 1.0.1h of OpenSSL.
* Created backwards compatibility with OpenTok iOS SDK 2.1.7 (subscriber
orientation).

Version 2.2.0

* For a list of new features and changes, see 
[Migrating to version 2.2 of the OpenTok SDK]
(http://tokbox.com/opentok/libraries/client/ios/migrating-to-version-2.2.html).

Known issues
------------

This version of the OpenTok iOS SDK does not support displaying videos using
Apple AirPlay.

In a session with the [media
mode](http://tokbox.com/opentok/tutorials/create-session/#media-mode)
set to relayed, only one client can subscribe to a stream published by an
ioS device.

The XCode iOS Simulator does not provide access to the camera. When testing in
the iOS Simulator, an OTPublisher object uses a demo video instead of the
camera.
