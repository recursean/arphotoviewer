//
//  PhotoViewerScene.swift
//  ARPhotoViewer
//
//  Class used to interact with the AR scene.
//
//  Created by Sean McShane on 5/3/20.
//  Copyright © 2020 Sean McShane. All rights reserved.
//

import Foundation
import SceneKit

class PhotoViewerScene {
    // main scene object
    var scene: SCNScene?
    
    // frame object used to hold image
    var frame: SCNBox?
    
    // container for frame; node's geometry is frame
    var frameContainer: SCNNode?
    
    // image used as material on frame
    var image: UIImage?
    
    // aspect ratio of image
    var aspect: Float = 2.0
    
    // frame rotation in radians
    var rotationOffset: Float = 0.0
    
    // whether the frame's position is locked
    var frameLocked = false
    
    // whether the frame's orientation is locked to camera
    var cameraLocked = true
    
    // material used for sides without image
    let defaultMaterial = SCNMaterial()
    
    // material containing image
    let imageMaterial = SCNMaterial()
    
    // meters to feet
    let mtof: Float = 3.28084
    
    /// flag to record if frame is showing image on all sides or not
    var showAllSides = true
    
    /// Creates the inital frame and scene object.
    init() {
        frame = SCNBox(width: 0.3048, height: 0.6096, length: 0.005, chamferRadius: 0.0)
        frameContainer = SCNNode(geometry: frame)
        
        scene = self.initializeScene()
    }
    
    /// init scene variable and set environmental defaults for it.
    /// - Returns: new scene object
    func initializeScene() -> SCNScene? {
        let scene = SCNScene()
        
        setDefaults(scene: scene)
        
        return scene
    }
    
    /// Set default environment for scene.
    /// - Parameter scene: main scene object
    func setDefaults(scene: SCNScene) {
        setDefaultMaterial(.brown, false)
    }
    
    /// Update position of frame. Called every frame.
    /// - Parameters:
    ///   - position: new position
    ///   - pov: scene's camera's pov used to get orientation
    func updateFramePosition(position: SCNVector3, _ pov: SCNNode) {
        if(!frameLocked) {
            frameContainer!.position = position
        }
            
        if(cameraLocked) {
            frameContainer!.orientation = pov.orientation

            frameContainer!.orientation = calculateRotateOrientation(rotationOffset)
        }
    }
    
    // MARK: - frame size updating methods
    /// Change the frame's size to new value.
    /// - Parameter value: new width (m)
    func updateFrameSize(_ value: Float) {
        frame?.width = CGFloat(value)
        
        // size slider controls frame's width so calculate height from original aspect ratio
        frame?.height = CGFloat(value * aspect)
    }
    
    /// Change the frame's size to new value.
    /// - Parameters:
    ///   - width: new width (px)
    ///   - height: new height (px)
    func updateFrameSize(_ width: CGFloat, _ height: CGFloat) {
        aspect = Float(height / width)
        
        frame?.width = width * 0.0001
        frame?.height = height * 0.0001
    }
    
    /// Update image length with specified value.
    /// - Parameter length: new length (m))
    func updateFrameLength(_ length: CGFloat) {
        frame?.length = length
    }
    
    // MARK: - frame rotation methods
    
    /// Rotate frame by specified amount.
    /// - Parameter rotation: rotation in radians
    func rotateFrame(_ rotation: Float) {
        // reset the rotation to 0 if a full rotation has been done
        if(rotationOffset + rotation == Float.pi * 2 || rotationOffset + rotation == -Float.pi * 2) {
            rotationOffset = 0
        }
        
        else {
            rotationOffset += rotation
        }
        
        // doing rotation here because it should only be done once and not every frame if camera not locked
        if(!cameraLocked) {
            frameContainer!.orientation = calculateRotateOrientation(rotation)
        }
    }
    
