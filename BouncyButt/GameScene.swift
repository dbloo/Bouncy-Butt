//
//  GameScene.swift
//  BouncyButt
//
//  Created by Dominic Bloomfield on 4/12/17.
//  Copyright © 2017 Dominic Bloomfield. All rights reserved.
//

import SpriteKit
import GameplayKit



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var player: SKSpriteNode!// player
    
    var pillarArray = ["pillar1"]// an array of pillar.png representing pillar node
    var badPillarArray = ["badpillar1"]
    var backgroundArray = ["background"]
    var foregroundArray = ["foreground"]
    

    var pillar : SKSpriteNode!
    var dummyPillar: SKSpriteNode!
    var badPillar : SKSpriteNode!
    var background: SKSpriteNode!
    var foreground: SKSpriteNode!
    var ground: SKSpriteNode!
    var pillarRestitution = 0.7

    var backgroundFrame: SKSpriteNode!
    var backgroundTimer: Timer!
    var frameCollisionBox: SKSpriteNode!
    var foregroundTimer: Timer!
    
    
    var pauseButton: SKSpriteNode!
    var timerIsRunning: Bool = false
    var resumeButton: SKSpriteNode!
    
    var tutorialScreen: SKSpriteNode!
    
    var pillarTimer: Timer!// timer for interval between pillars
    var badPillarTimer: Timer!
    var interval: TimeInterval!
    var time : GKRandomDistribution!
    var duration: Double = 4
    var durationTimer: Timer!
    
    var gameOver: Bool = false
    
    var scoreLabel : SKLabelNode!
    public var score : Int = 0{
        didSet {
            scoreLabel.text = "\(score)"
        }
        
        }
    var pausedTimerLabel: SKLabelNode!
    var pausedTimer: Timer!
    var timer : Int = 3
    var pausedLabel: SKLabelNode!
    
    var playerBitMask : UInt32 = 0b001
    var pillarBitMask : UInt32 = 0b0010
    var badPillarBitMask : UInt32 = 0b00100
    var frameCollisionBitMask: UInt32 = 0b001000
    
    let swipeUP = UISwipeGestureRecognizer()
    var swipeCounter : Int = 4
    var playerDidCollideWithPillar = false
    
    
    var fartAnimation : SKTextureAtlas!
    var fartTextureArray: [SKTexture]!
    var tapAnimation : SKTextureAtlas!
    var tapTextureArray : [SKTexture]!
    var tapNode : SKSpriteNode!
    var playerAnimation : SKTextureAtlas!
    var playerTextureArray: [SKTexture]!
    var pillarAnimation: SKTextureAtlas!
    var pillarTextureArray: [SKTexture]!
    var badpillarAnimation: SKTextureAtlas!
    var badpillarTextureArray: [SKTexture]!
    
    var canSpawn = false
    
    var tutorialButton: SKSpriteNode!
    
    var getReadyLabel: SKLabelNode!
    var getreadylabelTimer: Timer!
    
    var animArray = [SKAction]()
    
    var transitionNode: SKSpriteNode!
    var hasCollided = false
    
    let flapSound = SKAction.playSoundFileNamed("hatflap.wav", waitForCompletion: false)
    let collisionSound = SKAction.playSoundFileNamed("pillarHit.wav", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("endGameMusic.wav", waitForCompletion: false)
    


    
    // main method

    override func didMove(to view: SKView){
        
        self.scaleMode = .aspectFill

    
        
        backgroundFrame = self.childNode(withName: "frame") as! SKSpriteNode

        
        pauseButton = self.childNode(withName: "pauseButton") as! SKSpriteNode

        

        getReadyLabel = self.childNode(withName: "getReadyLabel") as! SKLabelNode
        getReadyLabel.run(animateGetReadyLabel())
        
        
        

        addBackground()


        
        
        transitionNode = SKSpriteNode(color: UIColor.white, size: self.frame.size)
        transitionNode.zPosition = 6
        self.addChild(transitionNode)
        transitionNode.run(SKAction.fadeOut(withDuration: 0.3))

        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.81)
        
        
        
        if(self.view?.isPaused == true){isPaused = true}
        
        self.isUserInteractionEnabled = true
        
        swipeUP.addTarget(self, action: #selector(GameScene.fart))
        swipeUP.direction = .up
        self.view?.addGestureRecognizer(swipeUP)
        
        
        
        
        dummyPillar = SKSpriteNode(imageNamed: "pillar1")
        dummyPillar.physicsBody = SKPhysicsBody(rectangleOf: dummyPillar.size )
        dummyPillar.physicsBody?.isDynamic = false;
        dummyPillar.physicsBody?.categoryBitMask = pillarBitMask
        dummyPillar.physicsBody?.collisionBitMask = playerBitMask
        dummyPillar.physicsBody?.contactTestBitMask = playerBitMask
        dummyPillar.zPosition = ground.zPosition + 1
        dummyPillar.physicsBody?.restitution = CGFloat(pillarRestitution)
        dummyPillar.position = CGPoint(x: 0, y: (ground.position.y + (dummyPillar.size.height - 40)))
        self.addChild(dummyPillar)
        
        pillarAnimation = SKTextureAtlas(named: "pillars")
        pillarTextureArray = [SKTexture]()
        badpillarAnimation = SKTextureAtlas(named: "badpillars")
        badpillarTextureArray = [SKTexture]()
        
        for i in 1...pillarAnimation.textureNames.count{
            
            pillarTextureArray.append(SKTexture(imageNamed: "pillar\(i)"))
            badpillarTextureArray.append(SKTexture(imageNamed: "badpillar\(i)"))
            
        }
        
        
        dummyPillar.texture = SKTexture(imageNamed: pillarAnimation.textureNames[0])
        dummyPillar.run(SKAction.repeatForever(SKAction.animate(with: pillarTextureArray, timePerFrame: 0.6)))
        
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        physicsWorld.contactDelegate = self
        
        player = self.childNode(withName: "player") as! SKSpriteNode
        player.position = CGPoint(x: 0 , y: self.frame.size.width / 2)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: (player.size.width / 2) + 5)
        
        player.physicsBody?.isDynamic = true ;
        player.physicsBody?.mass = 6
        player.physicsBody?.categoryBitMask = playerBitMask;
        player.physicsBody?.collisionBitMask = pillarBitMask
        player.physicsBody?.contactTestBitMask = pillarBitMask
        player.physicsBody?.usesPreciseCollisionDetection = true;
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.affectedByGravity = false
        
        player.constraints = [SKConstraint.positionX(SKRange(constantValue: 0))]

        
        
        frameCollisionBox = self.childNode(withName: "frameCollisionBox") as! SKSpriteNode
        
        frameCollisionBox.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frameCollisionBox.size.width, height: frameCollisionBox.size.height + 45))
        
        frameCollisionBox.physicsBody?.isDynamic = false
        frameCollisionBox.physicsBody?.affectedByGravity = false
        frameCollisionBox.physicsBody?.categoryBitMask = frameCollisionBitMask
        frameCollisionBox.physicsBody?.contactTestBitMask = playerBitMask
        frameCollisionBox.physicsBody?.collisionBitMask = playerBitMask
        frameCollisionBox.zPosition = player.zPosition

        
        
        
        tapAnimation = SKTextureAtlas(named: "tapToBegin")
        tapTextureArray = [SKTexture]()
        
        for i in 1...tapAnimation.textureNames.count {
            
            tapTextureArray.append(SKTexture(imageNamed: "tap\(i)"))
            
        }
        
        if self.view?.isPaused == true {
            resumeGame()
        }
        
        tapNode = self.childNode(withName: "tap1") as! SKSpriteNode!
        tapNode.texture = SKTexture(imageNamed: tapAnimation.textureNames[0])
        tapNode.position = CGPoint(x: 0 , y: 0)
        tapNode.zPosition = player.zPosition
        
        tapNode.run(SKAction.repeatForever(SKAction.animate(with: tapTextureArray, timePerFrame: 0.6)))
        
        
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: 0.5, y: player.position.y + 40)
        scoreLabel.zPosition = 1
        score = 0
        
        
        self.addChild(scoreLabel)
        
        
       
        
        
        pillarTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(addPillar), userInfo: nil, repeats: true)
        if score > 0 {
            pillarTimer.fire()
        }
        
       
        
        
        
        
        
        durationTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector (decrementDuration), userInfo: nil, repeats: true)
        durationTimer.fire()
    
        
        
        
        
        
        if(self.view?.isPaused == true){
            resumeGame()
        }
        
        if(UIApplication.isFirstLaunch()){
            
            
            
        
            
        }

        
        
    }
    
    func animateGetReadyLabel() -> SKAction{
        
        let blinkAction = SKAction.sequence([SKAction.fadeOut(withDuration: 0.3), SKAction.fadeIn(withDuration: 0.3)])
            
        return SKAction.repeatForever(blinkAction)
        
    }
    
    
    func pauseGame(){
        resumeButton = SKSpriteNode(imageNamed: "resumeButton(gba)")
        resumeButton.position = CGPoint(x: pauseButton.position.x , y: pauseButton.position.y)
        resumeButton.zPosition = pauseButton.zPosition + 1
        resumeButton.size = pauseButton.size
        resumeButton.name = "resumeButton"
        
        pausedLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        pausedLabel.text = "Paused"
        pausedLabel.fontColor = SKColor.black
        pausedLabel.position = CGPoint(x: 0, y: 0)
        pausedLabel.zPosition = resumeButton.zPosition
        pausedLabel.fontSize = 32
        pausedLabel.name = "pausedLabel"
        
        self.addChild(pausedLabel)
        
        self.addChild(resumeButton)
        
        durationTimer.invalidate()
        
        pauseButton.removeFromParent()
        
        let pauseAction = SKAction.run {
            
            self.timerIsRunning = true
            self.physicsWorld.speed = 0
            self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.isPaused = true
            
        }
        self.run(pauseAction)
    }
    
    
    func pauseTimer(){
        
        timer -= 1
        pausedTimerLabel.text = "\(timer)"
        
        timerIsRunning = pausedTimer.isValid
        
        if timer == 0{
            
            pausedTimerLabel.removeFromParent()
            self.physicsWorld.speed = 1
            self.player.physicsBody?.velocity = CGVector(dx: 0, dy: -5)
            self.addChild(pauseButton)
            timer = 3
            pausedTimer.invalidate()
            timerIsRunning = false
            isPaused = false
            pausedTimerLabel.removeFromParent()


        }
        
        
        
        
    }
    
    
    func resumeGame(){
     

        pausedTimerLabel = SKLabelNode(text: "3")
        pausedTimerLabel.fontName = "Fipps-Regular"
        pausedTimerLabel.fontSize = 32
        pausedTimerLabel.position = CGPoint(x: 0.5, y: 0.5)
        pausedTimerLabel.fontColor = SKColor.black
        pausedTimerLabel.name = "pausedTimerLabel"
        pausedTimerLabel.zPosition = 5
        
    
        self.addChild(pausedTimerLabel)

        pausedTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector (pauseTimer), userInfo: nil, repeats: true)
        
        
        resumeButton.removeFromParent()
        pausedLabel.removeFromParent()
        durationTimer.fire()
        
        
    }
    
    
    
    // function to add pillars to scene based on random time interval
    func addPillar(){
        
        pillarRestitution = 0.7
        
        
        pillar = SKSpriteNode(imageNamed: pillarArray[0])
        badPillar = SKSpriteNode(imageNamed: badPillarArray[0])
        
        var animArray = [SKAction]()
        
        pillar = SKSpriteNode(imageNamed: "pillar1")
        pillar.physicsBody = SKPhysicsBody(rectangleOf: pillar.size )
        pillar.physicsBody?.isDynamic = false;
        pillar.physicsBody?.categoryBitMask = pillarBitMask
        pillar.physicsBody?.collisionBitMask = playerBitMask
        pillar.physicsBody?.contactTestBitMask = playerBitMask
        pillar.zPosition = ground.zPosition + 1
        pillar.physicsBody?.restitution = CGFloat(pillarRestitution)
        
        badPillar = SKSpriteNode(imageNamed: "badpillar1")
        badPillar.physicsBody = SKPhysicsBody(rectangleOf: badPillar.size)
        badPillar.physicsBody?.isDynamic = false;
        badPillar.physicsBody?.categoryBitMask = badPillarBitMask
        badPillar.physicsBody?.collisionBitMask = playerBitMask
        badPillar.physicsBody?.contactTestBitMask = playerBitMask
        badPillar.zPosition = ground.zPosition + 1
        
        pillar.zPosition = player.zPosition
        
        
        pillarAnimation = SKTextureAtlas(named: "pillars")
        pillarTextureArray = [SKTexture]()
        badpillarAnimation = SKTextureAtlas(named: "badpillars")
        badpillarTextureArray = [SKTexture]()
        
        for i in 1...pillarAnimation.textureNames.count{
            
            pillarTextureArray.append(SKTexture(imageNamed: "pillar\(i)"))
            badpillarTextureArray.append(SKTexture(imageNamed: "badpillar\(i)"))
            
        }
        
        
        pillar.texture = SKTexture(imageNamed: pillarAnimation.textureNames[0])
        pillar.run(SKAction.repeatForever(SKAction.animate(with: pillarTextureArray, timePerFrame: 0.6)))
        badPillar.texture = SKTexture(imageNamed: pillarAnimation.textureNames[0])
        badPillar.run(SKAction.repeatForever(SKAction.animate(with: badpillarTextureArray, timePerFrame: 0.6)))
        
        
        
        pillar.position = CGPoint(x: backgroundFrame.size.width, y: (ground.position.y + (pillar.size.height - 40)))
        
            
            
        
        
            
        // set pillar physics body
        
        badPillar.position = CGPoint(x: backgroundFrame.size.width - pillar.size.width, y: (pillar.position.y))

        
        
        let max = Double(UInt32.max)
        
        
        let spawnRate = ((Double(arc4random()) / max) + 0.4) * 0.5
        var upperBounds = 0.65
        var lowerBounds = 0.6
        
        
        
        
        if((spawnRate > lowerBounds && spawnRate < upperBounds)){
            if timerIsRunning == false && isPaused == false && canSpawn == true{
                pillarArray.insert(contentsOf: badPillarArray, at: 0)
                self.addChild(badPillar)
                canSpawn = false

                SKAction.run {
                    upperBounds += 0.05
                    lowerBounds -= 0.05
                    if upperBounds == 0.95 {
                        upperBounds = 0.95
                    }else if lowerBounds == 0.3 {
                        lowerBounds = 0.3
                    }
                }
                
            }else if isPaused == true{
                animArray.append(SKAction.stop())
            }
        } else if(!(spawnRate > upperBounds && spawnRate < lowerBounds)){
            if timerIsRunning == false && isPaused == false {
                self.addChild(pillar)
                canSpawn = true
                
            }
        }
        
        for i in 1...pillarAnimation.textureNames.count{
            
            pillarTextureArray.append(SKTexture(imageNamed: "pillar\(i)"))
            badpillarTextureArray.append(SKTexture(imageNamed: "badpillar\(i)"))
            
        }
        
        
        pillar.texture = SKTexture(imageNamed: pillarAnimation.textureNames[0])
        pillar.run(SKAction.repeatForever(SKAction.animate(with: pillarTextureArray, timePerFrame: 0.6)))
        badPillar.texture = SKTexture(imageNamed: pillarAnimation.textureNames[0])
        badPillar.run(SKAction.repeatForever(SKAction.animate(with: badpillarTextureArray, timePerFrame: 0.6)))
        
        let randomInterval = ((Double(arc4random()) / max) + 0.5) * 0.2
        
        
        if (score > 0 ){
            animArray.append(SKAction.wait(forDuration: TimeInterval(Double(randomInterval))))
        }

        animArray.append(SKAction.move(to: CGPoint(x: -self.frame.size.width, y: pillar.position.y), duration: Double(duration)))
        

        
        animArray.append(SKAction.removeFromParent())
        
        pillar.run(SKAction.sequence(animArray), completion: endGame)
        badPillar.run(SKAction.sequence(animArray))
        


        
        
        
    }
    
    func decrementDuration() {
        duration -= 0.2
        
    }

    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.isPaused == false{
            
            dropPlayer()
            tapNode.removeFromParent()
            getReadyLabel.run(SKAction.fadeOut(withDuration: 0.5), completion: getReadyLabel.removeFromParent)

        }
        
        
    }
    

    
    
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch = touches.first
        if let location = touch?.location(in: self){
            let nodeArray = self.nodes(at: location)
            if(nodeArray.first?.name == "pauseButton"){
                pauseGame()
            }
            if(nodeArray.first?.name == "resumeButton"){
                    resumeGame()
            }
            
            
        }
    
    }
    
    func runPlayerAnimation(){
        
        playerAnimation = SKTextureAtlas(named: "playerjiggle")
        playerTextureArray = [SKTexture]()
        
        for i in 1...playerAnimation.textureNames.count {
            
            playerTextureArray.append(SKTexture(imageNamed: "player\(i)"))
            
        }
        player.texture = SKTexture(imageNamed: playerAnimation.textureNames[0])
        
        player.run(SKAction.animate(with: playerTextureArray, timePerFrame: 0.2), completion: {
            
            self.player.texture = SKTexture(imageNamed: "player1")
        })

        
    }
    
    
    func fart(){
        
        
    
        
        
        if(swipeCounter < 4){
            
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2500))
            swipeCounter += 1
            
            run(flapSound)
            
            
            self.player.texture = SKTexture(imageNamed: "player1")
            


        }else if(swipeCounter == 4){
            
        }
    }
    


    
    
    func dropPlayer(){
        
        pillarRestitution -= 0.5
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -6000))
        player.texture = SKTexture(imageNamed: "player2")

        

    }
    
    func didBegin(_ contact: SKPhysicsContact){
        
        
        
        var firstBody : SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        
        if((firstBody.categoryBitMask & playerBitMask) != 0 && (secondBody.categoryBitMask & pillarBitMask) != 0){
            
            run(collisionSound)
            
            playerDidCollideWithPillar(player: firstBody.node as! SKSpriteNode, pillar: secondBody.node as! SKSpriteNode)
            score+=1
            swipeCounter = 0
            


            
        }else if ((firstBody.categoryBitMask & playerBitMask) != 0 && (secondBody.categoryBitMask & badPillarBitMask) != 0){
            
            playerDidCollideWithBadPillar(player: firstBody.node as! SKSpriteNode, badPillar: secondBody.node as! SKSpriteNode)
        }else if ((firstBody.categoryBitMask & playerBitMask) != 0 && (secondBody.categoryBitMask & frameCollisionBitMask) != 0){
            
            playerDidCollideWithBottomOfScreen(player: firstBody.node as! SKSpriteNode, frame: secondBody.node as! SKSpriteNode)
            
        }else {
            
        }

    }
    
    
    func playerDidCollideWithPillar(player: SKSpriteNode, pillar: SKSpriteNode){
        

        
        hasCollided = true
        player.texture = SKTexture(imageNamed: "player1")
        
        if score == 0 {
            pillarTimer.fire()
        }

        
        pillar.physicsBody?.collisionBitMask = 0
        pillar.physicsBody?.contactTestBitMask = 0
        pillar.physicsBody?.categoryBitMask = 0
        pillar.physicsBody = nil
        
        
        let xConstraint = SKConstraint.positionX(SKRange(constantValue: pillar.position.x))
        pillar.constraints = [xConstraint]
        
        
        pillar.run(SKAction.moveTo(y: -self.frame.size.height , duration: 0.6), completion: pillar.removeFromParent)
        
        
           }

    
    func playerDidCollideWithBadPillar(player: SKSpriteNode, badPillar: SKSpriteNode){
        endGame()
        
        
    }
    
    func playerDidCollideWithBottomOfScreen(player: SKSpriteNode, frame: SKSpriteNode){
        endGame()
    }
    
    func endGame(){
        

        
        let endGameScene = SKScene(fileNamed: "EndGameScene" ) as! EndGameScene
        endGameScene.score = score
        if (score > endGameScene.highestscore){
            
        endGameScene.saveHighscore()
            
        }
        endGameScene.scaleMode = .aspectFill
        

        

        //let transition = SKTransition.push(with: SKTransitionDirection.right, duration: 0.5)
        self.view?.presentScene(endGameScene)

        transitionNode = SKSpriteNode(color: UIColor.white, size: self.frame.size)
        transitionNode.zPosition = 6
        self.addChild(transitionNode)
        transitionNode.run(SKAction.fadeIn(withDuration: 0.3))
        run(gameOverSound)
        
        //pillarTimer.invalidate()
        durationTimer.invalidate()
        

        
            
        gameOver = true
            
        
    }
    
   
    
    func addBackground(){

        
        
        for i in 0...2 {
            
            
            background = SKSpriteNode(imageNamed: "background")
            background.name = "background"
            background.size = CGSize(width: self.frame.size.width, height: self.frame.size.height / 2)
            background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: backgroundFrame.size.height - (background.size.height + 170))
            background.zPosition = -1
            
            self.addChild(background)
            
            
            
            foreground = SKSpriteNode(imageNamed: "foreground")
            foreground.name = "foreground"
            foreground.size = CGSize(width: self.frame.size.width , height: self.frame.size.height)
            foreground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            foreground.position = CGPoint(x: CGFloat(i) * foreground.size.width, y: 0)
            foreground.zPosition = 0
            
            self.addChild(foreground)
            
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "ground"
            ground.size = CGSize(width: ground.size.width, height: ground.size.height)
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: foreground.position.y - (foreground.size.height / 2) + ground.size.height - 12)
            //ground.xScale *= -1
            ground.zPosition = 1
            
            self.addChild(ground)
            
            
            
            
            
            
        }
        
        
        
       
        
        
    }
    

    
    func moveScenery(){
        self.enumerateChildNodes(withName: "background", using: ({
            (node, error) in

            node.position.x -= 0.5
            
            if(node.position.x < -(self.frame.size.width)){
                node.position.x += self.frame.width * 2
                

            }
        
        }))
        
        self.enumerateChildNodes(withName: "foreground", using: ({
            (node, error) in
            
            node.position.x -= 1
            
            if(node.position.x < -(self.frame.size.width)){
                node.position.x += self.frame.width * 2
            }
            
        }))
        
        self.enumerateChildNodes(withName: "ground", using: ({
            (node, error) in
            
            node.position.x -= 3

            
            if(node.position.x < -(self.frame.size.width)){
                node.position.x += self.frame.width * 2
            }
            
        }))

    }
    
    
    deinit {
        
        self.removeAllChildren()
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if hasCollided {
            moveScenery()

        }

        
        let playerVelocity = player.physicsBody!.velocity.dy
        if playerVelocity < 0 {
            player.texture = SKTexture(imageNamed: "player2")
            
        }
        
        
    }
    
    
    
}


