//
//  Constants.swift
//  NATO-1
//

import Foundation

enum AppConstants {

    // MARK: - SRS Intervals

    enum SRS {
        static let tier1Interval: TimeInterval = 4 * 60 * 60        // 4 hours
        static let tier2Interval: TimeInterval = 24 * 60 * 60       // 1 day
        static let tier3Interval: TimeInterval = 3 * 24 * 60 * 60   // 3 days
        static let tier4Interval: TimeInterval = 7 * 24 * 60 * 60   // 7 days

        static func interval(for tier: Int) -> TimeInterval {
            switch tier {
            case 1: return tier1Interval
            case 2: return tier2Interval
            case 3: return tier3Interval
            case 4: return tier4Interval
            default: return tier1Interval
            }
        }
    }

    // MARK: - Drill Session

    enum Drill {
        static let encodeCardFrequency: Int = 5  // 1 encode card per N letter cards
        static let encodePracticeRoundSize: Int = 5
    }

    // MARK: - Learning Session

    enum Learning {
        static let batch1EncodeWordCount: Int = 4
        static let defaultEncodeWordCount: Int = 3
    }

    // MARK: - Batches

    static let freeBatchIndex: Int = 0  // Batch 1 (index 0) is free
}
