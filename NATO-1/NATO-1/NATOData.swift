//
//  NATOData.swift
//  NATO-1
//

import Foundation

enum NATOData {

    // MARK: - All Letters

    static let allLetters: [Letter] = [
        // Batch 1 — A B C D
        Letter(id: "A", natoWord: "Alpha", emoji: "\u{1F53A}", mnemonic: "The first letter of the Greek alphabet — picture the letter A as a giant stone arch, the entrance to something ancient and important. Alpha. The beginning of everything.", batchIndex: 0),
        Letter(id: "B", natoWord: "Bravo", emoji: "\u{1F44F}", mnemonic: "A crowd on their feet, yelling \"Bravo! Bravo!\" — a single performer on stage, flowers raining down. The roar is deafening. B is Bravo.", batchIndex: 0),
        Letter(id: "C", natoWord: "Charlie", emoji: "\u{1F3A9}", mnemonic: "Charlie Chaplin — the tiny bowler hat, the twirling cane, the toothbrush mustache. The most famous Charlie who ever lived. C is Charlie.", batchIndex: 0),
        Letter(id: "D", natoWord: "Delta", emoji: "\u{2708}\u{FE0F}", mnemonic: "A river delta spreading into the sea like a triangle — the Greek letter \u{0394} stamped on the land from above. Or a Delta jet banking hard over the Mississippi. D is Delta.", batchIndex: 0),

        // Batch 2 — E F G H
        Letter(id: "E", natoWord: "Echo", emoji: "\u{1F3D4}\u{FE0F}", mnemonic: "You shout into a canyon — your own voice comes bouncing back a second later, slightly ghostly. Echo. E is Echo.", batchIndex: 1),
        Letter(id: "F", natoWord: "Foxtrot", emoji: "\u{1F98A}", mnemonic: "A fox in a tuxedo, doing a ballroom dance — the foxtrot. Perfectly dressed, gliding across the floor, ears perked. F is Foxtrot.", batchIndex: 1),
        Letter(id: "G", natoWord: "Golf", emoji: "\u{26F3}", mnemonic: "A lone golfer on an impossibly green course, squinting into the distance at a tiny flag. The satisfying thwack of the club. G is Golf.", batchIndex: 1),
        Letter(id: "H", natoWord: "Hotel", emoji: "\u{1F3E8}", mnemonic: "A grand hotel lobby — marble floors, a revolving door, a bellhop in a red uniform carrying a towering stack of luggage. H is Hotel.", batchIndex: 1),

        // Batch 3 — I J K L
        Letter(id: "I", natoWord: "India", emoji: "\u{1F418}", mnemonic: "A decorated elephant in a grand procession, moving through a city of colour and noise — the smell of spices, the sound of bells. I is India.", batchIndex: 2),
        Letter(id: "J", natoWord: "Juliet", emoji: "\u{1F339}", mnemonic: "Juliet on the balcony, moonlight, a single red rose, Romeo below in the shadows. The most famous J in all of literature. J is Juliet.", batchIndex: 2),
        Letter(id: "K", natoWord: "Kilo", emoji: "\u{2696}\u{FE0F}", mnemonic: "A perfect 1-kilogram weight sitting on a scale — dense, cold, precise. The kind of weight used to calibrate other weights. K is Kilo.", batchIndex: 2),
        Letter(id: "L", natoWord: "Lima", emoji: "\u{1FAD8}", mnemonic: "A bowl of lima beans — pale, flat, slightly waxy. The bean nobody asked for but everyone knows. Or Lima, Peru, high in the mountains above the clouds. L is Lima.", batchIndex: 2),

        // Batch 4 — M N O P
        Letter(id: "M", natoWord: "Mike", emoji: "\u{1F3A4}", mnemonic: "A stand-up microphone on a bare stage — one spotlight, nobody on stage yet. Or just Mike, the most average name for the most average guy, except he's holding a grenade. M is Mike.", batchIndex: 3),
        Letter(id: "N", natoWord: "November", emoji: "\u{1F342}", mnemonic: "November — grey skies, bare trees, the last of the leaves coming down. The month that feels like the world is exhaling before winter. N is November.", batchIndex: 3),
        Letter(id: "O", natoWord: "Oscar", emoji: "\u{1F3C6}", mnemonic: "The Oscar statuette — gold, bald, arms at its sides, staring blankly forward. A room full of people pretending not to care if they win. O is Oscar.", batchIndex: 3),
        Letter(id: "P", natoWord: "Papa", emoji: "\u{1F468}", mnemonic: "Papa — your father, or someone else's, sitting in a big chair with a newspaper. Or the Papa in \"Papa, can you hear me?\" called across a field. P is Papa.", batchIndex: 3),

        // Batch 5 — Q R S T
        Letter(id: "Q", natoWord: "Quebec", emoji: "\u{1F341}", mnemonic: "Quebec City in winter — stone walls, snow, a French sign above a café door. The sound of French spoken with a Canadian lilt. Q is Quebec.", batchIndex: 4),
        Letter(id: "R", natoWord: "Romeo", emoji: "\u{1F5E1}\u{FE0F}", mnemonic: "Romeo below the balcony — dramatic, lovesick, probably about to do something stupid. R is Romeo. (He and Juliet are in different batches on purpose.)", batchIndex: 4),
        Letter(id: "S", natoWord: "Sierra", emoji: "\u{1F3D4}\u{FE0F}", mnemonic: "The Sierra Nevada — jagged granite peaks, pine forests, the smell of cold air at altitude. Sierra. The mountains that divide California from everything east of it. S is Sierra.", batchIndex: 4),
        Letter(id: "T", natoWord: "Tango", emoji: "\u{1F483}", mnemonic: "Two dancers locked together, moving across a wooden floor in Buenos Aires — precise, slow, electric. The tango. T is Tango.", batchIndex: 4),

        // Batch 6 — U V W
        Letter(id: "U", natoWord: "Uniform", emoji: "\u{1F46E}", mnemonic: "A perfectly pressed uniform — brass buttons, creased trousers, polished shoes. The kind worn by someone who takes pride in looking exactly right. U is Uniform.", batchIndex: 5),
        Letter(id: "V", natoWord: "Victor", emoji: "\u{1F3C5}", mnemonic: "Victor on the podium — arms raised, gold medal swinging, the crowd going wild. The name means winner. V is Victor.", batchIndex: 5),
        Letter(id: "W", natoWord: "Whiskey", emoji: "\u{1F943}", mnemonic: "A glass of whiskey on a wooden bar — amber, still, a single ice cube slowly melting. The smell of peat and oak. W is Whiskey.", batchIndex: 5),

        // Batch 7 — X Y Z
        Letter(id: "X", natoWord: "X-ray", emoji: "\u{1F9B4}", mnemonic: "An X-ray clipped to a light box — your own skeleton staring back at you. Ribs, vertebrae, the ghostly outline of everything hidden inside. X is X-ray.", batchIndex: 6),
        Letter(id: "Y", natoWord: "Yankee", emoji: "\u{26BE}", mnemonic: "A Yankees cap — pinstripes, the interlocking NY, the smell of a baseball stadium on a warm evening. Or just a loud American tourist. Y is Yankee.", batchIndex: 6),
        Letter(id: "Z", natoWord: "Zulu", emoji: "\u{1F6E1}\u{FE0F}", mnemonic: "A Zulu warrior in full ceremonial dress — cowhide shield, assegai spear, the deep thrum of voices. Or Zulu time — UTC, the clock all aviators use. Z is Zulu.", batchIndex: 6),
    ]

