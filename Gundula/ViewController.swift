//
//  ViewController.swift
//  Gundula
//
//  Created by Feri Fajri on 08/06/20.
//  Copyright © 2020 Feri Fajri. All rights reserved.
//

import UIKit
import ARKit
//import RealityKit
import CoreMotion
import AVFoundation


// config Collect
 enum ParticleType: Int,CaseIterable{
     case collect = 0
     case walkDust
 }

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    //Particles
    private var particles = [SCNParticleSystem](repeating: SCNParticleSystem(), count: ParticleType.allCases.count)
    
    var particleEmitter: SCNNode!
    
    ////  Config Touch Location
    var center: CGPoint!
    var positions = [SCNVector3]()
    
    private var userScore: Int = 0 {
        didSet {
            // ensure UI update runs on main thread
            DispatchQueue.main.async {
                //self.scoreLabel.text = String(self.userScore)
            }
        }
    }
 

    
    // Config Element is added ?
    let PlaneDetectTrue = SCNScene(named: "art.scnassets/planedetecttrue.scn")!.rootNode
//    let PlaneDetectFalse = SCNScene(named: "art.scnassets/planedetectfalse.scn")!.rootNode
    let gacoan = SCNScene(named: "art.scnassets/gacoan.scn")!.rootNode
    let torus = SCNScene(named: "art.scnassets/torus.scn")!.rootNode
    let GunduFieldNodeDisable = SCNScene(named: "GunduField.scnassets/NewGunduFieldDisable.scn")!.rootNode
    //var gunduFieldNode:SCNNode!
    let GunduFieldNode = SCNScene(named: "GunduField.scnassets/NewGunduField.scn")!.rootNode
    let PressPlayNode = SCNScene(named: "GunduField.scnassets/PressPlay.scn")!.rootNode
    
    
    
//    let camera = SCNCamera()
//    camera = SCNNode(geometry: ARCamera)
    
    var isGameOn:Bool = false
    var isGunduFieldAdded:Bool = false
    var isGunduFieldNodeDisableAdded:Bool = false
    var isGacoanAdded:Bool = false
    var isInsideCircle:Bool = false
    
    var planeIsTouched:Bool = false
    
    /// Config Applying Force
    var startTime: Date?
    var difference:Float = 0
    
    // Configuration
    var power:Float = 10
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
    
    // Core Motion Setting
    private var _motionManager = CMMotionManager()
    private var _startAttitude: CMAttitude?
    private var _currentAttitude: CMAttitude?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        runSession()
        overlayCoachingView()
        center = view.center
        
        setupParticle()
        //addGunduField()
        
        self.userScore = 0

        
    }
    
    //MARK: - Touch Handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isGameOn && self.isGunduFieldNodeDisableAdded == false) {
            //place GameNode
            
            //guard let angle = sceneView.session.currentFrame?.camera.eulerAngles.y else {return}
            self.GunduFieldNodeDisable.position = self.PlaneDetectTrue.position
            //GunduFieldNodeDisable.eulerAngles.y = angle
                    
            self.GunduFieldNodeDisable.pivot = SCNMatrix4MakeTranslation(0,0,0)
            self.sceneView.scene.rootNode.addChildNode(self.GunduFieldNodeDisable)
            
            let circlePlane = SCNPlane(width: 1, height: 1)
            circlePlane.cornerRadius = 1
            circlePlane.firstMaterial?.diffuse.contents = UIColor.lightGray

            let circle = SCNNode(geometry: circlePlane)
            circle.eulerAngles = SCNVector3(Float(-90.0).degreestoRadians,0,0)
            circle.position = SCNVector3(0,0,0)
//            circle.opacity = 1
            self.GunduFieldNodeDisable.addChildNode(circle)
            
//            // Set Torus Ring via code
//            let torusShape = SCNTorus(ringRadius: 0.5, pipeRadius: 0.01)
//            //circlePlane.cornerRadius = 1
//            torusShape.firstMaterial?.diffuse.contents = UIColor.white
//            let torus = SCNNode(geometry: torusShape)
//            //torus.eulerAngles = SCNVector3(Float(-90.0).degreestoRadians,0,0)
//            torus.position = SCNVector3(0,0,0)
//            torus.opacity = 0.8
//            self.GunduFieldNodeDisable.addChildNode(torus)
            
            // Set torus ring from scn editor
            
//            self.torus.position = SCNVector3(0,0,0)
//            self.torus.opacity = 0.8
            self.addWall()
            //self.gunduFieldNode.addChildNode(wallNode)
            //self.GunduFieldNodeDisable.addChildNode()
                    
            PressPlayNode.position = SCNVector3(0,0.5,0)
            GunduFieldNodeDisable.addChildNode(self.PressPlayNode)
