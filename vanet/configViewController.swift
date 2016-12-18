//
//  configViewController.swift
//  vanet
//
//  Created by wakabashi on 2016/12/19.
//  Copyright © 2016年 wakabayashi. All rights reserved.
//

import UIKit

class configViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let vehicleArr: NSArray = ["自動車","自転車","歩行者"]
    
    @IBOutlet weak var vehiclePickerView: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        vehiclePickerView.delegate = self
        vehiclePickerView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //表示列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vehicleArr.count
    }
    
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return vehicleArr[row] as? String
    }
    
    //選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("列: \(row)")
        print("値: \(vehicleArr[row])")
        let ud = UserDefaults.standard
        ud.set(row, forKey: "major")
    }
    
}
