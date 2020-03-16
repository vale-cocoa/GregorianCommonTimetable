//
//  GregorianCommonTimetable
//  GregorianWeekdays+WebAPI.swift
//
//  Created by Valeriano Della Longa on 22/01/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import WebAPICodingOptions

extension GregorianWeekdays: Codable {
    public enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    public func encode(to encoder: Encoder) throws {
        if let codingOptions = encoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions {
            switch codingOptions.version {
            case .v1:
                let webAPI = _WebAPIGregorianWeekdays.init(self)
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
                let webAPI = try _WebAPIGregorianWeekdays.init(from: decoder)
                guard
                    let new = try? GregorianWeekdays.init(strings: webAPI.weekdays)
                    else {
                    throw WebAPICodingOptions.Error.invalidDecodedValues("Couldn't decode a valid GregorianWeedays value from: \(dump(webAPI))")
                }
                self = new
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.rawValue = try container.decode(UInt.self, forKey: .rawValue)
        }
    }
}

fileprivate struct _WebAPIGregorianWeekdays: Codable {
    let weekdays: [String]
    init(_ gregorianWeekdays: GregorianWeekdays) {
        self.weekdays = gregorianWeekdays.baseValidMembersAsStrings
    }
}

