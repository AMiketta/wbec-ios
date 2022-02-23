import Foundation
import SwiftUI
import Combine

struct AlertWrapper: Identifiable {
  let id = UUID()
  let alert: Alert
}

final class WebSocketController: ObservableObject {
  @Published var wbecState: WbecWebSocketResponse
  @Published var deduplicatedState: WbecWebSocketResponse
  @Published var alertWrapper: AlertWrapper?
    
    lazy var updatedCurrLimPublisher: AnyPublisher<Double, Never> = {
        return $wbecState
            .removeDuplicates {
                return  $0.currLim == $1.currLim
            }
        //.print()
            .flatMap { newstate in
                return Future<Double, Never> { promise in
                    return promise(.success(newstate.currLim))
             }
            }

        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }()
    
//    _ = socket.$wbecState.removeDuplicates {
//         return $0.currLim != $1.currLim
//    }.onch {
//         current = $0.currLim
//     }
  
  var alert: Alert? {
    didSet {
      guard let a = self.alert else { return }
      DispatchQueue.main.async {
        self.alertWrapper = .init(alert: a)
      }
    }
  }
  
  private var id: UUID!
  private let session: URLSession
  var socket: URLSessionWebSocketTask!
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()
  
    init(_ connect: Bool = true) {
        self.wbecState = WbecWebSocketResponse(id: 0, chgStat: 0, power: 0, energyI: 0.0, watt: 0, pvMode: 0, currLim: 0, timeNow: "-")
        self.deduplicatedState = WbecWebSocketResponse(id: 0, chgStat: 0, power: 0, energyI: 0.0, watt: 6, pvMode: 0, currLim: 0, timeNow: "-")
    self.alertWrapper = nil
    self.alert = nil
    
    self.session = URLSession(configuration: .default)
    if connect {
        self.connect()
    }
  }
  
  func connect() {
    self.socket = session.webSocketTask(with: URL(string: "ws://wbec:81/")!)
    self.listen()
    self.socket.resume()
  }
    
    enum pvMode: String {
        case PV_OFF
        case PV_ACTIVE
        case PV_MIN_PV
    }
  
   func updatePVMode(_ mode: pvMode) {
       self.socket.send(.string(mode.rawValue)){ (err) in
           if err != nil {
               DispatchQueue.main.async {
                   print(err.debugDescription)
               }
           }
       }
    }
    
    var leistungOld: Double = -1.0
    
    func updateLadeleistung(_ leistung: Double) {
        guard leistung != leistungOld, leistung != wbecState.currLim else { return }
        leistungOld = leistung
        self.socket.send(.string("currLim=\(leistung * 10)")){ (err) in
            if err != nil {
                DispatchQueue.main.async {
                    print(err.debugDescription)
                }
            }
        }
     }
  
  func handle(_ data: Data) {
    do {
      let sinData = try decoder.decode(WbecWebSocketResponse.self, from: data)
        DispatchQueue.main.async {
            self.wbecState = sinData
            self.leistungOld = sinData.currLim
        }
    } catch {
      print(error)
    }
  }
  
  func listen() {
    // 1
    self.socket.receive { [weak self] (result) in
      guard let self = self else { return }
      // 2
      switch result {
      case .failure(let error):
        print(error)
        // 3
        let alert = Alert(
            title: Text("Keine Verbindung zum wbec möglich!"),
            message: Text("Stelle sicher das du dich im selben WLAN befindest wie das wbec"),
            dismissButton: .default(Text("Wiederholen")) {
              self.alert = nil
              self.socket.cancel(with: .goingAway, reason: nil)
              self.connect()
            }
        )
        self.alert = alert
        return
      case .success(let message):
        // 4
        switch message {
        case .data(let data):
          self.handle(data)
        case .string(let str):
          guard let data = str.data(using: .utf8) else { return }
          self.handle(data)
        @unknown default:
          break
        }
      }
      // 5
      self.listen()
    }
  }
}
