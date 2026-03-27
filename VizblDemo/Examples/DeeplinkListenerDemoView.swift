//
//  DeeplinkListenerDemoView.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

// Manual testing: scan QR codes with the iPhone camera.

import SwiftUI
import VizblKit

struct DeeplinkListenerDemoView: View {
    @State private var lastDeeplink: String?
    @State private var deeplinkCount: Int = 0
    @State private var handlingStatus: String?
    
    @State private var pendingDeeplink: String?
    @State private var showingDeeplinkAlert = false
    @State private var dismissPanel: (() -> Void)?

    @StateObject private var controller = ARViewController(configuration: .init(contentMode: .multiple, qrCodeEnabled: true))
    
    private func handleDeeplink(_ urlString: String) -> Bool {
        if ARViewController.deeplink(from: urlString) != nil {
            guard !showingDeeplinkAlert else { return true }
            
            pendingDeeplink = urlString
            showingDeeplinkAlert = true
            handlingStatus = "Deeplink recognized. Awaiting confirmation to add to AR."
            return true
        } else {
            handlingStatus = "Unrecognized deeplink. Manual handling required."
            return false
        }
    }
    
    @MainActor
    private func confirmAndAddPendingDeeplink() async {
        guard let urlString = pendingDeeplink else { return }
        
        do {
            guard let reference = ARViewController.deeplink(from: urlString) else {
                handlingStatus = "Failed to resolve deeplink on confirmation."
                return
            }
            try await controller.add(reference)
            handlingStatus = "Object added from deeplink."
            
            dismissPanel?()
        } catch {
            handlingStatus = "Failed to add object: \(error.localizedDescription)"
        }
    }

    var body: some View {
        Form {
            Section("Manual test") {
                Text("In the first version you will test deeplinks by scanning QR codes with the iPhone camera.")
                    .foregroundStyle(.secondary)

                Button("Open AR") { controller.isPresented = true }
                    .buttonStyle(.borderedProminent)

                if let handlingStatus {
                    Text(handlingStatus)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            DeeplinkObservedSection(lastDeeplink: lastDeeplink, deeplinkCount: deeplinkCount)
            DeeplinkHowToHandleSection()
        }
        .navigationTitle("Deeplink")
        .onReceive(controller.$deeplink) { value in
            guard let value, !value.isEmpty else { return }
            lastDeeplink = value
            deeplinkCount += 1
            // Optional: clear after processing (single-shot behavior):
            // controller.deeplink = nil

            // Try to resolve and handle automatically using your resolver. If not recognized, manual handling demo remains.
            _ = handleDeeplink(value)
        }
        .fullScreenCover(isPresented: $controller.isPresented) {
            NavigationStack {
                ARView(
                    object: DemoARObjectCatalog.featured.first?.reference,
                    configuration: controller.configuration,
                    controller: controller
                )
                .demoPanel(title: "Deeplink") { dismiss in
                    DeeplinkPanel(lastDeeplink: lastDeeplink, deeplinkCount: deeplinkCount)
                        .onAppear { self.dismissPanel = dismiss }
                }
            }
            .alert(
                "Add recognized object?",
                isPresented: $showingDeeplinkAlert
            ) {
                Button("Cancel", role: .cancel) {
                    pendingDeeplink = nil
                }
                Button("Add to AR") {
                    Task {
                        await confirmAndAddPendingDeeplink()
                        pendingDeeplink = nil
                    }
                }
            } message: {
                if let pendingDeeplink { Text(pendingDeeplink) }
            }
        }
    }
}

private struct DeeplinkObservedSection: View {
    let lastDeeplink: String?
    let deeplinkCount: Int

    var body: some View {
        Section("Observed deeplink") {
            if let lastDeeplink {
                Text(lastDeeplink)
                    .textSelection(.enabled)
                    .font(.footnote)
            } else {
                Text("No deeplinks received yet.")
                    .foregroundStyle(.secondary)
            }

            LabeledContent("Count", value: String(deeplinkCount))
        }
    }
}

private struct DeeplinkHowToHandleSection: View {
    var body: some View {
        Section("What to do with deeplink") {
            Text(
                """
                Typical handling in an app:
                • Validate/parse the deeplink string (URL, JSON, custom scheme).
                • Try to resolve to an AR object: ARObjectCatalog.deeplink(from:).
                • If resolved, add the object to AR via the controller.
                • Otherwise, route manually (open product page, apply a preset, add an object, etc.).
                • Optionally clear the deeplink after handling (to avoid double-processing).
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}

private struct DeeplinkPanel: View {
    let lastDeeplink: String?
    let deeplinkCount: Int

    var body: some View {
        Form {
            DeeplinkObservedSection(lastDeeplink: lastDeeplink, deeplinkCount: deeplinkCount)
            DeeplinkHowToHandleSection()
        }
    }
}
