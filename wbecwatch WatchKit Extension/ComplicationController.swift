//
//  ComplicationController.swift
//  wbecwatch WatchKit Extension
//
//  Created by Andreas Miketta on 21.02.22.
//

import ClockKit
import Combine


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    let service: WebSocketController = .init(false)
    var cancelable: AnyCancellable?
    var dataArray: [Double] = []
    func requestedUpdateDidBegin() {
        service.connect()
        cancelable = service.$wbecState.sink(receiveValue: { data in
            self.dataArray.append(data.currLim)
        })
    }
    
    func requestedUpdateBudgetExhausted() {
        self.cancelable?.cancel()
        self.service.socket.cancel(with: .goingAway, reason: nil)
    }
    
    let supportedFamilies: [CLKComplicationFamily] = [CLKComplicationFamily.circularSmall, CLKComplicationFamily.graphicCircular]

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "wbec", supportedFamilies: supportedFamilies)
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        guard complication.family == .circularSmall || complication.family == .graphicCircular, let data = dataArray.last else {
                handler(nil)
                return
            }
        
        let line1 = CLKSimpleTextProvider(text:"\(data) A") // get real Values from DB
        let smallRingTemplate = CLKComplicationTemplateModularSmallRingText(textProvider: line1, fillFraction: Float(data / 16), ringStyle: .open)
        let timelineEntry = CLKComplicationTimelineEntry(date: .now, complicationTemplate: smallRingTemplate)
        handler(timelineEntry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard complication.family == .circularSmall || complication.family == .graphicCircular else {
                handler(nil)
                return
            }
        
        var entries = [CLKComplicationTimelineEntry]()
        
        for i in 0...(limit) {
            if i < dataArray.count {
            var futureDate = date
                        futureDate.addTimeInterval(TimeInterval(60 * i))
                let line1 = CLKSimpleTextProvider(text:"\(dataArray[i]) A") // get real Values from DB
                let smallRingTemplate = CLKComplicationTemplateModularSmallRingText(textProvider: line1, fillFraction: Float(dataArray[i] / 16), ringStyle: .open)
            let timelineEntry = CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: smallRingTemplate)
            entries.append(timelineEntry)
            }
        }
        handler(entries)
        // Call the handler with the timeline entries after the given date
//        let service: WebSocketController = .init()
//        _ = service.$wbecState.sink{
//
//            let line1 = CLKSimpleTextProvider(text:"\($0.currLim) A")
//            let smallRingTemplate = CLKComplicationTemplateCircularSmallRingText(textProvider: line1, fillFraction: Float(16 / $0.currLim), ringStyle: .open)
//            let smallRingEntry = CLKComplicationTimelineEntry(date: date.addingTimeInterval(Double(2)), complicationTemplate: smallRingTemplate)
//            handler([smallRingEntry])
//        }
        
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        
        guard complication.family == .circularSmall || complication.family == .graphicCircular else {
                handler(nil)
                return
            }
        
        let line1 = CLKSimpleTextProvider(text:"\(6) A")
        let smallRingTemplate = CLKComplicationTemplateModularSmallRingText(textProvider: line1, fillFraction: Float(16 / 6), ringStyle: .open)
        // This method will be called once per supported complication, and the results will be cached
        handler(smallRingTemplate)
    }
}
