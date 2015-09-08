//
//  ViewController.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import UIKit
import SwiftBus

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func agencyListTouched(sender: AnyObject) {
        SwiftBus.sharedController.transitAgencies({(agencies:[String : TransitAgency]) -> Void in
            print("Number of agencies loaded: \(agencies.count)", terminator: "\n")
            for agency in agencies.values {
                print("Name: " + agency.agencyTitle, terminator: "\n")
            }
            print("")
        })
    }

    
    @IBAction func routesForAgencyTouched(sender: AnyObject) {
        //Alternative:
        //var agency = TransitAgency(agencyTag: "sf-muni")
        //agency.getAgencyData({(success:Bool, agency:TransitAgency) -> Void in
        SwiftBus.sharedController.routesForAgency("sf-muni", closure: {(agencyRoutes:[String : TransitRoute]) -> Void in
            print("Number of routes loaded for SF MUNI: \(agencyRoutes.count)\n")
            for route in agencyRoutes.values {
                print("Route title: " + route.routeTitle)
            }
            print("\n")
        })
        
    }
    
    @IBAction func routeConfigurationTouched(sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
        SwiftBus.sharedController.routeConfiguration("5R", forAgency: "sf-muni", closure: {(route:TransitRoute?) -> Void in
            //If the route exists
            if let transitRoute = route as TransitRoute! {
                print("Route config for route " + transitRoute.routeTitle + "\n")
                print("Number of stops on route in one direction: \(Array(transitRoute.stopsOnRoute.values)[0].count)\n")
                print("\n")
            }
            
        })
        
    }
    
    @IBAction func vehicleLocationsTouched(sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getVehicleLocations({(success:Bool, vehicles:[TransitVehicle]) -> Void in
        SwiftBus.sharedController.vehicleLocationsForRoute("N", forAgency: "sf-muni", closure:{(route:TransitRoute?) -> Void in
            if let transitRoute = route as TransitRoute! {
                print("\(transitRoute.vehiclesOnRoute.count) vehicles on route N Judah\n")
                print("Example vehicle:Vehcle ID: \(transitRoute.vehiclesOnRoute[0].vehicleId), \(transitRoute.vehiclesOnRoute[0].speedKmH) Km/h, \(transitRoute.vehiclesOnRoute[0].lat), \(transitRoute.vehiclesOnRoute[0].lon), seconds since report: \(transitRoute.vehiclesOnRoute[0].secondsSinceReport)\n")
                print("\n")
            }
        })
        
    }
    
    @IBAction func stopPredictionsTouched(sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getStopPredictionsForStop("3909", finishedLoading: {(success:Bool, predictions:[String : [TransitPrediction]]) -> Void in
        SwiftBus.sharedController.stopPredictions("3909", onRoute: "N", withAgency: "sf-muni", closure: {(route:TransitStop?) -> Void in
            
            //If the stop and route exists
            if let transitStop = route as TransitStop! {
                print("Stop: \(transitStop.stopTitle)", terminator: "\n")
                let predictionStrings:[Int] = transitStop.combinedPredictions().map({$0.predictionInMinutes})
                print("Predictions at stop \(predictionStrings) mins", terminator: "\n")
                print("", terminator: "\n")
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

