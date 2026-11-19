# Vizbl iOS Demo

This repository contains a demo application that integrates the Vizbl iOS SDK.

The app demonstrates how to launch AR and load Vizbl objects by Object ID (UUID) or `tinuuid`.

## What this demo shows

- basic SDK integration into an iOS app
- presenting AR using `ARView`
- loading an object from Vizbl
- interacting with the object in AR

All AR logic, placement, and interaction are handled by the SDK.

## How to run

1. Clone the repository:

```bash
git clone https://github.com/VIZBL/vizbl-ios-demo.git
```

2. Open `VizblDemo.xcodeproj` in Xcode 26.4 or later. The SDK (`VizblKit` 0.1.0) is resolved automatically through Swift Package Manager

3. In the target's **Signing & Capabilities**, select your development team

4. Run the app on a physical device with iOS 18 or later

The demo ships with a few public Vizbl objects, so it works as is. To show your own products, replace the IDs in `VizblDemo/DemoARObjectCatalog.swift` with Object IDs or `tinuuid`s from your Vizbl library. No API key is needed in the app.

## Notes

- AR is not supported in the simulator
- a physical device is required
- the SDK automatically handles placement, UI, and interaction

## Documentation

https://developer.vizbl.com/docs/ios

## SDK

Vizbl iOS SDK repository:
https://github.com/VIZBL/vizbl-ios-sdk
