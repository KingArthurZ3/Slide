//
//  LineShape.swift
//  JumpMan
//
//  Created by Arthur Zhang on 1/28/17.
//  Copyright © 2017 Arthur Zhang. All rights reserved.
//

class LineShape: Shape{
    
    override var blockRowColumnPositions: [Orientation : Array<(columnDiff: Int, rowDiff: Int)>]{
        return[
            Orientation.Zero: [(0,0), (0,1), (0,2), (0,3)],
            Orientation.Ninety: [(-1, 0), (0,0), (1,0), (2,0)],
            Orientation.OneEighty: [(0,0), (0,1), (0,2), (0,3)],
            Orientation.TwoSeventy: [(-1, 0), (0,0), (1,0), (2,0)]
        ]
    }
    override var bottomBlocksForOrientations: [Orientation : Array<Block>]{
        return[
            Orientation.Zero: [blocks[FourthBlockIdx]],
            Orientation.Ninety: blocks,
            Orientation.OneEighty: [blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: blocks
        ]
    }
    
    
}
