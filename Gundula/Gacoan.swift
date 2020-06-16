//
//  Gacoan.swift
//  Gundula
//
//  Created by Feri Fajri on 11/06/20.
//  Copyright © 2020 Feri Fajri. All rights reserved.
//

import SceneKit

class Gacoan: SCNNode {
    
    private var gacoan: SCNNode = SCNNode()
    
    override init() {
        super.init()
        loadGacoan()
        addChildNode(gacoan)
    }
    
    
    
    private func loadGacoan() {
        guard let gacoan = SCNScene(named: "art.scnassets/gacoan.scn")
        else {
            fatalError("Wolf Scene is missing")
        }
        
        self.gacoan.addChildNode(gacoan.rootNode)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
