//
//  GameScene.swift
//  BlockJumper
//
//  Created by Chad on 7/4/16.
//  Copyright (c) 2016 Chad Williams. All rights reserved.
//

import SpriteKit

enum Physics {
  static let Character: UInt32 = 0b1 // 1
  static let Floor    : UInt32 = 0b10 // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  // characters
  let floor = SKSpriteNode(imageNamed: "blue")
  let player = SKSpriteNode(imageNamed: "orange")
  var enemies = [SKSpriteNode]()
  
  // timers
  var lastTime = 0
  var currentTime = 0
  var randomValue = 0
  
  
  
  
  override func update(delta: CFTimeInterval) {
    // loop all enemies and make them walk to collide with player
    for enemy in enemies {
      enemy.position = CGPoint(x: Double(enemy.position.x) - 5, y: Double(enemy.position.y))
    }
    
    currentTime = Int(delta)
    randomValue = randomizer()


    if (lastTime == 0) {
      lastTime = currentTime
    }
    
    if (currentTime > (lastTime + randomValue)) {
      lastTime = currentTime
      spawnEnemy()
    }
    
    /*
    if (lastTime == 0) {
      lastTime = currentTime
    }
    
    if (currentTime > (lastTime + randomValue)) {
      lastTime = currentTime
      spawnEnemy()
    }
    

    /*
    if (currentTime > (lastTime + 1)) {
      lastTime = currentTime
      spawnEnemy()
    }
 */
 */
    
    
    
  }
  
  func randomizer(range: Range<Int> = 2...5) -> Int {
    let min = range.startIndex
    let max = range.endIndex
    return Int(arc4random_uniform(UInt32(max - min))) + min
  }
  
  
  
  func spawnEnemy() {
    // create the red square sprite node
    let enemy = SKSpriteNode(imageNamed: "red")
    
    // define name of node
    enemy.name = "enemy"
    
    // define size equal to player
    enemy.size = CGSize(width: 50, height: 50)
    
    // define the position to be off-screen
    enemy.position = CGPoint(x: CGRectGetMidX(self.frame) + 350, y: CGRectGetMidY(self.frame) - 20)
    
    // created physics body with the size of the player
    enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
    
    // affected by gravity
    enemy.physicsBody?.affectedByGravity = true
    
    // make it collide with floor and player
    enemy.physicsBody?.categoryBitMask = Physics.Character
    enemy.physicsBody?.collisionBitMask = Physics.Character
    
    // notify when the enemy collides
    enemy.physicsBody?.contactTestBitMask = Physics.Character
    
    // add enemy to the scene
    addChild(enemy)
    
    // store the enemy to use later
    enemies.append(enemy)
  }
  
  
  
  override func didMoveToView(view: SKView) {
      // tell the physics world that the class that implements the SKPhysicsContactDelegate is the GameScene
      physicsWorld.contactDelegate = self
    
      setupFloor()
      setupPlayer()
    }
  
  // this method is called when user touches screen
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    /*
    if (player.position.y == 0.0) {
      player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 70.0))
    }
 */
    
    // we apply an impulse to the axis Y of 70 to make jump straight up
    player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 70.0))
  }
  
  func setupFloor() {
    // define name to the node
    floor.name = "floor"
    
    // size is represented by the CGSize
    // we are getting the size (CGSize) from the scene, it will fill 1/3 of screen
    floor.size = CGSize(width: self.size.width * 3, height: self.size.height/3)
    
    // putting floor in base of the screen
    floor.position = CGPoint(x: CGRectGetMinX(self.frame) + (floor.size.width / 2),
                             y: CGRectGetMinY(self.frame) + (floor.size.height/2))
    
    // created physics body with the size of the floor
    floor.physicsBody = SKPhysicsBody(rectangleOfSize: floor.size)
    
    // do not allow floor to move
    floor.physicsBody?.affectedByGravity = false
    
    // make floor collide with player
    floor.physicsBody?.categoryBitMask = Physics.Character
    floor.physicsBody?.collisionBitMask = Physics.Floor
    
    // notify when the floor collides
    floor.physicsBody?.contactTestBitMask = Physics.Floor
    
    // create Jump label
    let jumpLabel = SKLabelNode(fontNamed: "Arial")
    jumpLabel.text = "Jump!"
    jumpLabel.fontSize = 80
    jumpLabel.fontColor = SKColor.blackColor()
    jumpLabel.position = CGPoint(x: size.width/2, y: size.height/4)
    //jumpLabel.position = CGPoint(x: CGRectGetMinX(self.frame) + (floor.size.width / 2), y: CGRectGetMinY(self.frame) + (floor.size.height/2))


    addChild(jumpLabel)
    
    // add the floor to the scene in order to appear on screen
    addChild(floor)
  }
  
  func setupPlayer() {
    // define name to the node
    player.name = "player"
    
    // we want a fixed size
    player.size = CGSize(width: 50, height: 50)
    
    // put it in the half of screen - some space + half of player width
    player.position = CGPoint(x: CGRectGetMidX(self.frame) - 180 + 25, y: CGRectGetMidY(self.frame))
    
    // create a physics body with the size of the player
    player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
    
    // have player affected by gravity
    player.physicsBody?.affectedByGravity = true
    
    // make player collide with floor
    player.physicsBody?.categoryBitMask = Physics.Character
    player.physicsBody?.collisionBitMask = Physics.Character
    
    // notify when player collides
    player.physicsBody?.contactTestBitMask = Physics.Character
    
    // add the player to the scene in order to appear on screen
    addChild(player)
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    if (contact.bodyA.node!.name == "player" && contact.bodyB.node!.name == "enemy") {
      gameOver()
    }
  }
  
  func gameOver() {
    player.removeFromParent()
    for enemy in enemies {
      enemy.removeFromParent()
    }
    
    // transition effect that seems like doors opening
    let reveal = SKTransition.doorsOpenHorizontalWithDuration(0.5)
    
    // create the scene
    let gameOverScene = GameOverScene(size: self.size)
    
    // present the game over scene with the transition
    self.view?.presentScene(gameOverScene, transition: reveal)
    
  }
  
  
  

}
 

