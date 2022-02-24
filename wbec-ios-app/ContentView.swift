//
//  ContentView.swift
//  wbec-ios-app
//
//  Created by Andreas Miketta on 21.02.22.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var socket: WebSocketController = .init()
    @State var current: Int = 0
    @State private var currLim: Double = 0
    init() {
        
    }
    
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
                    //IntSlider(score: socket.deduplicatedState.currLim, socket: socket).disabled(socket.wbecState.pvMode > 1).padding().onReceive(socket.updatedCurrLimPublisher){
                    //    self.socket.deduplicatedState.currLim = $0
                    //}
                    VStack{
                        Text("\((socket.wbecState.currLim), specifier: "%.2f") A")
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
                    }
                }
                GroupBox(label: Label("PV Modus", systemImage: "tablecells.fill")
                            .foregroundColor(.blue)){
            
                HStack(alignment: .center, spacing: 2){
                    Button(action: { socket.updatePVMode(.PV_OFF) }) {
                        HStack {
                            Image(systemName: "bolt")
                            Text("Aus")
                        }
                    }.buttonStyle( ColorButtonStyle(color: socket.wbecState.pvMode == 1 ? .accentColor : .gray))
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
                
                LazyVGrid(columns: [.init(), .init()]) {
                    // Geladene KW
                    GroupBox(label: Label("Geladen", systemImage: "bolt")
                                .foregroundColor(.red)){
                        Text("\((socket.wbecState.energyIP), specifier: "%.2f") Kw")
                            .fontWeight(.bold)
                            .padding()
                        
                    }
                    
                    // Ladeleistung
                    GroupBox(label: Label("Ladeleistung", systemImage: "bolt.car")
                                ){
                        Text("\(socket.wbecState.power) Watt")
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    // Verbindunstatus
                    GroupBox(label: Label("verbunden", systemImage: "car")
                               ){
                        Text(carState)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(socket.wbecState.chgStat < 4 ? .red : .green)
                    }
                    
                    // Wallbox erlaubt laden
                    GroupBox(label: Label("Wallbox erlaubt laden", systemImage: wbStat == "nein" ? "lock" : "lock.open")
                               ){
                        Text(wbStat)
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    // Energiezähler
                    GroupBox(label: Label("Energiezähler", systemImage: "bolt.fill")
                                .foregroundColor(.green)){
                        Text("\((socket.wbecState.energyI), specifier: "%.2f") kwh")
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    // Bezug / Einspeisung
                    GroupBox(label: Label(socket.wbecState.watt > 0 ? "Bezug" : "Einspeisung", systemImage: "house.fill")
                                ){
                        Label("\(socket.wbecState.watt > 0 ? socket.wbecState.watt : socket.wbecState.watt * -1) Watt", systemImage: socket.wbecState.watt > 0 ? "arrow.down" : "arrow.up" )
                            .foregroundColor(socket.wbecState.watt > 0 ? .red : .green)
                            .padding()
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


//struct IntSlider: View {
//    var score: Int = 0 { didSet { score2 = score }}
//    @State var score2: Int = 0
//    @ObservedObject var socket: WebSocketController
//    var intProxy: Binding<Double>{
//        Binding<Double>(get: {
//            //returns the score as a Double
//            return Double(score)
//        }, set: {
//            //rounds the double to an Int
//            print($0.description)
//            score2 = Int($0)
//        })
//    }
//    var body: some View {
//        VStack{
//            Text("\(score) A")
//            Slider(value: intProxy , in: 0.0...16.0, step: 1.0){
//                Text("Ampere")
//            } minimumValueLabel: {
//                Text("0 A")
//            } maximumValueLabel: {
//                Text("16 A")
//            } onEditingChanged: { editing in
//
//                print(score.description)
//                socket.updateLadeleistung(score2)
//            }
//        }
//    }
//}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
