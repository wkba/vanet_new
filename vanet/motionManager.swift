//
//  motionManager.swift
//  vanet
//
//  Created by wakabashi on 2016/12/21.
//  Copyright © 2016年 wakabayashi. All rights reserved.
//

import UIKit
import CoreMotion

let urgency_acceleration = 1.0

func getMotionManager(debug_logs:UITextView)->CMMotionManager{
    // MotionManagerを生成.
    var myMotionManager: CMMotionManager!
    
    myMotionManager = CMMotionManager()
    
    // 更新周期を設定.
    myMotionManager.accelerometerUpdateInterval = 0.1
    
    // 加速度の取得を開始.
    myMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: {(accelerometerData, error) in
        if let e = error {
            print(e.localizedDescription)
            return
        }
        guard let data = accelerometerData else {
            return
        }
        let acceleration = getAcceleration(x:data.acceleration.x,y:data.acceleration.y,z:data.acceleration.z)
        if (urgency_acceleration < acceleration){
            //debug_logs.text = debug_logs.text + "\n" + (NSString(format: "%.4f", acceleration) as String) ;
            debug_logs.text = debug_logs.text + "\n" + "急なスピード変化"
        }
    })
    return myMotionManager
}

func getAcceleration(x:Double,y:Double,z:Double)-> Double{
    return sqrt(x*x + y*y + z*z)
}
