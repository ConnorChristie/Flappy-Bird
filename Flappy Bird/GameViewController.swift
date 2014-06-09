//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by Connor Christie on 6/6/14.
//  Copyright (c) 2014 Connor Christie. All rights reserved.
//

import UIKit
import SpriteKit

import iAd

extension SKNode
{
    class func unarchiveFromFile(file : NSString) -> SKNode?
    {
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
        
        archiver.finishDecoding()
        
        return scene
    }
}

class GameViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        {
            // Configure the view.
            let skView = self.view as SKView
            
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            self.canDisplayBannerAds = true
            
            skView.presentScene(scene)
        }
    }

    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.toRaw())
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
