//
//  ContentView.swift
//  wbecwatch WatchKit Extension
//
//  Created by Andreas Miketta on 21.02.22.
//

import SwiftUI

struct ContentView: View {
    @State private var currLim: Double = 0
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
                Text("Geladen: \((socket.wbecState.energyC), specifier: "%.2f") Kw")
                Text("Netz: \(socket.wbecState.watt) Watt").foregroundColor(socket.wbecState.watt > 0 ? .red : .green)
                Label("PV Modus: \(chargingMode)", systemImage: "tablecells.fill")
                            .foregroundColor(.blue)
                VStack(alignment: .center, spacing: 8){
                    Button(action: { socket.updatePVMode(.PV_OFF) }) {
                        HStack {
                            Image(systemName: "bolt")
                            Text("Aus").frame(maxWidth: .infinity)
                        }
                    }.buttonStyle( ColorButtonStyle(color: socket.wbecState.pvMode == 1 ? .accentColor : .gray)).padding(.horizontal)
                    Button(action: { socket.updatePVMode(.PV_ACTIVE) }) {
                        HStack {
                            Image(systemName: "tablecells.fill")
                            Text("PV").frame(maxWidth: .infinity)
                        }
                    }.buttonStyle(ColorButtonStyle(color: socket.wbecState.pvMode == 2 ? .accentColor : .gray)).padding(.horizontal)
                    Button(action: { socket.updatePVMode(.PV_MIN_PV) }) {
                        HStack {
                            Image(systemName: "tablecells.fill")
                            Image(systemName: "bolt")
                            Text("PV+Min").frame(maxWidth: .infinity)
                        }
                    }.buttonStyle(ColorButtonStyle(color: socket.wbecState.pvMode == 3 ? .accentColor : .gray)).padding(.horizontal)
                }
                Slider(value: $currLim , in: 0.0...16.0, step: 0.1){
                    Text("Ampere")
                } minimumValueLabel: {
                    Text("0 A")
                } maximumValueLabel: {
                    Text("16 A")
                } onEditingChanged: { editing in
                    socket.updateLadeleistung(currLim)
                }.onReceive(socket.updatedCurrLimPublisher){
                    self.currLim = $0
                }.disabled(socket.wbecState.pvMode > 1)
                    .padding()
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
