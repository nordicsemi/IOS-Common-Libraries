<p align="center" width="100%">
    <img width="60%" src="https://raw.githubusercontent.com/NordicPlayground/IOS-Common-Libraries/main/Logo_RGB_Horizontal_Transparent.png">
</p>

# iOS-Common-Libraries

![Swift](https://img.shields.io/badge/Swift-5.6-f05237.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20iPadOS%20|%20macOS-333333.svg)
[![License](https://img.shields.io/github/license/nordicsemi/IOS-Common-Libraries)](https://github.com/nordicsemi/IOS-Common-Libraries/blob/main/LICENSE)
[![Swift Package Manager](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen)](https://swift.org/package-manager/)
[![Release](https://img.shields.io/github/release/nordicsemi/IOS-Common-Libraries.svg)](https://github.com/nordicsemi/IOS-Common-Libraries/releases)

This is a Swift Package containing Swift code and Utilities/Assets, such as Colors, used by Nordic's iOS/Mac apps.

> [!IMPORTANT]  
> This repository contains APIs and Utilities used by ourselves. Ones that we find useful to extend to the community, because most of it we've learned through you, so we owe it back to you. That being said, this repository should not be considered public-facing API. We reserve the right to modify any of the components shared here to fit our uses.

## Contents

### Views

#### InlinePicker

<p align="center" width="100%">
    <img width="60%" src="https://raw.githubusercontent.com/NordicPlayground/IOS-Common-Libraries/main/inlinePicker.jpg">
</p>

The main use case for this UI Component is to basically have an alternative of macOS' Segmented Control but for iOS, including iOS-derived platforms such as the Mac via Catalyst. It took a lot of setup to have a Picker that didn't "push" the UI and the user towards a new View, which we found can be very distracting. So we came up with `InlinePicker` View, and we didn't just use it in nRF Connect, it's also gone on to become a staple in other projects such as the Wi-Fi Provisioner App.

#### PasswordField

<p align="center" width="100%">
    <img width="60%" src="https://raw.githubusercontent.com/NordicPlayground/IOS-Common-Libraries/main/passwordField.jpg">
</p>

> [!NOTE]  
> The above screenshot is from nRF Edge Impulse, which is applying custom styling to PasswordField.

nRF Edge Impulse was our team's first "REST-based client", let's say. As such, we had to handle networking and user account details. This included password input which, as we know, is handled by the existing ![SecureField](https://developer.apple.com/documentation/swiftui/securefield) component. But, to our surprise, there's no way to allow the user to explicitly see what they're typing. We could've just dismissed the issue, but even to us when using the app it was a big nuissance. So we wrote it, initially just for nRF Edge Impulse. And then a similar need arose for nRF Wi-Fi Provisioner. So we refactored it out, allowing nRF Edge Impulse to keep its UI design, but allowing it to look more system-like for nRF Wi-Fi Provisioner.

#### FPSCounter

<p align="center" width="100%">
    <img width="60%" src="https://raw.githubusercontent.com/NordicPlayground/IOS-Common-Libraries/main/fpsCounter.jpeg">
</p>

For nRF Connect, we rewrote the RSSI Graph from scratch, removing our dependency from the ![Charts framework we were using previously](https://github.com/ChartsOrg/Charts). In fact, it was in use even ![in the older, 1.x version of nRF Connect](https://devzone.nordicsemi.com/nordic/nordic-blog/b/blog/posts/announcing-nrf-connect-2-0-for-ios). Regardless, we decided to move on to our own implementation, based on SwiftUI, which provided a big improvement in CPU / power use. We wanted to measure how efficient our code is, so we came up with an `FPSCounter`.

It's tricky to use, so here's a simplified version of the code we use in nRF Connect to measure the time the RSSI Graph takes to draw. 

> [!CAUTION]
> This is our best-guess on how to implement such a thing. Obviously, we could be out-of-this-world wrong. If that's the case, we'd happy to listen and learn from you.

```swift
struct YourView: View {

    private let clock = ContinuousClock()
    private var fps = FPSCounter()

    var body: some View {
        VStack {
            
            var childViewToMeasure: ChildViewType? = nil
            let instant = clock.measure {
                childViewToMeasure = ChildViewType()
            }
            
            childViewToMeasure
            
            fps.countFrame(at: instant)
        }
    }
}
```

#### PipelineView

<p align="center" width="100%">
    <img width="60%" src="https://raw.githubusercontent.com/NordicPlayground/IOS-Common-Libraries/main/pipeline.jpg">
</p>

The process of deploying a ML model to a nRF5340-powered device, which is one of the things nRF Edge Impulse does, was very complicated. The user sets up parameters for the ML Model, we send the request to the Edge Impulse back-end, the back-end builds the firmware we need to deploy, we then download said firmware, and use our own ![Device Firmware Update Library](https://github.com/NordicSemiconductor/IOS-nRF-Connect-Device-Manager) to run it on the device. Making the user aware of all of the steps the app is doing, plus when and why it fails, was not easy. But we came up with a nice UI design we called 'the pipeline'. We then found ourselves in a similar situation when it came to nRF Wi-Fi Provisioner, which was unexpected. But we took the opportunity to make the pipeline components reusable, but also give ourselves some breathing space to allow each app to be able to customize it to their liking. 

### Colors

The swatch of Nordic colors is available here for our own use. We're keeping to the [DRY Principle](https://wiki.c2.com/?DontRepeatYourself) of course, but the side-benefit of this is that updating the colors in one place, automagically updates all of our apps.

Additionally, there are helper items here. We have `struct RGB` and `RGBA` structures so that 8-bit colors can be stored as a `UInt32` and thus helping memory consumption.

### Utilities

- `Cache`: Need to use `NSCache` with a pure-Swift `struct`? This is what this is for. Also, it's just John Sundell's work in a library that we use.
- `BitField`: Alternative to an `enum` `Set` that allows us to store everything in a single CPU Register, both in memory and as a `Codable`.
- `NordicLog`: Apple added `OSLog` as the [performance-oriented logging API](https://developer.apple.com/documentation/os/oslog) for their platforms back in 2018. We've since adopted it in nRF Connect for Mobile, and extended its use accross all apps. And what we found is that, we kept re-implementing the same set of APIs for logging everywhere. So we picked one implementation, and moved it here so that we can use it everywhere. Additionally, it supports not only OSLog APIs but also [performance-logging APIs](https://developer.apple.com/documentation/os/logging/recording_performance_data), allowing us to measure calls for performance.
- `Haptic`: Also a long time ago, haptic feedback was a thing. So we wrote wrapper APIs to make it easier to use. We even forgot about them! To a point, of course. Then we decided it was a good time to perhaps clean it up and, port it [over here](Sources/iOS-Common-Libraries/Utilities/Haptic.swift).

### Extensions

- `Data`: There are helper functions here to handle bytes within a `Data` blob. This is code used by [nRF Connect for Mobile](https://apps.apple.com/es/app/nrf-connect-for-mobile/id1054362403) to read individual bytes from advertised BLE `Data`. The are functions to format `Data` as `String` as well.
- `CGSize`: How is it that there's no Public API to initialise a size as a square!?
- `Compression`: A long time ago, back in 2020, we wrote code to Compress/Decompress blobs of Data. This was a major benefit for nRF Connect for Mobile, which regularly saves its state via JSON Encode/Decode to disk. This allows for persistent User Settings, as well as the app "remembering" where the user was irrespective of if the app is killed in the background or not. Unfortunately, two years later, undergoing some testing a crucial API call for compression was removed. We found it thinking it was code that was not used and needing to be deleted, then wondered 'why isn't this being used?' and the answer was, a bad copy/paste back of previous code gone wrong. So nRF Connect for Mobile is back to using it, providing great benefits to [solid state endurance](https://arstechnica.com/information-technology/2012/06/inside-the-ssd-revolution-how-solid-state-disks-really-work/) to our customers. Hence, why it belongs here.

## In Use By

Here's a listing of the iOS/iPadOS/macOS Projects we at Nordic use this code in. Obviously since this is Open Source, you're free to use any of it as well. We're just highlighting here some of the products that have lead to the battle-testing of some of this code.

- [x] `nRF Connect for Mobile`: [App Store](https://apps.apple.com/no/app/nrf-connect-for-mobile/id1054362403) [GitHub (not Open Source)](https://github.com/NordicSemiconductor/IOS-nRF-Connect)
- [x] `nRF Edge Impulse`: [App Store](https://apps.apple.com/no/app/nrf-edge-impulse/id1557234087?l=nb) [GitHub](https://github.com/NordicSemiconductor/IOS-nRF-Edge-Impulse)
- [x] `nRF Wi-Fi Provisioner`: [App Store](https://apps.apple.com/no/app/nrf-wi-fi-provisioner/id1638948698?platform=iphone) [GitHub](https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner)
- [x] `nRF Toolbox`: [App Store](https://apps.apple.com/no/app/nrf-toolbox/id820906058) [GitHub](https://github.com/NordicSemiconductor/IOS-nRF-Toolbox)
- [x] `nRF Memfault`: [App Store](https://apps.apple.com/no/app/nrf-memfault/id1641119282) [GitHub](https://github.com/NordicSemiconductor/IOS-Memfault-Library)
