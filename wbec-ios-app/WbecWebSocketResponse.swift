// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let wbecWebSocketResponse = try? newJSONDecoder().decode(WbecWebSocketResponse.self, from: jsonData)

import Foundation

// MARK: - WbecWebSocketResponse
struct WbecWebSocketResponse: Codable {
    let id, chgStat, power: Int
    let energyI: Double
    let energyC: Double
    var watt, pvMode: Int
    var currLim: Double
    let timeNow: String
}


// {"id":0,"chgStat":2,"power":0,"energyI":2546.852,"energyC":18.328,"currLim":0,"watt":0,"pvMode":1,"timeNow":"08:51:56"}