//            let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(360)), z: 0 , duration: 3)
//            PressPlayNode.runAction(SCNAction.repeatForever(rotateAction))
            PlaneDetectTrue.removeFromParentNode()
            
            isGunduFieldNodeDisableAdded = true
            
//            print(self.GunduFieldNodeDisable.position)
                    
            let tapFieldGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapField(sender:)))
            self.sceneView.addGestureRecognizer(tapFieldGestureRecognizer)
                    
//            let resizeFieldGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchResizeField(sender:)))
//            self.sceneView.addGestureRecognizer(resizeFieldGestureRecognizer)

                    
                    self.addSasaran()
                    //self.GunduFieldNode.addChildNode(sasaran)
                    
                }
        else if (isGameOn && self.isGunduFieldAdded == true && self.isGacoanAdded == false) {
//            self.addGacoan()
//            gacoan.position = sphereNode.position
//            self.sceneView.scene.rootNode.addChildNode(gacoan)
//            isGacoanAdded = true
            }
        else if (isGameOn && self.isGunduFieldAdded == true && self.isGacoanAdded == true) {
            
            
            //print(isGacoanAdded)
            
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
        
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOn  && self.isGunduFieldAdded == true && self.isGacoanAdded == true {
            
            endTouchTime = Date().timeIntervalSince1970
            let difference = Float(Date().timeIntervalSince(startTime!))
            self.power = self.power * difference * 1000
            print(difference)
            print(self.power)
            
            //self.shootGacoan()
            guard let poV = self.sceneView.pointOfView else {return}
                    let transform = poV.transform
                    let location = SCNVector3(transform.m41,transform.m42, transform.m43)
                    let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
                    let position = location + orientation
                    let gacoan = Gacoan()
            //        let ball = SCNNode(geometry: SCNSphere(radius: 0.05))
            //        ball.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "spark.png")
            //        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball))
            //        self.sceneView.scene.rootNode.addChildNode(self.gacoan)
                    gacoan.position = position
            print(gacoan.position)
                    gacoan.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: gacoan, options: nil))
                    gacoan.physicsBody?.applyForce(SCNVector3(orientation.x*self.power, orientation.y*self.power, orientation.z*self.power), asImpulse: true)
                    self.sceneView.scene.rootNode.addChildNode(gacoan)
            
