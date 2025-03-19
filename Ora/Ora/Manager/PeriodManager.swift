//
//  PeriodManager.swift
//  Ora
//
//  Created by Theresa Nguyen on 4/24/23.
//

import Foundation

/// Main data manager to handle period data and more
class PeriodManager: NSObject, ObservableObject {
    /// Dynamic properties that the UI will react to, '?' is an optional
    @Published var currentSelectedDate: Date?
    @Published var didSaveDateEntry: Bool = false
    @Published var selectedEntries = [DateModel]() {
        didSet {
            let periodEntries = selectedEntries.filter({ $0.dateType == .period })
            UserDefaults.standard.setValue(periodEntries.compactMap({ $0.dictionary }), forKey: "savedData")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Default init method
    override init() {
        super.init()
        fetchSavedData()
    }
    
    /// Fetch saved data
    func fetchSavedData() {
        guard let data = UserDefaults.standard.array(forKey: "savedData") else { return }
        data.forEach { saveItem in
            if let item = saveItem as? [String: Any] {
                self.selectedEntries.append(DateModel.build(withData: item))
            }
        }
        configureOvulationFertileDays()
    }
    
    /// Check if date entries contains any uneven start/end entry types
    var hasInProgressPeriod: Bool {
        let startEntries = selectedEntries.filter({ $0.timeline == .start }).count
        let endEntries = selectedEntries.filter({ $0.timeline == .end }).count
        return startEntries != endEntries
    }
    
    /// Days until the ovulation
    var untilOvulationDays: Int? {
        if let lastOvulationDate = selectedEntries.last(where: { $0.dateType == .ovulation })?.date {
            guard let days = Calendar.current.dateComponents([.day], from: Date(), to: lastOvulationDate).day else {
                return nil
            }
            if days == -1 { return -999 } /// show 1 day ago for ovulation
            return Date().fullDay == lastOvulationDate.fullDay ? 0 : (days + 1) >= 0 ? (days + 1) : nil
        }
        return nil
    }
    
    /// Days until the fertile days
    var untilFertileDays: Int? {
        if let lastOvulationDate = untilOvulationDays {
            return lastOvulationDate >= 3 ? lastOvulationDate - 3 : 0
        }
        return nil
    }
    
    /// Chance of getting pregnant
    var pregnancyChance: String {
        guard let ovulationDaysCount = untilOvulationDays else { return "Very low" }
        /// During ovulation day, there are high chances of getting pregnant
        if ovulationDaysCount <= 0 {
            return "High"
        }
        /// Whenever there are between 1 and 3 days left until the ovulation day, there are medium chances of getting pregnant
        if ovulationDaysCount >= 1 && ovulationDaysCount <= 3 {
            return "Medium"
        }
        return "Low"
    }
    
    /// Progress percentage until ovulation
    var ovulationProgress: CGFloat {
        guard let ovulationDaysCount = untilOvulationDays else { return 0.0 }
        return CGFloat(14-ovulationDaysCount) / 14.0
    }
}

// MARK: - Save/Delete date entries
extension PeriodManager {
    /// Save date entry
    func saveDateEntry(entry: DateModel) {
        if selectedEntries.contains(where: { $0.date.fullDay == entry.date.fullDay }) {
            selectedEntries.removeAll(where: { $0.date.fullDay == entry.date.fullDay })
        }
        selectedEntries.append(entry)
        currentSelectedDate = nil
        didSaveDateEntry = true
        configureOvulationFertileDays()
    }
    
    /// Delete current selected record
    func deleteDateEntry(date: Date?) {
        selectedEntries.removeAll(where: { $0.date.fullDay == date?.fullDay })
        currentSelectedDate = nil
        configureOvulationFertileDays()
    }
}

// MARK: - Configure ovulation and fertile days
extension PeriodManager {
    /// Based on the AppConfig details, setup the one ovulation day and a few fertile days
    func configureOvulationFertileDays() {
        let startEntries = selectedEntries.filter({ $0.timeline == .start })
        startEntries.forEach { periodStartDate in
            /// Add the 'x' days to the period start date to mark the ovulation date
            if let oDate = Calendar.current.date(byAdding: .day, value: AppConfig.ovulationDay-1, to: periodStartDate.date) {
                selectedEntries.append(DateModel(date: oDate, dateType: .ovulation, timeline: nil, flowType: nil))
                /// Add one fertile day after the ovulation
                if let fDate = Calendar.current.date(byAdding: .day, value: 1, to: oDate) {
                    selectedEntries.append(DateModel(date: fDate, dateType: .fertile, timeline: nil, flowType: nil))
                }
                /// Add 3 more fertile days prior to the ovulation
                for index in 1...3 {
                    if let fDate = Calendar.current.date(byAdding: .day, value: -index, to: oDate) {
                        selectedEntries.append(DateModel(date: fDate, dateType: .fertile, timeline: nil, flowType: nil))
                    }
                }
            }
        }
    }
}

// MARK: - Formatted days string
extension String {
    var formattedDays: String {
        if let daysCount = Int(components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
            let isToday = self.contains("-999") ? "1 DAY AGO" : (daysCount <= 0 ? "TODAY" : self)
            return daysCount == 1 ? self.replacingOccurrences(of: "s", with: "").replacingOccurrences(of: "S", with: "") : isToday
        }
        return self
    }
}
