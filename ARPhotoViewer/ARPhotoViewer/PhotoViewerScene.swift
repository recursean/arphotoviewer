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
    var frameContainer: SCNNode?
    var image: UIImage?
    var aspect: Float = 2.0
    var defaultRotation = SCNVector4(0, 0, 0, 0)
    var rotationOffset: Float = 0.0
    var updateRotation = false
    let defaultMaterial = SCNMaterial()
    let imageMaterial = SCNMaterial()
    
    // meters to feet
    let mtof: Float = 3.28084
    
    /**
     Create box "frame" and init scene
     */
    init() {
        frame = SCNBox(width: 0.3048, height: 0.6096, length: 0.05, chamferRadius: 0.0)
        frameContainer = SCNNode(geometry: frame)
        
        //setImageString("art.scnassets/arnolfini.jpg")
        
        scene = self.initializeScene()
    }
    
    /**
     Update image size. Either increase or decrease by certain amount.
     */
    func updateFrameSize(_ value: Float) {
        frame?.width = CGFloat(value)
        frame?.height = CGFloat(value * aspect)
    }
    
    /**
     Update image length with specified value.
     */
    func updateFrameLength(_ length: CGFloat) {
        frame?.length = length
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
        
        setDefaultMaterial(.brown)
    }
    
    /**
     Update position of frame
     Called:
        - every frame when frame is not placed yet
        - when screen is tapped to place frame
     */
    func updateFramePosition(position: SCNVector3, _ pov: SCNNode) {
        frameContainer!.orientation = pov.orientation
        frameContainer!.position = position
        
        if(updateRotation) {
           frameContainer!.rotation = defaultRotation
        }
        
        frameContainer!.eulerAngles.z += rotationOffset
        //frameContainer!.localRotate(by: SCNVector4(0, 0, rotationOffset, 0))
    }
    
    /**
     Sets if rotation should be updated each frame
     */
    func toggleUpdateRotation() -> Bool {
        updateRotation = !updateRotation
        
        return updateRotation
    }
    
    /**
     Adds frame to scene
     */
    func addFrame() {
        guard let scene = self.scene else { return }
        
        scene.rootNode.addChildNode(frameContainer!)
    }
    
    /**
     Set the frame material to be the specified image.
     */
    func setImage(_ image: UIImage) {
        self.image = image
        imageMaterial.diffuse.contents = self.image
        setMaterials(false)
    }
    
    /**
     Used for debug
     */
    func setImageString(_ image: String) {
        self.image = UIImage(named: image)
        imageMaterial.diffuse.contents = self.image
        setMaterials(false)
    }
    
    /**
     Set default material for sides of box not covered by box
     */
    func setDefaultMaterial(_ color: UIColor) {
        defaultMaterial.diffuse.contents = color
        defaultMaterial.locksAmbientWithDiffuse = true
        
        setMaterials(false)
    }
    
    /**
     Returns width, height, and length of frame.
     */
    func getImageDimensions() -> [CGFloat] {
        return [frame!.width, frame!.height, frame!.length]
    }
    
    /**
     Rotates frame by specified amount.
     */
    func rotateFrame(_ rotation: Float) {
        if(rotationOffset + rotation == Float.pi * 2 || rotationOffset + rotation == -Float.pi * 2) {
            rotationOffset = 0
        }
        
        else {
            rotationOffset += rotation
        }
        //frameContainer!.localRotate(by: SCNVector4(0, 0, 0, rotationOffset))
    }
    
    /**
     Toggle if image gets drawn on all sides or not
     */
    func toggleAllSides(_ showAllSides: Bool) {
        setMaterials(showAllSides)
    }
    
    /**
     Set the texture for each of the 6 sides of frame
     */
    func setMaterials(_ showAllSides: Bool) {
        if(showAllSides) {
            frame!.materials = [
                                imageMaterial,
                                imageMaterial,
                                imageMaterial,
                                imageMaterial,
                                imageMaterial,
                                imageMaterial
            ]
        }
        else {
            frame!.materials = [
                                imageMaterial,
                                defaultMaterial,
                                imageMaterial,
                                defaultMaterial,
                                defaultMaterial,
                                defaultMaterial
            ]
        }
    }
    
    /**
     Set back to default frame size and length.
     */
    func setDefaultEdit() {
        updateFrameSize(0.3048)
        updateFrameLength(0.05)
    }
    
    /**
     Removes frame from scene.
     */
    func removeFrame() {
        frameContainer!.removeFromParentNode()
    }
}
