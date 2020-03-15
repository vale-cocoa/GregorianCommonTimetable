# GregorianCommonTimetable

A `Schedule` concrete type which represents a common timetable based on gregorian calendar time unit. 

## Introduction
Commonly used schedule timetables are  hourly, weekday and monthly based. `GregorianCommonTimetable` is a concrete `Schedule` type whose instances represent these kind of timetables.

### `GregorianCommonTimeTable.Kind` enum
This `enum` is used to differentiate between each kind of representable timetable.
Its cases are:
* `.hourlyBased`: for a schedule based on hours of the day.
* `.weekdayBased`: for a schedule based on weekdays.
* `.monthlyBased`: for a schedule based on months of the year.

This subtype offers also some useful public instance variables:
* `component`: the `Calendar.Component` representing the schedule kind.
* `durationComponent`: the `Calendar.Component` representing the duration of the `Schedule.Element` generated for the schedule.
* `rangeOfScheduleValues`: the range of values of the schedule. That is the maximum range of the `component` of the schedule.

## Usage
To initialize an instance use the initializer specifying a `Kind` and the values of the schedule. 
These are some examples:
```swift
// A schedule falling on every midnight and noon hours of the day:
let everyNoonAndMidnight = try GregorianCommonTimetable(kind: .hourlyBased, onSchedule: [0, 12])

// A schedule falling on every sunday:
let everySunday = try GregorianCommonTimetable(kind: .weekdayBased, onSchedule: [1])

// A schedule of every February and June:
let everyFebAndJune = try GregorianCommonTimetable(kind: .monthlyBased, onSchedule: [2, 6])

// An empty schedule:
let emptyWeekday = try GregorianCommonTimetable(kind: .weekdayBased, onSchedule: [])

// Following are some examples where the initilizer throws because of 
// given onSchedule parameter contains one or more values not in range of the given kind:

let failingWeekdayBased = try GregorianCommonTimetable(kind: .weekdayBased, onSchedule: [1, 2, 8])

let failingMonthBased = try GregorianCommonTimetable(kind: .monthlyBased, onSchedule: [-1, 9, 13])

```
