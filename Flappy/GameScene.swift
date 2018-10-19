import SpriteKit
import UIKit
import SceneKit

enum GameSceneState {
    case active, gameOver
    /* Game management */
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    let atlas = SKTextureAtlas(named: "Coin")
    var TextureArray = [SKTexture]()
    var hero: SKSpriteNode!
    var CoinNode: SKNode!
    var scrollLayer: SKNode!
    var cloudScroll: SKNode!
    var obstacleSource: SKNode!
    var obstacleLayer: SKNode!
    var scoreLabel: SKLabelNode!
    var CurScoreLabel: SKLabelNode!
    var HighScoreLabel: SKLabelNode!
    var MoneyLabel: SKLabelNode!
    var buttonRestart: MSButtonNode!
    var buttonHome: MSButtonNode!
    var GameMenu: SKSpriteNode!
    var gameState: GameSceneState = .active
    var points = 0
    var sinceTouch : CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 100
    
    
    override func didMove(to view: SKView) {
        
        /* Setup your scene here */
        
        if Sounds().isPlayingMute == false{
            SKTAudio.sharedInstance().playBackgroundMusic("GameMusic.mp3")
        }
        /* Recursive node search for 'hero' (child of referenced node) */
        hero = self.childNode(withName: "//Hero") as? SKSpriteNode
        CoinNode = self.childNode(withName: "//Coin")
        AnimateCoin()
        /* Set reference to scroll layer node */
        scrollLayer = self.childNode(withName: "scrollLayer")
        /* Set reference to scroll layer node */
        cloudScroll = self.childNode(withName: "cloudScroll")
        
        /* Set reference to obstacle Source node */
        obstacleSource = self.childNode(withName: "//obstacle")
        
        /* Set reference to obstacle layer node */
        obstacleLayer = self.childNode(withName: "obstacleLayer")
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* set reference to restart buton*/
        buttonRestart = self.childNode(withName: "buttonRestart") as? MSButtonNode
        buttonHome = self.childNode(withName: "buttonHome") as? MSButtonNode
        GameMenu = self.childNode(withName: "GameMenu") as? SKSpriteNode
        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        CurScoreLabel = self.childNode(withName: "CurScoreLbl") as? SKLabelNode
        HighScoreLabel = self.childNode(withName: "HighScoreLbl") as? SKLabelNode
        MoneyLabel = self.childNode(withName: "MoneyLbl") as? SKLabelNode
        
        
        
        /* Setup restart button selection handler */
        buttonRestart.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView?
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene?
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            /* Restart game scene */
            skView?.presentScene(scene)
            
        }
        /* Hide restart button */
        self.buttonRestart.state = .MSButtonNodeStateHidden
        self.GameMenu.isHidden = true
        self.CurScoreLabel.isHidden = true
        self.HighScoreLabel.isHidden = true
        self.MoneyLabel.isHidden = true
        
        
        buttonHome.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView?
            
