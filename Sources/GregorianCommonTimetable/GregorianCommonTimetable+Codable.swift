//
//  GregorianCommonTimetable
//  GregorianCommonTimetable+Codable.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import WebAPICodingOptions

extension GregorianCommonTimetable: Codable
{
    fileprivate enum Base: String, Codable {
        case months
        case days
        case weekdays
        case hours
        
        fileprivate func toKind() -> Kind {
            switch self {
            case .months:
                return .monthlyBased
            case .days:
                return .dailyBased
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
            case .dailyBased:
                self = .days
            case .weekdayBased:
                self = .weekdays
            case .hourlyBased:
                self = .hours
            }
        }
        
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case base
        case schedule
    }
    
    public init(from decoder: Decoder) throws {
        if
            let codingOptions = decoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions
        {
            switch codingOptions.version {
            case .v1:
                let webInstance = try _WebAPIGregorianCommonTimeTable(from: decoder)
                self = try Self(webInstance)
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let base = try container.decode(Base.self, forKey: .base)
            let kind = base.toKind()
            let onSchedule = try container.decode(Set<Int>.self, forKey: .schedule)
            self = try Self.init(kind: kind, onSchedule: onSchedule)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if let codingOptions = encoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions {
            switch codingOptions.version {
            case .v1:
                let webInstance = _WebAPIGregorianCommonTimeTable(self)
                try webInstance.encode(to: encoder)
            }
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let base = Base(from: kind)
            try container.encode(base, forKey: .base)
            try container.encode(onScheduleValues, forKey: .schedule)
        }
    }
    
    fileprivate init (_ webInstance: _WebAPIGregorianCommonTimeTable) throws
    {
        if let hours = try? GregorianHoursOfDay(strings: webInstance.schedule)
        {
            self = Self(hours)
        } else if
            let weekdays = try? GregorianWeekdays(strings: webInstance.schedule)
        {
            self = Self(weekdays)
        } else if
            let days = try? GregorianDays(strings: webInstance.schedule)
        {
            self = Self(days)
        } else if
            let months = try? GregorianMonths(strings: webInstance.schedule)
        {
            self = Self(months)
        } else {
            throw WebAPICodingOptions.Error
                .invalidDecodedValues("Couldn't decode a valid GregorianCommonTimetable instance from \(dump(webInstance))")
        }
    }
    
}

fileprivate struct _WebAPIGregorianCommonTimeTable: Codable
{
    let schedule: [String]
    
    init(_ timetable: GregorianCommonTimetable)
    {
        self.schedule = timetable.onScheduleAsStrings
    }
    
}
