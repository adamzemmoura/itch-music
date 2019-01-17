//
//  ViewController.swift
//  Itch Music
//
//  Created by Adam Zemmoura on 15/01/2019.
//  Copyright © 2019 Adam Zemmoura. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class BusinessCardViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    // Create Our Image Tracking Configuration
    let configuration : ARImageTrackingConfiguration = {

        // make sure there are images to track
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            fatalError("Unable to locate images for tracking.")
        }

        let config = ARImageTrackingConfiguration()
        config.isAutoFocusEnabled = true
        config.maximumNumberOfTrackedImages = 1

        config.trackingImages = trackedImages
        return config
    }()
    
    //let configuration = ARWorldTrackingConfiguration()
    
    // MARK:- View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK:- Helper Methods
    func displayLogo(imageAnchor : ARImageAnchor, node: SCNNode) {
        
        let width = imageAnchor.referenceImage.physicalSize.width
        let height = imageAnchor.referenceImage.physicalSize.height
        
        let logoScene = SCNScene(named: "art.scnassets/itch_logo.scn")
        
        if let logoNode = logoScene?.rootNode.childNode(withName: "Logo", recursively: true) {
            
            node.addChildNode(logoNode)
            
            logoNode.position = SCNVector3(x: 0, y: 0, z: 0)
            
            let rotateAction = SCNAction.repeatForever(
                .rotateBy(x: 0, y: 0, z: 2, duration: 1)
            )
            
            logoNode.runAction(rotateAction)
        }
        
    }
    

}

// MARK: - ARSCNViewDelegate
extension BusinessCardViewController : ARSCNViewDelegate {
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //1. Load Our Videos From Both The Main Bundle
        guard let imageAnchor = anchor as? ARImageAnchor,
            let videoPathShowreel = Bundle.main.path(forResource: "showreel", ofType: "mp4") else { return }
        
        DispatchQueue.main.async {
            
            let width = imageAnchor.referenceImage.physicalSize.width
            let height = imageAnchor.referenceImage.physicalSize.height
            
            self.displayLogo(imageAnchor: imageAnchor, node: node)
        
            //2. Initialize The Video Player
            let videoNode = VideoNodeSK(width: width, height: height, videoPaths: [videoPathShowreel])
            
            //b. Rotate The Video Player If We Have A Vertical Plane
            videoNode.eulerAngles.x = -.pi / 2
            
            //c. Add It To Our Hierachy
            node.addChildNode(videoNode)
            
            //d. Scale The Video Player To Match The Initial Size Of The Detected Plane
            videoNode.scaleVideoPlayerFromAnchor(imageAnchor)
        
            
            
//            logoNode.runAction(.sequence([
//                .wait(duration: 1.0),
//                .moveBy(x: 0, y: height * 2, z: 0, duration: 1.5)
//                ]))
            
            // Perform a quick animation to visualize the plane on which the image was detected.
            // We want to let our users know that the app is responding to the tracked image.
//            self.displayLogoView(on: mainNode, width: physicalWidth, height: physicalHeight)
//
//            self.displayDetailView(on: mainNode, height: physicalHeight, width: physicalWidth)
//
//            self.displayVideo(on: mainNode, height: physicalHeight, width: physicalWidth)
            
         
        }
    }
    
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}
