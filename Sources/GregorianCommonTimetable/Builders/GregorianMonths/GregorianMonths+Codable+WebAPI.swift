//
//  GregorianMonths+Codable+WebAPI.swift
//  
//
//  Created by Valeriano Della Longa on 24/01/2020.
//

import Foundation
import WebAPICodingOptions

extension GregorianMonths: Codable {
    public enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    public func encode(to encoder: Encoder) throws {
        if let codingOptions = encoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions {
            switch codingOptions.version {
            case .v1:
                let webAPI = _WebApiGregorianMonths.init(self)
                try webAPI.encode(to: encoder)
            }
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.rawValue, forKey: .rawValue)
        }
    }
    
    public init(from decoder: Decoder) throws {
        if let codingOptions = decoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions {
            switch codingOptions.version {
            case .v1:
                let webAPI = try _WebApiGregorianMonths.init(from: decoder)
                guard
                    let new = try? GregorianMonths.init(strings: webAPI.months)
                    else {
                        throw WebAPICodingOptions.Error.invalidDecodedValues("Couldn't decode a valid GregorianMonths value from: \(dump(webAPI))")
                }
                self = new
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.rawValue = try container.decode(UInt.self, forKey: .rawValue)
        }
    }
}

fileprivate struct _WebApiGregorianMonths: Codable {
    let months: [String]
    init(_ gregorianMonths: GregorianMonths) {
        self.months = gregorianMonths.baseValidMembersAsStrings
    }
}
