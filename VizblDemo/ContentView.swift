//
//  ContentView.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import SwiftUI
import VizblKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Getting started") {
                    NavigationLink {
                        MinimalQuickStartDemoView()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quick Start")
                            Text("Open AR with one object and default settings")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Shop integration") {
                    NavigationLink {
                        StoreIntegrationDemoView()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Shop Preview")
                            Text("Typical store flow: preview, favorites and buy actions")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Configuration lab") {
                    NavigationLink {
                        ConfigurationLabDemoView()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Configuration Lab")
                            Text("Tune AR behavior and object interaction settings")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Advanced") {
                    NavigationLink {
                        AdvancedActionsDemoView()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Object Actions")
                            Text("Replace, remove, modes, and error handling")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        DeeplinkListenerDemoView()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Deeplink (QR)")
                            Text("Listen to deeplink events and route inside the app")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            .navigationTitle("VizblKit Examples")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            ARViewController.clearCache()
                        } label: {
                            Label("Clear Cache", systemImage: "trash")
                        }
                        
                        Button {
                            ARViewController.resetTips()
                        } label: {
                            Label("Reset Tips", systemImage: "lightbulb.slash")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}
