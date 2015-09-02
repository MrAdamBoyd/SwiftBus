//
//  TransitAgency.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let kAgencyTagEncoderString = "kAgencyTagEncoder"
private let kAgencyTitleEncoderString = "kAgencyTitleEncoder"
private let kAgencyShortTitleEncoderString = "kAgencyShortTitleEncoder"
private let kAgencyRegionEncoderString = "kAgencyRegionEncoder"
private let kAgencyRoutesEncoderString = "kAgencyRoutesEncoder"

class TransitAgency: NSObject, NSCoding {
    
    var agencyTag:String = ""
    var agencyTitle:String = ""
    var agencyShortTitle:String = ""
    var agencyRegion:String = ""
    var agencyRoutes:[String : TransitRoute] = [:]
    
    //Convenvience
    override init() { }
    
    //User initialization, only need the agencyTag, everything else can be downloaded
    init(agencyTag:String) {
        self.agencyTag = agencyTag
    }
    
    init(agencyTag:String, agencyTitle:String, agencyRegion:String) {
        self.agencyTag = agencyTag
        self.agencyTitle = agencyTitle
        self.agencyRegion = agencyRegion
    }
    
    /**
    Downloads all agency data from provided agencytag
    
    :param: finishedLoading Code that is called when the data is finished loading
        :param: success Whether or not the call was successful
        :param: agency  The agency when the data is loaded
    */
    func getAgencyData(finishedLoading:(success:Bool, agency:TransitAgency) -> Void) {
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
                    
                    finishedLoading(success: true, agency: self)
                    
                })
                
            } else {
                //This agency doesn't exist
                finishedLoading(success: false, agency: self)
            }
        })
    }

    //MARK : NSCoding
    
    required init(coder aDecoder: NSCoder) {
        agencyTag = aDecoder.decodeObjectForKey(kAgencyTagEncoderString) as! String
        agencyTitle = aDecoder.decodeObjectForKey(kAgencyTitleEncoderString) as! String
        agencyShortTitle = aDecoder.decodeObjectForKey(kAgencyShortTitleEncoderString) as! String
        agencyRegion = aDecoder.decodeObjectForKey(kAgencyRegionEncoderString) as! String
        agencyRoutes = aDecoder.decodeObjectForKey(kAgencyRoutesEncoderString) as! [String : TransitRoute]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(agencyTag, forKey: kAgencyTagEncoderString)
        aCoder.encodeObject(agencyTitle, forKey: kAgencyTitleEncoderString)
        aCoder.encodeObject(agencyShortTitle, forKey: kAgencyShortTitleEncoderString)
        aCoder.encodeObject(agencyRegion, forKey: kAgencyRegionEncoderString)
        aCoder.encodeObject(agencyRoutes, forKey: kAgencyRoutesEncoderString)
    }
}