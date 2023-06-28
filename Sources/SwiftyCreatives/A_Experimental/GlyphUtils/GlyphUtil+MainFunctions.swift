//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/28.
//

import simd

extension GlyphUtil {
    enum MainFunctions {
        static let DEPTH: Int = 8
        static func adaptiveQubicBezierCurve2(
            a: f2,
            b: f2,
            c: f2,
            d: f2,
            aVel: f2,
            bVel: f2,
            cVel: f2,
            angleLimit: Float,
            depth: Int,
            line: inout [f2]
        ) {
            if Self.DEPTH > 8 { return }
            let startMiddleAngle: Float = acos(simd_dot(aVel, bVel))
            let middleEndAngle: Float = acos(simd_dot(bVel, cVel))
            if startMiddleAngle + middleEndAngle > angleLimit {
                let ab = (a+b) * 0.5
                let bc = (b+c) * 0.5
                let cd = (c+d) * 0.5
                let abc = (ab + bc) * 0.5
                let bcd = (bc + cd) * 0.5
                let abcd = (abc + bcd) * 0.5
                let sVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(a, ab, abc, abcd, 0.5))
                Self.adaptiveQubicBezierCurve2(a: a, b: ab, c: abc, d: abcd, aVel: aVel, bVel: sVel, cVel: bVel, angleLimit: angleLimit, depth: depth+1, line: &line)
                line.append(abcd)
                let eVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(abcd, bcd, cd, d, 0.5))
                Self.adaptiveQubicBezierCurve2(a: abcd, b: bcd, c: cd, d: d, aVel: bVel, bVel: eVel, cVel: cVel, angleLimit: angleLimit, depth: depth+1, line: &line)
            }
        }
        static func adaptiveQuadraticBezierCurve2(
            a: simd_float2,
            b: simd_float2,
            c: simd_float2,
            aVel: simd_float2,
            bVel: simd_float2,
            cVel: simd_float2,
            angleLimit: Float,
            depth: Int,
            line: inout [simd_float2]
        ) {
            if depth > 8 { return }
            let startMiddleAngle: Float = acos(simd_dot(aVel, bVel))
            let middleEndAngle: Float = acos(simd_dot(bVel, cVel))
            if startMiddleAngle + middleEndAngle > angleLimit {
                let ab = (a+b) * 0.5
                let bc = (b+c) * 0.5
                let abc = (ab + bc) * 0.5
                let sVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(a, ab, abc, 0.5))
                adaptiveQuadraticBezierCurve2(a: a, b: ab, c: abc, aVel: aVel, bVel: sVel, cVel: bVel, angleLimit: angleLimit, depth: depth+1, line: &line)
                line.append(abc)
                let eVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(abc, bc, c, 0.5))
                adaptiveQuadraticBezierCurve2(a: abc, b: bc, c: c, aVel: bVel, bVel: eVel, cVel: cVel, angleLimit: angleLimit, depth: depth+1, line: &line)
            }
        }
    }
}
