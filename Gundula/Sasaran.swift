//
//  Gacoan.swift
//  Gundula
//
//  Created by Feri Fajri on 11/06/20.
//  Copyright © 2020 Feri Fajri. All rights reserved.
//

import SceneKit

class Sasaran: SCNNode {
    
    private var sasaran: SCNNode = SCNNode()
    
    override init() {
        super.init()
        //loadSasaran()
        //addChildNode(sasaran)
        
        
        let sasaranShape = SCNSphere(radius: 0.05)
        sasaranShape.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "2k_sun")
        let sasaran = SCNNode(geometry: sasaranShape)
        
        
        sasaran.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

        
        self.sasaran.addChildNode(sasaran)
        
        
    }
    
    
    
    private func loadSasaran() {
        guard let sasaran = SCNScene(named: "art.scnassets/sasaran.scn")
        else {
            fatalError("Sasaran Scene is missing")
        }
        
        self.sasaran.addChildNode(sasaran.rootNode)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



