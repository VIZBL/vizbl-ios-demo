//
//  DemoComponents.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import SwiftUI

/// Small helper button for async actions in demo lists/forms.
struct AsyncRowButton: View {
    let title: String
    let action: @MainActor () async -> Void

    @State private var isRunning = false

    var body: some View {
        Button {
            guard !isRunning else { return }
            isRunning = true
            Task { @MainActor in
                await action()
                isRunning = false
            }
        } label: {
            HStack {
                Text(title)
                Spacer()
                if isRunning {
                    ProgressView()
                }
            }
        }
        .disabled(isRunning)
    }
}
