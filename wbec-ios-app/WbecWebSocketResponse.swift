// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let wbecWebSocketResponse = try? newJSONDecoder().decode(WbecWebSocketResponse.self, from: jsonData)

import Foundation

// MARK: - WbecWebSocketResponse
struct WbecWebSocketResponse: Hashable,Codable {
    let id, chgStat, power: Int
    let energyI: Double
    let energyIP: Double
    var watt, pvMode: Int
    var currLim: Double
    let timeNow: String
}



