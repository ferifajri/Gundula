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
    
    ////  Config Touch Location
    var center: CGPoint!
    var positions = [SCNVector3]()

    
    // Config Element is added ?
    let PlaneDetectTrue = SCNScene(named: "art.scnassets/planedetecttrue.scn")!.rootNode
    let GunduFieldNodeDisable = SCNScene(named: "GunduField.scnassets/NewGunduFieldDisable.scn")!.rootNode
    let GunduFieldNode = SCNScene(named: "GunduField.scnassets/NewGunduField.scn")!.rootNode
    let PressPlayNode = SCNScene(named: "GunduField.scnassets/PressPlay.scn")!.rootNode
    
    var isGameOn:Bool = false
    var isGunduFieldAdded:Bool = false
    var isGacoanAdded:Bool = false
    
    var planeIsTouched:Bool = false
    
    /// Config Applying Force
    var startTime: Date?
    var difference:Float = 0
    
    // Configuration
    var power:Float = 1.5
    var scaleRatio:Float = 1.0
    
    var gunduFieldWidth:CGFloat = 2.0
    var gunduFieldHeight:CGFloat = 2.0
    
    // Coba lempar raywenderlich
    // Ball throwing mechanics
    var startTouchTime: TimeInterval!
    var endTouchTime: TimeInterval!
    var startTouch: UITouch?
    var endTouch: UITouch?
    var startPoint: CGPoint?
    var touchTime = NSDate()
    
    // Node that intercept touches in the scene
    lazy var touchCatchingPlaneNode: SCNNode = {
      let node = SCNNode(geometry: SCNPlane(width: 40, height: 40))
      node.opacity = 0.001
      node.castsShadow = false
      return node
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        
        //detects horizontal surfaces
        self.configuration.planeDetection = .horizontal
        //self.sceneView.session.run(configuration)
        
        //self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        center = view.center
        
        sceneView.scene.rootNode.addChildNode(self.PlaneDetectTrue)
        
    }
    
    ////  Tes
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isGameOn && self.isGunduFieldAdded == false) {
            //place GameNode
            //guard let angle = sceneView.session.currentFrame?.camera.eulerAngles.y else {return}
            self.GunduFieldNodeDisable.position = self.PlaneDetectTrue.position
            //GunduFieldNodeDisable.eulerAngles.y = angle
            isGameOn = true
            
            self.GunduFieldNodeDisable.pivot = SCNMatrix4MakeTranslation(0,0,0)
            self.sceneView.scene.rootNode.addChildNode(self.GunduFieldNodeDisable)
            
            PressPlayNode.position = SCNVector3(-0.75,0.5,0)
            GunduFieldNodeDisable.addChildNode(self.PressPlayNode)
            PlaneDetectTrue.removeFromParentNode()
            
            let tapFieldGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapField(sender:)))
            self.sceneView.addGestureRecognizer(tapFieldGestureRecognizer)
            
            let resizeFieldGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchResizeField(sender:)))
            self.sceneView.addGestureRecognizer(resizeFieldGestureRecognizer)
            //print(self.gunduFieldAdded)
            
            self.addSasaran()
            
        }
        else if (isGameOn == true && self.isGunduFieldAdded == true) {
            //print("add gacoan")
            if self.isGacoanAdded == false {
                self.addGacoan()
//                self.addSasaran()
                }
            else {
                
//                // Using Raywenderleich
//                super.touchesBegan(touches, with: event)
//
//
//                  guard let firstTouch = touches.first else { return }
//
//                  let point = firstTouch.location(in: sceneView)
//                  let hitResults = sceneView.hitTest(point, options: [:])
//
//                  if hitResults.first?.node == Gacoan() {
//                    startTouch = touches.first
//                    startTouchTime = Date().timeIntervalSince1970
//                  }
                
                // using long Tap as Force
                startTime = Date()
                startTouchTime = Date().timeIntervalSince1970
                
                guard touches.count == 1 else {
                    return
                }
                if let startTouch = touches.first {
                    startPoint = startTouch.location(in: view)
                    touchTime = NSDate()
                }
                
            }
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOn && self.isGunduFieldAdded == true && self.isGacoanAdded == true {
            
//            //cara raywender
//            super.touchesEnded(touches, with: event)
//
//            guard startTouch != nil else { return }
//
//            endTouch = touches.first
//            endTouchTime = Date().timeIntervalSince1970
//            throwBall()
        
            ///cara location
//            defer {
//                startPoint = nil
//            }
//            guard touches.count == 1, let startPoint = startPoint else {
//                return
//            }
//
//
//                    endTouchTime = Date().timeIntervalSince1970
//                    let timeDifference = endTouchTime - startTouchTime
//                    let velocityComponent = Float(min(max(1 - timeDifference, 0.1), 1.0))
//            let touch = touches.first
//            let viewTouchLocation:CGPoint = touch!.location(in: sceneView)
//            guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {return}
//            if result.node.name == "gacoan" {
//                let endPoint = touch!.location(in: view)
//                //Calculate your vector from the delta and what not here
//                let direction = CGVector(dx: endPoint.x - startPoint.x, dy: endPoint.y - startPoint.y)
//                let elapsedTime = touchTime.timeIntervalSinceNow
//                let angle = atan2f(Float(direction.dy), Float(direction.dx))
//
//
//
//            let impulseVector = SCNVector3(
//              x: abs(Float(direction.dx) / 10 * Float(elapsedTime) ),
//              y: abs(Float(direction.dy) / 50 * Float(elapsedTime)),
//              z: -(abs(Float(direction.dy) / 50 * Float(elapsedTime)))
//            )
//
//                print(elapsedTime)
//            print(abs(Float(direction.dx) * Float(elapsedTime)))
//            print(abs(Float(direction.dy) / 10 * Float(elapsedTime)))
//
//            print(direction.dx)
//            print(direction.dy)
//
//            let gacoan = result.node
//            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: gacoan))
//            gacoan.physicsBody = body
//            gacoan.physicsBody?.applyForce(impulseVector, asImpulse: true)
//
//                }
            
            
            ///
            
            
        endTouchTime = Date().timeIntervalSince1970
        let timeDifference = endTouchTime - startTouchTime
        let velocityComponent = Float(min(max(1 - timeDifference, 0.1), 1.0))
        
        let difference = Float(Date().timeIntervalSince(startTime!))
        self.power = self.power + difference

        let touch = touches.first
        if(touch?.view == self.sceneView){
        let viewTouchLocation:CGPoint = touch!.location(in: sceneView)
        guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {return}
            
        if result.node.name == "gacoan" {
//            using tapHold as force
//            let gacoan = result.node
//            guard let pointOfView = self.sceneView.pointOfView else {return}
//            let transform = pointOfView.transform
//            let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
//            let location = SCNVector3(transform.m41,transform.m42,transform.m43)
//
//            let endPoint = touch!.location(in: view)
//            //Calculate your vector from the delta and what not here
//            let direction = CGVector(dx: endPoint.x - startPoint!.x, dy: endPoint.y - startPoint!.y)
//
//            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: gacoan))
//            gacoan.physicsBody = body
//            gacoan.physicsBody?.applyForce(SCNVector3(orientation.x*power, 0, 2*power), asImpulse: true)
            
            let gacoan = result.node
            let (direction, position) = self.getUserVector()
            gacoan.position = position
            var nodeDirection = SCNVector3()
            nodeDirection = SCNVector3(direction.x*2,0,direction.z*2)
            gacoan.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.1,0,0), asImpulse: true)
            gacoan.physicsBody?.applyForce(nodeDirection , asImpulse: true)
            


            //using swipegesture as force orientation
//            let leftSwipeGacoanGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGacoan(sender:)))
//            let rightSwipeGacoanGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGacoan(sender:)))
////            self.sceneView.addGestureRecognizer(swipeGacoanGestureRecognizer)
//
//            leftSwipeGacoanGestureRecognizer.direction = .left
//            rightSwipeGacoanGestureRecognizer.direction = .right
//
//            self.sceneView.addGestureRecognizer(leftSwipeGacoanGestureRecognizer)
//            self.sceneView.addGestureRecognizer(rightSwipeGacoanGestureRecognizer)


            }
        }
            
            }
    }
    
    
    //MARK: - maths
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            // 4x4  transform matrix describing camera in world space
            let mat = SCNMatrix4(frame.camera.transform)
            // orientation of camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            // location of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func throwBall() {
        let gacoan = Gacoan()
        //guard let ballNode = Gacoan else { return }
        guard let endingTouch = endTouch else { return }
      
      // 1
      let firstTouchResult = sceneView.hitTest(
        endingTouch.location(in: view),
        options: nil
        ).filter({
          $0.node == touchCatchingPlaneNode
        }).first
      
      guard let touchResult = firstTouchResult else { return }
      