    // MARK: - Encode Words by Batch

    private static let encodeWordsByBatch: [[EncodeWord]] = [
        // Batch 1 — A B C D (4 words)
        [
            EncodeWord(id: "CAD", natoSpelling: ["Charlie", "Alpha", "Delta"]),
            EncodeWord(id: "BAD", natoSpelling: ["Bravo", "Alpha", "Delta"]),
            EncodeWord(id: "CAB", natoSpelling: ["Charlie", "Alpha", "Bravo"]),
            EncodeWord(id: "DAB", natoSpelling: ["Delta", "Alpha", "Bravo"]),
        ],
        // Batch 2 — + E F G H (3 words)
        [
            EncodeWord(id: "BEACH", natoSpelling: ["Bravo", "Echo", "Alpha", "Charlie", "Hotel"]),
            EncodeWord(id: "BADGE", natoSpelling: ["Bravo", "Alpha", "Delta", "Golf", "Echo"]),
            EncodeWord(id: "CABBAGE", natoSpelling: ["Charlie", "Alpha", "Bravo", "Bravo", "Alpha", "Golf", "Echo"]),
        ],
        // Batch 3 — + I J K L (3 words)
        [
            EncodeWord(id: "FLAK", natoSpelling: ["Foxtrot", "Lima", "Alpha", "Kilo"]),
            EncodeWord(id: "BLACK", natoSpelling: ["Bravo", "Lima", "Alpha", "Charlie", "Kilo"]),
            EncodeWord(id: "HIJACK", natoSpelling: ["Hotel", "India", "Juliet", "Alpha", "Charlie", "Kilo"]),
        ],
        // Batch 4 — + M N O P (3 words)
        [
            EncodeWord(id: "FLANK", natoSpelling: ["Foxtrot", "Lima", "Alpha", "November", "Kilo"]),
            EncodeWord(id: "PHONE", natoSpelling: ["Papa", "Hotel", "Oscar", "November", "Echo"]),
            EncodeWord(id: "PINHOLE", natoSpelling: ["Papa", "India", "November", "Hotel", "Oscar", "Lima", "Echo"]),
        ],
        // Batch 5 — + Q R S T (3 words)
        [
            EncodeWord(id: "STORM", natoSpelling: ["Sierra", "Tango", "Oscar", "Romeo", "Mike"]),
            EncodeWord(id: "RECON", natoSpelling: ["Romeo", "Echo", "Charlie", "Oscar", "November"]),
            EncodeWord(id: "SORTIE", natoSpelling: ["Sierra", "Oscar", "Romeo", "Tango", "India", "Echo"]),
        ],
        // Batch 6 — + U V W (3 words)
        [
            EncodeWord(id: "OUTPOST", natoSpelling: ["Oscar", "Uniform", "Tango", "Papa", "Oscar", "Sierra", "Tango"]),
            EncodeWord(id: "GUNWALE", natoSpelling: ["Golf", "Uniform", "November", "Whiskey", "Alpha", "Lima", "Echo"]),
            EncodeWord(id: "VECTORS", natoSpelling: ["Victor", "Echo", "Charlie", "Tango", "Oscar", "Romeo", "Sierra"]),
        ],
        // Batch 7 — + X Y Z (3 words)
        [
            EncodeWord(id: "MAYDAY", natoSpelling: ["Mike", "Alpha", "Yankee", "Delta", "Alpha", "Yankee"]),
            EncodeWord(id: "FOXHOLE", natoSpelling: ["Foxtrot", "Oscar", "X-ray", "Hotel", "Oscar", "Lima", "Echo"]),
            EncodeWord(id: "BLIZZARD", natoSpelling: ["Bravo", "Lima", "India", "Zulu", "Zulu", "Alpha", "Romeo", "Delta"]),
        ],
    ]

