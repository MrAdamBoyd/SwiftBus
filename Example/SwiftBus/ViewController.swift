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
    
    @IBAction func agencyListTouched(_ sender: AnyObject) {
        SwiftBus.sharedController.transitAgencies({(agencies:[String : TransitAgency]) -> Void in
            let agenciesString = "Number of agencies loaded: \(agencies.count)"
            let agencyNamesString = agencies.map({_, agency in "\(agency.agencyTitle)"})
            
            print("\n-----")
            print(agenciesString)
            print(agencyNamesString)
            
            self.showAlertControllerWithTitle(agenciesString, message: "\(agencyNamesString)")
        })
    }

    
    @IBAction func routesForAgencyTouched(_ sender: AnyObject) {
        //Alternative:
        //var agency = TransitAgency(agencyTag: "sf-muni")
        //agency.getAgencyData({(success:Bool, agency:TransitAgency) -> Void in
        SwiftBus.sharedController.routesForAgency("sf-muni", closure: {(agencyRoutes:[String : TransitRoute]) -> Void in
            let agencyString = "Number of routes loaded for SF MUNI: \(agencyRoutes.count)"
            let routeNamesString = agencyRoutes.map({_, route in "\(route.routeTitle)"})
            
            print("\n-----")
            print(agencyString)
            print(routeNamesString)
            
            self.showAlertControllerWithTitle(agencyString, message: "\(routeNamesString)")
        })
        
    }
    
    @IBAction func routeConfigurationTouched(_ sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
        SwiftBus.sharedController.routeConfiguration("5R", forAgency: "sf-muni", closure: {(route:TransitRoute?) -> Void in
            //If the route exists
            if let transitRoute = route as TransitRoute! {
                let routeCongigMessage = "Route config for route \(transitRoute.routeTitle)"
                let numberOfStopsMessage = "Number of stops on route in one direction: \(Array(transitRoute.stopsOnRoute.values)[0].count)"
                
                print("\n-----")
                print(routeCongigMessage)
                print(numberOfStopsMessage)
                
                self.showAlertControllerWithTitle(routeCongigMessage, message: numberOfStopsMessage)
            }
            
        })
        
    }
    
    @IBAction func vehicleLocationsTouched(_ sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getVehicleLocations({(success:Bool, vehicles:[TransitVehicle]) -> Void in
        SwiftBus.sharedController.vehicleLocationsForRoute("N", forAgency: "sf-muni", closure:{(route:TransitRoute?) -> Void in
            if let transitRoute = route as TransitRoute! {
                let vehicleTitleMessage = "\(transitRoute.vehiclesOnRoute.count) vehicles on route N Judah"
                let messageString = "Example vehicle:Vehcle ID: \(transitRoute.vehiclesOnRoute[0].vehicleId), \(transitRoute.vehiclesOnRoute[0].speedKmH) Km/h, \(transitRoute.vehiclesOnRoute[0].lat), \(transitRoute.vehiclesOnRoute[0].lon), seconds since report: \(transitRoute.vehiclesOnRoute[0].secondsSinceReport)"
                
                print("\n-----")
                print(vehicleTitleMessage)
                print(messageString)
                
                self.showAlertControllerWithTitle(vehicleTitleMessage, message: messageString)
            }
        })
        
    }

    @IBAction func stationPredictionsTouched(_ sender: AnyObject) {
        SwiftBus.sharedController.stationPredictions("5726", forRoutes: ["KT", "L", "M"], withAgency: "sf-muni", closure: {(station: TransitStation?) -> Void in
            if let transitStation = station as TransitStation! {
                let lineTitles = "Prediction for lines: \(transitStation.routesAtStation.map({"\($0.routeTitle)"}))"
                let predictionStrings = "Predictions at stop \(transitStation.combinedPredictions().map({$0.predictionInMinutes}))"
                
                print("\n-----")
                print("Station: \(transitStation.stopTitle)")
                print(lineTitles)
                print(predictionStrings)
                
                self.showAlertControllerWithTitle(lineTitles, message: "\(predictionStrings)")
            }
        })
    }
    
    
    @IBAction func stopPredictionsTouched(_ sender: AnyObject) {
        //Alternative:
        //var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
        //route.getStopPredictionsForStop("3909", closure: {(success:Bool, predictions:[String : [TransitPrediction]]) -> Void in
        SwiftBus.sharedController.stopPredictions("3909", onRoute: "N", withAgency: "sf-muni", closure: {(route:TransitStop?) -> Void in
            
            //If the stop and route exists
            if let transitStop = route as TransitStop! {
                let predictionStrings:[Int] = transitStop.combinedPredictions().map({$0.predictionInMinutes})
                
                print("\n-----")
                print("Stop: \(transitStop.stopTitle)")
                print("Predictions at stop \(predictionStrings) mins")
                
                self.showAlertControllerWithTitle("Stop Predictions for stop \(transitStop.stopTitle)", message: "\(predictionStrings)")
            }
            
        })
        
    }
    
    func showAlertControllerWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

