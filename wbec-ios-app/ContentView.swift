//
//  ContentView.swift
//  wbec-ios-app
//
//  Created by Andreas Miketta on 21.02.22.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var socket: WebSocketController = .init()
    var wbStat: String {
        var wbStat = ""
        switch (socket.wbecState.chgStat) {
                    case  2: /*A1*/ wbStat = "nein"
                    case  3: /*A2*/ wbStat = "ja"
                    case  4: /*B1*/ wbStat = "nein"
                    case  5: /*B2*/ wbStat = "ja"
                    case  6: /*C1*/ wbStat = "nein"
                    case  7: /*C2*/ wbStat = "ja"
                    default: wbStat = "-"
                }
        return wbStat
    }
    
    var carState: String {
        var carStat = ""
        switch (socket.wbecState.chgStat) {
                    case  2: /*A1*/ carStat = "nein"
                    case  3: /*A2*/ carStat = "nein"
                    case  4: /*B1*/ carStat = "ja, ohne Ladeanfrage."
                    case  5: /*B2*/ carStat = "ja, ohne Ladeanfrage."
                    case  6: /*C1*/ carStat = "ja, mit Ladeanfrage."
                    case  7: /*C2*/ carStat = "ja, mit Ladeanfrage."
                    default: carStat = String(socket.wbecState.chgStat)
                }
        return carStat
    }
    
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
            VStack(spacing: 16) {
                Text("wbec").font(.largeTitle).foregroundColor(.accentColor).fontWeight(.bold)
                Text("Heidelberg WallBox Energy Control über ESP8266").font(.subheadline).foregroundColor(.white)
                
                GroupBox(label: Label("Ladeleistung", systemImage: "bolt.fill")
                            .foregroundColor(.yellow)){
                    IntSlider(score: socket.wbecState.currLim, socket: socket).disabled(socket.wbecState.pvMode > 1)
                }
                GroupBox(label: Label("Status", systemImage: "bolt")
                            .foregroundColor(.yellow)){
                    HStack(alignment: .firstTextBaseline, spacing: 0){
                        Text("Stromlimit")
                        Spacer()
                        Text("\(String(socket.wbecState.currLim)) A")
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 8){
                        Text("Fahrzeug verbunden")
                        Spacer()
                        Text(carState)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 8){
                        Text("Wallbox erlaubt laden")
                        Spacer()
                        Text(wbStat)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 8){
                        Text("Ladeleistung")
                        Spacer()
                        Text("\(socket.wbecState.power) Watt")
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 8){
                        Text("Energiezähler")
                        Spacer()
                        Text("\((socket.wbecState.energyI), specifier: "%.2f") kwh")
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 8){
                        Text("Bezug(+)/Einsp.(-)")
                        Spacer()
                        Text("\(socket.wbecState.watt) Watt").foregroundColor(socket.wbecState.watt > 0 ? .red : .green)
                    }
                    
                }
                GroupBox(label: Label("PV Modus:", systemImage: "tablecells.fill")
                            .foregroundColor(.blue)){
            
                HStack(alignment: .center, spacing: 2){
                    Button(action: { socket.updatePVMode(.PV_OFF) }) {
                        HStack {
                            Image(systemName: "bolt")
                            Text("Aus")
                        }
                    }.buttonStyle( ColorButtonStyle(color: socket.wbecState.pvMode == 1 ? .accentColor : .gray))//.background(socket.wbecState.pvMode == 1 ? Color.accentColor : Color.gray)
                    Spacer()
                    Button(action: { socket.updatePVMode(.PV_ACTIVE) }) {
                        HStack {
                            Image(systemName: "tablecells.fill")
                            Text("PV")
                        }
                    }.buttonStyle(ColorButtonStyle(color: socket.wbecState.pvMode == 2 ? .accentColor : .gray))
                    Spacer()
                    Button(action: { socket.updatePVMode(.PV_MIN_PV) }) {
                        HStack {
                            Image(systemName: "tablecells.fill")
                            Image(systemName: "bolt")
                            Text("PV+Min")
                        }
                    }.buttonStyle(ColorButtonStyle(color: socket.wbecState.pvMode == 3 ? .accentColor : .gray))
                }
                }
                Spacer()
                HStack{
                    Text(socket.wbecState.timeNow).foregroundColor(.white)
                    .padding()
                }
            }.padding()
            .alert(item: $socket.alertWrapper) { $0.alert }
        }
    }
}


struct IntSlider: View {
    @State var score: Int = 0
    @ObservedObject var socket: WebSocketController
    var intProxy: Binding<Double>{
        Binding<Double>(get: {
            //returns the score as a Double
            return Double(score)
        }, set: {
            //rounds the double to an Int
            print($0.description)
            score = Int($0)
        })
    }
    var body: some View {
        VStack{
            Text("\(socket.wbecState.currLim.description) A")
            Slider(value: intProxy , in: 0.0...16.0, step: 1.0){
                Text("Speed")
            } minimumValueLabel: {
                Text("0 A")
            } maximumValueLabel: {
                Text("16 A")
            } onEditingChanged: { editing in
            
                print(score.description)
                socket.updateLadeleistung(score)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
