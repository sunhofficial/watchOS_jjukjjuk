//
//  MotionManager.swift
//  JjukJjuk Watch App
//
//  Created by 235 on 2023/08/21.
//

import SwiftUI
import CoreMotion
import WatchConnectivity
class MeasureViewModel: NSObject, ObservableObject, WCSessionDelegate, WKExtendedRuntimeSessionDelegate{
    var data: [MeasureModel] = []
    private var backgroundSession = WKExtendedRuntimeSession()
    private var motionManager = CMMotionManager()
    private var timer: Timer? = nil
    @Published var timering : Bool = false

    override init() {
        super.init()
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        if WKExtendedRuntimeSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

//    func startMotionUpdates() {
//        motionManager.deviceMotionUpdateInterval = 0.2
//        motionManager.startDeviceMotionUpdates()
//    }

    func startCollectData() {
        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates()
        timering = true
        self.backgroundSession = WKExtendedRuntimeSession()
        self.backgroundSession?.start()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            guard let motion = self.motionManager.deviceMotion else {return}
            let newData = MeasureModel(attitude: motion.attitude, gravity: motion.gravity, userAcceleration: motion.userAcceleration, rotationRate: motion.rotationRate)
            self.data.append(newData)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.stopCollectData()
        }
    }

    func stopCollectData() {
        timering = false
        WKInterfaceDevice.current().play(.notification)
        self.timer?.invalidate()
        self.timer = nil
        print(data)
        sendToPhone()
        data.removeAll()
//        self.backgroundSession?.invalidate()
//        self.backgroundSession = nil//        WKExtendedRuntimeSession().invalidate()

    }

    func sendToPhone() {
        let dataToSend = data.map {
            ["attitude": [
                "pitch": $0.attitude.pitch,
                "roll": $0.attitude.roll,
                "yaw": $0.attitude.yaw
            ],
             "gravity": [
                "x": $0.gravity.x,
                "y": $0.gravity.y,
                "z": $0.gravity.z
             ],
//             "timestamp": $0.timestamp,
             "userAcceleration": [
                "x": $0.userAcceleration.x,
                "y": $0.userAcceleration.y,
                "z": $0.userAcceleration.z
             ],
             "rotationRate": [
                "x": $0.rotationRate.x,
                "y": $0.rotationRate.y,
                "z": $0.rotationRate.z
             ]
            ]
        }
        WCSession.default.transferUserInfo(["Data": dataToSend])
    }
}
