//
//  GregorianCommonTimetableTests
//  MockGregorianGenerator.swift
//
//  Created by Valeriano Della Longa on 14/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import Schedule
@testable import GregorianCommonTimetable

func mockGregorianGenerator(of kind: GregorianCommonTimetable.Kind, onSchedule values: Set<Int>, throttle: Int) throws -> Schedule.Generator
{
    let timetable = try GregorianCommonTimetable.init(kind: kind, onSchedule: values)
    
    return { date, direction in
        var result: DateInterval? = nil
        let operationGroup = DispatchGroup()
        operationGroup.enter()
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + .seconds(throttle), execute: {
            result = timetable._generator(date, direction)
            operationGroup.leave()
        })
        
        _ = operationGroup.wait(timeout: .now() + .seconds(1 + throttle))
        
        return result
    }
}
