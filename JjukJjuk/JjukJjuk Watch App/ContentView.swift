//
//  ContentView.swift
//  JjukJjuk Watch App
//
//  Created by 235 on 2023/08/21.
//

import SwiftUI

import CoreML
import WatchConnectivity
import WatchKit


struct ContentView: View {
    @StateObject var motionManager = MeasureViewModel()

    var body: some View {
        VStack {
            Text("User Acceleration:")
            Button(action: {
                    motionManager.startCollectData()
            }) {
                Text(motionManager.timering ? "테스트진행중" : "테스트하자")
            }
        }
//        .onAppear {
//            motionManager.startMotionUpdates()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
