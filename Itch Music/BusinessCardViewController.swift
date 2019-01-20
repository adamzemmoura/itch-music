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
import SafariServices

class BusinessCardViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    private var videoPlayerNode: VideoNodeSK!
    private var trackedImageAnchor: ARImageAnchor?
    private var imageCurrentlyTracked = false {
        didSet {
            if videoPlayerNode != nil {
                imageCurrentlyTracked ? videoPlayerNode.play() : videoPlayerNode.pause()
            }
        }
    }
    private var logoNode: SCNNode?
    private let itchHomepageURL = URL(string: "https://www.itch.nyc")!
    
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
        sceneView.showsStatistics = false

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
        
        let height = imageAnchor.referenceImage.physicalSize.height
        
        let logoScene = SCNScene(named: "art.scnassets/itch_logo.scn")
        
        if let logoNode = logoScene?.rootNode.childNode(withName: "Logo", recursively: true) {
            
            self.logoNode = logoNode
            
            node.addChildNode(logoNode)
            
            let yOffset = Float(height / 2) * 1.5
            
            // scale the logo to 30% of the default size
            logoNode.scale = SCNVector3(0.2, 0.2, 0.2)
            
            
            //let logoHeight = logoNode.boundingBox.max.z - logoNode.boundingBox.min.z
            
            logoNode.position = SCNVector3(x: 0,
                                           y: 0,
                                           z: -yOffset)
            
            let rotateAction = SCNAction.repeatForever(
                .rotateBy(x: 0, y: 0, z: 2, duration: 1)
            )
            
            logoNode.runAction(.sequence([
                    rotateAction
                ]))
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let logoNode = self.logoNode else { return }
        
        if let touch = touches.first {
            
            
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, options: nil)
            
            if let result = results.first {
                if result.node == logoNode {
                    
                    // the user touched the logo so take them to the website in Safari
                    openSafari(url: itchHomepageURL)
                    
                }
            }
            
            
        }
        
    }
    
    private func openSafari(url: URL) {
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.configuration.barCollapsingEnabled = true
        safariVC.preferredBarTintColor = .black
        let pinkColor = UIColor(red: 237/255, green: 21/255, blue: 102/255, alpha: 1)
        safariVC.preferredControlTintColor = pinkColor
        videoPlayerNode.pause()
        present(safariVC, animated: true, completion: nil)
        
    }
    

}

// MARK: - ARSCNViewDelegate
extension BusinessCardViewController : ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARImageAnchor {
            if anchor.isTracked != imageCurrentlyTracked {
                imageCurrentlyTracked = anchor.isTracked
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //1. Load Our Videos From Both The Main Bundle
        guard let imageAnchor = anchor as? ARImageAnchor,
            let videoPathShowreel = Bundle.main.path(forResource: "showreel", ofType: "mp4") else { return }
        
        self.trackedImageAnchor = imageAnchor
        
        DispatchQueue.main.async {
            
            let width = imageAnchor.referenceImage.physicalSize.width
            let height = imageAnchor.referenceImage.physicalSize.height
            
            self.displayLogo(imageAnchor: imageAnchor, node: node)
        
            //2. Initialize The Video Player if not already
            if self.videoPlayerNode == nil {
                let videoNode = VideoNodeSK(width: width, height: height, videoPaths: [videoPathShowreel])
                
                //b. Rotate The Video Player If We Have A Vertical Plane
                videoNode.eulerAngles.x = -.pi / 2
                
                self.videoPlayerNode = videoNode
            }
            
            //c. Add It To Our Hierachy
            node.addChildNode(self.videoPlayerNode)
            
            //d. Scale The Video Player To Match The Initial Size Of The Detected Plane
            self.videoPlayerNode.scaleVideoPlayerFromAnchor(imageAnchor)
        
            self.videoPlayerNode.play()
            
            
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
