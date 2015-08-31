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
    
    private var transitAgencies:[String : TransitAgency] = [:]
    
    private init() {
        println("SwiftBus initialized")
    }
    
    /**
    Gets the list of agencies from the nextbus API or what is already in memory if getAgencies has been called before
    
    agencies.keys.array will return a list of the keys used
    agencies.values.array will return a list of TransitAgencies
    
    :param: closure Code that is called after the dictionary of agencies has loaded
    */
    func transitAgencies(closure: ((agencies:[String : TransitAgency]) -> Void)?) {
        
        if transitAgencies.count > 0 {
            
            //Transit agency data is in memory, provide that
            if let innerClosure = closure as ([String : TransitAgency] -> Void)! {
                innerClosure(transitAgencies)
            }
            
        } else {
            
            //We need to load the transit agency data
            let connectionHandler = ConnectionHandler()
            connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
                //Insert this closure around the inner one because the agencies need to be saved
                self.transitAgencies = agencies
                
                if let innerClosure = closure as ([String : TransitAgency] -> Void)! {
                    innerClosure(agencies)
                }
            })
            
        }
    }
    
    /**
    List of keys that can be used to access the TransitAgency objects in the dictionary of TransitAgencies
    
    :param: closure Code that is called after the keys have loaded
    */
    func getTransitAgencyDictionaryKeys(closure: ((agencyKeys:[String]) -> Void)?) {
        
        if transitAgencies.count > 0 {
            
            //Transit agency data is in memory, provide that
            if let innerClosure = closure as ([String] -> Void)! {
                innerClosure(transitAgencies.keys.array)
            }
            
        } else {
            
            //We need to load the transit agency data
            let connectionHandler = ConnectionHandler()
            connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
                //Insert this closure around the inner one because the agencies need to be saved
                self.transitAgencies = agencies
                
                if let innerClosure = closure as ([String] -> Void)! {
                    innerClosure(agencies.keys.array)
                }
            })
            
        }
    }
    
    /**
    Array of all TransitAgencies
    
    :param: closure Code that is called after the TransitAgencies have loaded. If they are already loaded, the code will be called immediately
    */
    func getTransitAgencyArray(closure: ((transitAgencies:[TransitAgency]) -> Void)?) {
        
        if transitAgencies.count > 0 {
            
            //Transit agency data is in memory, provide that
            if let innerClosure = closure as ([TransitAgency] -> Void)! {
                innerClosure(transitAgencies.values.array)
            }
            
        } else {
            
            //We need to load the transit agency data
            let connectionHandler = ConnectionHandler()
            connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
                //Insert this closure around the inner one because the agencies need to be saved
                self.transitAgencies = agencies
                
                if let innerClosure = closure as ([TransitAgency] -> Void)! {
                    innerClosure(agencies.values.array)
                }
            })
            
        }

    }
    
    /**
    The dictionary of transit agencies is saved in memory, but if it needs to be refreshed, this method can be called
    
    :param: closure Code that is called after the TransitAgency dictionary has been refreshed
    */
    func refreshTransitAgencies(closure: ((agencies:[String : TransitAgency]) -> Void)?) {
        //We need to load the transit agency data
        let connectionHandler = ConnectionHandler()
        connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
            //Insert this closure around the inner one because the agencies need to be saved
            self.transitAgencies = agencies
            
            if let innerClosure = closure as ([String : TransitAgency] -> Void)! {
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