//
//  MotionManager.swift
//  JjukJjuk Watch App
//
//  Created by 235 on 2023/08/21.
//

import SwiftUI
import CoreMotion
import WatchConnectivity
class MeasureViewModel: NSObject, ObservableObject, WCSessionDelegate {
    var session: WCSession
    var backgroundSession: WKExtendedRuntimeSession?
    private var motionManager: CMMotionManager?
    init(session: WCSession) {
        self.session = session
        self.session.delegate = self
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        <#code#>
    }

    func startMotionUpdates() {
        motionManager?.deviceMotionUpdateInterval = 0.2
        motionManager?.startDeviceMotionUpdates() {
            
        }
    }


}
