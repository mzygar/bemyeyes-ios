[![Crowdin](https://d322cqt584bo4o.cloudfront.net/bemyeyes/localized.png)](https://crowdin.com/project/bemyeyes)

Read more about [Be My Eyes](http://bemyeyes.org)

# Getting started
## Dependencies
All dependencies are already in the repo. To update pods use `pod update` in the terminal.
If you don't have CocoaPods already, install by `sudo gem install cocoapods`.

## Configuration
### Settings File
Rename BMEGlobal.temp.h to BMEGlobal.h and configure to your own needs.
Remember to update BMEGlobal.temp.h along with BMEGlobal.h
### 
OpenTok supports `armv7` and `armv7s` and _not_ `arm64`. Therefor the option `ONLY_ACTIVE_ARCH` should be set to `NO`.

## Localization / Translations
The translations are crowd sourced at [crowdin](http://crowdin.com/project/bemyeyes). Please contribute there, instead of editing the `.string`s files directly in the repo.

- Chinese `Simplified` is equivalent to `zh-Hant` in iOS and `zh-CN` on CrowdIn.
- Chinese `Traditional` is equivalent to `zh-Hans` in iOS and `zh-TW` on CrowdIn.
- Croation is `hr`
- Greek is `el`
- Urdu is `ur-PK`
