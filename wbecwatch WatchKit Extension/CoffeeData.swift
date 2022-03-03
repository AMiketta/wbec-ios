/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A data object that tracks the number of drinks that the user has drunk.
*/

import SwiftUI
import ClockKit
import os

private let floatFormatter = FloatingPointFormatStyle<Double>().precision(.significantDigits(1...3))

private actor WbecDataStore {
    
    let logger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.WbecDataStore", category: "ModelIO")
    
    // Use this value to determine whether you have changes that can be saved to disk.
    private var savedValue: [WbecWebSocketResponse] = []
    
    // Begin saving the drink data to disk.
    func save(_ currentDrinks: [WbecWebSocketResponse]) {
        
        // Don't save the data if there haven't been any changes.
        if currentDrinks == savedValue {
            logger.debug("The drink list hasn't changed. No need to save.")
            return
        }
        
        // Save as a binary plist file.
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        
        let data: Data
        
        do {
            // Encode the currentDrinks array.
            data = try encoder.encode(currentDrinks)
        } catch {
            logger.error("An error occurred while encoding the data: \(error.localizedDescription)")
            return
        }
        
        // Save the data to disk as a binary plist file.
        do {
            // Write the data to disk
            logger.debug("Asynchronously saving the model on a background thread.")
            try data.write(to: self.dataURL, options: [.atomic])
            
            // Update the saved value.
            self.savedValue = currentDrinks
            
            self.logger.debug("Saved!")
        } catch {
            self.logger.error("An error occurred while saving the data: \(error.localizedDescription)")
        }
    }
    
    // Begin loading the data from disk.
    func load() -> [WbecWebSocketResponse] {
        // Read the data from a background queue.
        logger.debug("Loading the model.")
        
        var drinks: [WbecWebSocketResponse]
        
        do {
            // Load the drink data from a binary plist file.
            let data = try Data(contentsOf: self.dataURL)
            
            // Decode the data.
            let decoder = PropertyListDecoder()
            drinks = try decoder.decode([WbecWebSocketResponse].self, from: data)
            logger.debug("Data loaded from disk")
        } catch CocoaError.fileReadNoSuchFile {
            logger.debug("No file found--creating an empty drink list.")
            drinks = []
        } catch {
            logger.error("*** An unexpected error occurred while loading the drink list: \(error.localizedDescription) ***")
            fatalError()
        }
        
        savedValue = drinks
        
        return drinks
    }
    
    // The URL for the plist file that stores the drink data.
    private var dataURL: URL {
        get throws {
            try FileManager
                   .default
                   .url(for: .documentDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: false)
                   // Append the file name to the directory.
                   .appendingPathComponent("CoffeeTracker.plist")
        }
    }

}

// The data model for the Coffee Tracker app.
@MainActor
class WbecData: ObservableObject {
    
    let logger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.CoffeeData", category: "Model")
    
    // The data model needs to be accessed both from the app extension
    // and from the complication controller.
    static let shared = WbecData()
  //  lazy var healthKitController = HealthKitController(withModel: self)
    
    // An actor used to save and load the model data in the background.
    private let store = WbecDataStore()
    
    // The list of drinks consumed.
    // Because this is @Published property,
    // Combine updates the app's main interface when a change occurs.
    @Published public private(set) var currentDrinks: [WbecWebSocketResponse] = []
    
    // Asynchronously update any active complications and save
    // the list of drinks after the current drinks property changes.
    private func drinkDataUpdated() async {
        logger.debug("Updating the system based on the new current drinks property.")
        
        // Save the app's data.
        await store.save(currentDrinks)
        
        // Update any complications on active watch faces.
        let server = CLKComplicationServer.sharedInstance()
        let complications = await server.getActiveComplications()
        
        for complication in complications {
            server.reloadTimeline(for: complication)
        }
    }
    
    // Calculate the amount of caffeine in the user's system at the specified date.
    // The amount of caffeine is calculated from the currentDrinks array.
    public func mgCaffeine(atDate date: Date) -> Double {
        currentDrinks.reduce(0.0) { total, drink in
            total + 1
        }
    }
    
    // Return a user-readable string that describes the amount of caffeine in the user's
    // system at the specified date.
    public func mgCaffeineString(atDate date: Date) -> String {
        mgCaffeine(atDate: date).formatted(floatFormatter)
    }
    
    // Return the total number of drinks consumed today.
    // The value is in the equivalent number of 8 oz. cups of coffee.
    public var totalCupsToday: Double {
        
        // Calculate midnight this morning.
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())
        
        // Filter the drinks.
        let drinks = 1
        
        // Get the total caffeine dose.
        let totalMG = 100.0
        
        // Convert mg caffeine to equivalent cups.
        return totalMG / 10.0
    }
    
    // Return the total equivalent cups of coffee as a user-readable string.
    public var totalCupsTodayString: String {
        totalCupsToday.formatted(floatFormatter)
    }
    
    // Return green, yellow, or red depending on the caffeine dose.
    public func color(forCaffeineDose dose: Double) -> UIColor {
        if dose < 200.0 {
            return .green
        } else if dose < 400.0 {
            return .yellow
        } else {
            return .red
        }
    }
    
    // Return green, yellow, or red depending on the total daily cups of  coffee.
    public func color(forTotalCups cups: Double) -> UIColor {
        if cups < 3.0 {
            return .green
        } else if cups < 5.0 {
            return .yellow
        } else {
            return .red
        }
    }
    
 

    
    // MARK: - Private Methods
    
    // The model's initializer. Do not call this method.
    // Use the shared instance instead.
    private init() {
        
        // Begin loading the data from disk.
        Task.detached { await self.load() }
    }
 
    // Update the entires on the main queue.
    private func load() async {
        
        var drinks = await store.load()
        
        // Filter the drinks.
        drinks.removeOutdatedDrinks()
        
        currentDrinks = drinks
        await loadFromHealthKit()
    }
    
    public func loadFromHealthKit() async {
        
        
    }
}

extension CLKComplicationServer {
    
    // Safely access the server's active complications.
    @MainActor
    func getActiveComplications() async -> [CLKComplication] {
        return await withCheckedContinuation { continuation in
            
            // First, set up the notification.
            let center = NotificationCenter.default
            let mainQueue = OperationQueue.main
            var token: NSObjectProtocol?
            token = center.addObserver(forName: .CLKComplicationServerActiveComplicationsDidChange, object: nil, queue: mainQueue) { _ in
                center.removeObserver(token!)
                continuation.resume(returning: self.activeComplications!)
            }
            
            // Then check to see if we have a valid active complications array.
            if activeComplications != nil {
                center.removeObserver(token!)
                continuation.resume(returning: self.activeComplications!)
            }
        }
    }
}

extension Array where Element == WbecWebSocketResponse {
    
    // Filter array to only the drinks in the last 24 hours.
    fileprivate mutating func removeOutdatedDrinks() {
       
    }
}
