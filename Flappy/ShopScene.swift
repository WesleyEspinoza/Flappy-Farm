import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class ShopScene: SKScene, SKPhysicsContactDelegate {
    var buttonBack: MSButtonNode!
    var scrollLayer: SKNode!
    var ShopScroll: SKNode!
    var isPlaying = true
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 100
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let right = SKAction.moveBy(x: 65, y: 0, duration: 0.3)
    let left = SKAction.moveBy(x: -65, y: 0, duration: 0.3)
    
    @objc func swipedRight(sender:UISwipeGestureRecognizer){
        ShopScroll.run(right)
    }
    
    @objc func swipedLeft(sender:UISwipeGestureRecognizer){
        ShopScroll.run(left)
    }
    
    
    
    override func didMove(to view: SKView) {
        swipeRightRec.addTarget(self, action: #selector(ShopScene.swipedRight) )
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeLeftRec.addTarget(self, action: #selector(ShopScene.swipedLeft) )
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        
        buttonBack = self.childNode(withName: "buttonBack") as? MSButtonNode
        
        /* Set reference to scroll layer node */
        scrollLayer = self.childNode(withName: "scrollLayer")
        ShopScroll = self.childNode(withName: "shopScroll")
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


