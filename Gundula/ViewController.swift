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


class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    ////  Config Touch Location
    var center: CGPoint!
    var positions = [SCNVector3]()

    
    // Config Element is added ?
    let PlaneDetectTrue = SCNScene(named: "art.scnassets/planedetecttrue.scn")!.rootNode
//    let PlaneDetectFalse = SCNScene(named: "art.scnassets/planedetectfalse.scn")!.rootNode
    let gacoan = SCNScene(named: "art.scnassets/gacoan.scn")!.rootNode
    let GunduFieldNodeDisable = SCNScene(named: "GunduField.scnassets/NewGunduFieldDisable.scn")!.rootNode
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
        runSession()
        overlayCoachingView()
        center = view.center
        
        
        
        
        

        
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
            circle.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
            circle.position = SCNVector3(0,0,0)
//            circle.opacity = 1
            self.GunduFieldNodeDisable.addChildNode(circle)
                    
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
                    
                }
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
            else if (isGunduFieldNodeDisableAdded == true && (hitTestResult.node.name == "kiri" || hitTestResult.node.name == "kanan")) {
                self.GunduFieldNode.position = self.GunduFieldNodeDisable.position
                self.GunduFieldNode.scale = self.GunduFieldNodeDisable.scale
                self.GunduFieldNodeDisable.removeFromParentNode()
                
                //Add Collision
                GunduFieldNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                GunduFieldNode.physicsBody?.categoryBitMask = GamePhysicsBitmask.plane
                GunduFieldNode.physicsBody?.collisionBitMask = GamePhysicsBitmask.gacoan
                
                self.sceneView.scene.rootNode.addChildNode(self.GunduFieldNode)
                
                let circlePlane = SCNPlane(width: 1, height: 1)
                circlePlane.cornerRadius = 1
                circlePlane.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "grass2")
                let circle = SCNNode(geometry: circlePlane)
                circle.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
                circle.position = SCNVector3(0,0,0)
                self.GunduFieldNode.addChildNode(circle)
                
                
                
                self.isGameOn = true
                self.isGunduFieldAdded = true
                //print(self.isGunduFieldAdded)
            }
            else {
                //print(hitTestResult.node.name!)
            }
        }
    }
    
    
    //MARK: - Function
    
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
    
    func InsideCircle() {
        if (
        (abs(self.GunduFieldNode.position.x) - abs(self.gacoan.position.x) > 0 ) && (abs(self.GunduFieldNode.position.z) - abs(self.gacoan.position.z) > 0 ) ) {
            isInsideCircle = true
        } else {
            isInsideCircle = false
        }
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
            
            
            /// Pakai point of View
            
            guard let pointOfView = self.sceneView.pointOfView else {return}
            let transform = pointOfView.transform
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let position = location + orientation
//            //  gacoan.makeUpdateCameraPos(towards: position)
//            let action = SCNAction.move(to: SCNVector3(position.x,GunduFieldNode.position.y,position.y), duration: 0.0)
//
//
            self.sceneView.scene.rootNode.addChildNode(gacoan)
            gacoan.position = SCNVector3(position.x,GunduFieldNode.position.y,position.z)
//            gacoan.runAction(action)
            
            
            print(GunduFieldNode.position)
            print(gacoan.position) // kiri kanan pakai x,, atas bawah pakai y
            
            
            
            //print(location)
            //print(gacoan.position)
            
////            gacoan.runAction(SCNAction.repeatForever(action))
//            self.sceneView.scene.rootNode.addChildNode(gacoan)
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.1 // Translate 10 cm in front of the camera
//            gacoan.simdTransform = matrix_multiply(camera.transform, translation)
            
        }
        }
    
    
    func addSasaran() {
                for i in 0...1 {
                    let sasaran = Sasaran()
//                    let x = Double.random(in: -0.3...0.5)
//                    let z = Double.random(in: -0.3...0.5)
//                    sasaran.position = SCNVector3(x, 0, z)
                    
                    let x = [0,0,0.4,0.4,0.4]
                    let z = [-0.4,0.4,0,-0.4,0.4]
                    sasaran.position = SCNVector3(x[i], 0, z[i])
                    //sasaran.simdScale = SIMD3(1*self.scaleRatio, 1*self.scaleRatio, 1*self.scaleRatio)
        //            // Add command code here into Donut()
                    //sasaran.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                    //sasaran.physicsBody?.isAffectedByGravity = true
        //            // Add Collision
        //            donutNode.physicsBody?.categoryBitMask = GamePhysicsBitmask.donut
        //            donutNode.physicsBody?.collisionBitMask = GamePhysicsBitmask.wolf
                    
                    self.GunduFieldNode.addChildNode(sasaran)
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
            else if isGameOn  {
//                print(isGameOn)
                PlayGame()
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
        //detects horizontal surfaces
      configuration.planeDetection = .horizontal
      configuration.isLightEstimationEnabled = true
      sceneView.session.run(configuration)
      #if DEBUG
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showCameras]
      #endif
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

//MARK: - Extension

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
