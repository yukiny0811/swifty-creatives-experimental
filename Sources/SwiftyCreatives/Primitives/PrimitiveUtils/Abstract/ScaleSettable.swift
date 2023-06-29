//
//  ScaleSettable.swift
//  
//
//  Created by Yuki Kuwashima on 2023/03/03.
//

import CommonEntity

public protocol ScaleSettable: AnyObject {
    var scale: f3 { get }
    @discardableResult func setScale(_ value: f3) -> Self
}
