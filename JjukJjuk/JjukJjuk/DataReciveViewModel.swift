//
//  DataReciveViewModel.swift
//  JjukJjuk
//
//  Created by 235 on 2023/08/21.
//

import SwiftUI
import WatchConnectivity

class DateReceiveViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedData:  [String: [String: Double]] = [:]
    private let fileManager = FileManager.default
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter
    }()

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("WCSession Activated - iPhone")
        }
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("이건 몬가?")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("언제연결끝기나?")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("연결되었나?")
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) { // 대량의 데이터를 주고받을때 사용. 다른것과 달리 백그라운드에서 전솓되고 동기화돼 큰데이터 다루는데 적합.
        if let dataArray = userInfo["Data"] as? [[String: Any]] {
            let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dateString = dateFormatter.string(from: Date())
            let fileURL = documentURL.appendingPathComponent("\(dateString).csv")
            let header = "timestamp,acceleration_x,acceleration_y,acceleration_z,attitude_pitch,attitude_roll,attitude_yaw,gravity_x,gravity_y,gravity_z,rotation_x,rotation_y,rotation_z\n"
            writeToFile(header, fileURL: fileURL)
            DispatchQueue.main.async {
//                var currentTime: Double = 0.0
//                let timeStep: Double = 0.2
                for data in dataArray {
//                    if let timestamp = data["timestamp"] as? Double {
//                        currentTime += timeStep
                        var sensorData: [String:[String:Double]] = [:]
                        for (key,val) in data {
                            if key != "timestamp", let val = val as? [String: Double] {
                                sensorData[key] = val
                            }
                        }
                        self.$receivedData.append(  sensorData)
                        let acceleration = sensorData["userAcceleration"] ?? ["x": 0.0, "y": 0.0, "z": 0.0]
                        let rotation = sensorData["rotationRate"] ?? ["x": 0.0, "y": 0.0, "z": 0.0]
                        let attitude = sensorData["attitude"] ?? ["pitch": 0.0, "roll": 0.0, "yaw": 0.0]
                        let gravity = sensorData["gravity"] ?? ["x": 0.0, "y": 0.0, "z": 0.0]
                        // Timestamp 소수점 둘째자리까지
//                        let currentTimeString = String(format: "%.2f", currentTime)
                        let row = "\(acceleration["x"]!),\(acceleration["y"]!),\(acceleration["z"]!),\(attitude["pitch"]!),\(attitude["roll"]!),\(attitude["yaw"]!),\(gravity["x"]!),\(gravity["y"]!),\(gravity["z"]!),\(rotation["x"]!),\(rotation["y"]!),\(rotation["z"]!)\n"
                        self.writeToFile(row, fileURL: fileURL)
                    }
//                }
            }

        }
    }
    private func writeToFile(_ string: String, fileURL: URL) {
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                try fileHandle.seekToEnd()
                if let data = string.data(using: .utf8) {
                    fileHandle.write(data)
                }
                try fileHandle.close()
            }
            else{
                try string.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
