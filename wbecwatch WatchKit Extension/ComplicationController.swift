////
////  ComplicationController.swift
////  wbecwatch WatchKit Extension
////
////  Created by Andreas Miketta on 21.02.22.
////
//
//import ClockKit
//import Combine
//import os
//
//
//class ComplicationController: NSObject, CLKComplicationDataSource {
//    let logger = Logger(subsystem:
//                            "com.miketta.wbec.watchkitapp.watchkitextension.complicationcontroller",
//                        category: "Complication")
//    
//    // MARK: - Complication Configuration
//   // let service: WebSocketController = .init(false)
//    var cancelable: AnyCancellable?
//    var dataArray: [Double] = []
//    // The Coffee Tracker app's data model
//    lazy var data = CoffeeData.shared
//    
//    let supportedFamilies: [CLKComplicationFamily] = CLKComplicationFamily.allCases
//
//    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
//        let descriptors = [
//            CLKComplicationDescriptor(identifier: "complication", displayName: "wbec", supportedFamilies: supportedFamilies)
//            // Multiple complication support can be added here with more descriptors
//        ]
//        
//        // Call the handler with the currently supported complication descriptors
//        handler(descriptors)
//    }
//    
//    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
//        // Do any necessary work to support these newly shared complication descriptors
//    }
//
//    // MARK: - Timeline Configuration
//    
//    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
//        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
//        handler(nil)
//    }
//    
//    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
//        // Call the handler with your desired behavior when the device is locked
//        handler(.showOnLockScreen)
//    }
//    
//    // MARK: - Timeline Population
//
//    // Return the current timeline entry.
//    func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
//        logger.debug("Accessing the current timeline entry.")
//        return createTimelineEntry(forComplication: complication, date: Date())
//    }
//
//    // Return future timeline entries.
//    func timelineEntries(for complication: CLKComplication,
//                         after date: Date,
//                         limit: Int) async -> [CLKComplicationTimelineEntry]? {
//        logger.debug("Accessing timeline entries for dates after \(DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)).")
//
//        let fiveMinutes = 5.0 * 60.0
//        let twentyFourHours = 24.0 * 60.0 * 60.0
//
//        // Create an array to hold the timeline entries.
//        var entries: [CLKComplicationTimelineEntry] = []
//
//        // Calculate the start and end dates.
//        var current = date.addingTimeInterval(fiveMinutes)
//        let endDate = date.addingTimeInterval(twentyFourHours)
//
//        // Create a timeline entry for every five minutes from the starting time.
//        // Stop once you reach the limit or the end date.
//        while current < endDate && entries.count < limit {
//            entries.append(createTimelineEntry(forComplication: complication, date: current))
//            current = current.addingTimeInterval(fiveMinutes)
//        }
//
//        return entries
//    }
//
//    // MARK: - Placeholder Templates
//
//    // Return a localized template with generic information.
//    // The system displays the placeholder in the complication selector.
//    func localizableSampleTemplate(for complication: CLKComplication) async -> CLKComplicationTemplate? {
//        
//        // Calculate the date 25 hours from now.
//        // Since it's more than 24 hours in the future,
//        // Our template will always show zero cups and zero mg caffeine.
//        let future = Date().addingTimeInterval(25.0 * 60.0 * 60.0)
//        return createTemplate(forComplication: complication, date: future)
//    }
//    
//    //    We don't need to implement this method because our privacy behavior is hideOnLockScreen.
//    //    Always-On Time automatically hides complications that would be hidden when the device is locked
//    //    func alwaysOnTemplate(for complication: CLKComplication) async -> CLKComplicationTemplate? {
//    //    }
//    
//    // MARK: - Private Methods
//    
//    // Return a timeline entry for the specified complication and date.
//    private func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
//        
//        // Get the correct template based on the complication.
//        let template = createTemplate(forComplication: complication, date: date)
//        
//        // Use the template and date to create a timeline entry.
//        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
//    }
//    
//    // Select the correct template based on the complication's family.
//    private func createTemplate(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTemplate {
//        switch complication.family {
//        case .modularSmall:
//            return createModularSmallTemplate(forDate: date)
//        case .modularLarge:
//            return createModularLargeTemplate(forDate: date)
//        case .utilitarianSmall, .utilitarianSmallFlat:
//            return createUtilitarianSmallFlatTemplate(forDate: date)
//        case .utilitarianLarge:
//            return createUtilitarianLargeTemplate(forDate: date)
//        case .circularSmall:
//            return createCircularSmallTemplate(forDate: date)
//        case .extraLarge:
//            return createExtraLargeTemplate(forDate: date)
//        case .graphicCorner:
//            return createGraphicCornerTemplate(forDate: date)
//        case .graphicCircular:
//            return createGraphicCircleTemplate(forDate: date)
//        case .graphicRectangular:
//            return createGraphicRectangularTemplate(forDate: date)
//        case .graphicBezel:
//            return createGraphicBezelTemplate(forDate: date)
//        case .graphicExtraLarge:
//            return createGraphicExtraLargeTemplate(forDate: date)
//    
//        @unknown default:
//            logger.error("Unknown Complication Family")
//            fatalError()
//        }
//    }
//    
//    // Return a modular small template.
//    private func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        
//        // Create the template using the providers.
//        return CLKComplicationTemplateModularSmallStackText(line1TextProvider: mgCaffeineProvider,
//                                                            line2TextProvider: mgUnitProvider)
//    }
//    
//    // Return a modular large template.
//    private func createModularLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let titleTextProvider = CLKSimpleTextProvider(text: "Coffee Tracker", shortText: "Coffee")
//
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        let combinedMGProvider = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
//               
//        let numberOfCupsProvider = CLKSimpleTextProvider(text: data.totalCupsTodayString)
//        let cupsUnitProvider = CLKSimpleTextProvider(text: "Cups", shortText: "C")
//        let combinedCupsProvider = CLKTextProvider(format: "%@ %@", numberOfCupsProvider, cupsUnitProvider)
//        
//        // Create the template using the providers.
//        let imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "CoffeeModularLarge"))
//        return CLKComplicationTemplateModularLargeStandardBody(headerImageProvider: imageProvider,
//                                                               headerTextProvider: titleTextProvider,
//                                                               body1TextProvider: combinedCupsProvider,
//                                                               body2TextProvider: combinedMGProvider)
//    }
//    
//    // Return a utilitarian small flat template.
//    private func createUtilitarianSmallFlatTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let flatUtilitarianImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "CoffeeSmallFlat"))
//        
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        let combinedMGProvider = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
//        
//        // Create the template using the providers.
//        return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: combinedMGProvider,
//                                                           imageProvider: flatUtilitarianImageProvider)
//    }
//    
//    // Return a utilitarian large template.
//    private func createUtilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let flatUtilitarianImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "CoffeeSmallFlat"))
//        
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        let combinedMGProvider = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
//        
//        // Create the template using the providers.
//        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: combinedMGProvider,
//                                                           imageProvider: flatUtilitarianImageProvider)
//    }
//    
//    // Return a circular small template.
//    private func createCircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        
//        // Create the template using the providers.
//        return CLKComplicationTemplateCircularSmallStackText(line1TextProvider: mgCaffeineProvider,
//                                                             line2TextProvider: mgUnitProvider)
//    }
//    
//    // Return an extra large template.
//    private func createExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg")
//        
//        // Create the template using the providers.
//        return CLKComplicationTemplateExtraLargeStackText(line1TextProvider: mgCaffeineProvider,
//                                                          line2TextProvider: mgUnitProvider)
//    }
//    
//    // Return a graphic template that fills the corner of the watch face.
//    private func createGraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let leadingValueProvider = CLKSimpleTextProvider(text: "0")
//        leadingValueProvider.tintColor = data.color(forCaffeineDose: 0.0)
//        
//        let trailingValueProvider = CLKSimpleTextProvider(text: "500")
//        trailingValueProvider.tintColor = data.color(forCaffeineDose: 500.0)
//        
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
//        let combinedMGProvider = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
//        
//        let percentage = Float(min(data.mgCaffeine(atDate: date) / 500.0, 1.0))
//        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
//                                                   gaugeColors: [.green, .yellow, .red],
//                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
//                                                   fillFraction: percentage)
//        
//        // Create the template using the providers.
//        return CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: gaugeProvider,
//                                                             leadingTextProvider: leadingValueProvider,
//                                                             trailingTextProvider: trailingValueProvider,
//                                                             outerTextProvider: combinedMGProvider)
//    }
//    
//    // Return a graphic circle template.
//    private func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let percentage = Float(min(data.mgCaffeine(atDate: date) / 500.0, 1.0))
//        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
//                                                   gaugeColors: [.green, .yellow, .red],
//                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
//                                                   fillFraction: percentage)
//        
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
//        
//        // Create the template using the providers.
//        return CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gaugeProvider,
//                                                                         bottomTextProvider: CLKSimpleTextProvider(text: "mg"),
//                                                                         centerTextProvider: mgCaffeineProvider)
//    }
//    
//    // Return a large rectangular graphic template.
//    private func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "CoffeeGraphicRectangular"))
//        let titleTextProvider = CLKSimpleTextProvider(text: "Coffee Tracker", shortText: "Coffee")
//        
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
//        let combinedMGProvider = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
//        
//        let percentage = Float(min(data.mgCaffeine(atDate: date) / 500.0, 1.0))
//        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
//                                                   gaugeColors: [.green, .yellow, .red],
//                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
//                                                   fillFraction: percentage)
//        
//        // Create the template using the providers.
//        
//        return CLKComplicationTemplateGraphicRectangularTextGauge(headerImageProvider: imageProvider,
//                                                                  headerTextProvider: titleTextProvider,
//                                                                  body1TextProvider: combinedMGProvider,
//                                                                  gaugeProvider: gaugeProvider)
//    }
//    
//    // Return a circular template with text that wraps around the top of the watch's bezel.
//    private func createGraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        
//        // Create a graphic circular template with an image provider.
//        let circle = CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "CoffeeGraphicCircular")))
//        
//        // Create the text provider.
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//        mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
//        let combinedMGProvider = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
//               
//        let numberOfCupsProvider = CLKSimpleTextProvider(text: data.totalCupsTodayString)
//        let cupsUnitProvider = CLKSimpleTextProvider(text: "Cups", shortText: "C")
//        cupsUnitProvider.tintColor = data.color(forTotalCups: data.totalCupsToday)
//        let combinedCupsProvider = CLKTextProvider(format: "%@ %@", numberOfCupsProvider, cupsUnitProvider)
//        
//        let separator = NSLocalizedString(",", comment: "Separator for compound data strings.")
//        let textProvider = CLKTextProvider(format: "%@%@ %@",
//                                           combinedMGProvider,
//                                           separator,
//                                           combinedCupsProvider)
//        
//        // Create the bezel template using the circle template and the text provider.
//        return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circle,
//                                                               textProvider: textProvider)
//    }
//    
//    // Returns an extra large graphic template.
//    private func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        
//        // Create the data providers.
//        let percentage = Float(min(data.mgCaffeine(atDate: date) / 500.0, 1.0))
//        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
//                                                   gaugeColors: [.green, .yellow, .red],
//                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
//                                                   fillFraction: percentage)
//        
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
//        
//        return CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeSimpleText(
//            gaugeProvider: gaugeProvider,
//            bottomTextProvider: CLKSimpleTextProvider(text: "mg"),
//            centerTextProvider: mgCaffeineProvider)
//    }
//}
