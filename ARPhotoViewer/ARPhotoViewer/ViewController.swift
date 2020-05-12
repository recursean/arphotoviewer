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
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var rotateRightImage: UIImageView!
    @IBOutlet weak var rotateLeftImage: UIImageView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var tapToPlaceLabel: UILabel!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var lengthLabel: UILabel!
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
        
        let addImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addImageTapped))
        addImageTapRecognizer.name = "tap"
        addImage.addGestureRecognizer(addImageTapRecognizer)
        
        let infoImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.infoImageTapped))
        infoImageTapRecognizer.name = "tap"
        infoImage.addGestureRecognizer(infoImageTapRecognizer)
        
        let rotateRightImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.rotateRightImageTapped))
        rotateRightImageTapRecognizer.name = "tap"
        rotateRightImage.addGestureRecognizer(rotateRightImageTapRecognizer)
        
        let rotateLeftImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.rotateLeftImageTapped))
        rotateLeftImageTapRecognizer.name = "tap"
        rotateLeftImage.addGestureRecognizer(rotateLeftImageTapRecognizer)
        
        let colorPickerViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.toggleColorPicker))
        colorPickerViewTapRecognizer.name = "tap"
        colorPickerButtonView.addGestureRecognizer(colorPickerViewTapRecognizer)
        
        let colorPickerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectColor))
        colorPickerTapRecognizer.name = "tap"
        colorPickerStack.addGestureRecognizer(colorPickerTapRecognizer)
        
        let lockImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.lockImageTapped))
        lockImageTapRecognizer.name = "tap"
        lockImage.addGestureRecognizer(lockImageTapRecognizer)
        
        let trashImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.trashImageTapped))
        trashImageTapRecognizer.name = "tap"
        trashImage.addGestureRecognizer(trashImageTapRecognizer)
        
        let resetImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.resetImageTapped))
        resetImageTapRecognizer.name = "tap"
        resetImage.addGestureRecognizer(resetImageTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didDoubleTapScreen))
        doubleTapRecognizer.name = "doubleTap"
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapRecognizer)
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
        lengthLabel.isHidden = true
        allSidesStack.isHidden = true
        colorPickerButtonView.isHidden = true
        colorPickerStack.isHidden = true
        trashImage.isHidden = true
        resetImage.isHidden = true
        infoImage.isHidden = false
        isUIHidden = false
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
        lengthLabel.isHidden = false
        allSidesStack.isHidden = false
        colorPickerButtonView.isHidden = false
        colorPickerStack.isHidden = true
        trashImage.isHidden = false
        resetImage.isHidden = false
        infoImage.isHidden = true
        isUIHidden = true
        startBlinkTimer()
        
        view.addConstraint(NSLayoutConstraint(item: lengthLabel, attribute: .top, relatedBy: .equal, toItem: lengthSlider, attribute: .bottom, multiplier: 1, constant: 20))
    }
    
    /**
     Open camera or user's photo gallery to allow them to select an image.
     */
    @IBAction func addImageTapped(_ sender: UITapGestureRecognizer) {
        
        let alert: UIAlertController?
        
        impact.impactOccurred()
        
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
     Called when image has been selected
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            sceneController.setImage(image.fixOrientation())
            sceneController.addFrame()
            setSliderValues()
            prepareForFrame()
        }
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
    @objc func blinkLabel() {
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
     Displays info popup.
     */
    @IBAction func infoImageTapped(_ sender: UITapGestureRecognizer) {
        impact.impactOccurred()
        
        let alert = UIAlertController(title: appTitle, message: "\(appVersion)\nCopyright © Sean McShane", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    /**
     Rotates frame right.
     */
    @IBAction func rotateRightImageTapped(_ sender: UITapGestureRecognizer) {
        impact.impactOccurred()
        
        sceneController.rotateFrame(-Float.pi / 2)
    }
    
    /**
     Rotates frame left.
     */
    @IBAction func rotateLeftImageTapped(_ sender: UITapGestureRecognizer) {
        impact.impactOccurred()
        
        sceneController.rotateFrame(Float.pi / 2)
    }
    
    /**
     Sets frame to be rotated every frame
     */
    @IBAction func lockImageTapped(_ sender: UITapGestureRecognizer) {
        impact.impactOccurred()
        
        let rotate = sceneController.toggleUpdateRotation()
        
        if(rotate) {
            lockImage.image = UIImage(systemName: "lock.open.fill")
        }
        else {
            lockImage.image = UIImage(systemName: "lock.fill")
        }
    }
    
    /**
     Called when distanceSlider value has changed.
     */
    @IBAction func distanceValueChanged(_ sender: UISlider) {
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
        sceneController.updateFrameSize(sizeSlider.value)

        updateSizeLabel()
    }
    
    /**
     Called when lengthSlider value has changed.
     */
    @IBAction func lengthValueChanged(_ sender: UISlider) {
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

        sceneController.setDefaultMaterial(subview!.backgroundColor!)

        colorPickerButtonView.backgroundColor = subview!.backgroundColor!

        colorPickerStack.isHidden = true
    }
    
    /**
     Hide the editing screen.
     */
    @objc func trashImageTapped() {
        impact.impactOccurred()
        
        prepareForSet()
        sceneController.removeFrame()
    }
    
    /**
     Reset back to default edit settings.
     */
    @objc func resetImageTapped() {
        impact.impactOccurred()
        
        sceneController.setDefaultEdit()
        setSliderValues()
    }
}
