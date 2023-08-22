//
//  MeasureModel.swift
//  JjukJjuk Watch App
//
//  Created by 235 on 2023/08/21.
//

import Foundation
import CoreMotion
struct MeasureModel {
    var attitude: CMAttitude
    var gravity: CMAcceleration
//    var timestamp: TimeInterval
     var userAcceleration: CMAcceleration
     var rotationRate: CMRotationRate


}
