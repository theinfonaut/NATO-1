//
//  Constants.swift
//  NATO-1
//

import Foundation

enum AppConstants {

    // MARK: - App Info

    enum App {
        static let name = "NATO-1"
        static let version = "1.0.0"
        static let studioName = "Tiny Tools Studio"
    }

    // MARK: - SRS Intervals

    enum SRS {
        // Production intervals
        static let productionTier1: TimeInterval = 4 * 60 * 60      // 4 hours
        static let productionTier2: TimeInterval = 24 * 60 * 60     // 1 day
        static let productionTier3: TimeInterval = 3 * 24 * 60 * 60 // 3 days
        static let productionTier4: TimeInterval = 7 * 24 * 60 * 60 // 7 days

        // Test intervals
        static let testInterval: TimeInterval = 10  // 10 seconds for all tiers

        // Current mode stored in UserDefaults
        private static let testModeKey = "nato1.testIntervalsEnabled"

        static var isTestMode: Bool {
            get { UserDefaults.standard.bool(forKey: testModeKey) }
            set { UserDefaults.standard.set(newValue, forKey: testModeKey) }
        }

        static var tier1Interval: TimeInterval {
            isTestMode ? testInterval : productionTier1
        }

        static var tier2Interval: TimeInterval {
            isTestMode ? testInterval : productionTier2
        }

        static var tier3Interval: TimeInterval {
            isTestMode ? testInterval : productionTier3
        }

        static var tier4Interval: TimeInterval {
            isTestMode ? testInterval : productionTier4
        }

        static func interval(for tier: Int) -> TimeInterval {
            switch tier {
            case 1: return tier1Interval
            case 2: return tier2Interval
            case 3: return tier3Interval
            case 4: return tier4Interval
            default: return tier1Interval
            }
        }

        static func toggleTestMode() {
            isTestMode.toggle()
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
