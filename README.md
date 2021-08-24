# MightyTabRefresh

[![Xcode build](https://github.com/kukushechkin/MightyTabRefresh/actions/workflows/xcode.yml/badge.svg?branch=main)](https://github.com/kukushechkin/MightyTabRefresh/actions/workflows/xcode.yml)

## What is this?

An app that will automatically reload specific web pages in Safari.

## Why?

Sometimes web services have aggressive activity tracking and force you to login every e.g. hour of inactivity on the page. If this is some internal resource like Jira this may be very inconvenient to go through 2fa several times per day.

## TODO:

### App:
* keep listening to the extension state in Safari after opening safari preferences
* update product icon — embroiled logo
* time interval formatter
* progressive slider values
* localizable strings with plural forms
* pattern editor (rename to domain for now?)
* animation on items add/remove
* move all identifiers to a shared place
* ExtensionSettings serialization tests
* rules view UI tests
* window size and resizing

### Extension:
* ReloadController tests (ruleFor)
* make host calculation lazy
* on app gui add a rule with prepopulated domain if no matching rule exists

### Open Sourcing
* DocC documentation

### Publishing:
* write that page should be reloaded after app installation and initial settings set
* publish to TestFlight
* create a GitHub Actions TestFlight and release pipeline

### iOS 
* check if this will work on iOS as well
