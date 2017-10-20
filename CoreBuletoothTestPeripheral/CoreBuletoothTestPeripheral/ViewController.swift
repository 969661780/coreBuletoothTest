//
//  ViewController.swift
//  CoreBuletoothTestPeripheral
//
//  Created by mt y on 2017/10/19.
//  Copyright © 2017年 mt y. All rights reserved.
//

import UIKit

import CoreBluetooth

class ViewController: UIViewController {

    var SERVER_UUID = "CDD1"
    var  CHARACTERISTIC_UUID = "CDD2"
    
    var charaater : CBMutableCharacteristic!
    var periphere : CBPeripheralManager!
    
    @IBOutlet weak var labek: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.periphere = CBPeripheralManager.init(delegate: self, queue: DispatchQueue.main)
        
    }
    @IBOutlet weak var btnButton: UIButton!
    @IBAction func myButton(_ sender: UIButton) {
        let sendSuccess = self.periphere.updateValue("321".data(using: String.Encoding.utf8)!, for: self.charaater, onSubscribedCentrals: nil)
        if sendSuccess {
            print("成功")
        }else{
            print("失败")
        }
    }
    
}

// MARK: - <#CBPeripheralManagerDelegate#>
extension ViewController:CBPeripheralManagerDelegate{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            //创建Server和特征
           self.setupSeverAndCharecter()
           self.periphere.startAdvertising([CBAdvertisementDataServiceUUIDsKey:CBUUID.init(string: SERVER_UUID)])
        }
    }
    func setupSeverAndCharecter() {
        
        //创建服务
        let server = CBMutableService.init(type: CBUUID.init(string: SERVER_UUID), primary: true)
        //创建服务的特征
        let charater = CBUUID.init(string: CHARACTERISTIC_UUID)
        let characerMuTable = CBMutableCharacteristic.init(type: charater, properties: [.read , .write , .notify], value: nil, permissions: [.readable ,.writeable])
        // 特征添加进服务
        server.characteristics = [characerMuTable]
        // 服务加入管理
        self.periphere.add(server)
        // 为了手动给中心设备发送数据
        self.charaater = characerMuTable
    }
    //中心设备读取这个外设会回调这个方法
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let str = "haha"
        request.value = str.data(using: String.Encoding.utf8)
        //成功响应请求
        peripheral.respond(to: request, withResult: .success)
    }
    //中心设备写入数据的时候回调
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        let request = requests.last
       
        self.labek.text =  NSString.init(data: (request?.value!)!, encoding: String.Encoding.utf8.rawValue) as String?
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
    }
}
