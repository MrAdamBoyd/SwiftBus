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
        
        SwiftBus.sharedController.transitAgencies({(agencies:[String : TransitAgency]) -> Void in
            println(agencies.count)
            println(agencies["sf-muni"])
        })
        
        SwiftBus.sharedController.routesForAgency("sf-muni", closure: {(agencyRoutes:[String : TransitRoute]) -> Void in
            println(agencyRoutes.count)
        })
        
        SwiftBus.sharedController.routesForAgency("sf-muni", closure: {(agencyRoutes:[String : TransitRoute]) -> Void in
            println(agencyRoutes.count)
        })
        
        SwiftBus.sharedController.routeConfiguration("5R", forAgency: "sf-muni", closure: {(route:TransitRoute?) -> Void in
            
            //If the route exists
            if let transitRoute = route as TransitRoute! {
                println(transitRoute.routeColor)
            }
            
        })
        
        SwiftBus.sharedController.stopPredictions("3909", onRoute: "N", withAgency: "sf-muni", closure: {(route:TransitStop?) -> Void in
            
            //If the stop and route exists
            if let transitStop = route as TransitStop! {
                println(transitStop.combinedPredictions())
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

