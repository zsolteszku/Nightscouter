//
//  Site.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public struct Site: Dateable, CustomStringConvertible {
    public var configuration: ServerConfiguration?
    public var milliseconds: Double
    public var url: URL
    public var overrideScreenLock: Bool
    public var disabled: Bool
    
    public var sgvs: [SensorGlucoseValue] = []
    public var cals: [Calibration] = []
    public var mbgs: [MeteredGlucoseValue] = []
    public var deviceStatuses: [DeviceStatus] = []
    public var complicationTimeline: [ComplicationTimelineEntry] = []
    
    // public var allowNotifications: Bool // Will be used when we support push notifications. Future addition.
    // public var treatments: [Treatment] = [] // Will be used when we support display of treatments. Future addition.
    
    public var nextRefreshDate: Date {
        
        let nextRefreshDate = lastUpdatedDate?.addingTimeInterval(60.0 * 4) ?? Date.distantPast
        
        if let latestSGVDate = sgvs.first?.date {
            // nextRefreshDate = lastSGVDate.addingTimeInterval((60.0 * 4))
            print("latestSGV Date: \(latestSGVDate)")
        }
        
        print("iOS nextRefreshDate: " + nextRefreshDate.description)
        
        return nextRefreshDate
    }
    
    public var updateNow: Bool {
        
        // Get time information for right now.
        let now = Date()
        // Compare now against when we should update.
        let compare = now.compare(nextRefreshDate)
        
        // If the newDate is in the future do not update. Exit function.
        return (compare == .orderedDescending || configuration == nil) && disabled == false
    }
    
    public var lastUpdatedDate: Date? = nil
        {
        didSet {
            guard let lastUpdatedDate = lastUpdatedDate else {
                return
            }
            milliseconds = lastUpdatedDate.timeIntervalSince1970.millisecond
        }
    }
    
    public var uuid: UUID
    
    public var description: String {
        return "{ Site: { url: \(url), configuration: \(configuration), lastConnectedDate: \(date), disabled: \(disabled), numberOfSgvs: \(sgvs.count), numberOfCals: \(cals.count), , numberOfMbgs: \(mbgs.count), numberOfTimeLineEntries: \(complicationTimeline.count) } }"
    }
    
    public init(){
        self.url = URL(string: "https://nscgm.herokuapp.com")!
        self.configuration = ServerConfiguration()
        self.milliseconds = AppConfiguration.Constant.knownMilliseconds
        self.overrideScreenLock = false
        self.disabled = false
        
        self.uuid = UUID()
    }
    
    public init(url: URL){
        self.configuration = nil
        self.milliseconds = AppConfiguration.Constant.knownMilliseconds
        self.url = url
        self.overrideScreenLock = false
        self.disabled = false
        
        self.uuid = UUID()
    }
    
    /**
     Resets the underlying identity of the `Site`. If a copy of this item is made, and a call
     to refreshIdentity() is made afterward, the items will no longer be equal.
     */
    public mutating func refreshIdentity() {
        self.uuid = UUID()
    }
}

extension Site: Equatable { }
public func ==(lhs: Site, rhs: Site) -> Bool {
    return (lhs.uuid == rhs.uuid)
}

extension Site: Hashable {
    public var hashValue: Int {
        return uuid.hashValue + sgvs.count.hashValue + cals.count.hashValue + deviceStatuses.count.hashValue
    }
}

extension Site {
    public var apiSecret: String? {
        set{
            // write to keychain
            // AppConfiguration.keychain[uuid.UUIDString] = newValue
        }
        get{
            // return AppConfiguration.keychain[uuid.UUIDString]
            return nil
        }
        
    }// SHA1 retrieved from keychain?
    
    public init(url: URL, apiSecret: String){
        self.configuration = nil
        self.milliseconds = Date().timeIntervalSince1970.millisecond
        self.url = url
        self.overrideScreenLock = false
        self.disabled = false
        self.uuid = UUID()
        
        self.apiSecret = apiSecret
    }
    
    public init(url: URL, uuid: UUID){
        self.configuration = nil
        self.milliseconds = Date().timeIntervalSince1970.millisecond
        self.url = url
        self.overrideScreenLock = false
        self.disabled = false
        self.uuid = uuid
        
        // self.apiSecret = AppConfiguration.keychain[uuid.UUIDString]
    }
}

extension Site {
    public var summaryViewModel: SiteSummaryModelViewModel {
        return SiteSummaryModelViewModel(withSite: self)
    }
  
}

struct SiteChangeset {
    let configurationChanged: Bool
    let sgvsChanged: Bool
    let calsChanged: Bool
    let mbgsChanged: Bool
    let deviceStatusesChanged: Bool
    let complicationTimelineChanged: Bool
    
    init(site: Site, otherSite: Site) {
        configurationChanged = site.configuration == otherSite.configuration
        sgvsChanged = site.sgvs == otherSite.sgvs
        calsChanged = site.cals == otherSite.cals
        mbgsChanged = site.mbgs == otherSite.mbgs
        deviceStatusesChanged = site.deviceStatuses == otherSite.deviceStatuses
        complicationTimelineChanged = site.complicationTimeline == otherSite.complicationTimeline
    }
    
    init() {
        configurationChanged = false
        sgvsChanged = false
        calsChanged = false
        mbgsChanged = false
        deviceStatusesChanged = false
        complicationTimelineChanged = false
    }
}