    // MARK: - Batches

    static let batches: [Batch] = {
        var result: [Batch] = []
        for batchIndex in 0..<7 {
            let letters = allLetters.filter { $0.batchIndex == batchIndex }
            let encodeWords = encodeWordsByBatch[batchIndex]
            result.append(Batch(id: batchIndex, letters: letters, encodeWords: encodeWords))
        }
        return result
    }()

    // MARK: - Lookup Helpers

    static func letter(for character: Character) -> Letter? {
        allLetters.first { $0.id == character }
    }

    static func letter(forId id: String) -> Letter? {
        guard let char = id.first else { return nil }
        return letter(for: char)
    }

    static func natoWord(for character: Character) -> String? {
        letter(for: character)?.natoWord
    }

    static func natoWord(forId id: String) -> String? {
        letter(forId: id)?.natoWord
    }

    static func batch(at index: Int) -> Batch? {
        guard index >= 0 && index < batches.count else { return nil }
        return batches[index]
    }

    /// Returns all encode words available given a set of completed batch indices
    static func availableEncodeWords(forCompletedBatches indices: Set<Int>) -> [EncodeWord] {
        indices.sorted().flatMap { batches[$0].encodeWords }
    }

    /// Generates a random encode word using only letters from completed batches
    static func randomEncodeWords(count: Int, fromCompletedBatches indices: Set<Int>) -> [EncodeWord] {
        let available = availableEncodeWords(forCompletedBatches: indices)
        guard !available.isEmpty else { return [] }
        return Array(available.shuffled().prefix(count))
    }
}
