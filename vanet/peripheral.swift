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

func getMinor(urgency_code:Int, accuracy:Int, count:Int)->UInt16{
    let arrenged_urgency_code = urgency_code * 1000 * 10
    let arrenged_accuracy = accuracy * 10
    let arrenged_count = count
    
    let arrenged_minor = arrenged_urgency_code + arrenged_accuracy + arrenged_count
    print("newMinor is")
    print(arrenged_minor)
    return UInt16(arrenged_minor)
}

func getMajor()->UInt16{
    let ud = UserDefaults.standard
    var ud_major = 3
    if ud.object(forKey: "major") != nil {
        ud_major = ud.object(forKey: "major") as! Int
    }
    print("newMajor is")
    print(ud_major)
    return UInt16(ud_major)
}

func getMajorWithRandomCode()->UInt16{
    let ud = UserDefaults.standard
    var ud_major = 3
    if ud.object(forKey: "major") != nil {
        ud_major = ud.object(forKey: "major") as! Int
    }
    let arrenged_major = Int(arc4random_uniform(1000)) * 10 + ud_major
    print("getMajorWithRandomCode is")
    print(arrenged_major)
    return UInt16(arrenged_major)
}

func startAdvertisingUrgencyPeripheralData(pheripheralManager: CBPeripheralManager,accuracy:Int,major: CLBeaconMajorValue,minor:CLBeaconMinorValue){

    if(accuracy == -1){
        print("accuracy == -1")
        return
    }
    if (Int(minor)%10000 == 0){
        let newPeripheralData = setPeripheralData(major: major, minor:minor)
        pheripheralManager.startAdvertising(newPeripheralData as? [String : Any])
        print("一番最初の端末")
    }else if(Int(minor)%10000 < 4){
        let urgency_code = Int(minor) % 100000 / 10000
        let arrenged_accuracy = (Int(minor) / 100) % 100 + accuracy
        let arrenged_count = Int(minor) % 10
        let minor = CLBeaconMinorValue(getMinor(urgency_code: urgency_code, accuracy: arrenged_accuracy + accuracy, count: arrenged_count+1))
        print("一番目でなく、三番目以内の端末.minor is " + minor.description + ", accuracy is " + accuracy.description +  ", major is " + major.description)
        let newPeripheralData = setPeripheralData(major: major, minor:minor)
        pheripheralManager.startAdvertising(newPeripheralData as? [String : Any])
    }
}

func is_urgency_signal(minor:CLBeaconMinorValue)->Bool{
    if(Int(minor)/10000 == 1){
        return true
    }
    return false
}

func is_first_time_random_code(major:CLBeaconMajorValue,random_code_list:Array<Int>)->Bool{
    let random_code = Int(major)/10
    if random_code_list.index(of: random_code) != nil {
        print("これは初めて！！！")
        return true
    }
    print("これは初めてじゃない")
    return false
}

func under_certain_count(beacon: CLBeacon)->Bool{
    if(Int(beacon.minor)%10 < 3){
        return true
    }
    print("緊急用のadは終了")
    return false
}
