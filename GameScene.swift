//
//  GameScene.swift
//  JumpMan
//
//  Created by Arthur Zhang on 1/24/17.
//  Copyright © 2017 Arthur Zhang. All rights reserved.
//

import SpriteKit
import GameplayKit

//#7
let BlockSize: CGFloat = 20.0

extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}

extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}

// #1
let TickLengthLevelOne = TimeInterval(600)

class GameScene: SKScene {
    
    //#8
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let layerPosition = CGPoint(x: 6, y: -6)
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var textureCache = Dictionary<String, SKTexture>()
    
    //#2
    var tick:(() -> ())?
    
    var TickLengthMillis = TickLengthLevelOne
    
    var lastTick : NSDate?
    
    
    required init(coder aDecoder: NSCoder){
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize){
        
        super.init(size: size)
        
        anchorPoint=CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        
        background.position = CGPoint(x: 0, y: 1.0)
        
        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        
        gameBoard.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        gameBoard.position = layerPosition
        
        shapeLayer.position = layerPosition
        
        shapeLayer.addChild(gameBoard)
        
        gameLayer.addChild(shapeLayer)
        
        //#8
        run(SKAction.repeatForever(SKAction.playSoundFileNamed("Sounds/theme.mp3", waitForCompletion: true)))
        
    }
    //#9
    func playSound(sound: String){
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        if let label = self.label {
    //            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
    //        }
    //
    //        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    //    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //#3
        guard let lastTick = lastTick else{
            return;
        }
        
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        
        if timePassed > TickLengthMillis {
            self.lastTick=NSDate()
            
            tick?()
        }
    }
    //#4
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick=nil
    }
    
    //#9
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = layerPosition.x + (CGFloat(column) * BlockSize)  + (BlockSize/2)
        let y = layerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize/2))
        
        return CGPoint(x,y)
    }
    //#10
    func addPreviewShapeToScene(shape: Shape, completion:@escaping () -> ()) {
        for block in shape.blocks{
            
            var texture = textureCache[block.spriteName]
            
            if texture == nil{
                texture = SKTexture(imageNamed: block.spriteName)
                
                textureCache[block.spriteName] = texture
            }
            
            let sprite = SKSpriteNode(texture: texture)
            
            //#11
            
            sprite.position = pointForColumn(column: block.column, row: block.row-2)
            shapeLayer.addChild(sprite)
            
            block.sprite = sprite
            
            //Animation
            
            sprite.alpha = 0
            
            //#12
            let moveAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: TimeInterval(0.2))
            
            moveAction.timingMode = .easeOut
            
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            
            fadeInAction.timingMode = .easeOut
            
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        
        run(SKAction.wait(forDuration: 0.4), completion: completion)
        
    }
    
    func movePreviewShape(shape: Shape, completion:@escaping () -> ()){
        for block in shape.blocks {
            let sprite = block.sprite!
            
            let moveTo = pointForColumn(column: block.column, row: block.row)
            
            let moveToAction: SKAction = SKAction.move(to: moveTo, duration: 0.2)
            
            moveToAction.timingMode = .easeOut
            
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion:{}
                
            )
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
        
    }
    
    func redrawShape (shape: Shape, completion: @escaping () -> ()){
        for block in shape.blocks{
            
            let sprite = block.sprite!
            
            let moveTo = pointForColumn(column: block.column, row: block.row)
            
            let moveToAction: SKAction = SKAction.move(to: moveTo, duration: 0.05)
            
            moveToAction.timingMode = .easeOut
            
            if block == shape.blocks.last {
                sprite.run( moveToAction, completion: completion)
            }else{
                sprite.run(moveToAction)
            }
        }
        
    }
    
    //#1
    
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:@escaping () -> () ){
        var longestDuration: TimeInterval = 0
        
        //#2
        for (columnIdx, column) in fallenBlocks.enumerated() {
            for (blockIdx, block) in column.enumerated(){
                let newPosition =  pointForColumn(column: block.column, row: block.row)
                
                let sprite = block.sprite!
                
                //#3
                
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1 )
                
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                
                moveAction.timingMode = .easeOut
                
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay), moveAction
                        ])
                )
                longestDuration = max(longestDuration, duration + delay)
            }
            
        }
        for rowToRemove in linesToRemove{
            for block in rowToRemove{
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                
                var point = pointForColumn(column: block.column, row: block.row)
                point = CGPoint(point.x + (goLeft ? -randomRadius : randomRadius), point.y)
                
                let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
                
                //#5
                
                var startAngle = CGFloat(M_PI)
                
                var endAngle = startAngle * 2
                
                if goLeft{
                    endAngle = startAngle
                    
                    startAngle = 0
                }
                
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                
                let archAction = SKAction.follow( archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
                
                archAction.timingMode = .easeOut
                
                let sprite = block.sprite!
                
                //#6
                
                sprite.zPosition = 100
                
                sprite.run(
                    SKAction.sequence(
                        [SKAction.group([archAction, SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]),
                         SKAction.removeFromParent()]
                    )
                )
            }
        }
        //#7
        
        run(SKAction.wait(forDuration: longestDuration), completion:completion)
        
    }
    
}















