//
//  VirtualPlane.swift
//  ARTest
//
//  Created by Evgenii Rtishchev on 26/11/2017.
//  Copyright © 2017 Evgenii Rtishchev. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class VirtualPlane: SCNNode {
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!

    init(anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = initializePlaneMaterial()
        self.planeGeometry!.materials = [material]
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
    
        updatePlaneMaterialDimensions()
        self.addChildNode(planeNode)
    }

    private func initializePlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.50)
        return material
    }

    func updatePlaneMaterialDimensions() {
        let material = self.planeGeometry.materials.first!

        let width = Float(self.planeGeometry.width)
        let height = Float(self.planeGeometry.height)
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
