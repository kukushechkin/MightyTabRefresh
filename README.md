# MightyTabRefresh

[![Xcode build](https://github.com/kukushechkin/MightyTabRefresh/actions/workflows/xcode.yml/badge.svg?branch=main)](https://github.com/kukushechkin/MightyTabRefresh/actions/workflows/xcode.yml)

## What is this?

An app that will automatically reload specific web pages in Safari.

## Why?

Sometimes web services have aggressive activity tracking and force you to login every e.g. hour of inactivity on the page. If this is some internal resource like Jira this may be very inconvenient to go through 2fa several times per day.

## TODO:

### App:
* SettingsView directly changes .rules list and crashing on removing last rule, refactor this
* pattern editor (rename to domain for now?)
* localizable strings with plural forms
* keep listening to the extension state in Safari after opening safari preferences
* time interval formatter
* progressive slider values
* animation on items add/remove
* move all identifiers to a shared place
* ExtensionSettings serialization tests
* rules view UI tests
* window size and resizing

### Extension:
* open app on toolbar item click, if there is no rule — make a new one with the host right away
* blue icon in toolbar if there is a rule matching this page
* cleanup closed pages
* ReloadController tests

### Open Sourcing
* DocC documentation

### Publishing:
* create app in iTunesConnect
* make screenshots and description
* publish to TestFlight
* release to the Mac App Store
* create a GitHub Actions TestFlight and release pipeline

### iOS 
* check if this will work on iOS as well
