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
    @IBOutlet weak var playerTwo: UIButton!
    @IBOutlet weak var playerOne: UIButton!
    @IBOutlet weak var ballTwo: UIImageView!
    @IBOutlet weak var ballOne: UIImageView!
    let cameraController = CameraController()
    var counter = 1
    var maxPhoto = 3
    
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
        playerOne.isSelected = false
        playerOne.setImage(UIImage(systemName: "person"), for: .selected)
        playerOne.setImage(UIImage(systemName: "phone"), for: .normal)
        playerTwo.isSelected = true
        playerTwo.setImage(UIImage(systemName: "person"), for: .selected)
        playerTwo.setImage(UIImage(systemName: "phone"), for: .normal)
//        playerTwo.onImage = UIImage(systemName: "person")
//        playerTwo.offImage = UIImage(systemName: "phone")
        let swipeGest = UISwipeGestureRecognizer(target: self, action:  #selector (self.changeBall(sender:)))
        swipeGest.view?.tag = 123
        ballOne.addGestureRecognizer(swipeGest)
        swipeGest.view?.tag = 456
        ballTwo.addGestureRecognizer(swipeGest)
        configureCameraController()
    }
    
    @objc func changeBall(sender:UISwipeGestureRecognizer){
        switch sender.direction {
        case .left :
            if counter == maxPhoto {
                counter = maxPhoto
            }else{
                counter += 1
            }
            checkSender(sender)
        case .right:
            if counter == 1 {
                counter = 1
            }else{
                counter -= 1
            }
            checkSender(sender)
        default:
            return
        }
    }
    
    func checkSender(_ sender:UISwipeGestureRecognizer) {
        if sender.view?.tag == 123 {
            ballOne.image = #imageLiteral(resourceName: "ball\(counter)")
        }else{
            ballTwo.image = #imageLiteral(resourceName: "ball\(counter)")
        }
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
