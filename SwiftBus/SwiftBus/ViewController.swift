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
        
        SwiftBus.sharedController.getAgencies({(agencies:[TransitAgency]) -> Void in
            println(agencies.count)
            println(SwiftBus.sharedController.transitAgencies[0].agencyTag)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

