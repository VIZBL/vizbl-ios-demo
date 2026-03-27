//
//  DemoPanelModifier.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import SwiftUI

private enum DemoPanelLayout {
    /// Standard button size used in corners.
    static let buttonSize: CGFloat = 44
    /// Padding that VizblKit keeps around the corners (without the button size).
    static let cornerPadding: CGFloat = 16
    /// Additional inset we want beyond the reserved corner area.
    static let extraInset: CGFloat = 32

    /// Trailing inset keeps us away from the corner by the button size + padding, plus our extra inset.
    static let trailingInset: CGFloat = cornerPadding + extraInset
    /// Bottom inset should only include padding (without button size) plus our extra inset.
    static let bottomInset: CGFloat = buttonSize + cornerPadding + extraInset
}

struct DemoPanelModifier<PanelContent: View>: ViewModifier {
    let title: String
    @ViewBuilder let panelContent: (_ dismissPanel: @escaping () -> Void) -> PanelContent

    @State private var isPresented = false
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Demo controls")
                    }
                    .font(.system(size: 14, weight: .semibold))

                    Text("Options & action")
                        .font(.system(size: 10, weight: .medium))
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.tint, in: .capsule)
                .padding(.trailing, DemoPanelLayout.trailingInset)
                .padding(.bottom, DemoPanelLayout.bottomInset)
                .offset(x: offset.width + dragOffset.width,
                        y: offset.height + dragOffset.height)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded {
                            offset.width += $0.translation.width
                            offset.height += $0.translation.height
                        }
                )
                .onTapGesture { isPresented = true }
                .accessibilityLabel(Text(title))
            }
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    panelContent { isPresented = false }
                        .navigationTitle(title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") { isPresented = false }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
    }
}

extension View {
    func demoPanel<PanelContent: View>(
        title: String,
        @ViewBuilder content: @escaping (_ dismissPanel: @escaping () -> Void) -> PanelContent
    ) -> some View {
        modifier(DemoPanelModifier(title: title, panelContent: content))
    }
}
