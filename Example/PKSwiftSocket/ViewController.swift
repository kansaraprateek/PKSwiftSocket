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
    
    let pksocketobj : PKSocket = PKSocket(lAddress : <Address>, lPort : <Port>)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        pksocketobj.handleConnection({
            data in
            if data == nil{
                self.pksocketobj.sendDataToStream("")
            }else{
                print(data!)
            }
        }, Error: {
                error in
            print(error)
        })
        
        /**
         Send data to address
         */
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

