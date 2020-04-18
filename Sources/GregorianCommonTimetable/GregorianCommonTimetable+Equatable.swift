//
//  GregorianCommonTimetable
//  GregorianCommonTimetable+Equatable.swift
//  
//  Created by Valeriano Della Longa on 18/04/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

extension GregorianCommonTimetable: Equatable {
    public static func == (lhs: GregorianCommonTimetable, rhs: GregorianCommonTimetable) -> Bool {
        guard
            lhs.kind == rhs.kind
            else { return false }
        
        return lhs.onScheduleValues == rhs.onScheduleValues
    }
    
}

extension GregorianCommonTimetable: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.kind)
        hasher.combine(self.onScheduleValues)
    }
    
}
