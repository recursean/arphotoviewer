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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var sceneController = PhotoViewerScene()
    var didInitializeScene: Bool = false
    var isPlacerSet: Bool = false
    let impact = UIImpactFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        if let scene = sceneController.scene {
            sceneView.scene = scene
            //sceneView.debugOptions.insert(.showWorldOrigin)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
        tapRecognizer.name = "tap"
        self.view.addGestureRecognizer(tapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didDoubleTapScreen))
        doubleTapRecognizer.name = "doubleTap"
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // enable plane detection
        //configuration.planeDetection = [.horizontal, .vertical]

        // Run the view's session
        sceneView.session.run(configuration)
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
            if(!isPlacerSet){
                if let camera = sceneView.session.currentFrame?.camera {
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -1.0
                    
                    let transform = camera.transform * translation
                    let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                    
                    sceneController.updatePlacerPosition(position: position, sceneView.pointOfView!)
                }
            }
        }
    }
    
    // MARK: - Gesture recognizers
    
    /**
     Place placer node as long as it hasn't been set already
     */
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if(didInitializeScene && !isPlacerSet) {
            if let camera = sceneView.session.currentFrame?.camera {
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.0
                
                let transform = camera.transform * translation
                let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                sceneController.updatePlacerPosition(position: position, sceneView.pointOfView!)
                
                impact.impactOccurred()
                isPlacerSet = true
            }
        }
    }
    
    /**
     Pick up placer node if placed and start to follow user's camera again
     */
    @objc func didDoubleTapScreen(recognizer: UITapGestureRecognizer) {
        if(didInitializeScene && isPlacerSet) {
            impact.impactOccurred()
            isPlacerSet = false
        }
    }
}
