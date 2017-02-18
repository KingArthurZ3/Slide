//
//  GameViewController.swift
//  JumpMan
//
//  Created by Arthur Zhang on 1/24/17.
//  Copyright © 2017 Arthur Zhang. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SwiftirisDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    
    var swiftiris: Swiftiris!
    
    //#1
    
    var panPointReference:CGPoint?
    
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure the view
        
        let skView = view as! SKView
        
        skView.isMultipleTouchEnabled = false
        
        //Create and configure the scene
        
        scene = GameScene(size: skView.bounds.size)
        
        scene.scaleMode = .aspectFill
        
        //#13
        
        scene.tick = didTick
        
        swiftiris = Swiftiris()
        
        swiftiris.delegate = self
        
        swiftiris.beginGame()
        
        //Present the scene
        
        skView.presentScene(scene)
        //#14
        //        scene.addPreviewShapeToScene(shape: swiftiris.nextShape!){
        //            self.swiftiris.nextShape?.moveTo(column: startingColumn, row: startingRow)
        //
        //            self.scene.movePreviewShape(shape: self.swiftiris.nextShape!) {
        //                let nextShapes = self.swiftiris.newShape()
        //
        //                self.scene.startTicking()
        //
        //                self.scene.addPreviewShapeToScene(shape: nextShapes.nextShape!){}
        //            }
        //        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
        
    }
    

    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        swiftiris.rotateShape()
    }

    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        //#2
        let currentPoint = sender.translation(in: self.view)
        
        if let originalPoint = panPointReference{
            //#3
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9){
                //#4
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    swiftiris.moveShapeRight()
                    panPointReference = currentPoint
                }else if sender.velocity(in: self.view).x < CGFloat(0){
                    swiftiris.moveShapeLeft()
                    panPointReference = currentPoint
                }
                
            } else if abs(currentPoint.y - originalPoint.y) > (BlockSize * 0.9){
                if sender.velocity(in: self.view).y > CGFloat(0){
                    swiftiris.moveShapeDown()
                    panPointReference = currentPoint

                }
            }
            
        }else if sender.state == .began{
            panPointReference = currentPoint
        }

    }
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        swiftiris.dropShape()
    }

    //#5
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //#6
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer{
            if otherGestureRecognizer is UIPanGestureRecognizer{
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer{
            if otherGestureRecognizer is UITapGestureRecognizer{
                return true
            }
        }
        return false
    }
    
    func didTick(){
        //#15
        swiftiris.letShapeFall()
        //        swiftiris.fallingShape?.lowerShapeByOneRow()
        //
        //        scene.redrawShape(shape: swiftiris.fallingShape!, completion: {})
    }
    func nextShape() {
        let newShapes = swiftiris.newShape()
        
        guard let fallingShape = newShapes.fallingShape else{
            return
            
        }
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!){}
        self.scene.movePreviewShape(shape: fallingShape){
            
            //#16
            
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    func gameDidBegin(swiftiris: Swiftiris) {
        
        levelLabel.text = "\(swiftiris.level)"
        
        scoreLabel.text = "\(swiftiris.score)"
        
        scene.TickLengthMillis = TickLengthLevelOne
        
        
        // the following is false when starting a new game
        if swiftiris.nextShape != nil && swiftiris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: swiftiris.nextShape!){
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftiris: Swiftiris){
        view.isUserInteractionEnabled = false
        scene.stopTicking()
        
        scene.playSound(sound: "Sounds/gameover.mp3")
        
        scene.animateCollapsingLines(linesToRemove: swiftiris.removeAllBlocks(), fallenBlocks: swiftiris.removeAllBlocks()){
            swiftiris.beginGame()
        }
    }
    
    func gameDidLevelUp(swiftiris: Swiftiris){
        levelLabel.text = "\(swiftiris.level)"
        
        if scene.TickLengthMillis >= 100{
            scene.TickLengthMillis -= 100
        } else if scene.TickLengthMillis > 50 {
            scene.TickLengthMillis -= 50
        }
        scene.playSound(sound: "Sounds/levelup.mp3")
    }
    
    
    func gameShapeDidDrop(swiftiris: Swiftiris) {
        scene.stopTicking()
        
        scene.redrawShape(shape: swiftiris.fallingShape!){
            swiftiris.letShapeFall()
        }
        scene.playSound(sound: "Sounds/drop.mp3")
    }
    func gameDidDrop(swiftiris: Swiftiris){
        //#7
        scene.stopTicking()
        scene.redrawShape(shape: swiftiris.fallingShape!){
            swiftiris.letShapeFall()
        }
    }
    func gameShapeDidLand(swiftiris: Swiftiris){
        scene.stopTicking()
        self.view.isUserInteractionEnabled = false
        
        //#10
        
        let removedLines = swiftiris.removeCompletedLines()
        
        if removedLines.linesRemoved.count > 0{
            self.scoreLabel.text = "\(swiftiris.score)"
            
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks){
                //#11
                self.gameShapeDidLand(swiftiris: swiftiris)
            }
            scene.playSound(sound: "Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    //#17
    func gameShapeDidMove(swiftiris: Swiftiris){
        scene.redrawShape(shape: swiftiris.fallingShape! ){}
    }
    
}
