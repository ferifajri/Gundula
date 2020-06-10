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
    
    ////  Tes
    var center: CGPoint!
    var positions = [SCNVector3]()
    let arrow = SCNScene(named: "art.scnassets/arrow.scn")!.rootNode
    let GunduFieldNodeDisable = SCNScene(named: "GunduField.scnassets/GunduFieldDisable.scn")!.rootNode
    let GunduFieldNode = SCNScene(named: "GunduField.scnassets/GunduField.scn")!.rootNode
    
    var isGameOn:Bool = false
    var isGunduFieldAdded:Bool = false
    var isGacoanAdded:Bool = false
    
    ///
    
    var startTime: Date?
    var difference:Float = 0
    
    //Configuration
    var power:Float = 2.0
//    var gunduFieldAdded: Bool {
////        return self.sceneView.scene.rootNode.childNode(withName: "GunduField", recursively: false) != nil
//        return self.sceneView.scene.rootNode.childNode(withName: "GunduField", recursively: false) != nil
//    }
//    var gacoanAdded: Bool {
//        return self.sceneView.scene.rootNode.childNode(withName: "Gacoan", recursively: false) != nil
//    }
    
    var gunduFieldWidth:CGFloat = 2.0
    var gunduFieldHeight:CGFloat = 2.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        
        //detects horizontal surfaces
        self.configuration.planeDetection = .horizontal
        //self.sceneView.session.run(configuration)
        
        //self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        center = view.center
        
        sceneView.scene.rootNode.addChildNode(self.arrow)
        
        
        
        //add gesture recognizer to place GunduField
        
        //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        //self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // Do any additional setup after loading the view.
    }
    
    ////  Tes
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isGameOn && self.isGunduFieldAdded == false) {
            //place GameNode
            //guard let angle = sceneView.session.currentFrame?.camera.eulerAngles.y else {return}
            self.GunduFieldNodeDisable.position = self.arrow.position
            //GunduFieldNodeDisable.eulerAngles.y = angle
            isGameOn = true
            
            self.sceneView.scene.rootNode.addChildNode(self.GunduFieldNodeDisable)
            arrow.removeFromParentNode()
            
            let tapFieldGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapField(sender:)))
            self.sceneView.addGestureRecognizer(tapFieldGestureRecognizer)
            
            let resizeFieldGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchResizeField(sender:)))
            self.sceneView.addGestureRecognizer(resizeFieldGestureRecognizer)
            
            //print(self.gunduFieldAdded)
            
        }
        else if (isGameOn == true && self.isGunduFieldAdded == true) {
            print("add gacoan")
            if self.isGacoanAdded == false {
                self.addGacoan()
                }
            else {
                startTime = Date()
            }
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOn && self.isGunduFieldAdded == true && self.isGacoanAdded == true {

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
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: gacoan))
            gacoan.physicsBody = body
            gacoan.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power,orientation.z*power), asImpulse: true)
            }
        }
            
            }
    }
    
    @objc func handleTapField(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation  = sender.location(in: sceneView)
        //Check whether the hit is same
        // This one using existing plane on world object
        //let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        //this one using any touch location
        let hitTestResult = sceneView.hitTest(touchLocation)

        if !hitTestResult.isEmpty {
            // add Gundu Field
            guard let hitTestResult = hitTestResult.first else { return }
//            print(hitTestResult)
////            print(hitTestResult.node.name)
//
//            if self.gunduFieldAdded == false {
//
//                //self.addGunduField(hitTestResult: hitTestResult)
//            }
            
            if ((hitTestResult.node.name?.isEmpty) == nil) {

            }
            else if (hitTestResult.node.name == "Play") {
                self.GunduFieldNode.position = self.GunduFieldNodeDisable.position
                self.GunduFieldNode.scale = self.GunduFieldNodeDisable.scale
                self.GunduFieldNodeDisable.removeFromParentNode()
                self.sceneView.scene.rootNode.addChildNode(self.GunduFieldNode)
                self.isGameOn = true
                self.isGunduFieldAdded = true
                print(self.isGunduFieldAdded)
            }
            else {
                //print(hitTestResult.node.name!)

            }
        }
    }
    
    @objc func handlePinchResizeField(sender: UIPinchGestureRecognizer) {
        //guard let sceneView = sender.view as? ARSCNView else {return}
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            if (node.parent?.name == "GunduFieldDisable") {
//                print(sceneView.scene)
                if (sender.state == .changed) {
                    let pinchScaleX = Float(sender.scale) * GunduFieldNodeDisable.scale.x
                    let pinchScaleY =  Float(sender.scale) * GunduFieldNodeDisable.scale.y
                    let pinchScaleZ =  Float(sender.scale) * GunduFieldNodeDisable.scale.z
                    GunduFieldNodeDisable.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
                    sender.scale=1
                    //self.isGameOn = true
                    
                    }
                }
//          if(node.name == "GunduFieldNodeDisable"){
//             if (sender.state == .changed) {
//                 let pinchScaleX = Float(sender.scale) * GunduFieldNodeDisable.scale.x
//                 let pinchScaleY =  Float(sender.scale) * GunduFieldNodeDisable.scale.y
//                 let pinchScaleZ =  Float(sender.scale) * GunduFieldNodeDisable.scale.z
//                 GunduFieldNodeDisable.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
//                 sender.scale=1
//             }
//          }
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !isGameOn {


            let hitTestResult = sceneView.hitTest(center, types: .estimatedHorizontalPlane)
            let result = hitTestResult.last
            guard let transform = result?.worldTransform else {return}
            let thirdColumn = transform.columns.3
            let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
//            positions.append(position)
//            let lastTenPositions = positions.suffix(10)
//            arrow.position = getAveragePosition(from: lastTenPositions)
            self.arrow.position = position
            //print(self.arrow.position)





            }
    }

    func getAveragePosition(from positions : ArraySlice<SCNVector3>) -> SCNVector3 {
        var averageX : Float = 0
        var averageY : Float = 0
        var averageZ : Float = 0
        
        for position in positions {
            averageX += position.x
            averageY += position.y
            averageZ += position.z
        }
        let count = Float(positions.count)
        return SCNVector3Make(averageX / count , averageY / count, averageZ / count)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        center = view.center
    }
    
    
    
    ////
    
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
        //let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: gacoan))
        //body.isAffectedByGravity = false
        //gacoan.physicsBody = body
        self.sceneView.scene.rootNode.addChildNode(gacoan)
        self.isGacoanAdded = true
        
    }
    
    func pressGacoan() {
        if self.isGunduFieldAdded == true && isGacoanAdded == true {
            }
    }
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if self.gunduFieldAdded == true {
//
//            if self.gacoanAdded == false {
//                self.addGacoan()
//                }
//            else {
//                startTime = Date()
//            }
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        let difference = Float(Date().timeIntervalSince(startTime!))
//        self.power = self.power + difference
//
//        let touch = touches.first
//        if(touch?.view == self.sceneView){
//        let viewTouchLocation:CGPoint = touch!.location(in: sceneView)
//        guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {return}
//        if result.node.name == "Gacoan" {
//            let gacoan = result.node
//            guard let pointOfView = self.sceneView.pointOfView else {return}
//            let transform = pointOfView.transform
//            let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
//            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: gacoan))
//            gacoan.physicsBody = body
//            gacoan.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power,orientation.z*power), asImpulse: true)
//            }
//        }
//    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation  = sender.location(in: sceneView)
        //Check whether the hit is same
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])

        if !hitTestResult.isEmpty {
            // add Gundu Field
            //self.addGunduField(hitTestResult: hitTestResult.first!)
            guard let hitTestResult = hitTestResult.first else { return }
            if self.isGunduFieldAdded == false {
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
        
//        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//
////        let hitTestResult = sceneView.hitTest(center, types: .featurePoint)
////        let result = hitTestResult.last
////        guard let transform = result?.worldTransform else {return}
////        let thirdColumn = transform.columns.3
////        let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
//        let position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
////        positions.append(position)
////        let lastTenPositions = positions.suffix(10)
////        arrow.position = getAveragePosition(from: lastTenPositions)
//        arrow.position = position
        
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
