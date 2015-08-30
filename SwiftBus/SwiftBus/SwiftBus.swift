//
//  SwiftBus.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

class SwiftBus {
    static let sharedController = SwiftBus()
    
    var transitAgencies:[TransitAgency] = []
    
    private init() {
        println("SwiftBus initialized")
    }
    
    func getAgencies(closure: ((agencies:[TransitAgency]) -> Void)?) {
        let connectionHandler = ConnectionHandler()
        connectionHandler.requestAllAgencies({(agencies:[TransitAgency]) -> Void in
            //Insert this closure around the inner one because the agencies need to be saved
            self.transitAgencies = agencies
            
            if let innerClosure = closure as ([TransitAgency] -> Void)! {
                innerClosure(agencies)
            }
        })
    }
    
    /*
        List of calls that are pulled live each time
        -Stop predictions
        -Vehicle locations
        
        List of calls that are not pulled live each time
        -Agency list
        -List of lines in an agency
        -List of stops per line
    */
}