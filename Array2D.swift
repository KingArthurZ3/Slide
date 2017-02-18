//
//  Array2D.swift
//  JumpMan
//
//  Created by Arthur Zhang on 1/24/17.
//  Copyright © 2017 Arthur Zhang. All rights reserved.
//

class Array2D<T> {
    
    //#1
    let columns: Int
    
    let rows: Int
    
    //#2
    var array: Array<T?>
    
    init(columns: Int, rows: Int){
        
        self.columns = columns
        self.rows = rows
        
        //#3
        array = Array<T?>(repeating: nil, count:rows * columns)
        
    }
    
    //#4
    subscript(column: Int, row: Int) ->T? {
        get{
            return array[(row * columns) + column]
        }
        set(newValue){
            array[(row*columns) + column] = newValue
        }
    }
    
}
