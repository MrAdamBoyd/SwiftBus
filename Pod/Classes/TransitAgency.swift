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

open class TransitAgency: NSObject, NSCoding {
    
    open var agencyTag:String = ""
    open var agencyTitle:String = ""
    open var agencyShortTitle:String = ""
    open var agencyRegion:String = ""
    open var agencyRoutes:[String : TransitRoute] = [:]
    
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
    open func getAgencyAndRoutes(_ closure:@escaping (_ success:Bool, _ agency:TransitAgency) -> Void) {
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
                    
                    closure(true, self)
                    
                })
                
            } else {
                //This agency doesn't exist
                closure(false, self)
            }
        })
    }

    //MARK : NSCoding
    
    required public init(coder aDecoder: NSCoder) {
        agencyTag = aDecoder.decodeObject(forKey: agencyTagEncoderString) as! String
        agencyTitle = aDecoder.decodeObject(forKey: agencyTitleEncoderString) as! String
        agencyShortTitle = aDecoder.decodeObject(forKey: agencyShortTitleEncoderString) as! String
        agencyRegion = aDecoder.decodeObject(forKey: agencyRegionEncoderString) as! String
        agencyRoutes = aDecoder.decodeObject(forKey: agencyRoutesEncoderString) as! [String : TransitRoute]
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(agencyTag, forKey: agencyTagEncoderString)
        aCoder.encode(agencyTitle, forKey: agencyTitleEncoderString)
        aCoder.encode(agencyShortTitle, forKey: agencyShortTitleEncoderString)
        aCoder.encode(agencyRegion, forKey: agencyRegionEncoderString)
        aCoder.encode(agencyRoutes, forKey: agencyRoutesEncoderString)
    }
}
