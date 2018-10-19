import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class MenuScene: SKScene, SKPhysicsContactDelegate {
    var buttonPlay: MSButtonNode!
    var buttonSetting: MSButtonNode!
    var buttonShop: MSButtonNode!
    var HighScoreLabel: SKLabelNode!
    var CurrencyLabel: SKLabelNode!
    var scrollLayer: SKNode!
    var scrollCloud: SKNode!
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 100
    let MainDefault = UserDefaults.standard
    
    
    override func didMove(to view: SKView) {
        
        buttonPlay = self.childNode(withName: "buttonPlay") as? MSButtonNode
        buttonShop = self.childNode(withName: "buttonShop") as? MSButtonNode
        HighScoreLabel = self.childNode(withName: "HighScoreLbl") as? SKLabelNode
        CurrencyLabel = self.childNode(withName: "CurrencyLbl") as? SKLabelNode
        /* Set reference to scroll layer node */
        scrollLayer = self.childNode(withName: "scrollLayer")
        scrollCloud = self.childNode(withName: "cloudLayer")
        /* Setup restart button selection handler */
        buttonPlay.selectedHandler = {
            if let scene = GKScene(fileNamed: "GameScene") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! GameScene? {
                    
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
        
        buttonSetting = self.childNode(withName: "buttonSetting") as? MSButtonNode
        
        buttonSetting.selectedHandler = {
            if let scene = GKScene(fileNamed: "SettingScene") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! SettingScene? {
                    
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
        buttonShop.selectedHandler = {
            if let scene = GKScene(fileNamed: "ShopScene") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! ShopScene? {
                    
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
        
        
        
        HighScoreLabel.text = String(MainDefault.integer(forKey: "HighScore"))
        CurrencyLabel.text = String(MainDefault.integer(forKey: "Coins"))
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        scrollWorld()
        scrollClouds()
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
        
        
        for cloud in scrollCloud.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let cloudPosition = scrollCloud.convert(cloud.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if cloudPosition.x <= -cloud.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + cloud.size.width, y: cloudPosition.y)
                
                /* Convert new node position back to scroll layer space */
                cloud.position = self.convert(newPosition, to: scrollCloud)
                
            }
        }
        
    }
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
    }
    func scrollClouds() {
        /* Scroll World */
        scrollCloud.position.x -= (scrollSpeed/8) * CGFloat(fixedDelta)
    }
}

