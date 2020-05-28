//
//  ScreenshotViewController.swift
//  ARPhotoViewer
//
//  Controls the delete/save view after screenshot.
//
//  Created by Sean McShane on 5/27/20.
//  Copyright © 2020 Sean McShane. All rights reserved.
//

import UIKit

class ScreenshotViewController: UIViewController {

    @IBOutlet weak var screenshotImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Sets the image shown in view
    /// - Parameter image: screenshot that was taken
    func setScreenshotImage(_ image: UIImage) {
        screenshotImage!.image = image
    }
    
    /// Discard screenshot
    /// - Parameter sender: sender description
    @IBAction func deleteButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /// Save screenshot to photo library
    /// - Parameter sender: sender description
    @IBAction func saveButtonTapped(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(screenshotImage!.image!, nil, nil, nil)
        
        dismiss(animated: true)
    }
}
