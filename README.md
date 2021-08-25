# MightyTabRefresh

[![Xcode build](https://github.com/kukushechkin/MightyTabRefresh/actions/workflows/xcode.yml/badge.svg?branch=main)](https://github.com/kukushechkin/MightyTabRefresh/actions/workflows/xcode.yml)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/5e328c582bc64e89b97dfcbdfbe89534)](https://www.codacy.com/gh/kukushechkin/MightyTabRefresh/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=kukushechkin/MightyTabRefresh&amp;utm_campaign=Badge_Grade)

## What is this

An app that will automatically reload specific web pages in Safari. And it is [available in the Mac App Store](https://apps.apple.com/fi/app/mighty-tab-refresh/id1582359612?mt=12)!

## Why

Sometimes web services have aggressive activity tracking and force you to log in every e.g. hour of inactivity on the page. If this is some internal resource like Jira this may be very inconvenient to go through 2fa several times per day.

## Features

*  Separate GUI for editing rules (currently — it is a match if page URL host contains rule string)
*  Fancy logic for figuring out is page is currently visible to avoid reloading right under your nose
*  Open the app with rules editor from the Safari toolbar or vice versa
*  Open Source development — you can check that app does not do anything with the pages or send URLs you visit to a cloud
*  818.2 KB of size, no, really, under 1 MB
