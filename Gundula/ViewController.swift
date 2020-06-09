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
        return self.sceneView.scene.rootNode.childNode(withName: "GunduField", recursively: false) != nil
    }
    var gacoanAdded: Bool {
        return self.sceneView.scene.rootNode.childNode(withName: "Gacoan", recursively: false) != nil
    }
    
    var gunduFieldWidth:CGFloat = 2.0
    var gunduFieldHeight:CGFloat = 2.0
    
    
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
        let gacoan = SCNNode(geometry: SCNSphere(radius: self.gunduFieldHeight/50))
        gacoan.name = "Gacoan"
        gacoan.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "gacoan-1")
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
        self.power = self.power + difference
            
        let touch = touches.first
        if(touch?.view == self.sceneView){
        let viewTouchLocation:CGPoint = touch!.location(in: sceneView)
        guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {return}
        if result.node.name == "Gacoan" {
            let gacoan = result.node
            guard let pointOfView = self.sceneView.pointOfView else {return}
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
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
//        let gunduFieldScene = SCNScene(named: "GunduField.scnassets/GunduField.scn")
//        let gunduNode = gunduFieldScene?.rootNode.childNode(withName: "Gundu", recursively: false)
//        let positionOfPlane = hitTestResult.worldTransform.columns.3
//        let xPosition = positionOfPlane.x
//        let yPosition = positionOfPlane.y
//        let zPosition = positionOfPlane.z
//
//        gunduNode?.position = SCNVector3(xPosition,yPosition,zPosition)
//        gunduNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: gunduNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        self.sceneView.scene.rootNode.addChildNode(gunduNode!)
        
        let gunduFieldNode = SCNNode()
        
        let gunduFieldWidth = self.gunduFieldWidth
        let gunduFieldHeight = self.gunduFieldHeight
        
//        gunduFieldNode.geometry = SCNPlane(width: 0.4, height: 0.4)
        gunduFieldNode.geometry = SCNPlane(width: gunduFieldWidth, height: gunduFieldHeight)
        gunduFieldNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "grass2")
        gunduFieldNode.geometry?.firstMaterial?.isDoubleSided = true
        gunduFieldNode.name = "GunduField"
        
        let positionOfPlane = hitTestResult.worldTransform.columns.3
        let xPosition = positionOfPlane.x
        let yPosition = positionOfPlane.y
        let zPosition = positionOfPlane.z
        
        //gunduFieldNode.position = SCNVector3(0,0,-0.5)
        gunduFieldNode.position = SCNVector3(xPosition,yPosition,zPosition)
        gunduFieldNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: gunduFieldNode, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        gunduFieldNode.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
        
        self.sceneView.scene.rootNode.addChildNode(gunduFieldNode)
        
        //let wall1 = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.5))
        let wall1 = SCNNode(geometry: SCNBox(width: 0.01, height: gunduFieldHeight/10, length: gunduFieldHeight, chamferRadius: 0))
        wall1.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_moon")
        wall1.position = SCNVector3(gunduFieldHeight/2,0,0.05)
        wall1.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
        wall1.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall1, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        gunduFieldNode.addChildNode(wall1)
        
        let wall2 = SCNNode(geometry: SCNBox(width: 0.01, height: gunduFieldHeight/10, length: gunduFieldHeight, chamferRadius: 0))
        wall2.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_moon")
        wall2.position = SCNVector3(-gunduFieldHeight/2,0,0.05)
        wall2.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
        wall2.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall2, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        gunduFieldNode.addChildNode(wall2)
        
        //let wall1 = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.5))
        let wall3 = SCNNode(geometry: SCNBox(width: 0.01, height: gunduFieldHeight/10, length: gunduFieldHeight, chamferRadius: 0))
        wall3.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_moon")
        wall3.position = SCNVector3(0,gunduFieldHeight/2,0.05)
        wall3.eulerAngles = SCNVector3(-90.degreestoRadians,0,-90.degreestoRadians)
        wall3.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall3, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        gunduFieldNode.addChildNode(wall3)
        
        //let wall1 = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.5))
        let wall4 = SCNNode(geometry: SCNBox(width: 0.01, height: gunduFieldHeight/10, length: gunduFieldHeight, chamferRadius: 0))
        wall4.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_moon")
        wall4.position = SCNVector3(0,-gunduFieldHeight/2,0.05)
        wall4.eulerAngles = SCNVector3(-90.degreestoRadians,0,-90.degreestoRadians)
        wall4.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall4, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        gunduFieldNode.addChildNode(wall4)
        
        //let circle = SCNNode(geometry: SCNCylinder(radius: gunduFieldHeight/10, height: 0.01))
        let circle = SCNNode(geometry: SCNTorus(ringRadius: gunduFieldHeight/10, pipeRadius: 0.001))
        circle.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        circle.position = SCNVector3(0,0,0)
        circle.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
        //circle.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall4, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        gunduFieldNode.addChildNode(circle)
        
        //let circle = SCNNode(geometry: SCNCylinder(radius: gunduFieldHeight/10, height: 0.01))
        let sasaran = SCNNode(geometry: SCNSphere(radius: self.gunduFieldHeight/50))
        sasaran.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "sasaran-1")
        sasaran.position = SCNVector3(0,0,gunduFieldHeight/50*2)
        sasaran.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
        sasaran.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: sasaran, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        gunduFieldNode.addChildNode(sasaran)
        
        
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

extension Int {
    var degreestoRadians: Double {return Double(self) * .pi / 180 }
}
