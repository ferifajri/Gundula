//
//  AchievementController.swift
//  Gundula
//
//  Created by Bryanza on 12/06/20.
//  Copyright © 2020 Feri Fajri. All rights reserved.
//

import UIKit
import ARKit

class AchievementController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    let cameraController = CameraController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCameraController()
    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.cameraView)
        }
    }
    
}
