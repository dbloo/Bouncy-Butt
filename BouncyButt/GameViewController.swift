//
//  GameViewController.swift
//  BouncyButt
//
//  Created by Dominic Bloomfield on 4/28/17.
//  Copyright © 2017 Dominic Bloomfield. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds
import GameKit

extension Notification.Name {
    static let showAd = Notification.Name("ShowAdNotification")
    static let showGC = Notification.Name("ShowGCView")
    static let addScore = Notification.Name("AddScore")
}

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {

    

    var interstitialAds : GADInterstitial!
    var gcEnabled = Bool()
    var gcDefaultLeaderBoard = String()
    
    let LEADERBOARD_ID = "LEAD330"
    @IBOutlet weak var myView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.view = SKView()
        
        authenticateLocalPlayer()
        
        
        
        if let view = self.view as! SKView! {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true


            
            
        }
        
        createAndLoadAd()
        NotificationCenter.default.addObserver(self, selector: #selector(showAds), name: .showAd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkGCLeaderboard), name: .showGC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addScoreAndSubmitToGC), name: .showGC, object: nil)
        
    }
    
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil {
                        
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                
            }
        }
    }
    
        func addScoreAndSubmitToGC() {
        let endGameScene = SKScene(fileNamed: "EndGameScene" ) as! EndGameScene
        let score = endGameScene.highestscore
        // Submit score to GC leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(score)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
    
    func checkGCLeaderboard() {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    
    
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    func createAndLoadAd(){
        
        let request = GADRequest()
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4253059033477148/5055440829")
        interstitial.delegate = self
        //request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitialAds = interstitial

        
    }
    
    func showAds(){
        
        if interstitialAds.isReady {
            
            interstitialAds.present(fromRootViewController: self)
            
        } else {
            print("adnotshown")
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
        createAndLoadAd()
        
    }
    
    
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
