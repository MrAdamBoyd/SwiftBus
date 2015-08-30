//
//  RequestURLs.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

let kSwiftBusAllAgenciesURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=agencyList"
let kSwiftBusAllRoutesURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=sf-muni"
let kSwiftBusRouteDefinitionURL = "http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r="
let kSwiftBusRoutePredictionURL1 = "http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&r="
let kSwiftBusRoutePredictionURL2 = "&s="