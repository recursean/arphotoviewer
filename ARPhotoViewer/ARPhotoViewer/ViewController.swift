//
//  ViewController.swift
//  ARPhotoViewer
//
//  Controls the main view of the app.
//
//  Created by Sean McShane on 5/3/20.
//  Copyright © 2020 Sean McShane. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // storyboard outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceHelpLabel: UILabel!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeHelpLabel: UILabel!
    @IBOutlet weak var rotateRightImage: UIImageView!
    @IBOutlet weak var rotateLeftImage: UIImageView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var tapToPlaceLabel: UILabel!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var lengthHelpLabel: UILabel!
    @IBOutlet weak var allSidesSwitch: UISwitch!
    @IBOutlet weak var allSidesStack: UIStackView!
    @IBOutlet weak var colorPickerButtonView: UIView!
    @IBOutlet weak var colorPickerStack: UIStackView!
    @IBOutlet weak var purpleButton: UIView!
    @IBOutlet weak var indigoButton: UIView!
    @IBOutlet weak var tealButton: UIView!
    @IBOutlet weak var greenButton: UIView!
    @IBOutlet weak var yellowButton: UIView!
    @IBOutlet weak var orangeButton: UIView!
    @IBOutlet weak var pinkButton: UIView!
    @IBOutlet weak var redButton: UIView!
    @IBOutlet weak var whiteButton: UIView!
    @IBOutlet weak var blackButton: UIView!
    @IBOutlet weak var darkGrayButton: UIView!
    @IBOutlet weak var lightGrayButton: UIView!
    @IBOutlet weak var brownButton: UIView!
    @IBOutlet weak var trashImage: UIImageView!
    @IBOutlet weak var resetImage: UIImageView!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var cameraLockImage: UIImageView!
    @IBOutlet weak var lockHelpLabel: UILabel!
    
    @IBOutlet weak var screenshotImage: UIImageView!
    @IBOutlet weak var distanceSliderAspect: NSLayoutConstraint!
    @IBOutlet weak var lengthSliderAspect: NSLayoutConstraint!
    @IBOutlet weak var sizeSliderAspect: NSLayoutConstraint!
    @IBOutlet weak var resetImageLeading: NSLayoutConstraint!
    @IBOutlet weak var trashImageLeading: NSLayoutConstraint!
    
    var distanceSliderAspectLandscape: NSLayoutConstraint?
    
    // used to cancel image taps if finger moves far
    var addImageStartPoint = CGPoint()
    var addImageGestureFailed = false
    
    var infoImageStartPoint = CGPoint()
    var infoImageGestureFailed = false
    
    var rotateRightImageStartPoint = CGPoint()
    var rotateRightImageGestureFailed = false
    
    var rotateLeftImageStartPoint = CGPoint()
    var rotateLeftImageGestureFailed = false
    
    var lockImageStartPoint = CGPoint()
    var lockImageGestureFailed = false
    
    var cameraLockImageStartPoint = CGPoint()
    var cameraLockImageGestureFailed = false
    
    var trashImageStartPoint = CGPoint()
    var trashImageGestureFailed = false
    
    var resetImageStartPoint = CGPoint()
    var resetImageGestureFailed = false
    
    var colorPickerStartPoint = CGPoint()
    var colorPickerGestureFailed = false
    
    var colorStartPoint = CGPoint()
    var colorGestureFailed = false
    
    var screenshotImageStartPoint = CGPoint()
    var screenshotImageGestureFailed = false
    
    // misc vars
    
    // main obj used to interact with scene
    var sceneController = PhotoViewerScene()
    
    // flag to check if AR scene is ready to interact with
    var didInitializeScene: Bool = false
    
    // is the frame currently showing
    var showFrame: Bool = false
    
    // is the frame set in place
    var frameSet: Bool = false
    
    // controls how far away the frame appears from camera
    var zFrameOffset: Float = -0.9144
    
    // formats number to 2 sig figs
    let numFmt = NumberFormatter()
    
    // is the UI (initial view) hidden
    var isUIHidden = false
    
    // is the "Tap to place" help label blinking
    var blink = false
    
    // is the camera/frame lock help label blinking
    var lockHelpBlinking = false
    
    // used to generate vibration
    let impact = UIImpactFeedbackGenerator()
    
    // used to allow user ability to use pick image from camera/album
    var imagePicker = UIImagePickerController()
    
    // used to store the selected color view from color picker
    var selectedColorView: UIView?

    // app info used for info button
    let appTitle = "ARPhotoView"
    let appVersion = "Arnolfini 1.1.1"
    
    // meters to feet
    let mtof: Float = 3.28084
    
    // hide status bar (time, battery, signal)
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /// hide home bar
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // MARK: - UIViewController
    
    /// Called when view is loaded and ready to interact with
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // create a new scene
        if let scene = sceneController.scene {
            sceneView.scene = scene
            
            // shows xyz axis at origin
            //sceneView.debugOptions.insert(.showWorldOrigin)
        }
        
        // make numbers format to 2 sig figs
        numFmt.numberStyle = .decimal
        numFmt.maximumSignificantDigits = 2
        
        // rotate sliders vertically
        distanceSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        lengthSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        
        // rotate min slider images -- turns image black for some reason
        distanceSlider.minimumValueImage = distanceSlider.minimumValueImage?.rotate(radians: -CGFloat.pi/2)
        distanceSlider.minimumValueImage = distanceSlider.minimumValueImage?.withTintColor(.white)
        
        lengthSlider.minimumValueImage = lengthSlider.minimumValueImage?.rotate(radians: -CGFloat.pi/2)
        lengthSlider.minimumValueImage = lengthSlider.minimumValueImage?.withTintColor(.white)
        
        // create and assign various gesture recognizers
        setGestureRecognizers()
    }
    
    /// Called when view is about to appear.
    /// - Parameter animated: whether view's appearance will be animated
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        distanceSliderAspectLandscape = distanceSliderAspect.constraintWithMultiplier(0.8)
        
        // create a session configuration
        let config = ARWorldTrackingConfiguration()
        
        // enable plane detection
        //config.planeDetection = [.horizontal, .vertical]

        // check to see if people occlusion is supported
        if(ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth)) {
            // enable people occlusion
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        // run the view's session
        sceneView.session.run(config)
    }
    
    /// Called when view is about to disappear
    /// - Parameter animated: whether view's disappearance will be animated
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // pause the view's session
        sceneView.session.pause()
    }
    
    /// Phone has been rotated from landscape/portrait mode
    /// - Parameters:
    ///   - size:
    ///   - coordinator:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if(showFrame) {
            updateConstraints()
        }
     }
    
    // MARK: - init helper methods
    
    /// Create and assign the many gesture recognizers needed.
    func setGestureRecognizers() {
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
        screenTapRecognizer.name = "tap"
        self.view.addGestureRecognizer(screenTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didDoubleTapScreen))
        doubleTapRecognizer.name = "doubleTap"
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapRecognizer)
        
        let infoImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.infoImageLongPressed))
        infoImageLongPressRecognizer.name = "longPress"
        infoImageLongPressRecognizer.minimumPressDuration = 0
        infoImage.addGestureRecognizer(infoImageLongPressRecognizer)
        
        let screenshotImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.screenshotImageLongPressed))
        screenshotImageLongPressRecognizer.name = "longPress"
        screenshotImageLongPressRecognizer.minimumPressDuration = 0
        screenshotImage.addGestureRecognizer(screenshotImageLongPressRecognizer)
        
        let addImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addImageLongPressed))
        addImageLongPressRecognizer.name = "longPress"
        addImageLongPressRecognizer.minimumPressDuration = 0
        addImage.addGestureRecognizer(addImageLongPressRecognizer)
        
        let rotateRightImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.rotateRightImageLongPressed))
        rotateRightImageLongPressRecognizer.name = "longPress"
        rotateRightImageLongPressRecognizer.minimumPressDuration = 0
        rotateRightImage.addGestureRecognizer(rotateRightImageLongPressRecognizer)
        
        let rotateLeftImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.rotateLeftImageLongPressed))
        rotateLeftImageLongPressRecognizer.name = "longPress"
        rotateLeftImageLongPressRecognizer.minimumPressDuration = 0
        rotateLeftImage.addGestureRecognizer(rotateLeftImageLongPressRecognizer)
        
        let colorPickerViewLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.colorPickerLongPressed))
        colorPickerViewLongPressRecognizer.name = "longPress"
        colorPickerViewLongPressRecognizer.minimumPressDuration = 0
        colorPickerButtonView.addGestureRecognizer(colorPickerViewLongPressRecognizer)
        
        let colorPickerLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.colorLongPressed))
        colorPickerLongPressRecognizer.name = "longPress"
        colorPickerLongPressRecognizer.minimumPressDuration = 0
        colorPickerStack.addGestureRecognizer(colorPickerLongPressRecognizer)
        
        let lockImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.lockImageLongPressed))
        lockImageLongPressRecognizer.name = "longPress"
        lockImageLongPressRecognizer.minimumPressDuration = 0
        lockImage.addGestureRecognizer(lockImageLongPressRecognizer)
        
        let cameraLockImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.cameraLockImageLongPressed))
        cameraLockImageLongPressRecognizer.name = "longPress"
        cameraLockImageLongPressRecognizer.minimumPressDuration = 0
        cameraLockImage.addGestureRecognizer(cameraLockImageLongPressRecognizer)
        
        let trashImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.trashImageLongPressed))
        trashImageLongPressRecognizer.name = "longPress"
        trashImageLongPressRecognizer.minimumPressDuration = 0
        trashImage.addGestureRecognizer(trashImageLongPressRecognizer)
        
        let resetImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.resetImageLongPressed))
        resetImageLongPressRecognizer.name = "longPress"
        resetImageLongPressRecognizer.minimumPressDuration = 0
        resetImage.addGestureRecognizer(resetImageLongPressRecognizer)
    }
    
    // MARK: - Delegate methods
    
    // MARK: - ARSCNViewDelegate
    
    /// Called every frame. Updates frame position if not set.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // check to see if the scene is ready to interact with
        if(!didInitializeScene) {
            if(sceneView.session.currentFrame?.camera != nil) {
                didInitializeScene = true
            }
        }
        
        // update the position of the frame every frame if frame is in edit UI
        if(didInitializeScene){
            if(showFrame && !frameSet){
                if let camera = sceneView.session.currentFrame?.camera {
                    
                    // calulate where the frame should be based off camera and zFrameOffset
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = zFrameOffset

                    let transform = camera.transform * translation
                    let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

                    // update position of the frame
                    sceneController.updateFramePosition(position: position, sceneView.pointOfView!)
                    
                    // calculate distance between frame and camera if frame is locked while editing
                    if(sceneController.isFrameLocked()) {
                        let node1Pos = SCNVector3ToGLKVector3(SCNVector3(camera.transform.columns.3.x, camera.transform.columns.3.y, camera.transform.columns.3.z))
                        let node2Pos = SCNVector3ToGLKVector3(sceneController.getFramePosition())

                        let distance = GLKVector3Distance(node1Pos, node2Pos)
                        
                        // run as main thread; can't update UI elements as background thread
                        DispatchQueue.main.async {
                            self.zFrameOffset = -1.0 * distance
                            self.distanceSlider.value = distance
                            self.updateDistanceLabel(distance)
                        }
                    }
                } 
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    /// Callback called when user selects an image from either camera or album.
    /// - Parameters:
    ///   - picker: the view controller object the image was picked from
    ///   - info: contains info about the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // close the photo selection view
        self.dismiss(animated: true, completion: { () -> Void in })
        
        // grab the selected image
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            sceneController.setImage(image.fixOrientation())
            sceneController.addFrame()
            setDefaults()
            prepareForFrame()
        }
    }
    
    // MARK: - Gesture recognizer methods
    
    /// Place frame if not set or toggle main UI
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if(didInitializeScene) {
            if(isSafeToPlace()) {
                if(showFrame && !frameSet) {
                    if let camera = sceneView.session.currentFrame?.camera {
                        var translation = matrix_identity_float4x4
                        translation.columns.3.z = zFrameOffset
                        
                        let transform = camera.transform * translation
                        let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                        sceneController.updateFramePosition(position: position, sceneView.pointOfView!)
                        
                        impact.impactOccurred()
                        prepareForSet()
                    }
                }
                else {
                    toggleUI()
                }
            }
        }
    }

    /// Pick up placer node if placed and start to follow user's camera again.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func didDoubleTapScreen(recognizer: UITapGestureRecognizer) {
        if(didInitializeScene && frameSet) {
            impact.impactOccurred()

            prepareForFrame()
        }
    }
    
    /// Displays the image selector view.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func addImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &addImageGestureFailed, addImage, &addImageStartPoint, 175.0, true)) {
            showImageSelector()
        }
    }
    
    /// Displays info popup.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func infoImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &infoImageGestureFailed, infoImage, &infoImageStartPoint, 175.0, true)) {
            displayInfo()
        }
    }
    
    /// Takes a screenshot.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func screenshotImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &screenshotImageGestureFailed, screenshotImage, &screenshotImageStartPoint, 175.0, true)) {
            takeScreenshot()
         }
    }
    
    /// Rotates frame right.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func rotateRightImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &rotateRightImageGestureFailed, rotateRightImage, &rotateRightImageStartPoint, 175.0, true)) {
            sceneController.rotateFrame(-Float.pi / 2)
        }
    }

    /// Rotates frame left.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func rotateLeftImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &rotateLeftImageGestureFailed, rotateLeftImage, &rotateLeftImageStartPoint, 175.0, true)) {
            sceneController.rotateFrame(Float.pi / 2)
        }
    }

    /// Controls whether the frame is locked in position or follows the camera.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func lockImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &lockImageGestureFailed, lockImage, &lockImageStartPoint, 175.0, true)) {
            if(!lockHelpBlinking) {
                toggleFrameLock()
            }
        }
    }
    
    /// Locks the frame's orientation to camera.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func cameraLockImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &cameraLockImageGestureFailed, cameraLockImage, &cameraLockImageStartPoint, 175.0, true)) {
            if(!lockHelpBlinking) {
                toggleCameraLock()
            }
        }
    }
    
    /// Removes the frame and hides editing UI.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func trashImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &trashImageGestureFailed, trashImage, &trashImageStartPoint, 175.0, true)) {
            // need to do twice so correct help labels are hidden
            frameSet = false
            prepareForSet()
            frameSet = false
            sceneController.removeFrame()
        }
    }
    
    /// Resets frame back to default settings.
    /// - Parameter recognizer: gesture recognizer triggered
    @objc func resetImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &resetImageGestureFailed, resetImage, &resetImageStartPoint, 175.0, true)) {
            if(!lockHelpBlinking) {
                startLockHelpBlink("Reset to default")
                setDefaults()
            }
         }
    }
    
    /// Called when color picked tapped. Either display or hide the color picker.
    /// - Parameter sender: color picker gesture recognizer
    @objc func colorPickerLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &colorPickerGestureFailed, colorPickerButtonView, &colorPickerStartPoint, 175.0, false)) {
            if(colorPickerStack.isHidden) {
                colorPickerStack.isHidden = false
            }
            else {
                colorPickerStack.isHidden = true
            }
        }
    }
    
    /// Called when a color was tapped on the color picker. Sets frame's default material to color.
    /// - Parameter sender: color  gesture recognizer
    @objc func colorLongPressed(_ sender: UILongPressGestureRecognizer) {
        // check to see what color view was pressed
        let view = sender.view
        let loc = sender.location(in: view)
        if let colorView = view?.hitTest(loc, with: nil) {
            // set the initial selected color view. needed in case finger drags across multiple colors.
            if(selectedColorView == nil) {
                selectedColorView = colorView
            }
        }
        
        // reset failure flag on new gesture
        if(sender.state == .began) {
            colorGestureFailed = false
        }
        
        if(!colorGestureFailed && checkLongPress(sender, &colorGestureFailed, selectedColorView!, &colorStartPoint, 175.0, false)) {
            setFrameColor(selectedColorView!.backgroundColor!)
            
            selectedColorView = nil
        }
        
        // reset selected color once gesture has failed
        if(colorGestureFailed) {
            selectedColorView = nil
        }
    }
    
    // MARK: - Storyboard actions
    
    /// Called when size slider value has changed.
    /// - Parameter sender: size slider
    @IBAction func sizeValueChanged(_ sender: UISlider) {
        impact.impactOccurred(intensity: 0.3)
        
        sceneController.updateFrameSize(sizeSlider.value)

        updateSizeLabel()
    }
    
    /// Called when length slider value has changed. Updates frame's length.
    /// - Parameter sender: length slider
    @IBAction func lengthValueChanged(_ sender: UISlider) {
        impact.impactOccurred(intensity: 0.3)
        
        sceneController.updateFrameLength(CGFloat(lengthSlider.value))

        updateSizeLabel()
    }
    
    /// Called when distanceSlider value has changed. Updates distance of frame from camera.
    /// - Parameter sender: distance slider
    @IBAction func distanceValueChanged(_ sender: UISlider) {
        impact.impactOccurred(intensity: 0.3)
        zFrameOffset = -1.0 * distanceSlider.value
        updateDistanceLabel(distanceSlider.value)
    }
    
    /**
     Called when the switch for show image on all sides is tapped. Updates frame's materials.
     */
    @IBAction func allSidesSwitchValueChanged(_ sender: UISwitch) {
        sceneController.toggleAllSides(allSidesSwitch.isOn)
        
        if(allSidesSwitch.isOn) {
            colorPickerButtonView.isHidden = true
            colorPickerStack.isHidden = true
        }
        else {
            colorPickerButtonView.isHidden = false
            colorPickerStack.isHidden = true
        }
    }
    
    // MARK: - prepare for frame state change functions
    
    /**
     Set flags before frame gets set in place
     */
    func prepareForSet() {
        frameSet = true
        showFrame = false
        distanceLabel.isHidden = true
        distanceSlider.isHidden = true
        addImage.isHidden = false
        sizeSlider.isHidden = true
        lengthSlider.isHidden = true
        sizeLabel.isHidden = true
        rotateRightImage.isHidden = true
        rotateLeftImage.isHidden = true
        lockImage.isHidden = true
        tapToPlaceLabel.isHidden = true
        sizeHelpLabel.isHidden = true
        distanceHelpLabel.isHidden = true
        lengthHelpLabel.isHidden = true
        allSidesStack.isHidden = true
        colorPickerButtonView.isHidden = true
        colorPickerStack.isHidden = true
        trashImage.isHidden = true
        resetImage.isHidden = true
        infoImage.isHidden = false
        screenshotImage.isHidden = false
        isUIHidden = false
        cameraLockImage.isHidden = true
    }
    /**
     Set flags before frame begins to follow camera after double tap
     */
    func prepareForFrame() {
        frameSet = false
        showFrame =  true
        distanceLabel.isHidden = false
        distanceSlider.isHidden = false
        addImage.isHidden = true
        sizeSlider.isHidden = false
        lengthSlider.isHidden = false
        sizeLabel.isHidden = false
        rotateRightImage.isHidden = false
        rotateLeftImage.isHidden = false
        lockImage.isHidden = false
        tapToPlaceLabel.isHidden = false
        sizeHelpLabel.isHidden = false
        distanceHelpLabel.isHidden = false
        lengthHelpLabel.isHidden = false
        allSidesStack.isHidden = false
        if(!allSidesSwitch.isOn) {
            colorPickerButtonView.isHidden = false
        }
        colorPickerStack.isHidden = true
        trashImage.isHidden = false
        resetImage.isHidden = false
        infoImage.isHidden = true
        screenshotImage.isHidden = true
        isUIHidden = true
        cameraLockImage.isHidden = false
        
        updateConstraints()
        startBlinkTimer()
    }
    
    // MARK: - misc methods
    
    /// Helper method to handle the different states of long press gestures. Highlighting / vibration for images taps done here.
    /// - Parameters:
    ///   - sender: gesture recognizer triggered
    ///   - failedFlag: controls if gesture has move too far and failed
    ///   - view: view that was selected
    ///   - startPoint: starting point of gesture
    ///   - allowableMovement: the amount of points that finger can move before gesture fails
    ///   - tint: change the tint (UIImage) or alpha (any other UIView)
    /// - Returns: True if gesture has ended succesfully
    func checkLongPress(_ sender: UILongPressGestureRecognizer, _ failedFlag: inout Bool, _ view: UIView, _ startPoint: inout CGPoint, _ allowableMovement: Float, _ tint: Bool) -> Bool {
        
        // record starting position and highlight
        if(sender.state == .began) {
            startPoint = sender.location(in: self.view)
            
            if(tint) {
                view.tintColor = .lightGray
            }
            
            else {
                view.alpha = 0.5
            }

            impact.impactOccurred()
        }
        
        // check to see if finger has moved too far since start
        else if(sender.state == .changed) {
            if(failedFlag) {
                return false
            }
            
            // check to see if finger has moved too far from origin
            let currentPoint = sender.location(in: self.view)
            let distance = hypotf(Float(currentPoint.x - startPoint.x), Float(currentPoint.y - startPoint.y))
            
            // mark the gesture as failed if finger has moved too far
            if (distance > allowableMovement) {
                if(tint) {
                    view.tintColor = .white
                }
                
                else {
                    view.alpha = 1.0
                }
                
                failedFlag = true
            }
        }
        
        // unhighlight if successful end
        else if(sender.state == .ended) {
            if(failedFlag) {
                failedFlag = false
            }
            else {
                if(tint) {
                    view.tintColor = .white
                }
                
                else {
                    view.alpha = 1.0
                }
                
                return true
            }
        }
        
        return false
    }
    
    /// Checks to see if any sliders are being used.
    /// - Returns: True if no sliders are being used
    func isSafeToPlace() -> Bool {
        return  distanceSlider.state == .normal &&
                sizeSlider.state == .normal &&
                lengthSlider.state == .normal
    }
    
    /// Take screenshot of AR scene and prompt for save/delete
    func takeScreenshot() {
        let image = sceneView.snapshot()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let screenshotView = (storyboard.instantiateViewController(withIdentifier: "ScreenshotView") as! ScreenshotViewController)
        
        self.present(screenshotView, animated: true)
        
        screenshotView.setScreenshotImage(image)
    }
    
    // MARK: - misc UI update methods
    
    /// Set editor UI to default settings.
    func setDefaults() {
        if(!allSidesSwitch.isOn) {
            allSidesSwitch.setOn(true, animated: false)
            colorPickerButtonView.isHidden = true
        }
        
        setFrameColor(.brown)
        
        if(sceneController.isFrameLocked()) {
            toggleFrameLock()
        }
        
        if(!sceneController.isCameraLocked()) {
            toggleCameraLock()
        }
        
        sceneController.setFrameNoRotation()
        
        sceneController.setDefaultEdit()
        setSliderValues()
    }
    
    /// Toggles the initinal UI so screen can be empty.
    func toggleUI() {
        isUIHidden = !isUIHidden
        
        addImage.isHidden = isUIHidden
        infoImage.isHidden = isUIHidden
        screenshotImage.isHidden = isUIHidden
    }
    
    /// Displays the image selection menu.
    func showImageSelector() {
        let alert: UIAlertController?
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            alert = UIAlertController(title: "Image Selection", message: "Take or select an image to display. This app does not store or share your images.", preferredStyle: .alert)
        }
        else {
            alert = UIAlertController(title: "Image Selection", message: "Take or select an image to display. This app does not store or share your images.", preferredStyle: .actionSheet)
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
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))

        
        alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
        self.present(alert!, animated: true)
    }
    
    /// Update UI layout constraints after screen was rotated
    func updateConstraints() {
        if(UIDevice.current.orientation.isLandscape) {
            let newDistanceConstraint = distanceSliderAspect.constraintWithMultiplier(0.75)
            let newLengthConstraint = lengthSliderAspect.constraintWithMultiplier(0.75)
            let newSizeConstraint = sizeSliderAspect.constraintWithMultiplier(0.95)
            let newResetConstraint = resetImageLeading.constraintWithValue(40)
            let newTrashConstraint = trashImageLeading.constraintWithValue(40)
            
            view.removeConstraint(distanceSliderAspect)
            view.removeConstraint(lengthSliderAspect)
            view.removeConstraint(sizeSliderAspect)
            view.removeConstraint(resetImageLeading)
            view.removeConstraint(trashImageLeading)
            
            view.addConstraint(newDistanceConstraint)
            view.addConstraint(newLengthConstraint)
            view.addConstraint(newSizeConstraint)
            view.addConstraint(newResetConstraint)
            view.addConstraint(newTrashConstraint)
            
            view.layoutIfNeeded()
            
            distanceSliderAspect = newDistanceConstraint
            lengthSliderAspect = newLengthConstraint
            sizeSliderAspect = newSizeConstraint
            resetImageLeading = newResetConstraint
            trashImageLeading = newTrashConstraint
        }
        
        else {
            let newDistanceConstraint = distanceSliderAspect.constraintWithMultiplier(0.5)
            let newLengthConstraint = lengthSliderAspect.constraintWithMultiplier(0.5)
            let newSizeConstraint = sizeSliderAspect.constraintWithMultiplier(0.35)
            let newResetConstraint = resetImageLeading.constraintWithValue(20)
            let newTrashConstraint = trashImageLeading.constraintWithValue(20)
             
            view.removeConstraint(distanceSliderAspect)
            view.removeConstraint(lengthSliderAspect)
            view.removeConstraint(sizeSliderAspect)
            view.removeConstraint(resetImageLeading)
            view.removeConstraint(trashImageLeading)
             
            view.addConstraint(newDistanceConstraint)
            view.addConstraint(newLengthConstraint)
            view.addConstraint(newSizeConstraint)
            view.addConstraint(newResetConstraint)
            view.addConstraint(newTrashConstraint)
             
            view.layoutIfNeeded()
             
            distanceSliderAspect = newDistanceConstraint
            lengthSliderAspect = newLengthConstraint
            sizeSliderAspect = newSizeConstraint
            resetImageLeading = newResetConstraint
            trashImageLeading = newTrashConstraint
        }
    }
    
    /// Toggles whether the frame's position is locked or not.
    func toggleFrameLock() {
        // toggle position lock
        let frameLocked = sceneController.toggleFrameLocked()
        
        // update UI
        if(frameLocked) {
            lockImage.image = UIImage(systemName: "lock.fill")
            distanceSlider.isHidden = true
            distanceHelpLabel.isHidden = true
            startLockHelpBlink("Image position locked")
        }
        else {
            lockImage.image = UIImage(systemName: "lock.open.fill")
            distanceSlider.isHidden = false
            distanceHelpLabel.isHidden = false
            startLockHelpBlink("Image position unlocked")
        }
    }
    
    /// Toggles whether the frame's orientation is locked to camera or not.
    func toggleCameraLock() {
        let cameraLocked = sceneController.toggleCameraLocked()
        
        if(cameraLocked) {
            cameraLockImage.image = UIImage(systemName: "camera.viewfinder")
            startLockHelpBlink("Image orientation locked to camera")
        }
        else {
            cameraLockImage.image = UIImage(systemName: "nosign")
            startLockHelpBlink("Image orientation not locked to camera")
        }
    }
    
    /// Set the sliders to correct positions.
    func setSliderValues() {
        let dims = sceneController.getFrameDimensions()
        
        sizeSlider.value = Float(dims[0])
        
        zFrameOffset = Float(-2.75 * dims[0])
        distanceSlider.value = -zFrameOffset
        
        lengthSlider.value = 0.05
        
        updateSizeLabel()
        updateDistanceLabel(-zFrameOffset)
    }
    
    /**
     Helper function to facilitate the changing of frame color from color picker.
     */
    func setFrameColor(_ color: UIColor) {
        sceneController.setDefaultMaterial(color, allSidesSwitch.isOn)

        colorPickerButtonView.backgroundColor = color

        colorPickerStack.isHidden = true
    }
    
    /// Display info popup with copyright and version info.
    func displayInfo() {
        let infoString = """
        \n--- Tips ---\n
        Functions best in well-lit areas
        \n
        While on this screen you can:
        1. Tap the plus button to take or select an image to view in augmented reality
        2. Tap the screen once to toggle the UI
        3. Tap the screen twice to pick up image (if image has been placed)
        4. Tap the camera button to take a screenshot of the augmented reality view
        \n
        After selecting an image:
        1. Use the sliders and buttons on the screen to modify the width, height, length, and rotation of the image
        2. Tap the screen to place the image in the augmented reality world which you view through your iPhone's camera
        \n
        \(appVersion)
        © 2020 Sean McShane
        smcshane.com/arphotoview
        """
        
        let alert = UIAlertController(title: appTitle, message: infoString, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "smcshane.com/arphotoview", style: .default, handler: {
            action in
            
            UIApplication.shared.open(URL(string: "https://www.smcshane.com/arphotoview")!) { success in
                
            }
        }))

        
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    /// Convert distance slider value to feet for label
    /// - Parameter value: slider value
    func updateDistanceLabel(_ value: Float) {
        distanceLabel.text! = "\(numFmt.string(from: NSNumber(value: value * mtof))!)ft away"
    }
    
    /// Convert frame's dimensions to feet for label.
    func updateSizeLabel() {
        let dims = sceneController.getFrameDimensions()
        
        sizeLabel.text! = "\(numFmt.string(from: NSNumber(value: Float(dims[0]) * mtof))!)ft w X \(numFmt.string(from: NSNumber(value: Float(dims[1]) * mtof))!)ft h X \(numFmt.string(from: NSNumber(value: Float(dims[2]) * mtof))!)ft l"
    }
    
    // MARK: - blinking help label methods
    
    /// Starts the timer for blinking the "Tap to place" help label.
    func startBlinkTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.25, repeats: true) { timer in
            if(self.showFrame) {
                self.blinkLabel()
            }
            
            else {
                timer.invalidate()
            }
        }
    }
    
    /// Animates the blinking of the "Tap to place"  help label.
    func blinkLabel() {
        var newAlpha: CGFloat = 0.0
        
        if(tapToPlaceLabel.alpha == 0.0) {
            newAlpha = 1.0
        }
        
        else {
            newAlpha = 0.0
        }
        
        // animate oldAlpha -> newAlpha
        UIView.animate(withDuration: 1.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.tapToPlaceLabel.alpha = newAlpha
        }, completion: nil)
    }
    
    /// Starts the blinking the camera/frame lock help label.
    /// - Parameter helpText: String to be displayed on help label
    func startLockHelpBlink(_ helpText: String) {
        if(!lockHelpBlinking) {
            lockHelpLabel.text = helpText
            lockHelpLabel.alpha = 1.0
            lockHelpLabel.isHidden = false
            lockHelpBlinking = true
        
            self.blinkLockHelpLabel()
        }
    }
    
    /// Animates the blinking of camera/frame lock help label.
    func blinkLockHelpLabel() {
        let newAlpha: CGFloat = 0.0
        
        UIView.animate(withDuration: 1.25, delay: 0.5, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.lockHelpLabel.alpha = newAlpha
        }, completion: { completed in
            self.lockHelpLabel.isHidden = true
            self.lockHelpBlinking = false
        })
    }
}