//            /// #### GmaePlay 2 #### ///
//            // using long Tap as Force
//
////            endTouchTime = Date().timeIntervalSince1970
////
////            let difference = Float(Date().timeIntervalSince(startTime!))
////            self.power = self.power + difference
//
//            let touch = touches.first
//            if(touch?.view == self.sceneView){
////                let viewTouchLocation:CGPoint = touch!.location(in: sceneView)
////                guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {return}
////                //if result.node.name == "gacoan" {
////                    let gacoan = result.node
//                let gacoan = Gacoan()
//                    guard let currentFrame = self.sceneView.session.currentFrame else {
//                        return
//                    }
//
//                    print("masuk")
//
//                    let original = SCNVector3(x: 0, y: 0, z: -2)
//                    let force = simd_make_float4(original.x, original.y, original.z, 0)
//                    let rotatedForce = simd_mul(currentFrame.camera.transform, force)
//
//                    let vectorForce = SCNVector3(x:rotatedForce.x, y:rotatedForce.y, z: (rotatedForce.z )) //* self.power))
//                    gacoan.physicsBody?.applyForce(vectorForce, asImpulse: true)
//
//                    //}
//            }
//            /// #### GmaePlay 2 #### ///
            
 

        }
        
        
    }
    
    
    func shootGacoan() {
        
        
        
    }
    
    //MARK: - Gesture Handler
    
    @objc func handleTapField(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation  = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation)

        if !hitTestResult.isEmpty {
            // add Gundu Field
            guard let hitTestResult = hitTestResult.first else { return }
            if ((hitTestResult.node.name?.isEmpty) == nil) {
            }
            else if (isGunduFieldNodeDisableAdded == true && (hitTestResult.node.name == "kiri" || hitTestResult.node.name == "kanan" || hitTestResult.node.name == "PlayText")) {
                
                
                self.GunduFieldNode.position = self.GunduFieldNodeDisable.position
                //self.GunduFieldNode.scale = self.GunduFieldNodeDisable.scale
                self.GunduFieldNodeDisable.removeFromParentNode()
                
//                // Add Bitmasks Collision for GunduFieldNode
//                GunduFieldNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                self.GunduFieldNode.physicsBody?.categoryBitMask = 2 //GamePhysicsBitmask2.plane
                self.GunduFieldNode.physicsBody?.collisionBitMask = 5 //GamePhysicsBitmask2.gacoan | GamePhysicsBitmask2.sasaran
                
                self.sceneView.scene.rootNode.addChildNode(self.GunduFieldNode)
                self.addWall()
                    //self.GunduFieldNode.addChildNode()
                
//                let circlePlane = SCNPlane(width: 1, height: 1)
//                circlePlane.cornerRadius = 1
//                circlePlane.firstMaterial?.diffuse.contents = UIColor.lightGray
//                let circle = SCNNode(geometry: circlePlane)
//                circle.eulerAngles = SCNVector3(Float(-90.0).degreestoRadians,0,0)
//                circle.position = SCNVector3(0,0,0)
//                self.GunduFieldNode.addChildNode(circle)
        
                
                //            // Set Torus Ring via code
                //            let torusShape = SCNTorus(ringRadius: 0.5, pipeRadius: 0.01)
                //            //circlePlane.cornerRadius = 1
                //            torusShape.firstMaterial?.diffuse.contents = UIColor.white
                //            let torus = SCNNode(geometry: torusShape)
                //            //torus.eulerAngles = SCNVector3(Float(-90.0).degreestoRadians,0,0)
                //            torus.position = SCNVector3(0,0,0)
                //            torus.opacity = 0.8
                //            self.GunduFieldNode.addChildNode(torus)
                            
                            // Set torus ring from scn editor
                            
//                            self.torus.position = SCNVector3(0,0,0)
//                            self.torus.opacity = 0.8
//
//                self.torus.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: self.torus, options: [SCNPhysicsShape.Option.keepAsCompound : true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//                self.GunduFieldNode.addChildNode(self.torus)
                
                
//                // Add Bitmasks Collision for Torus
//                self.torus.physicsBody?.categoryBitMask = 8 // GamePhysicsBitmask2.torus
//                self.torus.physicsBody?.contactTestBitMask = 5 //GamePhysicsBitmask2.gacoan | GamePhysicsBitmask2.sasaran
                
//                self.GunduFieldNode.addChildNode(self.torus)
                
                
                
                self.isGameOn = true
                self.isGunduFieldAdded = true
                
                // ## Skip Naruh Gundu Di lantai nya Gameplay 2
                self.isGacoanAdded = true
                // ## Skip Naruh Gundu Di lantai nya Gameplay 2
                
                
                //print(self.isGunduFieldAdded)
            }
            else {
                //print(hitTestResult.node.name!)
            }
        }
    }
    
    
   
    
    //MARK: - Function
    
