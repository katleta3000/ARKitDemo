//
//  ViewController.swift
//  ARTest
//
//  Created by Evgenii Rtishchev on 26/11/2017.
//  Copyright © 2017 Evgenii Rtishchev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    var planes = [UUID: VirtualPlane]()
    var placemarkNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        let scene = SCNScene()
        sceneView.scene = scene
        initializePlacemarkNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func initializePlacemarkNode() {
        let placemarkScene = SCNScene(named: "mug.dae")!
        self.placemarkNode = placemarkScene.rootNode.childNode(withName: "Mug", recursively: true)!
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // create a 3d plane from the anchor
        if let arPlaneAnchor = anchor as? ARPlaneAnchor {
            let plane = VirtualPlane(anchor: arPlaneAnchor)
            self.planes[arPlaneAnchor.identifier] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let plane = planes[arPlaneAnchor.identifier] {
            plane.updateWithNewAnchor(arPlaneAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let index = planes.index(forKey: arPlaneAnchor.identifier) {
            planes.remove(at: index)
        }
    }
    
    // MARK: - UIView interaction
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: sceneView)
        if let plane = planeForTouches(touchPoint: touchPoint) {
            addSpider(plane: plane, atPoint: touchPoint)
        }
    }
    
    private func planeForTouches(touchPoint: CGPoint) -> VirtualPlane? {
        let hits = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        if hits.count > 0, let firstHit = hits.first, let identifier = firstHit.anchor?.identifier, let plane = planes[identifier] {
            return plane
        }
        return nil
    }
    
    func addSpider(plane: VirtualPlane, atPoint point: CGPoint) {
        let hits = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
        if hits.count > 0, let firstHit = hits.first {
            if let anotherPlacemark = placemarkNode?.clone() {
                anotherPlacemark.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
                sceneView.scene.rootNode.addChildNode(anotherPlacemark)
            }
        }
    }
}