    /// Determine what the frame's orientation should be after applying rotation.
    /// - Parameter rotation: rotation in radians
    /// - Returns: frame's orientation after rotation
    func calculateRotateOrientation(_ rotation: Float) -> SCNQuaternion {
        var glQuaternion = GLKQuaternionMake(frameContainer!.orientation.x, frameContainer!.orientation.y, frameContainer!.orientation.z, frameContainer!.orientation.w)

        // Rotate around Z axis
        let multiplier = GLKQuaternionMakeWithAngleAndAxis(rotation, 0, 0, 1)
        glQuaternion = GLKQuaternionMultiply(glQuaternion, multiplier)
        
        return SCNQuaternion(x: glQuaternion.x, y: glQuaternion.y, z: glQuaternion.z, w: glQuaternion.w)
    }
    
    // MARK: - material changing methods
    
    /// Set default material for sides of box not covered by box.
    /// - Parameters:
    ///   - color: color to use for default matieral
    ///   - showAllSides: whether to show image on all sides or not
    func setDefaultMaterial(_ color: UIColor, _ showAllSides: Bool) {
        defaultMaterial.diffuse.contents = color
        defaultMaterial.locksAmbientWithDiffuse = true
        
        setMaterials(showAllSides)
    }
    
    /// Set the texture for each of the 6 sides of frame.
    /// - Parameter showAllSides: whether to show image on all sides or not
    func setMaterials(_ showAllSides: Bool) {
        self.showAllSides = showAllSides
        
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
    
    // MARK: - frame existance in scene methods
    
    /// Adds the frame object to the main scene.
    func addFrame() {
        guard let scene = self.scene else { return }
        
        scene.rootNode.addChildNode(frameContainer!)
    }
    
    /// Removes the frame from main scene.
    func removeFrame() {
        frameContainer!.removeFromParentNode()
    }
    
    /// Hides/shows the frame
    /// - Parameter hidden: flag to control hide frame or not
    func toggleFrameHidden(_ hidden: Bool) {
        if(hidden) {
            imageMaterial.diffuse.contents = UIColor.clear
            setMaterials(true)
        }
        
        else {
            imageMaterial.diffuse.contents = self.image
            setMaterials(showAllSides)
        }
    }
    
    // MARK: - misc methods
    
    /// Set back to default frame size and length.
    func setDefaultEdit() {
        updateFrameSize(image!.size.width, image!.size.height)
        
        updateFrameLength(0.05)
    }
    
    /// Set the frame material to be the specified image.
    /// - Parameter image: image to use for material
    func setImage(_ image: UIImage) {
        self.image = image
        
        updateFrameSize(image.size.width, image.size.height)
        aspect = Float(image.size.height / image.size.width)
        
        imageMaterial.diffuse.contents = self.image

        setMaterials(true)
    }
    
    /// Controls whether frame's position is locked or not.
    /// - Returns: frame position lock status
    func toggleFrameLocked() -> Bool {
        frameLocked = !frameLocked
        
        return frameLocked
    }
    
    /// Controls whether frame's orientation is locked to camera or not.
    /// - Returns: frame orientation lock status
    func toggleCameraLocked() -> Bool {
        cameraLocked = !cameraLocked
        
        return cameraLocked
    }
    
    /// Toggle if image gets drawn on all sides or not.
     /// - Parameter showAllSides: image should be drawn on all sides of frame
     func toggleAllSides(_ showAllSides: Bool) {
         setMaterials(showAllSides)
     }
    
    /// Gets the width, height, and length of frame.
    /// - Returns: frame's dimensions
    func getFrameDimensions() -> [CGFloat] {
        return [frame!.width, frame!.height, frame!.length]
    }
    
    /// Gets the frame's current position.
    /// - Returns: <#description#>
    func getFramePosition() -> SCNVector3 {
        return frameContainer!.position
    }
    
    /// Checks to see if frame's position is locked.
    /// - Returns: frame's position locked status
    func isFrameLocked() -> Bool {
        return frameLocked
    }
    
    /// Checks to see if frame's orientation is locked to camera.
    /// - Returns: frame's orientation lock status
    func isCameraLocked() -> Bool {
        return cameraLocked
    }
    
    /// Sets the frame to 0 rotation (default).
    func setFrameNoRotation() {
        rotationOffset = 0
    }
}
