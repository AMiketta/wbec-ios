//
//  ConfigurationView.swift
//  wbec
//
//  Created by Andreas Miketta on 24.02.22.
//

import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var configController: ConfigController = .init()
    
    init(){
        
    }
    
    var body: some View {
        if !configController.isLoaded {
            Text("Loading...").background(Color("BackGroundColor"))
        } else {
            Form {
                Section(header: Text("Access point")) {
                    HStack {
                        Text("SSID:")
                        TextField("Access point SSID", text: $configController.viewModel.cfgApSSID)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true).multilineTextAlignment(.leading)
                    }
                    HStack {
                        Text("Password:")
                        TextField("Password", text: $configController.viewModel.cfgApPass)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                  
                }
                Section(header: Text("Wechselrichter")) {
                    TextField("Ip (192.168.178.68)", text: $configController.viewModel.cfgSolarEdgeIP)
                    .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    TextField("Cycle Time", value: $configController.viewModel.cfgSolarEdgeCycleTime, formatter: NumberFormatter())
                }
                Section(header: Text("PV")) {
                    TextField("PV Cycle Time", value: $configController.viewModel.cfgPVCycleTime, formatter: NumberFormatter())
                    TextField("Factor", value: $configController.viewModel.cfgPVPhFactor, formatter: NumberFormatter())
                    TextField("Limit Stop", value: $configController.viewModel.cfgPVLimStop, formatter: NumberFormatter())
                }
                Button("Save"){
                    configController.saveConfig()
                }
            }.background(Color("BackGroundColor"))
        }
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}

class ConfigController: ObservableObject {
    @Published var isLoaded: Bool = false
    @Published var viewModel: WbecConfiguration
    
    init(){
        viewModel = WbecConfiguration(cfgApPass: "", cfgApSSID: "", cfgCntWb: 0, cfgMqttIP: "", cfgPVCycleTime: 0, cfgPVActive: 1, cfgMqttLp: [], cfgSolarEdgeIP: "", cfgSolarEdgeCycleTime: 15, cfgPVPhFactor: 69, cfgPVLimStop: 50)
        loadConfig()
    }
    
    func loadConfig() {
        Task {
            do {
                viewModel = try await NetworkManager.shared.loadConfigFile(filename: "cfg.json")
                isLoaded = true
            } catch {
                isLoaded = false
                // TODO: Add some errorhandling
            }
        }
    }
    
    func saveConfig(){
        Task {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(viewModel)
                _ = try await NetworkManager.shared.uploadConfigFile(filename: "cfg.json", configFileData: data)
            } catch {
                // TODO: Add some errorhandling
            }
        }
    }
}
