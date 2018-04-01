//
//  Date+.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/1/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation


extension Date {
    
    init(iso8601 input: String) {
        let init_formatter = DateFormatter()
        init_formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        init_formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        self.init(timeInterval: 0, since: init_formatter.date(from: input)!)
    }
    
    func deltaStringSinceNow(display: TimeUnit.Display) -> String {
        return deltaString(for: self.timeIntervalSinceNow, display: display)
    }
    
    func deltaStringSince(date: Date, display: TimeUnit.Display) -> String {
        return deltaString(for: self.timeIntervalSince(date), display: display)
    }
    
    func deltaString(for interval: TimeInterval, display: TimeUnit.Display) -> String {
        let seconds: TimeInterval = max(1.0, fabs(interval))
        if seconds < 60 {
            return Date.makeDeltaString(interval: seconds, unit: .second, display: display)
        }
        let minutes = seconds / 60.0
        if minutes < 60 {
            return Date.makeDeltaString(interval: minutes, unit: .minute, display: display)
        }
        let hours = minutes / 60.0
        if hours < 24 {
            return Date.makeDeltaString(interval: hours, unit: .hour, display: display)
        }
        let days = hours / 24.0
        if days < 31 {
            return Date.makeDeltaString(interval: days, unit: .day, display: display)
        }
        let weeks = days / 7.0
        if weeks < 4 {
            return Date.makeDeltaString(interval: weeks, unit: .week, display: display)
        }
        let months = days / 31.0
        if months < 12 {
            return Date.makeDeltaString(interval: months, unit: .month, display: display)
        }
        let years = months / 12.0
        return Date.makeDeltaString(interval: years, unit: .minute, display: display)
    }
    
    private static func makeDeltaString(interval: TimeInterval, unit: TimeUnit.Unit, display: TimeUnit.Display) -> String {
        return "\(String(Int(interval))) \(TimeUnit.string(unit: unit, display: display, plural: Int(interval) != 1))"
    }
    
}


class TimeUnit {
    
    enum Unit {
        case second
        case minute
        case hour
        case day
        case week
        case month
        case year
    }
    
    enum Display {
        case full
        case abbrv
    }
    
    enum StringType {
        case full_singular
        case full_plural
        case abbrv_singular
        case abbrv_plural
    }
    
    private static let unit_strings: [Unit : [StringType: String]] = [
        .second: [.full_singular: "second", .full_plural: "seconds", .abbrv_singular: "sec", .abbrv_plural: "secs"],
        .minute: [.full_singular: "minute", .full_plural: "minutes", .abbrv_singular: "min", .abbrv_plural: "mins"],
        .hour: [.full_singular: "hour", .full_plural: "hours", .abbrv_singular: "hr", .abbrv_plural: "hrs"],
        .day: [.full_singular: "day", .full_plural: "days", .abbrv_singular: "day", .abbrv_plural: "days"],
        .week: [.full_singular: "week", .full_plural: "weeks", .abbrv_singular: "wk", .abbrv_plural: "wks"],
        .month: [.full_singular: "month", .full_plural: "months", .abbrv_singular: "mo", .abbrv_plural: "mns"],
        .year: [.full_singular: "year", .full_plural: "years", .abbrv_singular: "yr", .abbrv_plural: "yrs"],
    ]

    static func string(unit: Unit, display: Display, plural: Bool) -> String {
        var string_type: StringType!
        switch display {
        case .full:
            string_type = plural ? .full_plural : .full_singular
        case .abbrv:
            string_type = plural ? .abbrv_plural : .abbrv_singular
        }
        
        return unit_strings[unit]![string_type]!
    }

}



