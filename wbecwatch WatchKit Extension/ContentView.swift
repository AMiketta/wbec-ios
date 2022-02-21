//
//  ContentView.swift
//  wbecwatch WatchKit Extension
//
//  Created by Andreas Miketta on 21.02.22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var socket: WebSocketController = .init()
    var chargingMode: String {
        switch (socket.wbecState.pvMode) {
            case 1: return "Aus"
            case 2: return "PV"
            case 3: return "Min+PV"
            default: return "-"
        }
    }
    
    var body: some View {
        VStack{
            Group{
                Label("PV Modus: \(chargingMode)", systemImage: "tablecells.fill")
                            .foregroundColor(.blue)
                HStack(alignment: .center, spacing: 0){
                    Button("Aus") {
                        socket.updatePVMode(.PV_OFF)
                    }.buttonStyle(.borderedProminent)
                    Spacer()
                    Button("PV") {
                        socket.updatePVMode(.PV_ACTIVE)
                    }.buttonStyle(.borderedProminent)
                    Spacer()
                    Button("PV+Min") {
                        socket.updatePVMode(.PV_MIN_PV)
                    }.buttonStyle(.borderedProminent)
                }
                HStack{
                    Text(socket.wbecState.timeNow)
                    .padding()
                }
            }
        }.alert(item: $socket.alertWrapper) { $0.alert }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
