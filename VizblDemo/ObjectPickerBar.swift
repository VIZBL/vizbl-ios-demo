//
//  ObjectPickerBar.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import SwiftUI

 struct ObjectPickerBar: View {
    let title: String
    @Binding var selected: DemoARObject
    let items: [DemoARObject]
    let buttonTitle: String
    let onApply: @MainActor () async -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Picker("", selection: $selected) {
                    ForEach(items) { item in
                        Text(item.name).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(buttonTitle) {
                Task { await onApply() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 10, y: 6)
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }
}
