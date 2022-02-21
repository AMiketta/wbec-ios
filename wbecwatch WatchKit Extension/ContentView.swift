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
        ScrollView {
        VStack{
                Text("Ladeleistung: \(String(socket.wbecState.power)) Watt")
                Text("\(socket.wbecState.watt) Watt").foregroundColor(socket.wbecState.watt > 0 ? .red : .green)
                Label("PV Modus: \(chargingMode)", systemImage: "tablecells.fill")
                            .foregroundColor(.blue)
                VStack(alignment: .center, spacing: 8){
                    Button(action: { socket.updatePVMode(.PV_OFF) }) {
                        HStack {
                            Image(systemName: "bolt")
                            Text("Aus")
                        }
                    }.buttonStyle( ColorButtonStyle(color: socket.wbecState.pvMode == 1 ? .accentColor : .gray))
                    Button(action: { socket.updatePVMode(.PV_ACTIVE) }) {
                        HStack {
                            Image(systemName: "tablecells.fill")
                            Text("PV")
                        }
                    }.buttonStyle(ColorButtonStyle(color: socket.wbecState.pvMode == 2 ? .accentColor : .gray))
                    Button(action: { socket.updatePVMode(.PV_MIN_PV) }) {
                        HStack {
                            Image(systemName: "tablecells.fill")
                            Image(systemName: "bolt")
                            Text("PV+Min")
                        }
                    }.buttonStyle(ColorButtonStyle(color: socket.wbecState.pvMode == 3 ? .accentColor : .gray))
                }
                HStack{
                    Text(socket.wbecState.timeNow)
                    .padding()
                }
        }.alert(item: $socket.alertWrapper) { $0.alert }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
