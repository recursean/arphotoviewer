//
//  ViewController.swift
//  ARPhotoViewer
//
//  Created by Sean McShane on 5/3/20.
//  Copyright © 2020 Sean McShane. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addImage: UIImageView!
    
    var sceneController = PhotoViewerScene()
    var didInitializeScene: Bool = false
    var showFrame: Bool = false
    var isFrameSet: Bool = false
    let impact = UIImpactFeedbackGenerator()
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        if let scene = sceneController.scene {
            sceneView.scene = scene
            //sceneView.debugOptions.insert(.showWorldOrigin)
        }
        
        // gesture recognizers
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
        screenTapRecognizer.name = "tap"
        self.view.addGestureRecognizer(screenTapRecognizer)
        
        let addImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addImageTapped))
        addImageTapRecognizer.name = "tap"
        addImage.addGestureRecognizer(addImageTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didDoubleTapScreen))
        doubleTapRecognizer.name = "doubleTap"
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let config = ARWorldTrackingConfiguration()
        
        // enable plane detection
        //config.planeDetection = [.horizontal, .vertical]

        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }
        
        // enable people occlusion 
        config.frameSemantics.insert(.personSegmentationWithDepth)
        
        // Run the view's session
        sceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    /**
     Called every frame. Used to update placer node position if not set.
     */
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if(!didInitializeScene) {
            if sceneView.session.currentFrame?.camera != nil {
                didInitializeScene = true
            }
        }
        
        if(didInitializeScene){
            if(showFrame && !isFrameSet){
                if let camera = sceneView.session.currentFrame?.camera {
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -1.0

                    let transform = camera.transform * translation
                    let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

                    sceneController.updateFramePosition(position: position, sceneView.pointOfView!)
                }
            }
        }
    }
    
    // MARK: - Gesture recognizers
    
    /**
     Place placer node as long as it hasn't been set already
     */
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if(didInitializeScene && showFrame && !isFrameSet) {
            if let camera = sceneView.session.currentFrame?.camera {
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.0
                
                let transform = camera.transform * translation
                let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                sceneController.updateFramePosition(position: position, sceneView.pointOfView!)
                
                impact.impactOccurred()
                isFrameSet = true
                showFrame = false
            }
        }
    }
    
    /**
     Pick up placer node if placed and start to follow user's camera again
     */
    @objc func didDoubleTapScreen(recognizer: UITapGestureRecognizer) {
        if(didInitializeScene && isFrameSet) {
            impact.impactOccurred()
            isFrameSet = false
            showFrame =  true
        }
    }
    
    /**
     Open camera or user's photo gallery to allow them to select an image.
     */
    @IBAction func addImageTapped(_ sender: UITapGestureRecognizer) {
        
        let alert: UIAlertController?
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            alert = UIAlertController(title: "Image Selection", message: "Take or select an image to display", preferredStyle: .alert)
        }
        else {
            alert = UIAlertController(title: "Image Selection", message: "Take or select an image to display", preferredStyle: .actionSheet)
        }
        
        alert!.addAction(UIAlertAction(title: "Open back camera", style: .default, handler: {
            action in
            
            if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraDevice = .rear
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        
        alert!.addAction(UIAlertAction(title: "Open front camera", style: .default, handler: {
            action in
            
            if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraDevice = .front
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        
        alert!.addAction(UIAlertAction(title: "Photos", style: .default, handler: {
            action in
            
            if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))

        
        alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
        self.present(alert!, animated: true)
    }
    
    /**
     Called when image has been selected
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            sceneController.setImage(image.fixOrientation())
            showFrame = true
        }
    }
}
