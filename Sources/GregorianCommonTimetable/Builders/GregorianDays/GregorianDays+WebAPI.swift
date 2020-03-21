//
//  GregorianCommonTimetable
//  GregorianDays+WebAPI.swift
//
//  Created by Valeriano Della Longa on 16/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import WebAPICodingOptions

extension GregorianDays: Codable {
    public enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    public init(from decoder: Decoder) throws {
        if let codingOptions = decoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions {
            switch codingOptions.version {
            case .v1:
                let webinstance = try _WebAPIGregorianDays(from: decoder)
                guard
                    let new = try? GregorianDays(strings: webinstance.days)
                    else {
                        throw WebAPICodingOptions.Error.invalidDecodedValues("Couldn't decode a valid GregorianDays value from: \(dump(webinstance))")
                }
                
                self = new
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.rawValue = try container.decode(UInt.self, forKey: .rawValue)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if
            let codingOptions = encoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions
        {
            switch codingOptions.version {
            case .v1:
                let webinstance = _WebAPIGregorianDays(self)
                try webinstance.encode(to: encoder)
            }
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(rawValue, forKey: .rawValue)
        }
    }
    
}

fileprivate struct _WebAPIGregorianDays: Codable {
    let days: [String]
    
    init(_ gregorianDays: GregorianDays) {
        self.days = gregorianDays.baseValidMembersAsStrings
    }
}
