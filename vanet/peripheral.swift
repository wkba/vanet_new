//
//  peripheral.swift
//  vanet
//
//  Created by wakabashi on 2016/12/20.
//  Copyright © 2016年 wakabayashi. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

func setPeripheralData(major:CLBeaconMajorValue, minor:CLBeaconMinorValue)->NSDictionary{
    // iBeaconのUUID.
    let myProximityUUID = NSUUID(uuidString: "9EDFA660-204E-4066-8644-A432AE2B6EC1")
    
    // iBeaconのIdentifier.
    let myIdentifier = "fabo2"
    
    // BeaconRegionを定義.
    let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID! as UUID, major: major, minor: minor, identifier: myIdentifier)
    
    // Advertisingのフォーマットを作成.
    let myBeaconPeripheralData = NSDictionary(dictionary: myBeaconRegion.peripheralData(withMeasuredPower: nil))
    
    return myBeaconPeripheralData
}

func getMinor(urgency_code:Int, accuracy:Int, count:Int)->Int16{
    let arrenged_urgency_code = urgency_code * 1000 * 10
    let arrenged_accuracy = accuracy * 10
    let arrenged_count = count
    
    let arrenged_minor = arrenged_urgency_code + arrenged_accuracy + arrenged_count
    return Int16(arrenged_minor)
}

func getMajor()->Int{
    let ud = UserDefaults.standard
    var ud_major = 3
    if ud.object(forKey: "major") != nil {
        ud_major = ud.object(forKey: "major") as! Int
    }
    return ud_major
}

func startAdvertisingUrgencyPeripheralData(pheripheralManager: CBPeripheralManager,accuracy:Int,minor:CLBeaconMinorValue){
    pheripheralManager.stopAdvertising();
    if (Int(minor) == 0){
        let minor = CLBeaconMinorValue(getMinor(urgency_code: 1, accuracy: 0, count: 0))
        let major = CLBeaconMajorValue(getMajor())
        let newPeripheralData = setPeripheralData(major: major, minor:minor)
        pheripheralManager.startAdvertising(newPeripheralData as? [String : Any])
        print("きてない")
    }else{
        let urgency_code = Int(minor) / 1000
        let arrenged_accuracy = (Int(minor) / 10) % 100
        let arrenged_count = Int(minor) % 10
        let minor = CLBeaconMinorValue(getMinor(urgency_code: urgency_code, accuracy: arrenged_accuracy + accuracy, count: arrenged_count+1))
        let major = CLBeaconMajorValue(getMajor())
        print("kita")
        let newPeripheralData = setPeripheralData(major: major, minor:minor)
        pheripheralManager.startAdvertising(newPeripheralData as? [String : Any])
    }
}

func reciveAdvertisingUrgencyPeripheralData(pheripheralManager: CBPeripheralManager,accuracy:Int,minor:CLBeaconMinorValue){
    startAdvertisingUrgencyPeripheralData(pheripheralManager: pheripheralManager, accuracy: accuracy, minor:minor)
}

func is_urgency_signal(minor:CLBeaconMinorValue)->Bool{
    if(Int(minor)/1000 == 1){
        return true
    }
    return false
}
