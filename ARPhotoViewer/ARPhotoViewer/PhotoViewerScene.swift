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
    var frame: SCNBox?
    var frameAdded = false
    var prevContainerNode: SCNNode?
    var image: UIImage?
    
    /**
     Create box "frame" and init scene
     */
    init() {
        frame = SCNBox(width: 0.5, height: 1.0, length: 0.1, chamferRadius: 1.0)
        
        //setImageString("art.scnassets/arnolfini.jpg")
        
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
     Update position of frame
     Called:
        - every frame when frame is not placed yet
        - when screen is tapped to place frame
     */
    func updateFramePosition(position: SCNVector3, _ pov: SCNNode) {
        guard let scene = self.scene else { return }
        
        let containerNode = SCNNode(geometry: frame)
        
        containerNode.orientation = pov.orientation
        containerNode.position = position
        
        if(!frameAdded) {
            scene.rootNode.addChildNode(containerNode)
            frameAdded = true
        }
        else {
            scene.rootNode.replaceChildNode(prevContainerNode!, with: containerNode)
        }
        
        prevContainerNode = containerNode
    }
    
    /**
     Set the frame material to be the specified image.
     */
    func setImage(_ image: UIImage) {
        self.image = image
        
        frame!.firstMaterial?.diffuse.contents = self.image
    }
    
    /**
     Used for debug
     */
    func setImageString(_ image: String) {
        self.image = UIImage(named: image)
        
        frame!.firstMaterial?.diffuse.contents = self.image
    }
}
