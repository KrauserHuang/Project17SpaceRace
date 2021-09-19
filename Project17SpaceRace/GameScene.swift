//
//  GameScene.swift
//  Project17SpaceRace
//
//  Created by Tai Chin Huang on 2021/9/19.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    // using property observer
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var gameOver: SKSpriteNode!
    var finalScore: SKLabelNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var isTracking = false
    
    var timeInterval = 1.0
    var enemyCount = 0
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .black
        
        starField = SKEmitterNode(fileNamed: "starfield")!
        starField.position = CGPoint(x: 1024, y: 384)
        starField.zPosition = -1
        starField.advanceSimulationTime(10)
        addChild(starField)
        // 建立player實體範圍，因為是不規則的，所以要使用texture來模擬大致實體外表
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 284)
        gameOver.zPosition = 1
        addChild(gameOver)
        gameOver.isHidden = true
        
        score = 0
        // 製造無重力，讓物件不會掉下來，並且符合物件接觸的協議，需要增加SKPhysicsContactDelegate
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        if enemyCount < 20 {
            guard let enemy = possibleEnemies.randomElement() else { return }
            let sprite = SKSpriteNode(imageNamed: enemy)
            sprite.position = CGPoint(x: 1200, y: CGFloat.random(in: 50...736))
            addChild(sprite)
            
            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.physicsBody?.categoryBitMask = 1
            sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
            // 角速度, 角阻尼, 線阻尼，代表他的旋轉及移動速度不會收到阻尼影響(=0)
            sprite.physicsBody?.angularVelocity = 5
            sprite.physicsBody?.angularDamping = 0
            sprite.physicsBody?.linearDamping = 0
            
            enemyCount += 1
        } else {
            enemyCount = 0
            timeInterval -= 0.1
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 所有製造出來的SKNode都儲存在children裏，所以當裡面node的x位置低於-300就要將它消滅
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        // 沒失敗就會一直增加分數
        if !isGameOver {
            score += 1
        } else {
            gameTimer?.invalidate()
            gameOver.isHidden = false
            scoreLabel.isHidden = true
            
            finalScore = SKLabelNode(fontNamed: "Chalkduster")
            finalScore.text = "Final score: \(score)"
            finalScore.position = CGPoint(x: 0, y: -80)
            finalScore.fontSize = 48
            finalScore.horizontalAlignmentMode = .center
            gameOver.addChild(finalScore)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = Set(self.nodes(at: location))
        if nodes.contains(player) {
            isTracking = true
        }
    }
    // 偵測手指觸控
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTracking else { return }
        // 篩選第一下，並轉換成座標
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        // player的位置依照手指點選座標移動
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTracking = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        
        isGameOver = true
    }
}