//    func addGunduField() {
//        let gunduFieldNode = GunduField()
//        //let sasaran = Sasaran()
//        //self.sceneView.scene.rootNode.addChildNode(gunduFieldNode)
//
//    }
    
    func addWall() {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: -50, y: 0))
            
            path.addQuadCurve(to: CGPoint(x: 0, y: 50), controlPoint: CGPoint(x: -50, y: 50))
            path.addLine(to: CGPoint(x: 0, y: 48))
            path.addQuadCurve(to: CGPoint(x: -48, y: 0), controlPoint: CGPoint(x: -50, y: 48))
            
            let shape = SCNShape(path: path, extrusionDepth: 10)
            shape.firstMaterial?.diffuse.contents = UIColor.blue
            let shapeNode = SCNNode(geometry: shape)
            shapeNode.scale = SCNVector3(0.01,0.01,0.01)
            
            let shape2 = SCNShape(path: path, extrusionDepth: 10)
            
            shape2.firstMaterial?.diffuse.contents = UIColor.red
            let shapeNode2 = SCNNode(geometry: shape2)
            shapeNode2.eulerAngles.x = Float(Float(180).degreestoRadians)
            shapeNode2.scale = SCNVector3(0.01,0.01,0.01)
            
            let shape3 = SCNShape(path: path, extrusionDepth: 10)
            
            shape3.firstMaterial?.diffuse.contents = UIColor.black
            let shapeNode3 = SCNNode(geometry: shape3)
            shapeNode3.eulerAngles.x = Float(Float(180).degreestoRadians)
            shapeNode3.eulerAngles.y = Float(Float(180).degreestoRadians)
            shapeNode3.scale = SCNVector3(0.01,0.01,0.01)
            
            let shape4 = SCNShape(path: path, extrusionDepth: 10)
            shape4.firstMaterial?.diffuse.contents = UIColor.green
            let shapeNode4 = SCNNode(geometry: shape4)
            shapeNode4.eulerAngles.y = Float(Float(180).degreestoRadians)
            shapeNode4.scale = SCNVector3(0.01,0.01,0.01)
            
            let wall = SCNNode()
            wall.addChildNode(shapeNode)
            wall.addChildNode(shapeNode2)
            wall.addChildNode(shapeNode3)
            wall.addChildNode(shapeNode4)
            wall.position = SCNVector3(0,0,0)
            wall.eulerAngles.x = Float(Float(90).degreestoRadians)
            wall.scale = SCNVector3(2,2,2)
            
            //wall.pivot =
            let wallNode = SCNNode()
            wallNode.position = SCNVector3(0,0,0)
            let wallRotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(Float(180).degreestoRadians), z: 0, duration: 5))
            wallNode.runAction(wallRotate)
            
            self.GunduFieldNode.addChildNode(wallNode)
            
        //self.GunduFieldNodeDisable.addChildNode(wallNode)
            wallNode.addChildNode(wall)
            
    //        print(wall.pivot)
    //        print(wallNode.position)
    //        print(wall.position)
    //
    //        let coneshape = SCNCone(topRadius: 0.2, bottomRadius: 0.4, height: 0.3)
    //        coneshape.firstMaterial?.diffuse.contents = UIColor.purple
    //        let cone = SCNNode(geometry: coneshape)
    //        cone.position = SCNVector3(0,0,0)
    //        //self.sceneView.scene.rootNode.addChildNode(cone)
        }
    
    func setupParticle(){
        //particles[ParticleType.collect.rawValue] = SCNParticleSystem.loadParticleSystems(atPath: "art.scnassets/Particles/collect.scnp").first!
    }
    
    func collect(_ sasaran: Sasaran){
        sasaran.runAction(SCNAction.playAudio(SCNAudioSource(fileNamed: "collect.mp3")!, waitForCompletion: true))
        //sasaran.particleSystems.addpar
        //sasaran.particleEmitter.addParticleSystem(particles[ParticleType.collect.rawValue])
        //sasaran.childNode(withName: "sasaran", recursively: true)?.isHidden = true
    }
    
    func showDummyPointer() {
        
        // ### Add Dummy Pointer for force direction ###
                let gacoanDummyNode = SCNNode()
                gacoanDummyNode.position = SCNVector3(0, 0.05, 0)
//                gacoanNode.opacity = 0.1
                                
                self.gacoan.addChildNode(gacoanDummyNode)
        
                let pointerDummySphere = SCNSphere(radius: 0.02)
                pointerDummySphere.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "gacoan-1")
                let pointerDummyNode1 = SCNNode(geometry: pointerDummySphere)
                pointerDummyNode1.opacity = 0.8
                //        let z = [-0.05,-0.1,-0.15]
                pointerDummyNode1.position = SCNVector3(0, 0, 0)
                pointerDummyNode1.name = "pointerDummyNode1"
                        
                let pointerDummyNode2 = SCNNode(geometry: pointerDummySphere)
                pointerDummyNode2.opacity = 0.65
                        //        let z = [-0.05,-0.1,-0.15]
                pointerDummyNode2.position = SCNVector3(0, 0, 0)
                pointerDummyNode2.name = "pointerDummyNode2"
                        
                let pointerDummyNode3 = SCNNode(geometry: pointerDummySphere)
                pointerDummyNode3.opacity = 0.5
                        //        let z = [-0.05,-0.1,-0.15]
                pointerDummyNode3.position = SCNVector3(0, 0, 0)
                pointerDummyNode3.name = "pointerDummyNode3"
                
                //self.gacoan.position = SCNVector3(0,0,-0.1)
                gacoanDummyNode.addChildNode(pointerDummyNode1)
                gacoanDummyNode.addChildNode(pointerDummyNode2)
                gacoanDummyNode.addChildNode(pointerDummyNode3)
                
                guard let currentFrame = self.sceneView.session.currentFrame else {return}
                
                let force = SCNVector4(0, 0, -5, 0)
                // Convert the tranform to a SCNMatrix4
                let transformR = SCNMatrix4(currentFrame.camera.transform)
                // Convert the matrix to the nodes coordinate space
                let localTransform = pointerDummyNode1.convertTransform(transformR, from: gacoanDummyNode)
                let localTransform2 = pointerDummyNode2.convertTransform(transformR, from: gacoanDummyNode)
                let localTransform3 = pointerDummyNode3.convertTransform(transformR, from: gacoanDummyNode)
                
                let rotatedForce = (localTransform * force).to3()
                let rotatedForce2 = (localTransform2 * force).to3()
                let rotatedForce3 = (localTransform3 * force).to3()
                
                pointerDummyNode1.position = SCNVector3(rotatedForce.x*0.05, gacoanDummyNode.position.y, -0.05)
                pointerDummyNode2.position = SCNVector3(rotatedForce2.x*0.1, gacoanDummyNode.position.y, -0.1)
                pointerDummyNode3.position = SCNVector3(rotatedForce3.x*0.15, gacoanDummyNode.position.y, -0.15)
                
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node,_) in
                    if node.name == "pointerDummyNode1" || node.name == "pointerDummyNode2" || node.name == "pointerDummyNode3" {
                    node.removeFromParentNode()
                    }
                })
                
                gacoanDummyNode.addChildNode(pointerDummyNode1)
                gacoanDummyNode.addChildNode(pointerDummyNode2)
                gacoanDummyNode.addChildNode(pointerDummyNode3)
                
