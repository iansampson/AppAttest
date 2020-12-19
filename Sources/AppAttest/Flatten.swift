//
//  Flatten.swift
//  
//
//  Created by Ian Sampson on 2020-12-19.
//

protocol Node {
    associatedtype S: Sequence where S.Element == Self
    var children: S { get }
}

extension Node {
    var flatten: [Self] {
        [self] + children.flatMap { $0.flatten }
    }
}

extension ASN1.ASN1Node: Node {
    var children: [ASN1.ASN1Node] {
        switch self.content {
        case let .constructed(nodes):
            return Array(nodes)
            // Inefficient. Construct an empty ASN1.ASN1NodeCollection instead.
        case .primitive(_):
            return []
        }
    }
}
