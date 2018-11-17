//
//  InterfaceController.swift
//  nayoro_watch WatchKit Extension
//
//  Created by Takuya Kudo on 2018/11/17.
//  Copyright © 2018 Takuya Kudo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // HealthKitで扱うデータを管理するクラス(データの読み書きにはユーザの許可が必要)
    let healthStore = HKHealthStore()
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // HealthKitがデバイス上で利用できるか確認
        guard HKHealthStore.isHealthDataAvailable() else {
            self.label.setText("not available")
            return
        }
        
        // アクセス許可をユーザに求める
        let dataTypes = Set([HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!])
        self.healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) -> Void in
            guard success else {
                self.label.setText("not allowed")
                return
            }
        }
    }

}