//                print(self.gacoan.position)
//                print(gacoanDummyNode.position)
//                print(pointerDummyNode1)
//                print(pointerDummyNode2)
//                print(pointerDummyNode3)
        }
    
    private func setupMotionHandler() {
      if (_motionManager.isAccelerometerAvailable) {
        _motionManager.accelerometerUpdateInterval = 1/60.0

        _motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {(data, error) in
            //self.motionDidChange(data: data!)
        })
      }
    }
    
    
    
    
    func addGacoan() {
        
        guard let currentFrame = self.sceneView.session.currentFrame else {return}

        // Add Dummy Gacoan Position as sphereNodeGacoan
        let sphere = SCNSphere(radius: 0.02)
        sphere.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "gacoan-1")
        let sphereNodeGacoan = SCNNode(geometry: sphere)
        self.sceneView.scene.rootNode.addChildNode(sphereNodeGacoan)
        sphereNodeGacoan.position = SCNVector3(0, 0, -0.05)
        sphereNodeGacoan.name = "sphereNodeGacoan"
        //
        
        // pinned/translate sphereNodeGacoan to camera view
        let force = SCNVector4(0, 0, -5, 0)
        let transformR = SCNMatrix4(currentFrame.camera.transform)
        let localTransform = sphereNodeGacoan.convertTransform(transformR, from: sphereNodeGacoan)
        let rotatedForce = (localTransform * force).to3()
        // sphereNodeGacoan Dummy Position always on the floor (same with GunduField)
        //sphereNodeGacoan.position = SCNVector3(rotatedForce.x*0.05, self.GunduFieldNode.position.y, -0.05)
        
        sphereNodeGacoan.position = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.y)
            
        //let self.gacoan = Gacoan()
        self.gacoan.name = "gacoan"
                        
