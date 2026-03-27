//
//  StoreIntegrationDemoView.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import SwiftUI
import VizblKit

struct StoreIntegrationDemoView: View {
    @State private var selected: DemoARObject? = DemoARObjectCatalog.featured.first
    @State private var isPresentingAddSheet = false

    @State private var lastBuyInfo: String?
    @State private var isShowingBuyBanner = false
    @State private var favorites = Set<UUID>()
    
    @State private var contentMode: ARContentMode = .multiple

    @StateObject private var controller = ARViewController(
        configuration: .init(
            contentMode: .multiple,
            objectDefaults: .default,
            qrCodeEnabled: true,
            popoverTipsEnabled: true
        )
    )

    var body: some View {
        List {
            Section("Catalog") {
                ForEach(DemoARObjectCatalog.all) { item in
                    Button {
                        selected = item
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name).font(.headline)
                                Text(item.displayId)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if selected?.id == item.id {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                    }
                }
            }
            
            Section("Mode") {
                Picker("Content mode", selection: $contentMode) {
                    Text("Single").tag(ARContentMode.single)
                    Text("Multiple").tag(ARContentMode.multiple)
                }
                .pickerStyle(.segmented)
            }

            Section("Action") {
                Button("Open AR (store flow)") {
                    controller.configuration = ARViewConfiguration(
                        contentMode: contentMode,
                        objectDefaults: .default,
                        qrCodeEnabled: true,
                        popoverTipsEnabled: true
                    )
                    controller.isPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Store integration")
        .fullScreenCover(isPresented: $controller.isPresented) {
            NavigationStack {
                ARView(
                    object: selected?.reference,
                    with: .default,
                    configuration: controller.configuration,
                    controller: controller,
                    controls: controls
                )
                .demoPanel(title: "Panel") { dismissPanel in
                    StorePanel(controller: controller, favorites: $favorites, dismissPanel: dismissPanel)
                }
                .overlay(alignment: .top) {
                    if isShowingBuyBanner, let lastBuyInfo {
                        Text(lastBuyInfo)
                            .font(.footnote)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.top, 12)
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddObjectsSheet(controller: controller, favorites: $favorites)
            }
        }
    }

    private var controls: AROverlayControls {
        AROverlayControls.build(
            add: { _ in
                AddButton { isPresentingAddSheet = true }
            },
            primary: { _, placed in
                BuyButton(title: "Buy") {
                    let hid = placed?.materialHid ?? "nil"
                    lastBuyInfo = "Buy tapped. placed.hid=\(hid)"
                    isShowingBuyBanner = true
                    // Auto-hide after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if isShowingBuyBanner { isShowingBuyBanner = false }
                    }
                }
            },
            secondary: { _, placed in
                let isFav = placed?.objectId.map { favorites.contains($0) } ?? false
                FavoriteButton(isFav) {
                    guard let objectId = placed?.objectId else { return }
                    if favorites.contains(objectId) {
                        favorites.remove(objectId)
                    } else {
                        favorites.insert(objectId)
                    }
                }
            }
        )
    }
}

private struct AddObjectsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var controller: ARViewController
    @Binding var favorites: Set<UUID>

    @State private var search = ""

    private var filtered: [DemoARObject] {
        let all = DemoARObjectCatalog.all
        guard !search.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    private var placedSorted: [ARPlacedObject] {
        Array(controller.placedObjects.values)
            .sorted { $0.id.uuidString < $1.id.uuidString }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Add object to AR") {
                    ForEach(filtered) { item in
                        AsyncRowButton(title: item.name) {
                            _ = try? await controller.add(item.reference, configuration: .default)
                            dismiss()
                        }
                    }
                }

                Section("Placed objects") {
                    if placedSorted.isEmpty {
                        Text("No placed objects yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(placedSorted, id: \.id) { placed in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(placed.name ?? "Placed object")
                                    .font(.headline)

                                Text("placedId: \(placed.id.uuidString)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                if let hid = placed.materialHid {
                                    Text("hid: \(hid)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                HStack {
                                    Button("Remove") {
                                        controller.remove(id: placed.id)
                                    }
                                    .foregroundStyle(.red)
                                    .buttonStyle(.borderless)

                                    Spacer()

                                    if let objectId = placed.objectId {
                                        Button(favorites.contains(objectId) ? "Unfavorite" : "Favorite") {
                                            if favorites.contains(objectId) {
                                                favorites.remove(objectId)
                                            } else {
                                                favorites.insert(objectId)
                                            }
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add / Manage")
            .searchable(text: $search)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct StorePanel: View {
    @ObservedObject var controller: ARViewController
    @Binding var favorites: Set<UUID>
    let dismissPanel: () -> Void

    @State private var search = ""

    private var filtered: [DemoARObject] {
        let all = DemoARObjectCatalog.all
        guard !search.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    private var placedSorted: [ARPlacedObject] {
        Array(controller.placedObjects.values)
            .sorted { $0.id.uuidString < $1.id.uuidString }
    }

    var body: some View {
        List {
            Section("Add object to AR") {
                ForEach(filtered) { item in
                    AsyncRowButton(title: item.name) {
                        _ = try? await controller.add(item.reference, configuration: .default)
                        dismissPanel()
                    }
                }
            }

            Section("Placed objects") {
                if placedSorted.isEmpty {
                    Text("No placed objects yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(placedSorted, id: \.id) { placed in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(placed.name ?? "Placed object")
                                .font(.headline)

                            Text("placedId: \(placed.id.uuidString)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let hid = placed.materialHid {
                                Text("hid: \(hid)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Button("Remove") {
                                    controller.remove(id: placed.id)
                                }
                                .foregroundStyle(.red)
                                .buttonStyle(.borderless)

                                Spacer()

                                if let objectId = placed.objectId {
                                    Button(favorites.contains(objectId) ? "Unfavorite" : "Favorite") {
                                        if favorites.contains(objectId) {
                                            favorites.remove(objectId)
                                        } else {
                                            favorites.insert(objectId)
                                        }
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                    }

                    Button("Remove all") { controller.removeAll() }
                        .foregroundStyle(.red)
                }
            }
        }
        .searchable(text: $search)
    }
}
