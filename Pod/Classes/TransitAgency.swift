//
//  TransitAgency.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let agencyTagEncoderString = "kAgencyTagEncoder"
private let agencyTitleEncoderString = "kAgencyTitleEncoder"
private let agencyShortTitleEncoderString = "kAgencyShortTitleEncoder"
private let agencyRegionEncoderString = "kAgencyRegionEncoder"
private let agencyRoutesEncoderString = "kAgencyRoutesEncoder"

public class TransitAgency: NSObject, NSCoding {
    
    public var agencyTag:String = ""
    public var agencyTitle:String = ""
    public var agencyShortTitle:String = ""
    public var agencyRegion:String = ""
    public var agencyRoutes:[String : TransitRoute] = [:]
    
    //Convenvience
    public override init() { }
    
    //User initialization, only need the agencyTag, everything else can be downloaded
    public init(agencyTag:String) {
        self.agencyTag = agencyTag
    }
    
    public init(agencyTag:String, agencyTitle:String, agencyRegion:String) {
        self.agencyTag = agencyTag
        self.agencyTitle = agencyTitle
        self.agencyRegion = agencyRegion
    }
    
    /**
    Downloads all agency data from provided agencytag
    
    - parameter closure:    Code that is called when the data is finished loading
        - parameter success:    Whether or not the call was successful
        - parameter agency:     The agency when the data is loaded
    */
    public func getAgencyAndRoutes(closure:(success:Bool, agency:TransitAgency) -> Void) {
        //We need to load the transit agency data
        let connectionHandler = SwiftBusConnectionHandler()
        
        //Need to request agency data first because only this call has the region and full name
        connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
            
            //Getting the current agency
            if let thisAgency = agencies[self.agencyTag] {
                self.agencyTitle = thisAgency.agencyTitle
                self.agencyShortTitle = thisAgency.agencyShortTitle
                self.agencyRegion = thisAgency.agencyRegion
                
                connectionHandler.requestAllRouteData(self.agencyTag, closure: {(newAgencyRoutes:[String : TransitRoute]) -> Void in
                    self.agencyRoutes = newAgencyRoutes
                    
                    closure(success: true, agency: self)
                    
                })
                
            } else {
                //This agency doesn't exist
                closure(success: false, agency: self)
            }
        })
    }

    //MARK : NSCoding
    
    required public init(coder aDecoder: NSCoder) {
        agencyTag = aDecoder.decodeObjectForKey(agencyTagEncoderString) as! String
        agencyTitle = aDecoder.decodeObjectForKey(agencyTitleEncoderString) as! String
        agencyShortTitle = aDecoder.decodeObjectForKey(agencyShortTitleEncoderString) as! String
        agencyRegion = aDecoder.decodeObjectForKey(agencyRegionEncoderString) as! String
        agencyRoutes = aDecoder.decodeObjectForKey(agencyRoutesEncoderString) as! [String : TransitRoute]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(agencyTag, forKey: agencyTagEncoderString)
        aCoder.encodeObject(agencyTitle, forKey: agencyTitleEncoderString)
        aCoder.encodeObject(agencyShortTitle, forKey: agencyShortTitleEncoderString)
        aCoder.encodeObject(agencyRegion, forKey: agencyRegionEncoderString)
        aCoder.encodeObject(agencyRoutes, forKey: agencyRoutesEncoderString)
    }
}