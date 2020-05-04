//
//  SCNNode+Extensions.swift
//  ARPhotoViewer
//
//  Created by Sean McShane on 5/3/20.
//  Copyright © 2020 Sean McShane. All rights reserved.
//

import Foundation
import SceneKit
extension SCNNode {
    
    public class func allNodes(from file: String) -> [SCNNode] {
        var nodesInFile = [SCNNode]()
        do {
            guard let sceneURL = Bundle.main.url(forResource: file, withExtension: nil) else {
                print("Could not find scene file \(file)")
                return nodesInFile
            }
            
            let objScene = try SCNScene(url: sceneURL as URL, options: [SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay])
            
            objScene.rootNode.enumerateChildNodes({ (node, _) in
                nodesInFile.append(node)
            })
        } catch {}
        return nodesInFile
    }
}
