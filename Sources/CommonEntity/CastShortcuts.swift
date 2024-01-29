//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/07/04.
//

public extension CGPoint {
    var f2Value: f2 {
        f2(Float(self.x), Float(self.y))
    }
}

public extension CGSize {
    var f2Value: f2 {
        f2(Float(self.width), Float(self.height))
    }
}
