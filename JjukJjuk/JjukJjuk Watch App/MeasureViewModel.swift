//
//  MotionManager.swift
//  JjukJjuk Watch App
//
//  Created by 235 on 2023/08/21.
//

import SwiftUI
import CoreMotion
import WatchConnectivity
class MeasureViewModel: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate, WCSessionDelegate{
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        print("??")
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {

    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {

    }

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
        backgroundSession.delegate = self
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
        backgroundSession.invalidate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

    func startMotionUpdates() {
        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates()
    }

    func startCollectData() {
        startMotionUpdates()
        timering = true
        self.backgroundSession.start()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            guard let motion = self.motionManager.deviceMotion else {return}
            let newData = MeasureModel(attitude: motion.attitude, gravity: motion.gravity, timestamp: motion.timestamp, userAcceleration: motion.userAcceleration, rotationRate: motion.rotationRate)
            self.data.append(newData)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
            self.stopCollectData()
        }
    }

    func stopCollectData() {
        timering = false
        WKInterfaceDevice.current().play(.notification)
        self.timer?.invalidate()
        self.timer = nil
        sendToPhone()
        data.removeAll()
    }

    func sendToPhone() {
        let dataToSend = data.map {
            [
                "timestamp": $0.timestamp,
                "attitude": [
                "pitch": $0.attitude.pitch,
                "roll": $0.attitude.roll,
                "yaw": $0.attitude.yaw
            ],
             "gravity": [
                "x": $0.gravity.x,
                "y": $0.gravity.y,
                "z": $0.gravity.z
             ],
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
