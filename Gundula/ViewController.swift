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
    
    var startTime: Date?
    var difference:Float = 0
    
    //Configuration
    var power:Float = 2.0
    var gunduFieldAdded: Bool {
        return self.sceneView.scene.rootNode.childNode(withName: "Gundu", recursively: false) != nil
    }
    var gacoanAdded: Bool {
        return self.sceneView.scene.rootNode.childNode(withName: "Gacoan", recursively: false) != nil
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
    
//    func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
//        let referenceNodeTransform = matrix_float4x4(referenceNode.transform)
//
//        // Setup a translation matrix with the desired position
//        var translationMatrix = matrix_identity_float4x4
//        translationMatrix.columns.3.x = position.x
//        translationMatrix.columns.3.y = position.y
//        translationMatrix.columns.3.z = position.z
//
//        // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
//        let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
//        node.transform = SCNMatrix4(updatedTransform)
//    }
    
    func addGacoan() {
        guard let pointOfView = self.sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
        let position = location + orientation
        let gacoan = SCNNode(geometry: SCNSphere(radius: 0.1))
        gacoan.name = "Gacoan"
        gacoan.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        gacoan.position = position
        //updatePositionAndOrientationOf(gacoan, withPosition: position, relativeTo: pointOfView)
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: gacoan))
        //body.isAffectedByGravity = false
        gacoan.physicsBody = body
        self.sceneView.scene.rootNode.addChildNode(gacoan)
        
    }
    
    func pressGacoan() {
        if self.gunduFieldAdded == true && gacoanAdded == true {
            }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.gunduFieldAdded == true {

            if self.gacoanAdded == false {
                self.addGacoan()
                }
            else {
                startTime = Date()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        let difference = Float(Date().timeIntervalSince(startTime!))
        print(difference)
        self.power = self.power + difference
        print(self.power)
            
        let touch = touches.first
        if(touch?.view == self.sceneView){
        let viewTouchLocation:CGPoint = touch!.location(in: sceneView)
        guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {return}
        if result.node.name == "Gacoan" {
                //self.sentilGacoan(result)
            let gacoan = result.node
            guard let pointOfView = self.sceneView.pointOfView else {return}
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
                //self.power = self.power * difference
                                                //gacoan.physicsBody?.applyForce(SCNVector3(0,0,-1), asImpulse: true)
            gacoan.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power,orientation.z*power), asImpulse: true)
            
            }
            
            
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation  = sender.location(in: sceneView)
        //Check whether the hit is same
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])

        if !hitTestResult.isEmpty {
            // add Gundu Field
            //self.addGunduField(hitTestResult: hitTestResult.first!)
            guard let hitTestResult = hitTestResult.first else { return }
            if self.gunduFieldAdded == false {
                self.addGunduField(hitTestResult: hitTestResult)
                }
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
        gunduNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: gunduNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        self.sceneView.scene.rootNode.addChildNode(gunduNode!)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
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
