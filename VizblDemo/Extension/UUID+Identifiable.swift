//
//  UUID+Identifiable.swift
//  VizblDemo
//

import Foundation

extension UUID: @retroactive Identifiable {
    public var id: UUID {
        self
    }
}
