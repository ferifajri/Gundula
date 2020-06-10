////
////  ManualCreateFunduField.swift
////  Gundula
////
////  Created by Feri Fajri on 10/06/20.
////  Copyright © 2020 Feri Fajri. All rights reserved.
////
//
//import SceneKit
//
//// Manual Create Gundu Field
//        
//        let gunduFieldNode = SCNNode()
//        
//        let gunduFieldWidth = self.gunduFieldWidth
//        let gunduFieldHeight = self.gunduFieldHeight
//        
////        gunduFieldNode.geometry = SCNPlane(width: 0.4, height: 0.4)
//        gunduFieldNode.geometry = SCNPlane(width: gunduFieldWidth, height: gunduFieldHeight)
//        gunduFieldNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "grass2")
//        gunduFieldNode.geometry?.firstMaterial?.isDoubleSided = true
//        gunduFieldNode.name = "GunduField"
//        
//        let positionOfPlane = hitTestResult.worldTransform.columns.3
//        let xPosition = positionOfPlane.x
//        let yPosition = positionOfPlane.y
//        let zPosition = positionOfPlane.z
//        
//        //gunduFieldNode.position = SCNVector3(0,0,-0.5)
//        gunduFieldNode.position = SCNVector3(xPosition,yPosition,zPosition)
//        gunduFieldNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: gunduFieldNode, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        
//        gunduFieldNode.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
//        
//        self.sceneView.scene.rootNode.addChildNode(gunduFieldNode)
//        
//        //let wall1 = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.5))
//        let wall1 = SCNNode(geometry: SCNBox(width: 0.01, height: gunduFieldHeight/10, length: gunduFieldHeight, chamferRadius: 0))
//        wall1.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_moon")
//        wall1.position = SCNVector3(gunduFieldHeight/2,0,0.05)
//        wall1.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
//        wall1.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall1, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        gunduFieldNode.addChildNode(wall1)
//        
//        let wall2 = SCNNode(geometry: SCNBox(width: 0.01, height: gunduFieldHeight/10, length: gunduFieldHeight, chamferRadius: 0))
//        wall2.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_moon")
//        wall2.position = SCNVector3(-gunduFieldHeight/2,0,0.05)
//        wall2.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
//        wall2.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall2, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        gunduFieldNode.addChildNode(wall2)
//        
//        //let wall1 = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.5))
//        let wall3 = SCNNode(geometry: SCNBox(width: 0.01, height: gunduFieldHeight/10, length: gunduFieldHeight, chamferRadius: 0))
//        wall3.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_moon")
//        wall3.position = SCNVector3(0,gunduFieldHeight/2,0.05)
//        wall3.eulerAngles = SCNVector3(-90.degreestoRadians,0,-90.degreestoRadians)
//        wall3.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall3, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        gunduFieldNode.addChildNode(wall3)
//        
//        //let wall1 = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.5))
//        let wall4 = SCNNode(geometry: SCNBox(width: 0.01, height: gunduFieldHeight/10, length: gunduFieldHeight, chamferRadius: 0))
//        wall4.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_moon")
//        wall4.position = SCNVector3(0,-gunduFieldHeight/2,0.05)
//        wall4.eulerAngles = SCNVector3(-90.degreestoRadians,0,-90.degreestoRadians)
//        wall4.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall4, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        gunduFieldNode.addChildNode(wall4)
//        
//        //let circle = SCNNode(geometry: SCNCylinder(radius: gunduFieldHeight/10, height: 0.01))
//        let circle = SCNNode(geometry: SCNTorus(ringRadius: gunduFieldHeight/10, pipeRadius: 0.001))
//        circle.geometry?.firstMaterial?.diffuse.contents = UIColor.white
//        circle.position = SCNVector3(0,0,0)
//        circle.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
//        //circle.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall4, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        gunduFieldNode.addChildNode(circle)
//        
//        //let circle = SCNNode(geometry: SCNCylinder(radius: gunduFieldHeight/10, height: 0.01))
//        let sasaran = SCNNode(geometry: SCNSphere(radius: self.gunduFieldHeight/50))
//        sasaran.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "sasaran-1")
//        sasaran.position = SCNVector3(0,0,gunduFieldHeight/50*2)
//        sasaran.eulerAngles = SCNVector3(-90.degreestoRadians,0,0)
//        sasaran.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: sasaran, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        gunduFieldNode.addChildNode(sasaran)
//
//
//
