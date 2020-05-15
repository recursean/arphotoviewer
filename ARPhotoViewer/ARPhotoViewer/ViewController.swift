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
    
    var sceneController = PhotoViewerScene()
    var didInitializeScene: Bool = false
    var showFrame: Bool = false
    var isFrameSet: Bool = false
    let impact = UIImpactFeedbackGenerator()
    var imagePicker = UIImagePickerController()
    var zFrameOffset: Float = -0.9144
    let numFmt = NumberFormatter()
    var isUIHidden = false
    var blink = false
    var lockHelpBlinking = false
    
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

    let appTitle = "AR Photo Viewer"
    let appVersion = "Arnolfini 1.0"
    
    // meters to feet
    let mtof: Float = 3.28084
    
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
        
        numFmt.numberStyle = .decimal
        numFmt.maximumSignificantDigits = 2
        
        // rotate sliders
        distanceSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        lengthSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        
        // rotate min slider image -- turns image black for some reason
        distanceSlider.minimumValueImage = distanceSlider.minimumValueImage?.rotate(radians: -CGFloat.pi/2)
        distanceSlider.minimumValueImage = distanceSlider.minimumValueImage?.withTintColor(.white)
        
        lengthSlider.minimumValueImage = lengthSlider.minimumValueImage?.rotate(radians: -CGFloat.pi/2)
        lengthSlider.minimumValueImage = lengthSlider.minimumValueImage?.withTintColor(.white)
        
        updateDistanceLabel(distanceSlider.value)
        zFrameOffset = -1.0 * distanceSlider.value
        
        updateSizeLabel()
        
        setGestureRecognizers()
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

    /**
     Set up the many gesture recognizers needed
     */
    func setGestureRecognizers() {
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
        screenTapRecognizer.name = "tap"
        self.view.addGestureRecognizer(screenTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didDoubleTapScreen))
        doubleTapRecognizer.name = "doubleTap"
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapRecognizer)
        
        let infoImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.infoImageLongPressed))
        infoImageLongPressRecognizer.name = "tap"
        infoImageLongPressRecognizer.minimumPressDuration = 0
        infoImageLongPressRecognizer.allowableMovement = 15.0
        infoImage.addGestureRecognizer(infoImageLongPressRecognizer)
        
        let addImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addImageLongPressed))
        addImageLongPressRecognizer.name = "longPress"
        addImageLongPressRecognizer.minimumPressDuration = 0
        addImageLongPressRecognizer.allowableMovement = 1.0
        addImage.addGestureRecognizer(addImageLongPressRecognizer)
        
        let rotateRightImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.rotateRightImageLongPressed))
        rotateRightImageLongPressRecognizer.name = "tap"
        rotateRightImageLongPressRecognizer.minimumPressDuration = 0
        rotateRightImage.addGestureRecognizer(rotateRightImageLongPressRecognizer)
        
        let rotateLeftImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.rotateLeftImageLongPressed))
        rotateLeftImageLongPressRecognizer.name = "tap"
        rotateLeftImageLongPressRecognizer.minimumPressDuration = 0
        rotateLeftImage.addGestureRecognizer(rotateLeftImageLongPressRecognizer)
        
        let colorPickerViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.toggleColorPicker))
        colorPickerViewTapRecognizer.name = "tap"
        colorPickerButtonView.addGestureRecognizer(colorPickerViewTapRecognizer)
        
        let colorPickerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectColor))
        colorPickerTapRecognizer.name = "tap"
        colorPickerStack.addGestureRecognizer(colorPickerTapRecognizer)
        
        let lockImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.lockImageLongPressed))
        lockImageLongPressRecognizer.name = "tap"
        lockImageLongPressRecognizer.minimumPressDuration = 0
        lockImage.addGestureRecognizer(lockImageLongPressRecognizer)
        
        let cameraLockImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.cameraLockImageLongPressed))
        cameraLockImageLongPressRecognizer.name = "tap"
        cameraLockImageLongPressRecognizer.minimumPressDuration = 0
        cameraLockImage.addGestureRecognizer(cameraLockImageLongPressRecognizer)
        
        let trashImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.trashImageLongPressed))
        trashImageLongPressRecognizer.name = "tap"
        trashImageLongPressRecognizer.minimumPressDuration = 0
        trashImage.addGestureRecognizer(trashImageLongPressRecognizer)
        
        let resetImageLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.resetImageLongPressed))
        resetImageLongPressRecognizer.name = "tap"
        resetImageLongPressRecognizer.minimumPressDuration = 0
        resetImage.addGestureRecognizer(resetImageLongPressRecognizer)
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
                    translation.columns.3.z = zFrameOffset

                    let transform = camera.transform * translation
                    let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

                    sceneController.updateFramePosition(position: position, sceneView.pointOfView!)
                    
                    // calculate distance between frame and camera if frame is locked while editing
                    if(sceneController.isFrameLocked()) {
                        let node1Pos = SCNVector3ToGLKVector3(SCNVector3(camera.transform.columns.3.x, camera.transform.columns.3.y, camera.transform.columns.3.z))
                        let node2Pos = SCNVector3ToGLKVector3(sceneController.getFramePosition())

                        let distance = GLKVector3Distance(node1Pos, node2Pos)
                        
                        // run as main thread
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
    
    // MARK: - Gesture recognizers
    
    /**
     Place placer node as long as it hasn't been set already
     */
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if(didInitializeScene) {
            if(isSafeToPlace()) {
                if(showFrame && !isFrameSet) {
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

    /**
     Pick up placer node if placed and start to follow user's camera again
     */
    @objc func didDoubleTapScreen(recognizer: UITapGestureRecognizer) {
        if(didInitializeScene && isFrameSet) {
            impact.impactOccurred()
            prepareForFrame()
        }
    }
    
    /**
     Called when add image is long pressed.
     */
    @objc func addImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &addImageGestureFailed, &addImage, &addImageStartPoint, 175.0)) {
            showImageSelector()
        }
    }
    
    /**
     Displays info popup.
     */
    @objc func infoImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &infoImageGestureFailed, &infoImage, &infoImageStartPoint, 175.0)) {
            displayInfo()
        }
    }
    
    /**
     Rotates frame right.
     */
    @objc func rotateRightImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &rotateRightImageGestureFailed, &rotateRightImage, &rotateRightImageStartPoint, 175.0)) {
            sceneController.rotateFrame(-Float.pi / 2)
        }
    }
    
    /**
     Rotates frame left.
     */
    @objc func rotateLeftImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &rotateLeftImageGestureFailed, &rotateLeftImage, &rotateLeftImageStartPoint, 175.0)) {
            sceneController.rotateFrame(Float.pi / 2)
        }
    }
    
    /**
     Sets frame to be rotated every frame
     */
    @objc func lockImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &lockImageGestureFailed, &lockImage, &lockImageStartPoint, 175.0)) {
            if(!lockHelpBlinking) {
                toggleFrameLock()
            }
        }
    }
    
    /**
     Locks the frame orientation to camera.
     */
    @objc func cameraLockImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &cameraLockImageGestureFailed, &cameraLockImage, &cameraLockImageStartPoint, 175.0)) {
            if(!lockHelpBlinking) {
                toggleCameraLock()
            }
        }
    }
    
    /**
     Hide the editing screen.
     */
    @objc func trashImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &trashImageGestureFailed, &trashImage, &trashImageStartPoint, 175.0)) {
            prepareForSet()
            isFrameSet = false
            sceneController.removeFrame()
        }
    }
    
    /**
     Reset back to default edit settings.
     */
    @objc func resetImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(checkLongPress(sender, &resetImageGestureFailed, &resetImage, &resetImageStartPoint, 175.0)) {
            setDefaults()
         }
    }
    
    /**
     Helper function to handle the different states of long press gestures. Returns true if gesture ended successfully.
     */
    func checkLongPress(_ sender: UILongPressGestureRecognizer, _ failedFlag: inout Bool, _ image: inout UIImageView, _ startPoint: inout CGPoint, _ allowableMovement: Float) -> Bool {
        // record starting position and highlight
        if(sender.state == .began) {
            startPoint = sender.location(in: self.view)
            image.tintColor = .lightGray
            impact.impactOccurred()
        }
        
        // check to see if finger has moved too far since start
        else if(sender.state == .changed) {
            if(failedFlag) {
                return false
            }
            
            let currentPoint = sender.location(in: self.view)
            
            let distance = hypotf(Float(currentPoint.x - startPoint.x), Float(currentPoint.y - startPoint.y))
            
            if (distance > allowableMovement) {
                image.tintColor = .white
                failedFlag = true
            }
        }
        
        // unhighlight if succesfull end
        else if(sender.state == .ended) {
            if(failedFlag) {
                failedFlag = false
            }
            else {
                image.tintColor = .white
                
                return true
            }
        }
        
        return false
    }
    
    /**
     Set flags before frame gets set in place
     */
    func prepareForSet() {
        isFrameSet = true
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
        isUIHidden = false
        cameraLockImage.isHidden = true
        
    }
    /**
     Set flags before frame begins to follow camera after double tap
     */
    func prepareForFrame() {
        isFrameSet = false
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
        isUIHidden = true
        cameraLockImage.isHidden = false
        startBlinkTimer()
    }
    
    func toggleFrameLock() {
        let frameLocked = sceneController.toggleFrameLocked()
        
        if(frameLocked) {
            lockImage.image = UIImage(systemName: "lock.fill")
            distanceSlider.isHidden = true
            distanceHelpLabel.isHidden = true
            startLockHelpBlinkTimer("Frame position locked")
        }
        else {
            lockImage.image = UIImage(systemName: "lock.open.fill")
            distanceSlider.isHidden = false
            distanceHelpLabel.isHidden = false
            startLockHelpBlinkTimer("Frame position unlocked")
        }
    }
    
    func toggleCameraLock() {
        let cameraLocked = sceneController.toggleCameraLocked()
        
        if(cameraLocked) {
            cameraLockImage.image = UIImage(systemName: "camera.circle.fill")
            startLockHelpBlinkTimer("Frame locked to camera")
        }
        else {
            cameraLockImage.image = UIImage(systemName: "nosign")
            startLockHelpBlinkTimer("Frame not locked to camera")
        }
    }
    
    /**
     Checks to see if any sliders are being used.
     */
    func isSafeToPlace() -> Bool {
        return  distanceSlider.state == .normal &&
                sizeSlider.state == .normal &&
                lengthSlider.state == .normal
    }
    
    /**
     Toggles the UI for viewing pleasure.
     */
    func toggleUI() {
        isUIHidden = !isUIHidden
        
        addImage.isHidden = isUIHidden
        infoImage.isHidden = isUIHidden
    }
    
    /**
     Called when image has been selected
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            sceneController.setImage(image.fixOrientation())
            sceneController.addFrame()
            setDefaults()
            prepareForFrame()
        }
    }
    
    /**
     Display the image selection menu.
     */
    func showImageSelector() {
        let alert: UIAlertController?
        
        //impact.impactOccurred()
        
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
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))

        
        alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
        self.present(alert!, animated: true)
    }
    
    /**
     Set the sliders to correct positions
     */
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
     Starts to timer for blinking the help label.
     */
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
    
    /**
     Animates the blinking of help label.
     */
    func blinkLabel() {
        var newAlpha: CGFloat = 0.0
        
        if(tapToPlaceLabel.alpha == 0.0) {
            newAlpha = 1.0
        }
        
        else {
            newAlpha = 0.0
        }
        
        UIView.animate(withDuration: 1.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.tapToPlaceLabel.alpha = newAlpha
        }, completion: nil)
    }
    
    /**
     Starts to timer for blinking the camera/frame lock help label.
     */
    func startLockHelpBlinkTimer(_ helpText: String) {
        if(!lockHelpBlinking) {
            lockHelpLabel.text = helpText
            lockHelpLabel.alpha = 1.0
            lockHelpLabel.isHidden = false
            lockHelpBlinking = true
        
            self.blinkLockHelpLabel()
        }
    }
    
    /**
     Animates the blinking of camera/frame lock help label.
     */
    func blinkLockHelpLabel() {
        let newAlpha: CGFloat = 0.0
        
        UIView.animate(withDuration: 1.25, delay: 0.5, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.lockHelpLabel.alpha = newAlpha
        }, completion: { completed in
            self.lockHelpLabel.isHidden = true
            self.lockHelpBlinking = false
        })
    }
    
    /**
     Display info popup
     */
    func displayInfo() {
        let alert = UIAlertController(title: appTitle, message: "\(appVersion)\nCopyright © Sean McShane", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    /**
     Called when distanceSlider value has changed.
     */
    @IBAction func distanceValueChanged(_ sender: UISlider) {
        impact.impactOccurred(intensity: 0.3)
        zFrameOffset = -1.0 * distanceSlider.value
        updateDistanceLabel(distanceSlider.value)
    }
    
    /**
     Convert distanceSlider value to feet for label
     */
    func updateDistanceLabel(_ value: Float) {
        distanceLabel.text! = "\(numFmt.string(from: NSNumber(value: value * mtof))!)ft away"
    }
    
    /**
     Called when sizeSlider value has changed.
     */
    @IBAction func sizeValueChanged(_ sender: UISlider) {
        impact.impactOccurred(intensity: 0.3)
        
        sceneController.updateFrameSize(sizeSlider.value)

        updateSizeLabel()
    }
    
    /**
     Called when lengthSlider value has changed.
     */
    @IBAction func lengthValueChanged(_ sender: UISlider) {
        impact.impactOccurred(intensity: 0.3)
        
        sceneController.updateFrameLength(CGFloat(lengthSlider.value))

        updateSizeLabel()
    }
    
    /**
     Convert sizeSlider value to feet for label
     */
    func updateSizeLabel() {
        let dims = sceneController.getFrameDimensions()
        
        sizeLabel.text! = "\(numFmt.string(from: NSNumber(value: Float(dims[0]) * mtof))!)ft w X \(numFmt.string(from: NSNumber(value: Float(dims[1]) * mtof))!)ft h X \(numFmt.string(from: NSNumber(value: Float(dims[2]) * mtof))!)ft l"
    }
    
    /**
     Called when the switch for show image on all sides is tapped.
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
    
    /**
     Either display or hide the color picker.
     */
    @objc func toggleColorPicker() {
        impact.impactOccurred()
        
        if(colorPickerStack.isHidden) {
            colorPickerStack.isHidden = false
        }
        else {
            colorPickerStack.isHidden = true
        }
    }
    
    /**
     A color was tapped on the color picker.
     */
    @objc func selectColor(_ recognizer: UIGestureRecognizer) {
        impact.impactOccurred()
        
        let view = recognizer.view
        let loc = recognizer.location(in: view)
        let subview = view?.hitTest(loc, with: nil)

        setFrameColor(subview!.backgroundColor!)
    }
    
    /**
     Helper function to facilitate the changing of frame color from color picker.
     */
    func setFrameColor(_ color: UIColor) {
        sceneController.setDefaultMaterial(color, allSidesSwitch.isOn)

        colorPickerButtonView.backgroundColor = color

        colorPickerStack.isHidden = true
    }
    
    /**
     Set editor to default settings.
     */
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
}
