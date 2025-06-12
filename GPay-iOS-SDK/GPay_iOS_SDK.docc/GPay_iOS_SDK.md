# GPay iOS SDK

> **Requirements:**
> - iOS 14.0 or higher is required to use the GPay iOS SDK.
> 

## Prerequisite: Define a URL Scheme for Your App

Before integrating the GPay iOS SDK, you must ensure your app has a custom URL scheme defined. This is required so the GPay app can return control to your application after a payment is made.

### Why is this needed?
The GPay app uses your app's URL scheme to redirect users back to your app after completing or cancelling a payment. Without a URL scheme, your app cannot receive the callback from GPay.

### How to define a URL scheme in Xcode
1. Open your project in Xcode.
2. Select your app target in the Project Navigator.
3. Go to the **Info** tab.
4. Scroll down to the **URL Types** section.
5. Click the **+** button to add a new URL type.
6. In the **Identifier** field, enter a unique identifier (e.g., `com.yourcompany.yourapp`).
7. In the **URL Schemes** field, enter your desired scheme (e.g., `yourappscheme`).
8. Leave the other fields blank or as default.
9. Save your changes.

Your `Info.plist` will now include an entry like this:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourappscheme</string>
        </array>
    </dict>
</array>
```
Replace `yourappscheme` with your chosen scheme. This value will be used by the GPay SDK to enable app-to-app communication.

---

## Overview
This is the official Libya Guide GPay SDK for iOS. It allows you to easily integrate the GPay payment portal into your iOS app.

## Installation

### 1. Add the SDK to Your Project
- Add the `GPay-iOS-SDK` folder to your Xcode project.
- Make sure to include all Swift files and resources.
- Ensure your app's URL scheme is defined as described above.

### 2. Import the SDK
In any Swift file where you want to use the SDK:

```swift
import SwiftUI
// import GPay_iOS_SDK if using as a module
```

## Usage Example

### Presenting the GPay Portal

```swift
import SwiftUI

struct ContentView: View {
    @State private var showGPay = false
    var body: some View {
        Button("Pay with GPay") {
            showGPay = true
        }
        .fullScreenCover(isPresented: $showGPay) {
            GPayPortal(
                sdkUrl: .production, // or .staging
                amount: 100.0,
                requesterUsername: "your_username",
                requestId: UUID().uuidString,
                requestTime: String(Int(Date().timeIntervalSince1970 * 1000)),
                onCheckPayment: { portal in
                    // Called when returning from GPay app or when payment confirmation is requested
                    // You can check payment status here
                },
                onViewClosed: { portal in
                    // Called when the user closes the portal
                    showGPay = false
                }
            )
        }
    }
}
```

### Callbacks
- `onCheckPayment`: Called when the app returns from the GPay app or when the payment confirmation button is pressed in the web portal. Use this to check the payment status.
- `onViewClosed`: Called when the user closes the GPay portal (taps the close button).

## Notes
- The SDK automatically retrieves your app's URL scheme from the `Info.plist` and passes it to the GPay system.
- Make sure your app can handle the custom URL scheme if you want to support deep linking or callbacks from the GPay app.
- The SDK requires network access to load the payment portal.

For more advanced integration or troubleshooting, see the SDK source code and comments.