---
title: "accept android sdk license"
date: 2019-01-29T9:02:00+08:00
tags: ["android", "sdkmanager"]
author: "zhang wanming"
categories: ["android"]
---

## Build Error Message

android app build failed, error message:

    > Failed to install the following Android SDK packages as some licences have not been accepted.
     build-tools;28.0.3 Android SDK Build-Tools 28.0.3
     platforms;android-28 Android SDK Platform 28

    To build this project, accept the SDK license agreements and install the missing components using the Android Studio SDK Manager.
    Alternatively, to transfer the license agreements from one workstation to another, see http://d.android.com/r/studio-ui/export-licenses.html

    Using Android SDK: /opt/android-sdk-linux

## Install Build-Tools 28.0.3

    $ yes y | sdkmanager "build-tools;28.0.3"

## Accept all SDK licences

    $ yes y | sdkmanager --licenses
