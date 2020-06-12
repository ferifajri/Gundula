//
//  WelcomeController.swift
//  Gundula
//
//  Created by Bryanza on 11/06/20.
//  Copyright © 2020 Feri Fajri. All rights reserved.
//

import UIKit
import ARKit

class WelcomeController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet weak var sceneView: ARSKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
}