            /* Load Game scene */
            let scene = MenuScene(fileNamed:"MenuScene") as MenuScene?
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            /* Restart game scene */
            skView?.presentScene(scene)
            if Sounds().isPlayingMute == false{
                SKTAudio.sharedInstance().playBackgroundMusic("MenuMusic.mp3")
            }
            
            
        }
        /* Hide restart button */
        self.buttonHome.state = .MSButtonNodeStateHidden
        HighScoreLabel.text = String(MainDefault.integer(forKey: "HighScore"))
        MoneyLabel.text = String(MainDefault.integer(forKey: "Coins"))
    }
    func didBegin(_ contact: SKPhysicsContact) {
        /* Get references to bodies involved in collision */
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* Did our hero pass through the 'goal'? */
        if nodeA.name == "goal" || nodeB.name == "goal" {
            
            points += 1
            /* Update score label */
            scoreLabel.text = String(points)
            CurScoreLabel.text = String(points)
            
            /* Store the users high score */
            if points >= MainDefault.integer(forKey: "HighScore") {
                MainDefault.set(points, forKey: "HighScore")
        scoreLabel.fontColor = UIColor.yellow
            }
            HighScoreLabel.text = String(MainDefault.integer(forKey: "HighScore"))
            /* We can return now */
            return
        }
        if nodeA.name == "Coin" || nodeB.name == "Coin" {
            var CurCoin = MainDefault.integer(forKey: "Coins")
            LinkedNodes.shared.removeNodesLinked(to: CoinNode)
            CurCoin += 1
            MainDefault.set(CurCoin, forKey: "Coins")
            MoneyLabel.text = String(MainDefault.integer(forKey: "Coins"))
            return
        }
        
        /* Hero touches anything, game over */
        
        /* Ensure only called while game running */
        if gameState != .active { return }
        
        /* Change game state to game over */
        gameState = .gameOver
        
        /* Stop any new angular velocity being applied */
        hero.physicsBody?.allowsRotation = false
        
        /* Reset angular velocity */
        hero.physicsBody?.angularVelocity = 0
        
        /* Stop hero flapping animation */
        
        
        /* Create our hero death action */
        let heroDeath = SKAction.run({
            
            /* Put our hero face down in the dirt */
            self.hero.zRotation = CGFloat(-90).degreesToRadians()
        })
        
        /* Run action */
        hero.run(heroDeath)
        
        /* Load the shake action resource */
        let shakeScene:SKAction = SKAction.init(named: "Shake")!
        
        /* Loop through all nodes  */
        for node in self.children {
            
            /* Apply effect each ground node */
            node.run(shakeScene)
        }
        
        
        /* Show restart button */
        buttonRestart.state = .MSButtonNodeStateActive
        buttonHome.state = .MSButtonNodeStateActive
        self.GameMenu.isHidden = false
        self.CurScoreLabel.isHidden = false
        self.HighScoreLabel.isHidden = false
        self.MoneyLabel.isHidden = false
        
        /* Reset Score label */
        scoreLabel.text = "\(points)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .active { return }
        /* Called when a touch begins */
        /* Reset velocity, helps improve response against cumulative falling velocity */
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        /* Apply vertical impulse */
        hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
        hero.texture = SKTexture(imageNamed: "panda_02")
        emitter()
        
        /* Apply subtle rotation */
        hero.physicsBody?.applyAngularImpulse(1)
        
        /* Reset touch timer */
        sinceTouch = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Skip game update if game no longer active */
        if gameState != .active { return }
        /* Called before each frame is rendered */
        
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        /* Check and cap vertical velocity */
        if velocityY > 400 {
            hero.physicsBody?.velocity.dy = 400
        }
        
        /* Apply falling rotation */
        if sinceTouch > 0.2 {
            let impulse = -20000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
            hero.texture = SKTexture(imageNamed: "panda_01")
            
        }
        
        /* Clamp rotation */
        hero.zRotation.clamp(v1: CGFloat(-90).degreesToRadians(), CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(v1: -1, 3)
        
        /* Update last touch timer */
        sinceTouch += fixedDelta
        /* Process world scrolling */
        scrollWorld()
        /* Process obstacles */
        updateObstacles()
        
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
        /* Loop through scroll layer nodes */
        for cloud in cloudScroll.children as! [SKSpriteNode] {
            
            /* Get cloud node position, convert node position to scene space */
            let cloudPosition = cloudScroll.convert(cloud.position, to: self)
            
            /* Check if cloud sprite has left the scene */
            if cloudPosition.x <= -cloud.size.width / 2 {
                
                /* Reposition cloud sprite to the second starting position */
                let newcloudPosition = CGPoint(x: (self.size.width / 2) + cloud.size.width, y: cloudPosition.y)
                
                /* Convert new node position back to scroll layer space */
                cloud.position = self.convert(newcloudPosition, to: cloudScroll)
                
            }
        }
        
    }
    func updateObstacles() {
        
        spawnTimer+=fixedDelta
        /* Update Obstacles */
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes
         as! [SKReferenceNode] */
        for obstacle in obstacleLayer.children {
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.x <= -26 {
                // 26 is one half the width of an obstacle
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
            }
            
        }
        /* Time to add a new obstacle? */
        if spawnTimer >= 1.3 {
            /* Create a new obstacle by copying the source obstacle */
            let newObstacle = obstacleSource.copy() as! SKNode
            obstacleLayer.addChild(newObstacle)
            /* Generate new obstacle position, start just outside screen and with a random y value */
            let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 234, max: 382))
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
            // Reset spawn timer
            let random = Int(arc4random_uniform(15))
            
            if random == 0 {
                let newCoin = CoinNode.copy() as! SKNode
                LinkedNodes.shared.link(nodeA: CoinNode, to: newCoin)
                obstacleLayer.addChild(newCoin)
                newCoin.position = self.convert(randomPosition, to: obstacleLayer)
            }
            
            spawnTimer = 0
        }
    }
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        cloudScroll.position.x -= (scrollSpeed - 75) * CGFloat(fixedDelta)
    }
    func emitter() {
        if let sparkPath = Bundle.main.path(forResource: "MagicParticle", ofType: "sks"),
            let spark = NSKeyedUnarchiver.unarchiveObject(withFile: sparkPath) as? SKEmitterNode {
            spark.position = CGPoint(x: hero.position.x + 80, y: hero.position.y + 325)
            addChild(spark)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { 
                spark.removeFromParent()
            }
        }
    }
    func AnimateCoin() {
        for i in 1...atlas.textureNames.count{
            let Name = "Coin_\(i).png"
            TextureArray.append(SKTexture(imageNamed: Name))
        }
        CoinNode.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        CoinNode.physicsBody?.isDynamic = false
        CoinNode.physicsBody?.allowsRotation = false
        CoinNode.physicsBody?.restitution = 1.0
        CoinNode.physicsBody?.friction = 0.0
        CoinNode.physicsBody?.angularDamping = 0.0
        CoinNode.physicsBody?.linearDamping = 0.0
        CoinNode.physicsBody?.categoryBitMask = 8
        CoinNode.physicsBody?.contactTestBitMask = 14
        CoinNode.physicsBody?.collisionBitMask = 1
        let myAnimation = SKAction.animate(with: TextureArray, timePerFrame: 0.1)
        CoinNode.run(SKAction.repeatForever(myAnimation))
    }
    
    final class LinkedNodes {
        
        static let shared = LinkedNodes()
        private var links: [(SKNode, SKNode)] = []
        
        private init() { }
        
        func link(nodeA: SKNode, to nodeB: SKNode) {
            let pair = (nodeA, nodeB)
            links.append(pair)
        }
        
        func removeNodesLinked(to node: SKNode) {
           
                let linkedNodes = links.reduce(Set<SKNode>()) { (res, pair) -> Set<SKNode> in
                    var res = res
                    if pair.0 == node {
                        res.insert(pair.1)
                    }
                    if pair.1 == node {
                        res.insert(pair.0)
                    }
                    return res
            }
            linkedNodes.forEach { $0.removeFromParent() }
            links = links.filter { $0.0 != node && $0.1 != node }
        }
    }
    
}
