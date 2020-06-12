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
    @IBOutlet weak var achievementView: UIView!
    
    let cameraController = CameraController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let storyboard = UIStoryboard(name: "WelcomeScreen", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "Achievement") as? WelcomeController
//        self.sceneView.delegate = self
//        self.sceneView.showsFPS = true
//        self.sceneView.showsNodeCount = true
        
        // Do any additional setup after loading the view.
        // here we instantiate an object of gesture recognizer
        let gestureRec = UITapGestureRecognizer(target: self, action:  #selector (self.achievementButton(sender:)))
        // here we add it to our custom view
        self.achievementView.addGestureRecognizer(gestureRec)
        configureCameraController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
    }
      
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    @objc func achievementButton(sender:UITapGestureRecognizer){
        performSegue(withIdentifier: "achievementSegue", sender: self)
    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.sceneView)
        }
    }
    
}

extension WelcomeController {
    func session(_ session: ARSession,
               didFailWithError error: Error) {
        print("Session Failed - probably due to lack of camera access")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        print("Session interrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session resumed")
        self.sceneView.session.run(session.configuration!,
                            options: [.resetTracking,
                                      .removeExistingAnchors])
    }
}

