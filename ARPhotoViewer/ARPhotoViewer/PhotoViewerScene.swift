//
//  PhotoViewerScene.swift
//  ARPhotoViewer
//
//  Created by Sean McShane on 5/3/20.
//  Copyright © 2020 Sean McShane. All rights reserved.
//

import Foundation
import SceneKit

class PhotoViewerScene {
    var scene: SCNScene?
    var placer: SCNBox?
    var placerAdded = false
    var prevContainerNode: SCNNode?
    
    /**
     Create box "placer" and init scene
     */
    init() {
        placer = SCNBox(width: 0.5, height: 1.0, length: 0.1, chamferRadius: 1.0)
        
        scene = self.initializeScene()
    }
    
    /**
     init scene variable and set environmental defaults for it
     */
    func initializeScene() -> SCNScene? {
        let scene = SCNScene()
        
        setDefaults(scene: scene)
        
        return scene
    }
    
    /**
     Set default environment (lighting) for scene
     */
    func setDefaults(scene: SCNScene) {
        let ambientLightNode = SCNNode()
        
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLight.LightType.ambient
        ambientLightNode.light?.color = UIColor(white: 0.6, alpha: 1.0)
        
        scene.rootNode.addChildNode(ambientLightNode)
        
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        
        let directionalNode = SCNNode()
        directionalNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-130), GLKMathDegreesToRadians(0), GLKMathDegreesToRadians(35))
        directionalNode.light = directionalLight
        
        scene.rootNode.addChildNode(directionalNode)
    }
    
    /**
     Update position of placer
     Called:
        - every frame when placer is not placed yet
        - when screen is tapped to place placer
     */
    func updatePlacerPosition(position: SCNVector3, _ pov: SCNNode) {
        guard let scene = self.scene else { return }
        
        let containerNode = SCNNode(geometry: placer)
        
        containerNode.orientation = pov.orientation
        containerNode.position = position

        if(!placerAdded) {
            scene.rootNode.addChildNode(containerNode)
            placerAdded = true
        }
        else {
            scene.rootNode.replaceChildNode(prevContainerNode!, with: containerNode)
        }
        
        prevContainerNode = containerNode
    }
}
