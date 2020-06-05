//
//  WorldTrackingHelpLabel.swift
//  ARPhotoViewer
//
//  Created by Sean McShane on 6/4/20.
//  Copyright © 2020 Sean McShane. All rights reserved.
//

import Foundation
import UIKit

class WorldTrackingHelpLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
}
