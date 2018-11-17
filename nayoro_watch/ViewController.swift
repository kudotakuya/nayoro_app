//
//  ViewController.swift
//  nayoro_watch
//
//  Created by Takuya Kudo on 2018/11/17.
//  Copyright © 2018 Takuya Kudo. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    
    private let healthStore = HKHealthStore()
    // ワークアウトと心拍数を読み出しに設定
    private let readDataTypes: Set<HKObjectType> = [
        HKWorkoutType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        ]
    
    override func viewDidLoad() { do {
        super.viewDidLoad()
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { (success, error) in
            guard success, error == nil else {
                return
            }
            self.getHeartRates()
            self.getHeartRateWithFiveMinutes()
        }
    }}
    
    

    private var statistics = [HKStatistics]()

    private func getHeartRates() {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let startDate = dateformatter.date(from: "2018/11/17")
        let endDate = dateformatter.date(from: "2018/11/18")
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.discreteAverage, .discreteMin, .discreteMax]) { [unowned self] (query, statistic, error) in
            guard let statistic = statistic, error == nil else {
                return
            }
            self.statistics.append(statistic)
            print("最低値 \(statistic.minimumQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) bpm")
            print("最高値 \(statistic.maximumQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) bpm")
            print("平均値 \(statistic.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) bpm")
        }
        healthStore.execute(query)
    }

    private var heartRateStatistics = [HKStatistics]()
    
    private func getHeartRateWithFiveMinutes() {
        var dateComponents = DateComponents()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let startDate = dateformatter.date(from: "2018/11/17")
        let endDate = dateformatter.date(from: "2018/11/18")
        dateComponents.minute = 60  // 間隔時間
        let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!,
        
        query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: [.discreteAverage, .discreteMin, .discreteMax], anchorDate: startDate!, intervalComponents: dateComponents)
        query.initialResultsHandler = { [unowned self] (query, result, error) in
            guard let result = result, error == nil else {
                return
            }
            result.enumerateStatistics(from: startDate!, to: endDate!) { (statistic, stop) in
                self.heartRateStatistics.append(statistic)
                print("平均値 \(statistic.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) bpm")
            }
        }
        healthStore.execute(query)
    }
    
    
    //    func getWorkout(){
    //        // 取得する期間を設定
    //        let dateformatter = DateFormatter()
    //        dateformatter.dateFormat = "yyyy/MM/dd"
    //        let startDate = dateformatter.date(from: "2017/12/01")
    //        let endDate = dateformatter.date(from: "2018/01/01")
    //
    //        // 取得するデータを設定
    //        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
    //        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
    //        let q = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: sort, resultsHandler:{
    //            (query, result, error) in
    //
    //            if let e = error {
    //                print("Error: \(e.localizedDescription)")
    //                return
    //            }
    //            DispatchQueue.main.async {
    //                guard let r = result else {
    //                    return
    //                }
    //
    //                let workouts = r as! [HKWorkout]
    //                for workout in workouts {
    //                    print(workout.startDate)
    //                    print(workout.totalDistance!)
    //                    print(workout.totalEnergyBurned!)
    //                }
    //            }
    //        })
    //
    //        healthStore.execute(q)
    //    }
}