//      // 2
//      levelScene.rootNode.runAction(
//        SCNAction.playAudio(
//          helper.whooshAudioSource,
//          waitForCompletion: false
//        )
//      )
      
      // 3
      let timeDifference = endTouchTime - startTouchTime
      let velocityComponent = Float(min(max(1 - timeDifference, 0.1), 1.0))
      
      // 4
      let impulseVector = SCNVector3(
        x: touchResult.localCoordinates.x * velocityComponent * 3,
        y: touchResult.localCoordinates.y * velocityComponent * 3,
        z: touchResult.localCoordinates.y * velocityComponent * 15
      )
      
      gacoan.physicsBody?.applyForce(impulseVector, asImpulse: true)
      //sceneView.ballNodes.append(gacoan)
      
      // 5
      //currentBallNode = nil
      startTouchTime = nil
      endTouchTime = nil
      startTouch = nil
      endTouch = nil
    }
    
    @objc func handleSwipeGacoan(sender: UISwipeGestureRecognizer) {
        switch sender.direction{
        case .left:
             //left swipe action
            print("left")
        case .right:
             //right swipe action
            print("right")
        default: //default
            print("bukan kanan kiri")
        }
    }
    
    @objc func handleTapField(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation  = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation)

        if !hitTestResult.isEmpty {
            // add Gundu Field
            guard let hitTestResult = hitTestResult.first else { return }
            if ((hitTestResult.node.name?.isEmpty) == nil) {
            }
            else if (hitTestResult.node.name == "Play") {
                self.GunduFieldNode.position = self.GunduFieldNodeDisable.position
                self.GunduFieldNode.scale = self.GunduFieldNodeDisable.scale
                self.GunduFieldNodeDisable.removeFromParentNode()
                
                //Add Collision
                GunduFieldNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                GunduFieldNode.physicsBody?.categoryBitMask = GamePhysicsBitmask.plane
                GunduFieldNode.physicsBody?.collisionBitMask = GamePhysicsBitmask.gacoan
                
                self.sceneView.scene.rootNode.addChildNode(self.GunduFieldNode)
                self.isGameOn = true
                self.isGunduFieldAdded = true
                //print(self.isGunduFieldAdded)
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
                if (sender.state == .changed) {
                    let pinchScaleX = Float(sender.scale) * GunduFieldNodeDisable.scale.x
                    let pinchScaleY =  Float(sender.scale) * GunduFieldNodeDisable.scale.y
                    let pinchScaleZ =  Float(sender.scale) * GunduFieldNodeDisable.scale.z
                    GunduFieldNodeDisable.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
                    //GunduFieldNodeDisable.simdScale = SIMD3(1*scaleRatio, 1*scaleRatio, 1*scaleRatio)
                    //print(Float(sender.scale))
                    print(GunduFieldNodeDisable.scale.x)
                    print(GunduFieldNodeDisable.scale.y)
                    print(GunduFieldNodeDisable.scale.z)
                    sender.scale=1
                    self.scaleRatio = pinchScaleX
                    

                    
                    }
                }
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
            self.PlaneDetectTrue.position = position
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
    
    func addGacoan() {
        guard let pointOfView = self.sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
        let position = location + orientation
        
        let gacoan = Gacoan()
        
        //let gacoan = SCNNode(geometry: SCNSphere(radius: self.gunduFieldHeight/50))
        gacoan.name = "gacoan"
        //gacoan.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "gacoan-1")
        gacoan.position = position
//        gacoan.simdScale = SIMD3(1*scaleRatio, 1*scaleRatio, 1*scaleRatio)
       // gacoan.simdScale = SIMD3(1*self.scaleRatio, 1*self.scaleRatio, 1*self.scaleRatio)
            
        //print(Int(self.gunduFieldHeight))
        
        //updatePositionAndOrientationOf(gacoan, withPosition: position, relativeTo: pointOfView)
        //let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: gacoan))
        //body.isAffectedByGravity = false
        //gacoan.physicsBody = body
        
        
        //Add Collision
        gacoan.physicsBody?.categoryBitMask = GamePhysicsBitmask.gacoan
        // Remember collision use binary operator
        gacoan.physicsBody?.collisionBitMask = GamePhysicsBitmask.plane | GamePhysicsBitmask.sasaran
        gacoan.physicsBody?.contactTestBitMask = GamePhysicsBitmask.sasaran
        self.sceneView.scene.rootNode.addChildNode(gacoan)
        self.isGacoanAdded = true
        
    }
    
        func addSasaran() {
            for i in 0...2 {
                let sasaran = Sasaran()
//                let x = Double.random(in: -0.3...0.5)
//                let z = Double.random(in: -0.3...0.5)
//                sasaran.position = SCNVector3(x, 0, z)
                
                let x = [0,0,0,0.3,0.3,0.3]
                let z = [0,-0.3,0.3,0,-0.3,0.3]
                sasaran.position = SCNVector3(x[i], 0, z[i])
                //sasaran.simdScale = SIMD3(1*self.scaleRatio, 1*self.scaleRatio, 1*self.scaleRatio)
    //            // Add command code here into Donut()
                sasaran.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                sasaran.physicsBody?.isAffectedByGravity = true
    //            // Add Collision
    //            donutNode.physicsBody?.categoryBitMask = GamePhysicsBitmask.donut
    //            donutNode.physicsBody?.collisionBitMask = GamePhysicsBitmask.wolf
                
                self.GunduFieldNode.addChildNode(sasaran)
            }
        }
    
    func pressGacoan() {
        if self.isGunduFieldAdded == true && isGacoanAdded == true {
            }
    }
    
//    func addGunduField(hitTestResult: ARHitTestResult) {
//                let gunduFieldScene = SCNScene(named: "GunduField.scnassets/GunduField.scn")
//                let gunduNode = gunduFieldScene?.rootNode.childNode(withName: "Gundu", recursively: false)
//                let positionOfPlane = hitTestResult.worldTransform.columns.3
//                let xPosition = positionOfPlane.x
//                let yPosition = positionOfPlane.y
//                let zPosition = positionOfPlane.z
//
//                gunduNode?.position = SCNVector3(xPosition,yPosition,zPosition)
//                gunduNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: gunduNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//                self.sceneView.scene.rootNode.addChildNode(gunduNode!)
//    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !isGameOn {
            DispatchQueue.main.async {
                self.planeDetected.isHidden = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetected.isHidden = true
            }
        }
    }
    

}

func +(left: SCNVector3, right:SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Int {
    var degreestoRadians: Double {return Double(self) * .pi / 180 }
}


extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("cek kontak")
        if contact.nodeB.name == "GunduField" || contact.nodeB.name == "planeGunduField" {
            print("kontak kah?")
            self.planeIsTouched = true
            if self.planeIsTouched == true {
                print("kena plane")
                }
            else {
                print("Out of bounds")
                self.planeDetected.isHidden = false
            }

        }
    }
}
