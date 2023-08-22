//
//  ContentView.swift
//  JjukJjuk
//
//  Created by 235 on 2023/08/21.
//

import SwiftUI
import WatchConnectivity
struct ContentView: View {
    @StateObject var vm = DateReceiveViewModel()
    var body: some View {
        ScrollView {
//            ForEach(vm.receivedData, id: \.self) { item in
//                VStack(alignment: .leading) {
//                    Text("Timestamp: \(item.timestamp)")
//                }
//                .padding(.bottom, 10)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


