// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let wbecConfiguration = try? newJSONDecoder().decode(WbecConfiguration.self, from: jsonData)

import Foundation

// MARK: - WbecConfiguration
struct WbecConfiguration: Codable {
    var cfgApPass: String = ""
    var cfgApSSID: String = ""
    var cfgCntWb: Int?
    var cfgMqttIP: String?
    var cfgPVCycleTime, cfgPVActive: Int?
    var cfgMqttLp: [Int]?
    var cfgSolarEdgeIP: String = ""
    var cfgSolarEdgeCycleTime, cfgPVPhFactor, cfgPVLimStop: Int?

    enum CodingKeys: String, CodingKey {
        case cfgApSSID = "cfgApSsid"
        case cfgApPass, cfgCntWb
        case cfgMqttIP = "cfgMqttIp"
        case cfgPVCycleTime = "cfgPvCycleTime"
        case cfgPVActive = "cfgPvActive"
        case cfgMqttLp
        case cfgSolarEdgeIP = "cfgSolarEdgeIp"
        case cfgSolarEdgeCycleTime
        case cfgPVPhFactor = "cfgPvPhFactor"
        case cfgPVLimStop = "cfgPvLimStop"
    }
}
