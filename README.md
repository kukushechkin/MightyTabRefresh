# MightyTabRefresh

[![Xcode build](https://github.com/kukushechkin/MightyTabRefresh/actions/workflows/xcode.yml/badge.svg?branch=main)](https://github.com/kukushechkin/MightyTabRefresh/actions/workflows/xcode.yml)

## What is this?

An app that will automatically reload specific web pages in Safari.

## Why?

Sometimes web services have aggressive activity tracking and force you to login every e.g. hour of inactivity on the page. If this is some internal resource like Jira this may be very inconvenient to go through 2fa several times per day.

## TODO:

### App:
* app icon
* update settings on edit finish (=> no need in send settings button)
* pattern editor (rename for domain for now?)
* localizable strings with plural forms
* make slider for interval look better
* make extension state controls look better
* animation on items add/remove
* other small TODOs in code
* tests

### Extension:
* blue icon in toolbar if there is a rule matching this page
* open app on toolbar item click, if there is no rule — make a new one with the host right away
* other small TODOs in code
* tests