//        //  Add Bitmasks Collision for Gacoan
//        self.gacoan.physicsBody?.categoryBitMask = 1 // GamePhysicsBitmask2.gacoan
//        self.gacoan.physicsBody?.collisionBitMask = 6 //GamePhysicsBitmask2.plane | GamePhysicsBitmask2.sasaran
//        self.gacoan.physicsBody?.contactTestBitMask = 12 //GamePhysicsBitmask2.torus | GamePhysicsBitmask2.sasaran
        
        // Add Real Gacoan to the scene, remove all dummy GacoanNodeSphere and sphere at updateTime
        self.gacoan.position = sphereNodeGacoan.position
        self.sceneView.scene.rootNode.enumerateChildNodes({ (node,_) in
                if node.name == "sphereNodeGacoan" || node.name == "sphereNode" {
                node.removeFromParentNode()
                }
            })
        self.sceneView.scene.rootNode.addChildNode(self.gacoan)
        
        //Change state gacoan added
        self.isGacoanAdded = true
        //print (self.sphereNode.position)
        }
    
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
    

    
    func PlayGame() {
        if (isGameOn && self.isGunduFieldAdded == true && isInsideCircle == false ) {
//            print("Mulai Game")

//            self.sceneView.scene.rootNode.addChildNode(gacoan)
//
//            let frame = self.sceneView.session.currentFrame
//            //            let mat = SCNMatrix4.init(frame!.camera.transform)
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.3
//            //translation.columns.3.y = self.GunduFieldNode.position.y
//            self.gacoan.simdTransform = matrix_multiply(translation, (frame?.camera.transform)!)
            //self.gacoan.position.y = self.GunduFieldNode.position.y
            
//            /// Simpen ini
//            var translation = matrix_identity_float4x4
//            translation.columns.3 = simd_float4(0, GunduFieldNode.position.y, 0, 1)      // x, y, z, HC
//            gacoan.simdTransform = matrix_multiply(translation, camera.transform)
            
            ///  ### Pakai ini nempel ke kamera ###
//            guard let currentFrame = sceneView.session.currentFrame else {return}
//            let camera = currentFrame.camera
//            let transform = camera.transform
//
//
//            var translation_matrix = matrix_identity_float4x4
////            let cameraRelativePosition = SCNVector3(0,0,-0.1)
//            //let cameraRelativePosition = self.GunduFieldNode.position
//            //translation_matrix.columns.3.x = cameraRelativePosition.x
//            //translation_matrix.columns.3.y = simd_float4(
//            translation_matrix.columns.3.z = -0.1
//            let modifiedMatrix = simd_mul(transform, translation_matrix)
//            let sphere = SCNSphere(radius: 0.01)
//            sphere.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "gacoan-1.png")
//            let sphereNode = SCNNode(geometry: sphere)
////            firstMaterial.diffuse.contents = UIColor.lightGray
//            //firstMaterial?.diffuse.contents = UIColor.lightGray
//            sphereNode.simdTransform = modifiedMatrix
//            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            
            
            
            //coba lagi pake ini
//            let ballShape = SCNSphere(radius: 0.03)
//            ballShape.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "gacoan-1.png")
//            let ballNode = SCNNode(geometry: ballShape)
//            ballNode.position = SCNVector3Make(0.0, GunduFieldNode.position.y , -0.4)
//            let ballMatrix = ballNode.transform
//            let cameraMatrix = sceneView.pointOfView!.transform
//            let newBallMatrix = SCNMatrix4Mult(ballMatrix, cameraMatrix)
//            ballNode.transform = newBallMatrix
//            self.sceneView.scene.rootNode.addChildNode(ballNode)
//            print(GunduFieldNode.position)
//            print(ballNode.position)

            
            
            ///  ### Pakai ini nempel ke kamera ###
            
            /// Coba core motion ###

            
            /// ####
            
//                        guard let pointOfView = self.sceneView.pointOfView else {return}
//                        let transform = pointOfView.transform
//                        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
//                        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
//                        let position = location //+ orientation
//
//                        self.sceneView.scene.rootNode.addChildNode(gacoan)
//                        gacoan.position = SCNVector3(position.x,GunduFieldNode.position.y,position.z - 0.5)
            
            
            /// Pakai point of View
            
//            guard let pointOfView = self.sceneView.pointOfView else {return}
//            let transform = pointOfView.transform
//            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
//            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
//            let position = location + orientation
//
//            self.sceneView.scene.rootNode.addChildNode(gacoan)
//            gacoan.position = SCNVector3(position.x,GunduFieldNode.position.y,position.z)
////            gacoan.runAction(action)
//
//
//            print(GunduFieldNode.position)
//            print(gacoan.position) // kiri kanan pakai x,, atas bawah pakai y
            
            
            
            //print(modifiedMatrix)
            //print(gacoan.position)
            
////            gacoan.runAction(SCNAction.repeatForever(action))
//            self.sceneView.scene.rootNode.addChildNode(gacoan)
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.1 // Translate 10 cm in front of the camera
//            gacoan.simdTransform = matrix_multiply(camera.transform, translation)
            
        }
        }
    
    
    func addSasaran() {
                for i in 0...5 {
                    //let sasaran = Sasaran()
//                    let x = Double.random(in: -0.3...0.5)
//                    let z = Double.random(in: -0.3...0.5)
//                    sasaran.position = SCNVector3(x, 0, z)
                    let sasaranShape = SCNSphere(radius: 0.05)
                    sasaranShape.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_sun")
                    let sasaran = SCNNode(geometry: sasaranShape)
                    
                    let x = [0, 0, -0.2, -0.2, 0.2, 0.2]
                    let z = [-0.2, 0.2, -0.2, 0.2, -0.2, 0.2]
                    sasaran.position = SCNVector3(Float(x[i]), 0.351, Float(z[i]))
                    //sasaran.simdScale = SIMD3(1*self.scaleRatio, 1*self.scaleRatio, 1*self.scaleRatio)
                    // Add command code here into Donut()
                    //sasaran.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                    //sasaran.physicsBody?.isAffectedByGravity = true
                    
//                    // Add Bitmasks Collision for Sasaran
//                    sasaran.physicsBody?.categoryBitMask = 4 // GamePhysicsBitmask2.sasaran
//                    sasaran.physicsBody?.collisionBitMask = 7 //GamePhysicsBitmask2.gacoan | GamePhysicsBitmask2.sasaran
//                    sasaran.physicsBody?.contactTestBitMask = 12 //GamePhysicsBitmask2.torus | GamePhysicsBitmask2.sasaran
                    
                    self.GunduFieldNode.addChildNode(sasaran)
                    
                    //particleEmitter = sasaran.rootNode.childNode(withName: "particleEmitter", recursively: true)!
                    
                }
            }
    
    
    // Add rendering pointer where to place GunduField or Gacoan
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//            self.isGameOn = true
            if !isGameOn {
//                print(isGameOn)
                let hitTestResult = sceneView.hitTest(center, types: .existingPlaneUsingExtent).filter { (result) -> Bool in
                    return (result.anchor as? ARPlaneAnchor)?.alignment == ARPlaneAnchor.Alignment.horizontal
                }.last
                
//                print(hitTestResult)
                let result = hitTestResult
                guard let transform = result?.worldTransform else {return}
                let thirdColumn = transform.columns.3
                let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
                    
                self.PlaneDetectTrue.position = position
                self.sceneView.scene.rootNode.addChildNode(self.PlaneDetectTrue)

                }
            else if (isGameOn && self.isGunduFieldAdded == true && self.isGacoanAdded == true)  {
                
                //PlayGame()
                //let gacoan = Gacoan()
//                guard let poV = self.sceneView.pointOfView else {return}
//                let transform = poV.transform
//                let orientation = SCNVector3Make(-1*transform.m31,-1*transform.m32, -1*transform.m33)
//                let sphere = SCNSphere(radius: 0.1)
//                sphere.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_sun.png")
 
                guard let currentFrame = self.sceneView.session.currentFrame else {return}
                
                let sphere = SCNSphere(radius: 0.01)
                                sphere.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "gacoan-1")
                                let sphereNode = SCNNode(geometry: sphere)
                                
                //                sphereNode.opacity = 0.5
                                sphereNode.position = SCNVector3(0, 0, -1)
                
                var positionx = matrix_identity_float4x4
                positionx.columns.3.z = -0.1
                                    
                sphereNode.simdTransform = matrix_multiply(currentFrame.camera.transform, positionx)
                sphereNode.name = "sphereNode"

                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                    //gacoanNode.addChildNode(sphereNode)
                    
                    self.sceneView.scene.rootNode.enumerateChildNodes({ (node,_) in
                        if node.name == "sphereNode" {
                        node.removeFromParentNode()
                        }
                    })
                    
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
//                print(GunduFieldNode.position)
//                print(sphereNode.position)
                
                
                
                
//                let hitTestResult = sceneView.hitTest(center, types: .existingPlaneUsingExtent).filter { (result) -> Bool in
//                                    return (result.anchor as? ARPlaneAnchor)?.alignment == ARPlaneAnchor.Alignment.horizontal
//                                }.last
//
//                //                print(hitTestResult)
//                                let result = hitTestResult
//                                guard let transform = result?.worldTransform else {return}
//                                let thirdColumn = transform.columns.3
//                                let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
//
//                                self.gacoan.position = position
//                                self.sceneView.scene.rootNode.addChildNode(self.gacoan)
    
            }
            else if (isGameOn && self.isGunduFieldAdded == true && self.isGacoanAdded == true) {
               //print("show pointer")
                //showDummyPointer()
            }
            
        }
    
    
    // Add Coaching to search Plane horizontal
    func overlayCoachingView () {
        
        let coachingView = ARCoachingOverlayView(frame: CGRect(x: 0, y: 0, width: sceneView.frame.width, height: sceneView.frame.height))
        
        coachingView.session = sceneView.session
        coachingView.activatesAutomatically = true
        coachingView.goal = .horizontalPlane
        
        view.addSubview(coachingView)
        
    }
    
    func runSession() {
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        //detects horizontal surfaces
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        #if DEBUG
            self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        #endif
        
        //sceneView.scene.physicsWorld.gravity = SCNVector3Make(0.0, -4.0, 0.0)
        
        let scene = SCNScene()
        sceneView.scene = scene
        
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


    

}

