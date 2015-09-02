//
//  ViewController.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    @IBAction func agencyListTouched(sender: AnyObject) {
        SwiftBus.sharedController.transitAgencies({(agencies:[String : TransitAgency]) -> Void in
            println("Number of agencies loaded: \(agencies.count)")
            for agency in agencies.values {
                println("Name: " + agency.agencyTitle)
            }
            println()
        })
    }

    
    @IBAction func routesForAgencyTouched(sender: AnyObject) {
        //Alternative:
        //var agency = TransitAgency(agencyTag: "sf-muni")
        //agency.getAgencyData({(success:Bool, agency:TransitAgency) -> Void in
        SwiftBus.sharedController.routesForAgency("sf-muni", closure: {(agencyRoutes:[String : TransitRoute]) -> Void in
            println("Number of routes loaded for SF MUNI: \(agencyRoutes.count)")
            for route in agencyRoutes.values {
                println("Route title: " + route.routeTitle)
            }
            println()
        })
        
    }
    
    @IBAction func routeConfigurationTouched(sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
        SwiftBus.sharedController.routeConfiguration("5R", forAgency: "sf-muni", closure: {(route:TransitRoute?) -> Void in
            //If the route exists
            if let transitRoute = route as TransitRoute! {
                println("Route config for route " + transitRoute.routeTitle)
                println("Number of stops on route in one direction: \(transitRoute.stopsOnRoute.values.array[0].count)")
                println()
            }
            
        })
        
    }
    
    @IBAction func vehicleLocationsTouched(sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getVehicleLocations({(success:Bool, vehicles:[TransitVehicle]) -> Void in
        SwiftBus.sharedController.vehicleLocationsForRoute("N", forAgency: "sf-muni", closure:{(route:TransitRoute?) -> Void in
            if let transitRoute = route as TransitRoute! {
                println("\(transitRoute.vehiclesOnRoute.count) vehicles on route N Judah")
                println("Example vehicle:Vehcle ID: \(transitRoute.vehiclesOnRoute[0].vehicleId), \(transitRoute.vehiclesOnRoute[0].speedKmH) Km/h, \(transitRoute.vehiclesOnRoute[0].lat), \(transitRoute.vehiclesOnRoute[0].lon), seconds since report: \(transitRoute.vehiclesOnRoute[0].secondsSinceReport)")
                println()
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
                println("Stop: \(transitStop.stopTitle)")
                var predictionStrings:[Int] = transitStop.combinedPredictions().map({$0.predictionInMinutes})
                println("Predictions at stop \(predictionStrings) mins")
                println()
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

