//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/30/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import AVFoundation
var endCount:Int = 0
var backgroundMusicPlayer: AVAudioPlayer!
//var backgroundColor:!
func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gplayer:CGPoint!
    var shoot:CGPoint!
    var shoot2:CGPoint!
    var shoot3:CGPoint!
    var shoot4:CGPoint!
    var shoot5:CGPoint!
    var shoots:CGPoint!
    var players:CGPoint!
    
    let player = SKSpriteNode(imageNamed: "player")
    let player2 = SKSpriteNode(imageNamed: "player")
    let player3 = SKSpriteNode(imageNamed: "player")
    let player4 = SKSpriteNode(imageNamed: "player")
    let player5 = SKSpriteNode(imageNamed: "player")
    var monstersDestroyed = 0
    
    override func didMoveToView(view: SKView) {
        
        playBackgroundMusic("background-music-aac.caf")
        
        backgroundColor = SKColor.whiteColor()
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        players = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        shoot = CGPoint(x: size.height * 20, y: size.height * 0.5)
        shoots = CGPoint(x: size.height * 20, y: size.height * 0.5)
        println(player.position)
        println(shoot)
        
        addChild(player)
        player2.position = CGPoint(x: size.width * 0.1, y: players.y + 50)
        shoot2 = CGPoint(x: size.height * 20, y: shoots.y + 50)
        
        addChild(player2)
        player3.position = CGPoint(x: size.width * 0.1, y: players.y + 100)
        
        shoot3 = CGPoint(x: size.height * 20, y: shoots.y + 100)
        addChild(player3)
        player4.position = CGPoint(x: size.width * 0.1, y: players.y - 50)
        shoot4 = CGPoint(x: size.height * 20, y: shoots.y - 50)
        addChild(player4)
        
        player5.position = CGPoint(x: size.width * 0.1, y: players.y - 100)
        shoot5 = CGPoint(x: size.height * 20, y: shoots.y - 100)
        addChild(player5)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        addMonster()
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(0.5)
                ])
            ))
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        println(gplayer)
        if gplayer==nil
        {
            
        }
        else
        {
            // Create sprite
            let monster = SKSpriteNode(imageNamed: "monster")
            monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
            monster.physicsBody?.dynamic = true
            monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
            monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
            monster.physicsBody?.collisionBitMask = PhysicsCategory.None
            
            // Determine where to spawn the monster along the Y axis
            let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
            
            // Position the monster slightly off-screen along the right edge,
            // and along a random position along the Y axis as calculated above
            monster.position = CGPoint(x: size.width + monster.size.width/2, y: gplayer.y)
            
            // Add the monster to the scene
            addChild(monster)
            
            // Determine speed of the monster
            let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
            
            // Create the actions
            let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
           
                let loseAction = SKAction.runBlock() {
                    
                    endCount = endCount + 1
                    println(endCount)
                    if endCount == 5
                    {
                        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                        let gameOverScene = GameOverScene(size: self.size, won: false)
                        self.view?.presentScene(gameOverScene, transition: reveal)
                    }
                    
                    
                    
                    
                                   }
                monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
                
            }
            
           
        
        
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        
        
        let touchLocation = touch.locationInNode(self)
        
        //
        //player1
        if(player .containsPoint(touchLocation))
        {
            gplayer = touchLocation
            println("done")
            // 2 - Set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = player.position
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            // 3 - Determine offset of location to projectile
            let offset = shoot //touchLocation - projectile.position
            
            // 4 - Bail out if you are shooting down or backwards
            if (offset.x < 0) { return }
            
            // 5 - OK to add now - you've double checked position
            addChild(projectile)
            
            // 6 - Get the direction of where to shoot
            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // 9 - Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
        
        //player2
        
        if(player2 .containsPoint(touchLocation))
        {
            println("done")
            gplayer = touchLocation
            // 2 - Set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = player2.position
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            // 3 - Determine offset of location to projectile
            let offset = shoot //touchLocation - projectile.position
            
            // 4 - Bail out if you are shooting down or backwards
            if (offset.x < 0) { return }
            
            // 5 - OK to add now - you've double checked position
            addChild(projectile)
            
            // 6 - Get the direction of where to shoot
            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // 9 - Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
        
        //player3
        if(player3 .containsPoint(touchLocation))
        {
            println("done")
            gplayer = touchLocation
            // 2 - Set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = player3.position
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            // 3 - Determine offset of location to projectile
            let offset = shoot //touchLocation - projectile.position
            
            // 4 - Bail out if you are shooting down or backwards
            if (offset.x < 0) { return }
            
            // 5 - OK to add now - you've double checked position
            addChild(projectile)
            
            // 6 - Get the direction of where to shoot
            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // 9 - Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
        //player4
        if(player4 .containsPoint(touchLocation))
        {
            println("done")
            gplayer = touchLocation
            // 2 - Set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = player4.position
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            // 3 - Determine offset of location to projectile
            let offset = shoot //touchLocation - projectile.position
            
            // 4 - Bail out if you are shooting down or backwards
            if (offset.x < 0) { return }
            
            // 5 - OK to add now - you've double checked position
            addChild(projectile)
            
            // 6 - Get the direction of where to shoot
            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // 9 - Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
        //player5
        if(player5 .containsPoint(touchLocation))
        {
            println("done")
            gplayer = touchLocation
            // 2 - Set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = player5.position
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            // 3 - Determine offset of location to projectile
            let offset = shoot //touchLocation - projectile.position
            
            // 4 - Bail out if you are shooting down or backwards
            if (offset.x < 0) { return }
            
            // 5 - OK to add now - you've double checked position
            addChild(projectile)
            
            // 6 - Get the direction of where to shoot
            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // 9 - Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        println("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed++
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.1)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as SKSpriteNode, monster: secondBody.node as SKSpriteNode)
        }
        
    }
    
}
