//
//  WebView.swift
//
//  Created by Basem Elazzabi on 11/6/2025.
//  Copyright © 2025 Libya Guide for Information Technology and Training. All rights reserved.
//


import SwiftUI
import WebKit
import UIKit

public enum GPaySdkUrl: String {
    case staging = "http://192.168.0.111:8080/banking/gpay_payment_page.jsp"
    case production = "https://gpay.ly/banking/gpay_payment_page.jsp"
}

public struct GPayPortal: View {
    public let sdkUrl: GPaySdkUrl
    public let amount: Double
    public let requesterUsername: String
    public let requestId: String
    public let requestTime: String
    public var onCheckPayment: ((GPayPortal) -> Void)?
    public var onViewClosed: ((GPayPortal) -> Void)?

    @State private var isLoading = true
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var wasInactive = false


    private var urlWithQuery: URL? {
        var appName = ""
        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]],
           let firstType = urlTypes.first,
           let schemes = firstType["CFBundleURLSchemes"] as? [String],
           let firstScheme = schemes.first {
           appName = firstScheme
        }
        
        var components = URLComponents(string: sdkUrl.rawValue)
        components?.queryItems = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "requester_username", value: requesterUsername),
            URLQueryItem(name: "request_id", value: requestId),
            URLQueryItem(name: "request_time", value: requestTime),
            URLQueryItem(name: "app_name", value: appName),
            URLQueryItem(name: "platform", value: "ios")
        ]
        return components?.url
    }

    public init(
        sdkUrl: GPaySdkUrl,
        amount: Double,
        requesterUsername: String,
        requestId: String,
        requestTime: String,
        onCheckPayment: ((GPayPortal) -> Void)? = nil,
        onViewClosed: ((GPayPortal) -> Void)? = nil
    ) {
        self.sdkUrl = sdkUrl
        self.amount = amount
        self.requesterUsername = requesterUsername
        self.requestId = requestId
        self.requestTime = requestTime
        self.onCheckPayment = onCheckPayment
        self.onViewClosed = onViewClosed
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let url = urlWithQuery {
                GPayWebViewWithPortal(
                    url: url,
                    isLoading: $isLoading,
                    portal: self,
                    onCheckPayment: onCheckPayment,
                    onOpenApp: openGPayApp
                )
                .ignoresSafeArea()
            } else {
                Text("Invalid URL")
            }
            if isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
            }
            HStack {
                Button(action: {
                    dismissView()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding([.top, .leading], 16)
                }
                Spacer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            onCheckPayment?(self)
        }
    }

    private func dismissView() {
#if canImport(UIKit)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController?.dismiss(animated: true, completion: nil)
        }

        onViewClosed?(self)
#endif
    }

    private func openGPayApp(url: URL, portal: GPayPortal) {
#if canImport(UIKit)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
#endif
        wasInactive = false // Mark as not inactive so we know when we return
    }
}

extension GPayPortal {
    public func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        let hostingController = UIHostingController(rootView: self)
        hostingController.modalPresentationStyle = .fullScreen
        rootVC.present(hostingController, animated: true, completion: nil)
    }
    
    public func close() {
        dismissView()
    }
}

struct GPayWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    var onCheckPayment: ((GPayPortal) -> Void)?
    var onOpenApp: ((_ url: URL, _ portal: GPayPortal) -> Void)?

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: GPayWebView
        var portal: GPayPortal
        init(parent: GPayWebView, portal: GPayPortal) {
            self.parent = parent
            self.portal = portal
        }
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "iosListener", let body = message.body as? [String: Any], let event = body["event"] as? String else { return }
            if event == "confirmPayment" {
                parent.onCheckPayment?(portal)
            } else if event == "makePayment" {
                // Build the lggpay://pay-request URL
                guard let amount = body["amount"],
                      let requestId = body["requestId"],
                      let requestTime = body["requestTimestamp"],
                      let requesterUsername = body["requesterUsername"],
                      let appName = body["appName"] else { return }
                var components = URLComponents()
                components.scheme = "lggpay"
                components.host = "pay-request"
                components.queryItems = [
                    URLQueryItem(name: "amount", value: String(describing: amount)),
                    URLQueryItem(name: "request_id", value: String(describing: requestId)),
                    URLQueryItem(name: "request_time", value: String(describing: requestTime)),
                    URLQueryItem(name: "requester_username", value: String(describing: requesterUsername)),
                    URLQueryItem(name: "app_name", value: String(describing: appName))
                ]
                if let url = components.url {
                    parent.onOpenApp?(url, portal)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        fatalError("Coordinator must be initialized with portal instance from GPayPortal")
    }

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "iosListener")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

// Helper wrapper to inject portal into GPayWebView
struct GPayWebViewWithPortal: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    let portal: GPayPortal
    var onCheckPayment: ((GPayPortal) -> Void)?
    var onOpenApp: ((_ url: URL, _ portal: GPayPortal) -> Void)?

    func makeCoordinator() -> GPayWebView.Coordinator {
        GPayWebView.Coordinator(parent: GPayWebView(url: url, isLoading: $isLoading, onCheckPayment: onCheckPayment, onOpenApp: onOpenApp), portal: portal)
    }
    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "iosListener")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}


