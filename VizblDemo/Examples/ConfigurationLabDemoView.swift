//
//  ConfigurationLabDemoView.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import SwiftUI
import VizblKit

struct ConfigurationLabDemoView: View {
    @StateObject private var controller = ARViewController(configuration: .default)

    @State private var selectedObject: DemoARObject = DemoARObjectCatalog.featured[0]
    @State private var pendingAddOnPresent = false

    @State private var contentMode: ARContentMode = .multiple
    @State private var qrCodeEnabled = false
    @State private var popoverTipsEnabled = true

    @State private var allowsTapToSelect = true
    @State private var allowsMove = true
    @State private var allowRotation = true
    @State private var allowScale = false
    @State private var scaleFactor: Float = 1.0

    var body: some View {
        Form {
            ConfigurationLabControls(
                contentMode: $contentMode,
                qrCodeEnabled: $qrCodeEnabled,
                popoverTipsEnabled: $popoverTipsEnabled,
                allowsTapToSelect: $allowsTapToSelect,
                allowsMove: $allowsMove,
                allowRotation: $allowRotation,
                allowScale: $allowScale,
                scaleFactor: $scaleFactor
            )

            Section {
                Button("Open AR") {
                    controller.configuration = makeConfiguration()
                    controller.isPresented = true
                }
                .buttonStyle(.borderedProminent)
            }

            Section("Quick test") {
                AsyncRowButton(title: "Add selected object (per-add config)") {
                    await addSelectedObject()
                }
            }
        }
        .navigationTitle("Configuration lab")
        .safeAreaInset(edge: .bottom) {
            ObjectPickerBar(
                title: "Model",
                selected: $selectedObject,
                items: DemoARObjectCatalog.all,
                buttonTitle: "Open in AR",
                onApply: {
                    // Main screen: open AR + add selected.
                    controller.configuration = makeConfiguration()
                    pendingAddOnPresent = true
                    controller.isPresented = true
                }
            )
        }
        .fullScreenCover(isPresented: $controller.isPresented) {
            NavigationStack {
                ARView(
                    object: nil,
                    configuration: controller.configuration,
                    controller: controller
                )
                .task {
                    // Run exactly once when requested from the main picker bar.
                    let shouldAdd = pendingAddOnPresent
                    pendingAddOnPresent = false
                    guard shouldAdd else { return }
                    await addSelectedObject()
                }
                .demoPanel(title: "Panel") { dismissPanel in
                    ConfigurationLabPanel(
                        selectedObject: $selectedObject,
                        contentMode: $contentMode,
                        qrCodeEnabled: $qrCodeEnabled,
                        popoverTipsEnabled: $popoverTipsEnabled,
                        allowsTapToSelect: $allowsTapToSelect,
                        allowsMove: $allowsMove,
                        allowRotation: $allowRotation,
                        allowScale: $allowScale,
                        scaleFactor: $scaleFactor,
                        controller: controller,
                        addSelectedObject: {
                            await addSelectedObject()
                            dismissPanel()
                        },
                        applyConfiguration: {
                            controller.configuration = makeConfiguration()
                        }
                    )
                }
            }
        }
    }

    @MainActor
    private func addSelectedObject() async {
        controller.configuration = makeConfiguration()
        _ = try? await controller.add(selectedObject.reference, configuration: makeObjectConfiguration())
    }

    private func makeObjectConfiguration() -> ARObjectConfiguration {
        ARObjectConfiguration(
            allowsTapToSelect: allowsTapToSelect,
            allowsMove: allowsMove,
            allowRotation: allowRotation,
            allowScale: allowScale,
            scaleFactor: scaleFactor
        )
    }

    private func makeConfiguration() -> ARViewConfiguration {
        ARViewConfiguration(
            contentMode: contentMode,
            objectDefaults: makeObjectConfiguration(),
            qrCodeEnabled: qrCodeEnabled,
            popoverTipsEnabled: popoverTipsEnabled
        )
    }
}

private struct ConfigurationLabControls: View {
    @Binding var contentMode: ARContentMode
    @Binding var qrCodeEnabled: Bool
    @Binding var popoverTipsEnabled: Bool

    @Binding var allowsTapToSelect: Bool
    @Binding var allowsMove: Bool
    @Binding var allowRotation: Bool
    @Binding var allowScale: Bool
    @Binding var scaleFactor: Float

    var body: some View {
        Section("ARViewConfiguration") {
            Picker("Content mode", selection: $contentMode) {
                Text("Single").tag(ARContentMode.single)
                Text("Multiple").tag(ARContentMode.multiple)
            }
            .pickerStyle(.segmented)

            Toggle("QR code enabled", isOn: $qrCodeEnabled)
            Toggle("Popover tips enabled", isOn: $popoverTipsEnabled)
        }

        Section("ARObjectConfiguration (defaults)") {
            Toggle("Tap to select", isOn: $allowsTapToSelect)
            Toggle("Move", isOn: $allowsMove)
            Toggle("Rotation", isOn: $allowRotation)
            Toggle("Scale", isOn: $allowScale)

            HStack {
                Text("Scale factor")
                Spacer()
                Text(String(format: "%.2f", scaleFactor))
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { Double(scaleFactor) },
                    set: { scaleFactor = Float($0) }
                ),
                in: 0.1...3.0
            )
        }
    }
}

private struct ConfigurationLabPanel: View {
    @Binding var selectedObject: DemoARObject

    @Binding var contentMode: ARContentMode
    @Binding var qrCodeEnabled: Bool
    @Binding var popoverTipsEnabled: Bool

    @Binding var allowsTapToSelect: Bool
    @Binding var allowsMove: Bool
    @Binding var allowRotation: Bool
    @Binding var allowScale: Bool
    @Binding var scaleFactor: Float

    @ObservedObject var controller: ARViewController

    let addSelectedObject: @MainActor () async -> Void
    let applyConfiguration: () -> Void

    var body: some View {
        Form {
            ConfigurationLabControls(
                contentMode: $contentMode,
                qrCodeEnabled: $qrCodeEnabled,
                popoverTipsEnabled: $popoverTipsEnabled,
                allowsTapToSelect: $allowsTapToSelect,
                allowsMove: $allowsMove,
                allowRotation: $allowRotation,
                allowScale: $allowScale,
                scaleFactor: $scaleFactor
            )

            Section("Apply") {
                Button("Apply configuration (next actions)") {
                    applyConfiguration()
                }

                AsyncRowButton(title: "Add selected object (per-add config)") {
                    await addSelectedObject()
                }

                if !controller.placedObjects.isEmpty {
                    Button("Remove all") { controller.removeAll() }
                        .foregroundStyle(.red)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            ObjectPickerBar(
                title: "Model",
                selected: $selectedObject,
                items: DemoARObjectCatalog.all,
                buttonTitle: contentMode == .single ? "Replace" : "Add",
                onApply: {
                    await addSelectedObject()
                }
            )
        }
    }
}
