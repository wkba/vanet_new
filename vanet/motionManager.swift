//
//  motionManager.swift
//  vanet
//
//  Created by wakabashi on 2016/12/21.
//  Copyright © 2016年 wakabayashi. All rights reserved.
//

import UIKit
import CoreMotion

let urgency_acceleration = 1.5

func getMotionManager()->CMMotionManager{
    // MotionManagerを生成.
    let motionManager = CMMotionManager()
    // 更新周期を設定.
    motionManager.accelerometerUpdateInterval = 0.1
    return motionManager
}

func getAcceleration(x:Double,y:Double,z:Double)-> Double{
    return sqrt(x*x + y*y + z*z)
}
