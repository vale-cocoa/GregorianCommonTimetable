//
//  GregorianCommonTimetable
//  GregorianCommonTimetable+Codable.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

extension GregorianCommonTimetable: Codable
{
    private enum Base: String, Codable {
        case months
        case weekdays
        case hours
        
        fileprivate func toKind() -> Kind {
            switch self {
            case .months:
                return .monthlyBased
            case .weekdays:
                return .weekdayBased
            case .hours:
                return .hourlyBased
            }
        }
        
        fileprivate init(from kind: Kind) {
            switch kind {
            case .monthlyBased:
                self = .months
            case .weekdayBased:
                self = .weekdays
            case .hourlyBased:
                self = .hours
            }
        }
        
    }
    
    fileprivate enum CodingKeys: CodingKey {
        case base
        case schedule
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        let kind = base.toKind()
        let onSchedule = try container.decode(Set<Int>.self, forKey: .schedule)
        self = try Self.init(kind: kind, onSchedule: onSchedule)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let base = Base(from: kind)
        try container.encode(base, forKey: .base)
        try container.encode(onScheduleValues, forKey: .schedule)
    }
    
}
