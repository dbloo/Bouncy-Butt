//
//  EndGameScene.swift
//  BouncyButt
//
//  Created by Dominic Bloomfield on 5/3/17.
//  Copyright © 2017 Dominic Bloomfield. All rights reserved.
//

import SpriteKit
import GoogleMobileAds

class EndGameScene: SKScene{
    
    var gameOverLabel: SKSpriteNode!
    var restartGameButton: SKSpriteNode!
    var menuButton: SKSpriteNode!
    
    var background: SKSpriteNode!
    var foreground: SKSpriteNode!
    var backgroundFrame: SKSpriteNode!
    var transitionNode: SKSpriteNode!

    
    var scoreLabel: SKLabelNode!
    var score : Int = 0
    var highscoreLabel: SKLabelNode!
    var highestscore = UserDefaults().integer(forKey: "HIGHSCORE") {
        willSet {
            highscoreLabel.text = "High Score: \(highestscore)"
        }
    }

    
    let gameScene = SKScene(fileNamed: "GameScene") as! GameScene



    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFill
        self.run(SKAction.playSoundFileNamed("endGameMusic", waitForCompletion: true))

        
        let max = Double(UInt32.max)
        let adPostRate = ((Double(arc4random()) / max) + 0.4) * 0.5
        
        if adPostRate > 0.55 && adPostRate < 0.65 {
        
            NotificationCenter.default.post(name: .showAd, object: nil)
        }

        

        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "Score: \(score)"
        
        highscoreLabel = self.childNode(withName: "highscoreLabel") as! SKLabelNode
        
        if score > highestscore{
            
            saveHighscore()
            NotificationCenter.default.post(name: .addScore, object: nil)


            
        }
        highscoreLabel.text = "High Score : \(highestscore)"

    
        gameOverLabel = self.childNode(withName: "gameOverLabel") as! SKSpriteNode
        
        restartGameButton = self.childNode(withName: "replayButton") as! SKSpriteNode
        
        menuButton = self.childNode(withName: "menuButton") as! SKSpriteNode
        
        

        backgroundFrame = self.childNode(withName: "frame") as! SKSpriteNode
        

        addBackground()
        
        
        transitionNode = SKSpriteNode(color: UIColor.white, size: self.frame.size)
        transitionNode.zPosition = 6
        self.addChild(transitionNode)
        transitionNode.run(SKAction.fadeOut(withDuration: 0.3))
    }
    
    func saveHighscore(){
        //highscoreLabel.text = "High Score : \(highestscore)"
        let viewController = GameViewController()
        viewController.addScoreAndSubmitToGC()
        let userDefaults = UserDefaults.standard
        userDefaults.set(score, forKey: "HIGHSCORE")
        userDefaults.synchronize()
        

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodeArray = self.nodes(at: location)
            
            if nodeArray.first?.name == "replayButton" {
                
                
                
                transitionNode = SKSpriteNode(color: UIColor.white, size: self.frame.size)
                transitionNode.zPosition = 6
                self.addChild(transitionNode)
                transitionNode.run(SKAction.fadeIn(withDuration: 0.3))
                gameScene.scaleMode = .aspectFill
                
                self.view?.presentScene(gameScene)

                
            }
            if nodeArray.first?.name == "menuButton"{
                
                let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene
                
                transitionNode = SKSpriteNode(color: UIColor.white, size: self.frame.size)
                transitionNode.zPosition = 6
                self.addChild(transitionNode)
                transitionNode.run(SKAction.fadeIn(withDuration: 0.3))
                
                menuScene.scaleMode = .aspectFill
                
                self.view?.presentScene(menuScene)
                
                
            }
            if(nodeArray.first?.name == "rateButton"){
                rateApp(appId: "id1258027784", completion: { success in
                    print("RateApp \(success)")
                })
                
                
            }
            
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    func addBackground(){
        
        
        
        for i in 0...2 {
            
            
            background = SKSpriteNode(imageNamed: "background")
            background.name = "background"
            background.size = CGSize(width: self.frame.size.width, height: self.frame.size.height / 2)
            background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: backgroundFrame.size.height - (background.size.height + 170))
            background.zPosition = 0
            
            self.addChild(background)
            
            
            
            foreground = SKSpriteNode(imageNamed: "foreground")
            foreground.name = "foreground"
            foreground.size = CGSize(width: self.frame.size.width , height: self.frame.size.height)
            foreground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            foreground.position = CGPoint(x: CGFloat(i) * foreground.size.width, y: 0)
            foreground.zPosition = 1
            
            self.addChild(foreground)
            
            
            
            
            
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
            
            node.position.x -= 2
            
            if(node.position.x < -(self.frame.size.width)){
                node.position.x += self.frame.width * 2
            }
            
        }))
        
        self.enumerateChildNodes(withName: "ground", using: ({
            (node, error) in
            
            node.position.x -= 1
            
            
            if(node.position.x < -(self.frame.size.width)){
                node.position.x += self.frame.width * 2
            }
            
        }))
        
    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveScenery()
        
        
        
        
    }

    
    deinit {
         self.removeAllChildren()
    }
}
