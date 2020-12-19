//
//  Octet.swift
//  
//
//  Created by Ian Sampson on 2020-12-18.
//

extension Attestation {
    // TODO: Shorten errors or combine OID value into a struct.
    enum ParseError: Error {
        case expectedASN1Node(oid: String)
        case failedToExtractValueFromASN1Node(oid: String)
        case expectedOctetStringInsideASN1Node(oid: String)
    }
    
    func extractOctet() throws -> [UInt8] {
        let certificate = statement.certificates[0]
        let octetNodeOIDString = "1.2.840.113635.100.8.2"
        // TOOD: Extend ASN1.ASN1ObjectIdentifier with .string or .description
        let octetNodeOID = ASN1.ASN1ObjectIdentifier(arrayLiteral: 1, 2, 840, 113635, 100, 8, 2)
        let rootNode = try ASN1.parse(certificate.bytes)
        
        // Obtain the value of the credCert extension with OID 1.2.840.113635.100.8.2,
        // which is a DER-encoded ASN.1 sequence.
        let extensionBytes = try rootNode.flatten
            .first { node in
                node.children.contains {
                    let oid = try? ASN1.ASN1ObjectIdentifier(asn1Encoded: $0)
                    return oid == octetNodeOID
                }
            }
            .tryUnwrap(ParseError.expectedASN1Node(oid: octetNodeOIDString))
            .flatten
            .compactMap {
                try? ASN1.ASN1OctetString(asn1Encoded: $0).bytes
                // Or whatever follows the object identifier.
            }
            .first
            .tryUnwrap(ParseError.failedToExtractValueFromASN1Node(oid: octetNodeOIDString))
        
        // Decode the sequence and extract the single octet string that it contains.
        return try ASN1.parse(extensionBytes)
            .flatten
            .compactMap {
                try? ASN1.ASN1OctetString(asn1Encoded: $0)
            }
            .first
            .map {
                Array($0.bytes)
            }
            .tryUnwrap(ParseError.expectedOctetStringInsideASN1Node(oid: octetNodeOIDString))
    }
}

extension Optional {
    func tryUnwrap(_ error: Error) throws -> Wrapped {
        switch self {
        case .none:
            throw error
        case let .some(value):
            return value
        }
    }
}
