//
//  MenuScene.swift
//  BouncyButt
//
//  Created by Dominic Bloomfield on 4/30/17.
//  Copyright © 2017 Dominic Bloomfield. All rights reserved.
//

import SpriteKit
import GameKit

class MenuScene: SKScene {
    
   // var newGameButtonDepressedNode: SKSpriteNode!
    var newGameButtonNode: SKSpriteNode!
    var leaderBoardButton: SKSpriteNode!
    var background: SKSpriteNode!
    var backgroundframe: SKSpriteNode!
    var transitionNode: SKSpriteNode!
    var foreground: SKSpriteNode!
    let LEADERBOARD_ID = "com.score.bouncybutt"

    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        
        newGameButtonNode = self.childNode(withName: "startGameButton") as! SKSpriteNode
        backgroundframe = self.childNode(withName: "frame") as! SKSpriteNode
        leaderBoardButton = self.childNode(withName: "leaderBoardButton") as! SKSpriteNode

        

        addBackground()
        
        transitionNode = SKSpriteNode(color: UIColor.white, size: self.frame.size)
        transitionNode.zPosition = 4
        self.addChild(transitionNode)
        transitionNode.run(SKAction.fadeOut(withDuration: 0.3))
        

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodeArray = self.nodes(at: location)
            
            if(nodeArray.first?.name == "startGameButton"){
                //newGameButtonNode.removeFromParent()
                
                let gameScene = SKScene(fileNamed: "GameScene") as! GameScene
                
                transitionNode = SKSpriteNode(color: UIColor.white, size: self.frame.size)
                transitionNode.zPosition = 6
                self.addChild(transitionNode)
                transitionNode.run(SKAction.fadeIn(withDuration: 0.3))
                gameScene.scaleMode = .aspectFill
                
                self.view?.presentScene(gameScene)
                
                
            }
            if(nodeArray.first?.name == "rateButton"){
                rateApp(appId: "id1258027784", completion: { success in
                    print("RateApp \(success)")
                })
                
            
            }
            if(nodeArray.first?.name == "leaderBoardButton"){
                NotificationCenter.default.post(name: .showGC, object: nil)

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
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: backgroundframe.size.height - (background.size.height + 170))
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


