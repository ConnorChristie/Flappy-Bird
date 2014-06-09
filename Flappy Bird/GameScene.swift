//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Connor Christie on 6/6/14.
//  Copyright (c) 2014 Connor Christie. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var bird: SKShapeNode = SKShapeNode(circleOfRadius: 15)
    var overlay: SKSpriteNode = SKSpriteNode()
    
    var ground1: SKSpriteNode = SKSpriteNode()
    var ground2: SKSpriteNode = SKSpriteNode()
    
    var background1: SKSpriteNode = SKSpriteNode()
    var background2: SKSpriteNode = SKSpriteNode()
    
    var scoreLabel = SKLabelNode(fontNamed: "System-Bold")
    
    var mainPipe: Pipe = Pipe()
    var pipes: Pipe[] = []
    
    var score: Int = 0
    var space: Float = 90
    
    var prevNum: Float = 0
    var prevOffset: Float = 0
    
    var maxRange: Float = 150
    var minRange: Float = -100
    
    var maxOffset: Float = 300
    
    var pipeCategory: UInt32 = 1
    var birdCategory: UInt32 = 2
    
    var isMoving: Bool = false
    var groundMoving: Bool = true
    
    var movingSpeed: Float = 2.3
    var enableHits: Bool = true

    override func didMoveToView(view: SKView)
    {
        background1 = SKSpriteNode(imageNamed: "Background")
        background2 = SKSpriteNode(imageNamed: "Background")
        
        background1.zPosition = -10
        background2.zPosition = -10
        
        background1.position.x = view.bounds.size.width * 0.5
        background2.position.x = view.bounds.size.width * 1.5
        
        background1.position.y = view.bounds.size.height * 0.5
        background2.position.y = view.bounds.size.height * 0.5
        
        background1.texture.filteringMode = SKTextureFilteringMode.Nearest
        background2.texture.filteringMode = SKTextureFilteringMode.Nearest
        
        ground1 = SKSpriteNode(imageNamed: "Ground")
        ground2 = SKSpriteNode(imageNamed: "Ground")
        
        ground1.name = "Ground1"
        ground2.name = "Ground2"
        
        ground1.texture.filteringMode = SKTextureFilteringMode.Nearest
        ground2.texture.filteringMode = SKTextureFilteringMode.Nearest
        
        ground1.size.width = view.bounds.size.width + 2
        ground2.size.width = view.bounds.size.width + 2
        
        ground1.position.x = view.bounds.size.width * 0.5
        ground2.position.x = view.bounds.size.width * 1.5
        
        ground1.position.y = ground1.size.height * 0.4
        ground2.position.y = ground2.size.height * 0.4
        
        ground1.zPosition = 10
        ground2.zPosition = 10
        
        ground1.physicsBody = SKPhysicsBody(rectangleOfSize: ground1.size)
        ground2.physicsBody = SKPhysicsBody(rectangleOfSize: ground2.size)
        
        ground1.physicsBody.dynamic = false
        ground2.physicsBody.dynamic = false
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        bird.physicsBody.dynamic = false
        
        bird.zPosition = 9
        bird.lineWidth = 0
        
        bird.fillColor = UIColor.blackColor()
        bird.position  = CGPoint(x: 150, y: view.bounds.height / 2 - 10);
        
        scoreLabel.position.x = 13
        scoreLabel.position.y = view.bounds.height - 50
        
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        scoreLabel.hidden = true
        scoreLabel.zPosition = 12
        
        overlay = SKSpriteNode(color: UIColor.grayColor(), size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
        
        overlay.alpha = 0.7
        overlay.zPosition = 11
        
        overlay.position.x += overlay.size.width / 2
        overlay.position.y += overlay.size.height / 2
        
        mainPipe = Pipe(color: UIColor.blackColor(), size: CGSize(width: view.bounds.size.width / 6, height: 480))
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        self.addChild(background1)
        self.addChild(background2)
        
        self.addChild(ground1)
        self.addChild(ground2)
        
        self.addChild(bird)
        self.addChild(scoreLabel)
    }
    
    func spawnPipeRow(offs: Float)
    {
        let offset = offs - (space / 2)
        
        let pBot = (mainPipe as Pipe).copy() as Pipe
        let pTop = (mainPipe as Pipe).copy() as Pipe
        
        pBot.isBottom = true
        
        pBot.texture = SKTexture(imageNamed: "Pipe")
        pTop.texture = SKTexture(imageNamed: "UPipe")
        
        pBot.texture.filteringMode = SKTextureFilteringMode.Nearest
        pTop.texture.filteringMode = SKTextureFilteringMode.Nearest
        
        let xx = view.bounds.size.width
        
        self.setPositionRelativeBot(pBot, x: xx, y: offset)
        self.setPositionRelativeTop(pTop, x: xx, y: offset + space)
        
        pBot.physicsBody = SKPhysicsBody(rectangleOfSize: pBot.size)
        pTop.physicsBody = SKPhysicsBody(rectangleOfSize: pTop.size)
        
        pBot.physicsBody.dynamic = false
        pTop.physicsBody.dynamic = false
        
        if (enableHits)
        {
            pBot.physicsBody.contactTestBitMask = birdCategory
            pTop.physicsBody.contactTestBitMask = birdCategory
            
            pBot.physicsBody.collisionBitMask   = birdCategory
            pTop.physicsBody.collisionBitMask   = birdCategory
        }
        
        pipes.append(pBot)
        pipes.append(pTop)
        
        self.addChild(pBot)
        self.addChild(pTop)
    }
    
    func randomOffset() -> Float
    {
        var rNum: Float  = Float(arc4random() % 31) + 40
        var rNum1: Float = Float(arc4random() % 31) + 1
        
        if (rNum1 % 2 == 0)
        {
            rNum = prevNum + rNum
            
            if (rNum > maxRange)
            {
                rNum = maxRange - (Float(arc4random() % 31) + 25)
            }
        } else
        {
            rNum = prevNum - rNum
            
            if (rNum < minRange)
            {
                rNum = minRange + (Float(arc4random() % 31) + 25)
            }
        }
        
        prevNum = rNum
        
        return rNum
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        /* Called when a touch begins */
        
        if (!bird.physicsBody.dynamic)
        {
            //First touch
            
            self.spawnPipeRow(self.randomOffset())
            
            bird.physicsBody.dynamic = true
            
            if (enableHits)
            {
                bird.physicsBody.contactTestBitMask = pipeCategory
                bird.physicsBody.collisionBitMask   = pipeCategory
            }
            
            bird.physicsBody.velocity = CGVectorMake(0, 175)
            
            isMoving = true
            groundMoving = true
            
            scoreLabel.hidden = false
        } else if (isMoving)
        {
            var vel: Float = 200
            
            if (self.view.bounds.size.height - bird.position.y < 85)
            {
                vel -= 85 - (self.view.bounds.size.height - bird.position.y)
            }
            
            bird.physicsBody.velocity = CGVectorMake(0, vel)
        } else
        {
            overlay.removeFromParent()
            
            for pi in pipes
            {
                pi.removeFromParent()
            }
            
            pipes.removeAll(keepCapacity: false)
            
            score = 0
            
            bird.physicsBody.dynamic = false
            bird.position = CGPoint(x: 150, y: view.bounds.height / 2 - 10);
            
            scoreLabel.hidden = true
            
            groundMoving = true
        }
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        
        if (groundMoving)
        {
            ground1.position.x -= movingSpeed
            ground2.position.x -= movingSpeed
            
            if (ground1.position.x <= -self.view.bounds.size.width / 2)
            {
                ground1.position.x = self.view.bounds.size.width * 1.5 - 2
            }
            
            if (ground2.position.x <= -self.view.bounds.size.width / 2)
            {
                ground2.position.x = self.view.bounds.size.width * 1.5 - 2
            }
            
            background1.position.x -= movingSpeed / 3
            background2.position.x -= movingSpeed / 3
            
            if (background1.position.x <= -self.view.bounds.size.width / 2)
            {
                background1.position.x = self.view.bounds.size.width * 1.5 - 2
            }
            
            if (background2.position.x <= -self.view.bounds.size.width / 2)
            {
                background2.position.x = self.view.bounds.size.width * 1.5 - 2
            }
            
            if (isMoving)
            {
                for (var p = 0; p < pipes.count; p++)
                {
                    let pi = pipes[p]
                    
                    if (pi.position.x + (pi.size.width / 2) < 0)
                    {
                        pipes.removeAtIndex(p)
                        
                        pi.removeFromParent()
                        
                        continue
                    }
                    
                    if (pi.position.x + (pi.size.width / 2) < self.view.bounds.size.width / 2 && pi.isBottom && !pi.pointAdded)
                    {
                        score++
                        
                        pi.pointAdded = true
                    }
                    
                    pi.position.x -= movingSpeed
                    
                    if (p == pipes.count - 1)
                    {
                        if (pi.position.x < self.view.bounds.width - pi.size.width * 2.0)
                        {
                            self.spawnPipeRow(self.randomOffset())
                        }
                    }
                }
                
                scoreLabel.text = "Score: \(score)"
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact!)
    {
        if (isMoving)
        {
            isMoving = false
            groundMoving = false
            
            bird.physicsBody.velocity = CGVectorMake(0, 0)
            
            for pi in pipes
            {
                pi.physicsBody = nil
            }
            
            self.addChild(overlay)
        } else
        {
            bird.physicsBody.velocity = CGVectorMake(0, 0)
        }
    }
    
    func setPositionRelativeBot(node: SKSpriteNode, x: Float, y: Float)
    {
        let xx = (Float(node.size.width) / 2) + x
        let yy = Float(self.view.bounds.size.height) / 2 - (Float(node.size.height) / 2) + y
        
        node.position.x = CGFloat(xx)
        node.position.y = CGFloat(yy)
    }
    
    func setPositionRelativeTop(node: SKSpriteNode, x: Float, y: Float)
    {
        let xx = (Float(node.size.width) / 2) + x
        let yy = Float(self.view.bounds.size.height) / 2 + (Float(node.size.height) / 2) + y
        
        node.position.x = CGFloat(xx)
        node.position.y = CGFloat(yy)
    }
    
    class Pipe: SKSpriteNode
    {
        var isBottom: Bool = false
        
        var pointAdded: Bool = false
    }
}
