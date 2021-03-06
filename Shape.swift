//
//  Shape.swift
//  JumpMan
//
//  Created by Arthur Zhang on 1/27/17.
//  Copyright © 2017 Arthur Zhang. All rights reserved.
//

import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, CustomStringConvertible{
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String{
        switch self{
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    static func random() -> Orientation{
        return Orientation(rawValue: Int(arc4random_uniform(NumOrientations)))!
    }
    
    //#1
    
    static func rotate(orientation: Orientation, clockwise: Bool) -> Orientation{
        var rotated = orientation.rawValue + (clockwise ? 1: -1)
        
        if rotated > Orientation.TwoSeventy.rawValue{
            rotated = Orientation.Zero.rawValue
        } else if(rotated < 0){
            rotated = Orientation.TwoSeventy.rawValue
        }
        
        return Orientation(rawValue: rotated)!
    }
    
}

//Total shape varieties

let NumShapeTypes: UInt32 = 7

// Shape indexes

let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible{
    
    let color:BlockColor
    // the blocks comprising the shape
    var blocks = Array<Block>()
    // the current orientation of the shape
    var orientation: Orientation
    // the column and row representing the points anchor point
    var column, row: Int
    
    // #2 Required overrides
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>]{
        return[:]
    }
    
    //#3 subclasses must override this property
    
    var bottomBlocksForOrientations: [Orientation: Array<Block>]{
        return[:]
    }
    //#4
    var bottomBlocks: Array<Block>{
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else{
            return []
        }
        return bottomBlocks
    }
    //Hashable
    var hashValue: Int{
        //#5
        return blocks.reduce(0){$0.hashValue ^ $1.hashValue}
        
    }
    //CustomStringConvertible
    var description: String{
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column: Int, row: Int, color: BlockColor, orientation: Orientation){
        self.color = color
        self.column = column
        self.row = row
        self.orientation = orientation
        
        initializeBlocks()
    }
    // #6
    convenience init(column: Int, row: Int){
        self.init(column: column, row: row, color: BlockColor.random(), orientation: Orientation.random())
    }
    
    // #7
    final func initializeBlocks(){
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else{
            return
        }
        // #8
        blocks = blockRowColumnTranslations.map { (diff) -> Block in
            return Block(column: column + diff.columnDiff, row: row+diff.rowDiff, color: color)
        }
    }
    
    final func rotateBlocks(orientation: Orientation){
        
        guard let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else{
            return
        }
        //#1
        for(idx, diff) in blockRowColumnTranslation.enumerated(){
            blocks[idx].column = column + diff.columnDiff
            blocks[idx].row = row + diff.rowDiff
        }
    }
    
    // #3
    
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: true)
        
        rotateBlocks(orientation: newOrientation)
        
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: false)
        
        rotateBlocks(orientation: newOrientation)
        
        orientation = newOrientation
    }
    
    final func lowerShapeByOneRow(){
        shiftBy(columns: 0, rows: 1)
    }
    
    final func raiseShapeByOneRow(){
        shiftBy(columns: 0, rows: -1)
    }
    
    final func shiftRightByOneColumn(){
        shiftBy(columns: 1, rows: 0)
    }
    
    final func shiftLeftByOneColumn(){
        shiftBy(columns: -1, rows: 0)
    }
 
    
    //#2
    final func shiftBy(columns: Int, rows: Int){
        self.column += columns
        self.row += rows
        
        for block in blocks{
            block.column += columns
            block.row += rows
        }
    }
    //#3
    final func moveTo(column: Int, row: Int){
        self.column = column
        self.row = row
        rotateBlocks(orientation: orientation)
    }
    
    
    final class func random(startingColumn: Int, startingRow: Int) -> Shape{
        
        //#4
        switch Int(arc4random_uniform(NumShapeTypes)){
        case 0:
            return SquareShape(column: startingColumn, row: startingRow)
        case 1:
            return TShape(column: startingColumn, row: startingRow)
        case 2:
            return LineShape(column: startingColumn, row: startingRow)
        case 3:
            return LShape(column: startingColumn, row: startingRow)
        case 4:
            return JShape(column: startingColumn, row: startingRow)
        case 5:
            return SShape(column: startingColumn, row: startingRow)
        default:
            return ZShape(column: startingColumn, row: startingRow)
        }
    }
    
}

func==(lhs: Shape, rhs: Shape) -> Bool{
    return lhs.row==rhs.row && lhs.column==rhs.column
}



