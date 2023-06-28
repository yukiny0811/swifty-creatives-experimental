//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/28.
//

import Foundation

extension GlyphUtil {
    enum HelperFunctions {
        static func cubicBezierVelocity2(_ a: f2, _ b: f2, _ c: f2, _ d: f2, _ t: Float) -> f2 {
            let oneMinusT = 1.0 - t
            let oneMinusT2 = oneMinusT * oneMinusT
            let temp1 = 3.0 * oneMinusT2 * (b - a)
            let temp2 = 6.0 * oneMinusT * t * (c - b)
            let temp3 = 3.0 * t * t * (d - c)
            return temp1 + temp2 + temp3
        }
        static func quadraticBezierVelocity2(_ a: f2, _ b: f2, _ c: f2, _ t: Float) -> f2 {
            let oneMinusT: Float = 1.0 - t
            return 2 * oneMinusT * (b-a) + 2 * t * (c-b)
        }
    }
}
