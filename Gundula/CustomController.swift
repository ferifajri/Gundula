//
//  CustomController.swift
//  Gundula
//
//  Created by Bryanza on 15/06/20.
//  Copyright © 2020 Feri Fajri. All rights reserved.
//

import UIKit
import ARKit

class CustomController: UIViewController {
    
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var playerTwo: UISwitch!
    @IBOutlet weak var playerOne: UIButton!
    let cameraController = CameraController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
//
//        button.frame = CGRectMake(100, 100, 200, 40)
//        button.setTitle("Get Started", forState: UIControlState.Normal)
//        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        button.backgroundColor = UIColor.clearColor()
        playerOne.layer.borderWidth = 1.0
        playerOne.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        playerOne.layer.cornerRadius = cornerRadius
//        playerOne.isSelected = true
        playerOne.setImage(UIImage(systemName: "person"), for: .selected)
        playerOne.setImage(UIImage(systemName: "phone"), for: .normal)
        playerTwo.onImage = UIImage(systemName: "person")
        playerTwo.offImage = UIImage(systemName: "phone")
        configureCameraController()
    }
 
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }

            try? self.cameraController.displayPreview(on: self.totalView)
        }
    }
}
