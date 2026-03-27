//
//  AdvancedActionsDemoView.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import SwiftUI
import VizblKit

struct AdvancedActionsDemoView: View {
    @StateObject private var controller = ARViewController(configuration: .init(contentMode: .multiple))
    @State private var lastErrorText: String?

    var body: some View {
        Form {
            Section("What this demo covers") {
                Text("This example demonstrates object actions available via ARViewController: add, replace, remove, and error handling.")
                    .foregroundStyle(.secondary)
            }

            ModeSection(configuration: $controller.configuration)

            Section {
                DisabledActionsPreview()
            } header: {
                Text("Available in AR (via Panel)")
            } footer: {
                Text("Open AR first. In AR, tap Panel (bottom-right) to run actions.")
            }

            Section("AR") {
                Button("Open AR") {
                    lastErrorText = nil
                    controller.isPresented = true
                }
                .buttonStyle(.borderedProminent)

                if let lastErrorText {
                    Text(lastErrorText)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Advanced")
        .fullScreenCover(isPresented: $controller.isPresented) {
            NavigationStack {
                ARView(
                    object: nil,
                    configuration: controller.configuration,
                    controller: controller
                )
                .demoPanel(title: "Panel") { dismissPanel in
                    AdvancedActionsPanel(
                        controller: controller,
                        lastErrorText: $lastErrorText,
                        dismissPanel: dismissPanel
                    )
                }
            }
        }
    }
}

private struct ModeSection: View {
    @Binding var configuration: ARViewConfiguration

    var body: some View {
        Section("Mode") {
            Picker("Content mode", selection: Binding(
                get: { configuration.contentMode },
                set: { newValue in
                    var cfg = configuration
                    cfg.contentMode = newValue
                    configuration = cfg
                }
            )) {
                Text("Single").tag(ARContentMode.single)
                Text("Multiple").tag(ARContentMode.multiple)
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct DisabledActionsPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            FeatureRow(
                title: "Add",
                subtitle: "Add a selected object to AR",
                systemImage: "plus.circle"
            )

            FeatureRow(
                title: "Replace",
                subtitle: "Replace the selected object with another",
                systemImage: "arrow.triangle.2.circlepath"
            )

            FeatureRow(
                title: "Remove",
                subtitle: "Remove selected object or clear all",
                systemImage: "trash"
            )

            FeatureRow(
                title: "Error demo",
                subtitle: "Simulate an add error and handle it",
                systemImage: "exclamationmark.triangle"
            )
        }
        .foregroundStyle(.secondary)
    }
}

private struct FeatureRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .frame(width: 22)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct AdvancedActionsPanel: View {
    @ObservedObject var controller: ARViewController
    @Binding var lastErrorText: String?

    let dismissPanel: () -> Void

    @State private var addObject: DemoARObject = DemoARObjectCatalog.all.first ?? DemoARObjectCatalog.featured[0]
    @State private var replaceObject: DemoARObject = {
        let all = DemoARObjectCatalog.all
        if all.count >= 2 { return all[1] }
        return DemoARObjectCatalog.featured[0]
    }()

    private var placedCount: Int { controller.placedObjects.count }

    var body: some View {
        Form {
            ModeSection(configuration: $controller.configuration)

            Section("State") {
                LabeledContent("Placed", value: "\(placedCount)")

                if let selected = controller.selectedPlacedId {
                    Text("Selected: \(selected.uuidString)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                } else {
                    Text("Selected: none (tap an object in AR)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let lastErrorText {
                    Text(lastErrorText)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            Section("Add") {
                Picker("Object", selection: $addObject) {
                    ForEach(DemoARObjectCatalog.all) { item in
                        Text(item.name).tag(item)
                    }
                }
                .pickerStyle(.menu)

                AsyncRowButton(title: "Add to AR") {
                    lastErrorText = nil
                    _ = try? await controller.add(addObject.reference)
                    dismissPanel()
                }
            }

            Section("Replace selected") {
                Picker("Replace with", selection: $replaceObject) {
                    ForEach(DemoARObjectCatalog.all) { item in
                        Text(item.name).tag(item)
                    }
                }
                .pickerStyle(.menu)

                if let selected = controller.selectedPlacedId {
                    AsyncRowButton(title: "Replace selected") {
                        lastErrorText = nil
                        do {
                            try await controller.replace(replacing: selected, with: replaceObject.reference)
                        } catch {
                            lastErrorText = error.localizedDescription
                        }
                        dismissPanel()
                    }
                } else {
                    Text("Select a placed object in AR to enable replace.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Remove") {
                if let selected = controller.selectedPlacedId {
                    Button("Remove selected") {
                        lastErrorText = nil
                        controller.remove(id: selected)
                        dismissPanel()
                    }
                    .foregroundStyle(.red)
                }

                Button("Remove all") {
                    lastErrorText = nil
                    controller.removeAll()
                    dismissPanel()
                }
                .foregroundStyle(.red)
            }

            Section("Error demo") {
                AsyncRowButton(title: "Simulate add error") {
                    do {
                        _ = try await controller.add(objectId: UUID(), materialId: nil)
                        lastErrorText = nil
                    } catch {
                        lastErrorText = error.localizedDescription
                    }
                    dismissPanel()
                }

                Text("Expected result: you should see an error state/message in the demo UI or your logging.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            if replaceObject == addObject,
               let different = DemoARObjectCatalog.all.first(where: { $0 != addObject }) {
                replaceObject = different
            }
        }
        .onChange(of: addObject) { _, newValue in
            if replaceObject == newValue,
               let different = DemoARObjectCatalog.all.first(where: { $0 != newValue }) {
                replaceObject = different
            }
        }
    }
}
