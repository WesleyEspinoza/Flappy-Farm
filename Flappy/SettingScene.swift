import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class SettingScene: SKScene, SKPhysicsContactDelegate {
    var buttonBack: MSButtonNode!
    var musicButton: MSButtonNode!
    var scrollLayer: SKNode!
    var isPlaying = true
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 100
    
    
    override func didMove(to view: SKView) {
        
        buttonBack = self.childNode(withName: "buttonBack") as? MSButtonNode
        musicButton = self.childNode(withName: "musicButton") as? MSButtonNode
        
        if Sounds().isPlayingMute == true {
            self.musicButton.texture = SKTexture(imageNamed: "MusicNotPlayingButton")
        }
        
        /* Set reference to scroll layer node */
        scrollLayer = self.childNode(withName: "scrollLayer")
        /* Setup restart button selection handler */
        buttonBack.selectedHandler = {
            if let scene = GKScene(fileNamed: "MenuScene") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! MenuScene? {
                    
                    // Copy gameplay related content over to the scene
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    if let view = self.view {
                        view.presentScene(sceneNode)
                    }
                    
                }
            }
        }
        //MuteButton
        musicButton.selectedHandler = {
            if Sounds().isPlayingMute == false {
                 MainDefault.set(true, forKey: "Sounds")
                SKTAudio.sharedInstance().pauseBackgroundMusic()
                self.musicButton.texture = SKTexture(imageNamed: "MusicNotPlayingButton")
            } else {
                self.musicButton.texture = SKTexture(imageNamed: "MusicPlayingButton")
                MainDefault.set(false, forKey: "Sounds")
                SKTAudio.sharedInstance().resumeBackgroundMusic()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        scrollWorld()
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
                
            }
        }
        
    }
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
    }
}


