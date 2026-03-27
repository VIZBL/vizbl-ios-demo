//
//  MinimalQuickStartDemoView.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import SwiftUI
import VizblKit

struct MinimalQuickStartDemoView: View {
    @StateObject private var controller = ARViewController(configuration: .default)
    private let object = DemoARObjectCatalog.featured[0]

    var body: some View {
        VStack(spacing: 16) {
            Text("Minimal integration example")
                .font(.headline)

            Text("One object, default configuration.")
                .foregroundStyle(.secondary)

            Button("Open AR") { controller.isPresented = true }
                .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("Minimal")
        .fullScreenCover(isPresented: $controller.isPresented) {
            NavigationStack {
                ARView(
                    object: object.reference,
                    configuration: controller.configuration,
                    controller: controller
                )
            }
        }
    }
}
