//
//  ViewController.swift
//  PKSwiftSocket
//
//  Created by Prateek Kansara on 07/14/2016.
//  Copyright (c) 2016 Prateek Kansara. All rights reserved.
//

import UIKit
import PKSwiftSocket

class ViewController: UIViewController {
    
    let address = ""
    let port = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let pksocketobj : PKSocket = PKSocket(lAddress : address, lPort : port)
        
        pksocketobj.handleConnection({
            
            }, data: {
                (Data : String) in
                // Handle response data
                print("Response data : \(Data)")
                
                
            }, Error: {
                (errorString : String) in
                // Error when connection to address
                print("Error : \(errorString)")
                
        })
        
        /**
         Send data to address
         */
        pksocketobj.sendDataToStream("")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

