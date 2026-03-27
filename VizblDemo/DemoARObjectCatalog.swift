//
//  DemoARObjectCatalog.swift
//  VizblDemo
//
//  Copyright (c) 2026 Vizbl
//

import Foundation
import VizblKit

struct DemoARObject: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let identifier: ARObjectReference.Identifier
    let materialId: String?

    init(name: String, objectId: UUID, materialId: String? = nil) {
        self.name = name
        self.identifier = .objectId(objectId)
        self.materialId = materialId
    }

    init(name: String, tinuuid: String, hid: String? = nil) {
        self.name = name
        self.identifier = .tinuuid(tinuuid)
        self.materialId = hid
    }

    var reference: ARObjectReference {
        ARObjectReference(identifier, with: materialId)
    }

    var displayId: String {
        switch identifier {
        case .objectId(let id): return id.uuidString
        case .tinuuid(let tinuuid): return tinuuid
        }
    }
}

enum DemoARObjectCatalog {
    static let featured: [DemoARObject] = [
        .init(
            name: "Smart Speaker",
            objectId: UUID(uuidString: "f7eee3cc-b019-458d-b71c-6b3e4d99f339")!
        ),
        .init(
            name: "Modern Lamp",
            tinuuid: "1nQhScTfSrWB9CM9MWcChA",
            hid: "9318d8b7"
        ),
        .init(
            name: "Husk Armchair",
            tinuuid: "OKb1FOpDRnOMjXQGG4c-sg",
            hid: "1d730836"
        ),
        .init(
            name: "Vitio",
            tinuuid: "oWb5XjXrRrOXazkxqveazg"
        )
    ]

    static let all: [DemoARObject] = featured
}
