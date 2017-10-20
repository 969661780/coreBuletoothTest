//
//  ViewController.swift
//  CoreBluetoothTestCentral
//
//  Created by mt y on 2017/10/19.
//  Copyright © 2017年 mt y. All rights reserved.
//

import UIKit

import CoreBluetooth


class ViewController: UIViewController {
    
    var SERVICE_UUID = "CDD1"
    var CHAEACTERUSTUC_UUID = "CDD2"
    
    
    
    var centerManager : CBCentralManager!
    
    var peripheral : CBPeripheral!
    
    var characteristic : CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "蓝牙中心设备"
        self.centerInit()
    }

    func centerInit()  {
        self.centerManager = CBCentralManager.init(delegate: self, queue: DispatchQueue.main)
        
    }
    @IBAction func writeData(_ sender: UIButton) {
        let str = "123"
        let data = str.data(using: String.Encoding.utf8)
        self.peripheral.writeValue(data!, for:self.characteristic , type: .withResponse)

    }
    
    @IBAction func readData(_ sender: UIButton) {
        self.peripheral.readValue(for: self.characteristic)
    }
    @IBOutlet weak var readData: UIButton!
}

// MARK: -CBCentralManagerDelegate,CBPeripheralManagerDelegate
extension ViewController:CBCentralManagerDelegate,CBPeripheralDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state.rawValue == 5 {
            // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
            central.scanForPeripherals(withServices: [CBUUID.init(string: SERVICE_UUID)], options: nil)
        }
        if central.state.rawValue == 2{
            print("该设备不支持蓝牙")
        }
        if central.state == .poweredOff {
            print("蓝牙关闭")
        }
    }
   //当扫描到外设后，会调用这个方法，可以使用该方法来筛选条件
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
       print(peripheral.name)
//        if (peripheral.name?.hasPrefix("谭彪"))! {
//
//        }
        self.peripheral = peripheral
        self.peripheral.delegate = self
         central.connect(peripheral, options: nil)
    }
    

    //连接状态
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centerManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID.init(string: SERVICE_UUID)])
        print("连接成功")
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败")
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral) {
        central.connect(peripheral, options: nil)
        print("断开连接从新连接")
    }
  //连接成功后,找服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for servers in peripheral.services! {
            print(servers)
        }
         let serverConnect = peripheral.services?.last
        peripheral.discoverCharacteristics([CBUUID.init(string: CHAEACTERUSTUC_UUID)], for: serverConnect!)
    }
    //发现特征，筛选特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for charact in service.characteristics! {
            print(charact)
        }
        self.characteristic = service.characteristics?.last!
        peripheral.readValue(for: (service.characteristics?.last)!)
        //订阅这个通知
        peripheral.setNotifyValue(true, for: (service.characteristics?.last)!)
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            print("订阅失败")
        }
        if characteristic.isNotifying {
            print("订阅成功")
        }else{
            print("取消订阅")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
        
    }
    
    
}
