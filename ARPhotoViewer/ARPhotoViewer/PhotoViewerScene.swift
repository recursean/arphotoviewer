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
    var frameLocked = false
    let defaultMaterial = SCNMaterial()
    let imageMaterial = SCNMaterial()
    var cameraLocked = true
    
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
     Update frame size. Sizes coming in will be in pixels.
     */
    func updateFrameSize(_ width: CGFloat, _ height: CGFloat) {
        aspect = Float(height / width)
        
        frame?.width = width * 0.0001
        frame?.height = height * 0.0001
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
     Set default environment for scene
     */
    func setDefaults(scene: SCNScene) {
        setDefaultMaterial(.brown, false)
    }
    
    /**
     Update position of frame
     Called:
        - every frame when frame is not placed yet
        - when screen is tapped to place frame
     */
    func updateFramePosition(position: SCNVector3, _ pov: SCNNode) {
        if(!frameLocked) {
            frameContainer!.position = position
        }
            
        if(cameraLocked) {
            frameContainer!.orientation = pov.orientation

            frameContainer!.orientation = calculateRotateOrientation(rotationOffset)
        }
    }
    
    /**
     Determine what the frame's orientation should be after applying rotation.
     */
    func calculateRotateOrientation(_ rotation: Float) -> SCNQuaternion {
        var glQuaternion = GLKQuaternionMake(frameContainer!.orientation.x, frameContainer!.orientation.y, frameContainer!.orientation.z, frameContainer!.orientation.w)

        // Rotate around Z axis
        let multiplier = GLKQuaternionMakeWithAngleAndAxis(rotation, 0, 0, 1)
        glQuaternion = GLKQuaternionMultiply(glQuaternion, multiplier)
        
        return SCNQuaternion(x: glQuaternion.x, y: glQuaternion.y, z: glQuaternion.z, w: glQuaternion.w)
    }
    
    /**
     Sets if rotation should be updated each frame
     */
    func toggleFrameLocked() -> Bool {
        frameLocked = !frameLocked
        
        return frameLocked
    }
    
    /**
     Sets if frame should be locked to camera.
     */
    func toggleCameraLocked() -> Bool {
        cameraLocked = !cameraLocked
        
        return cameraLocked
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
        
        updateFrameSize(image.size.width, image.size.height)
        aspect = Float(image.size.height / image.size.width)
        
        imageMaterial.diffuse.contents = self.image
        
        setMaterials(true)
    }
    
    /**
     Used for debug
     */
    func setImageString(_ image: String) {
        self.image = UIImage(named: image)
        imageMaterial.diffuse.contents = self.image
        setMaterials(true)
    }
    
    /**
     Set default material for sides of box not covered by box
     */
    func setDefaultMaterial(_ color: UIColor, _ showAllSides: Bool) {
        defaultMaterial.diffuse.contents = color
        defaultMaterial.locksAmbientWithDiffuse = true
        
        setMaterials(showAllSides)
    }
    
    /**
     Returns width, height, and length of frame.
     */
    func getFrameDimensions() -> [CGFloat] {
        return [frame!.width, frame!.height, frame!.length]
    }
    
    /**
     Returns the frame's position.
     */
    func getFramePosition() -> SCNVector3 {
        return frameContainer!.position
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
        
        // doing rotation here because it should only be done once and not every frame
        if(!cameraLocked) {
            frameContainer!.orientation = calculateRotateOrientation(rotation)
        }
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
        updateFrameSize(image!.size.width, image!.size.height)
        
        updateFrameLength(0.05)
    }
    
    /**
     Removes frame from scene.
     */
    func removeFrame() {
        frameContainer!.removeFromParentNode()
    }
    
    /**
     Checks to see if frame is locked.
     */
    func isFrameLocked() -> Bool {
        return frameLocked
    }
    
    /**
     Checks to see if camera is locked.
     */
    func isCameraLocked() -> Bool {
        return cameraLocked
    }
    
    /**
     Sets the frame to locked (default).
     */
    func setFrameNoRotation() {
        rotationOffset = 0
    }
}