func +(left: SCNVector3, right:SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func pointInFrontOfPoint(point: SCNVector3, direction: SCNVector3, distance: Float) -> SCNVector3 {
    var x = Float()
    var y = Float()
    var z = Float()

    x = point.x + distance * direction.x
    y = point.y + distance * direction.y
    z = point.z + distance * direction.z

    let result = SCNVector3Make(x, y, z)
    return result
}

func calculateCameraDirection(cameraNode: SCNNode) -> SCNVector3 {
    let x = -cameraNode.rotation.x
    let y = -cameraNode.rotation.y
    let z = -cameraNode.rotation.z
    let w = cameraNode.rotation.w
    let cameraRotationMatrix = GLKMatrix3Make(cos(w) + pow(x, 2) * (1 - cos(w)),
                                              x * y * (1 - cos(w)) - z * sin(w),
                                              x * z * (1 - cos(w)) + y*sin(w),

                                              y*x*(1-cos(w)) + z*sin(w),
                                              cos(w) + pow(y, 2) * (1 - cos(w)),
                                              y*z*(1-cos(w)) - x*sin(w),

                                              z*x*(1 - cos(w)) - y*sin(w),
                                              z*y*(1 - cos(w)) + x*sin(w),
                                              cos(w) + pow(z, 2) * ( 1 - cos(w)))

    let cameraDirection = GLKMatrix3MultiplyVector3(cameraRotationMatrix, GLKVector3Make(0.0, 0.0, -1.0))
    return SCNVector3FromGLKVector3(cameraDirection)
}

//MARK: - Extension

extension Float {
    var degreestoRadians: Double {return Double(self) * .pi / 180 }
}


extension ViewController {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("** Collision!! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)
//
        var contactNode:SCNNode!
        //print("Mulai PContactDelegate")

        if (contact.nodeA.name == "gacoan" || contact.nodeB.name == "gacoan") {
            //print("salah satunya gacoan")
            // Contact Gacoan Terhadap Sasaran dan Torus
            if contact.nodeA.name == "gacoan" {
                contactNode = contact.nodeB
            } else{
                contactNode = contact.nodeA
            }
            
            // Jika Gacoan kena sasaran
            if contactNode.physicsBody?.categoryBitMask == 4 {
            //contactNode.isHidden = true

            //play audio
                //let sawSound = sounds["saw"]!
                //ballNode.runAction(SCNAction.playAudio(sawSound, waitForCompletion: false))

                contactNode.runAction(SCNAction.playAudio(SCNAudioSource(fileNamed: "art.scnassets/Audio/collect.mp3")!, waitForCompletion: true))
                //print(" Node is Gacoan Kena Sasaran")
            }
            else if contactNode.physicsBody?.categoryBitMask == 8 {
                // Reset Game State back to gacoan ready to put on the field
                //numberofcontact?
                print("Node is Gacoan Reset Game State")
            }

        }
//
//        else if (contact.nodeA.name == "sasaran" || contact.nodeB.name == "sasaran") {
//            // Contact Sasaran Terhadap Sasaran lain dan juga Torus
//            if contact.nodeA.name == "sasaran" {
//                contactNode = contact.nodeB
//            } else {
//                contactNode = contact.nodeA
//            }
//
//            // Jika Sasaran kena sasaran lain
//            if contactNode.physicsBody?.categoryBitMask == GamePhysicsBitmask.sasaran {
//            //contactNode.isHidden = true
//
//            //play audio
//                //let sawSound = sounds["saw"]!
//                //ballNode.runAction(SCNAction.playAudio(sawSound, waitForCompletion: false))
//
//                contactNode.runAction(SCNAction.playAudio(SCNAudioSource(fileNamed: "collect.mp3")!, waitForCompletion: true))
//            }
//            else if contactNode.physicsBody?.categoryBitMask == GamePhysicsBitmask.torus {
//                // Score + 1
//                print("Score + 1")
//                self.userScore += 1
//            }
//
//
//            }
//
//
////        if let sasaran = contact.nodeB.parent as? Sasaran{
////            collect(sasaran)
////        }
        
    }

//    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
//        var contactEndNode:SCNNode!
//        
//        if (contact.nodeA.name == "gacoan" || contact.nodeB.name == "gacoan") {
//        print("salah satunya gacoan")
//        // Contact Gacoan Terhadap Sasaran dan Torus
//        if contact.nodeA.name == "gacoan" {
//            contactEndNode = contact.nodeB
//        } else{
//            contactEndNode = contact.nodeA
//        }
//    }
//        
//        if contactEndNode.physicsBody?.categoryBitMask == 8 {
//            print("End Contact With Torus")
//            }
//        else {
//        }
//        
//        }

}


extension SCNMatrix4 {
    static public func *(left: SCNMatrix4, right: SCNVector4) -> SCNVector4 {
        let x = left.m11*right.x + left.m21*right.y + left.m31*right.z + left.m41*right.w
        let y = left.m12*right.x + left.m22*right.y + left.m32*right.z + left.m42*right.w
        let z = left.m13*right.x + left.m23*right.y + left.m33*right.z + left.m43*right.w
        let w = left.m14*right.x + left.m24*right.y + left.m43*right.z + left.m44*right.w

        return SCNVector4(x: x, y: y, z: z, w: w)
    }
}
extension SCNVector4 {
    public func to3() -> SCNVector3 {
        return SCNVector3(self.x , self.y, self.z)
    }
}


