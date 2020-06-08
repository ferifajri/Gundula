//
//  ViewController.swift
//  Gundula
//
//  Created by Feri Fajri on 08/06/20.
//  Copyright © 2020 Feri Fajri. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    //Configuration
    var gunduFieldAdded: Bool {
        return self.sceneView.scene.rootNode.childNode(withName: "Gundu", recursively: false) != nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        
        //detects horizontal surfaces
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        
        //add gesture recognizer to place GunduField
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gunduFieldAdded == true {
            guard let pointOfView = self.sceneView.pointOfView else {return}
            let transform = pointOfView.transform
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
            let position = location + orientation
            let gacoan = SCNNode(geometry: SCNSphere(radius: 0.3))
            gacoan.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            gacoan.position = position
            self.sceneView.scene.rootNode.addChildNode(gacoan)
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation  = sender.location(in: sceneView)
        //Check whether the hit is same
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        if !hitTestResult.isEmpty {
            // add Gundu Field
            self.addGunduField(hitTestResult: hitTestResult.first!)
        }
    }
    
    func addGunduField(hitTestResult: ARHitTestResult) {
        let gunduFieldScene = SCNScene(named: "GunduField.scnassets/GunduField.scn")
        let gunduNode = gunduFieldScene?.rootNode.childNode(withName: "Gundu", recursively: false)
        let positionOfPlane = hitTestResult.worldTransform.columns.3
        let xPosition = positionOfPlane.x
        let yPosition = positionOfPlane.y
        let zPosition = positionOfPlane.z
        
        gunduNode?.position = SCNVector3(xPosition,yPosition,zPosition)
        self.sceneView.scene.rootNode.addChildNode(gunduNode!)
        
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetected.isHidden = true
        }
    }
    
    

}

func +(left: SCNVector3, right:SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
