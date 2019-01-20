//
//  VideoNodeSK.swift
//  Itch Music
//
//  Created by Adam Zemmoura on 15/01/2019.
//  Copyright © 2019 Adam Zemmoura. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation
import SpriteKit
import ARKit

class VideoNodeSK: SCNNode {
    
    private var videoPlayerHolder : SCNNode!
    private var videoPlayer : AVPlayer!
    private var videoPlayerNode : SKVideoNode!
    private var spriteKitScene : SKScene!
    private var videoArray = [String]()
    
    init(width: CGFloat, height: CGFloat, videoPaths: [String]) {
        
        super.init()
        
        //1. Assign The Video Paths To Our Video Array
        videoArray = videoPaths
        
        //4. Create A Node To Holder The Video Player
        videoPlayerHolder = SCNNode()
        
        //5. Create The Plane Geometry With The Passesd Width & Calculate The Height
        videoPlayerHolder.geometry = SCNPlane(width: width, height: height)
        
        //6. Create A URL From Our Video Path
        guard let firstVideoPath = videoPaths.first else { return }
        let url = URL(fileURLWithPath: firstVideoPath)
        
        //7. Instanciate The AVPlayer With Our Video URL
        videoPlayer = AVPlayer(url: url)
        
        //8. Initialize The VideoNode With The AVPlayer
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)
        
        //9. Ensure The Video Is Shown The Right Way Round
        videoPlayerNode.yScale = -1
        
        //10. Initialize The SKScene
        spriteKitScene = SKScene(size: CGSize(width: 1280, height: 960))
        
        //11. Set It's Scale Mode
        spriteKitScene.scaleMode = .aspectFit
        
        //12. Set The VideoPlayerNode Size
        videoPlayerNode.size = spriteKitScene.size
        
        //13. Position The VideoPlayerNode Centrally In The Scene
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        
        //14. Add The VideoPlayerNode To The Scene
        spriteKitScene.addChild(videoPlayerNode)
        
        //15. Set The Planes Geoemtry To Our SpriteKit Scene
        videoPlayerHolder.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        
        //16. Add The VideoPlayer Holder
        self.addChildNode(videoPlayerHolder)
        
    
    }
    
    func play() {
        videoPlayer.play()
        videoPlayer.volume = 1
    }
    
    func pause() {
        videoPlayer.pause()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    /// Scales The VideoNode Depending Upon The Initial Size Of A Detected ARPlaneAnchor
    ///
    /// - Parameter anchor: ARPlaneAnchor
    func scaleVideoPlayerFromAnchor(_ anchor: ARImageAnchor){
        
        //1. Create An SCNPlane So We Can Get The Intiial Size Of The Anchor
        let plane = SCNPlane(width: anchor.referenceImage.physicalSize.width, height: anchor.referenceImage.physicalSize.height)
        let planeNode = SCNNode(geometry: plane)
        let sizeOfAnchor = planeNode.boundingBox
        
        //2. Get The Width Of The SCNPlane
        let widthNeeded = sizeOfAnchor.max.x - sizeOfAnchor.min.x
        
        //3. Get The Current Width Of The Video Player
        let currentWidthOfVideoPlayer = self.boundingBox.max.x - self.boundingBox.min.x
        
        //4. Get The Scale Factor
        let scalar = widthNeeded/currentWidthOfVideoPlayer
        
        //5. Scale The VideoPlayer To Fit The Initial Size Of The Plane
        self.scale = SCNVector3(scalar, scalar, scalar)
        
    }
    
}
