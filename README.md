# GPay iOS SDK

> **Requirements:**
> - iOS 14.0 or higher is required to use the GPay iOS SDK.
> 

----

## Overview
This is the official Libya Guide GPay SDK for iOS. It allows you to easily integrate the GPay payment portal into your iOS app.

## Installation

### Swift Package Manager (Recommended)
You can add the GPay iOS SDK to your project using Swift Package Manager:

1. In Xcode, go to **File > Add Packages...**
2. Enter the repository URL:
   ```
   https://github.com/Libya-Guide/GPay-iOS-SDK.git
   ```
3. Choose the version or branch you want to use (e.g., `master` or a specific tag).
4. Add the package to your app target.

### CocoaPods
You can also install the SDK using CocoaPods. Add the following to your `Podfile`:

```ruby
pod 'GPay_iOS_SDK', :git => 'https://github.com/Libya-Guide/GPay-iOS-SDK.git', :branch => 'master'
```

Then run:

```sh
pod install
```

----


## Prerequisites

### 1. Define a URL Scheme for Your App

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

### 2. Create a Payment Request

Before you present the GPay Payment Portal, you need to create a payment request using the the GPay API. NOTE: for security reasons, do NOT communicate with the GPay API
directly from your app. Make the request to your system's back-end, and have the back-end send the request to GPay to create the payment request. The GPay API will return the information you need to present to the GPay Payment Portal.

The information you need to aqcuire are:
* The `amount` to be paid, in LYD. This should be the same amount with which you created the payment request.
* The `requestId`. The `request_id` that was returned by the GPay API when you created the payment request.
* The `requestTime`. The `request_time` that was returned by the GPay API when you created the payment request.
* The `requesterUsername`. The username used to create the payment request. This is basically the username of the account that owns the API Key that was used to communicate with the GPay API.

----

## Usage Example

### 1. Import the SDK
In any Swift file where you want to use the SDK:

```swift
import GPay_iOS_SDK
```

### 2. Presenting the GPay Portal

```swift

import SwiftUI
import GPay_iOS_SDK

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                let gpayView = GPayPortal(
                    sdkUrl: .staging, // For production, use .production
                    amount: 85.4, // The amount in LYD
                    requesterUsername: "<YOUR_ACCOUNT_USERNAME>",
                    requestId: "<UUID>",
                    requestTime: "<LONG_NUMBER>",
                    onCheckPayment: { view in
                        // Check if the payment request has been paid
                        // by calling the GPay API from your system's backend
                        // ....
                        
                        // To close the view. Execute this line.
                        view.close()
                    },
                    onViewClosed: { view in
                        // Use this callback to perform any action
                        // you need after the view is closed.
                        // ...
                    }
                )
                gpayView.show()
                
                // If you want to close the view programmatically,
                // gpayView.close()
            }) {
                Text("Tap Me")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
    }
}
```

### Callbacks
- `onCheckPayment`: Called when the app returns from the GPay app or when the payment confirmation button is pressed in the GPay Payment Portal interface. Use this to check the payment status. NOTE: receiving the callback doesn't guaratee that the payment was made. You are expected to make a request using the GPay API to check the status of the payment request that you made. If the `is_paid` field in the response is set to `true`, then the payment was made successfully to your account and you can finalize the checkout process. Otherwise, either the payment has not yet been made or the payment has failed.
- `onViewClosed`: Called when the user closes the GPay portal (taps the close button or by explicitly calling the close() function).

