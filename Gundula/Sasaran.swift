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
        loadSasaran()
        addChildNode(sasaran)
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
