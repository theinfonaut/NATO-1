//
//  DesignSystem.swift
//  NATO-1
//
//  DOS Terminal visual direction constants.
//  All timing, color, and type values live here — tunable in one place.
//
//  FONT SETUP (one-time, manual steps required):
//    1. Download Intel One Mono from https://github.com/intel/intel-one-mono/releases
//       Get: IntelOneMono-Regular.ttf (and Bold if needed)
//    2. Drag the .ttf file(s) into the NATO-1 folder in Xcode.
//       Make sure "Add to target: NATO-1" is checked.
//    3. In Xcode → target → Info tab, add "Fonts provided by application" (UIAppFonts)
//       as an Array, with each .ttf filename as a String item.
//    Until the font is installed, SwiftUI silently falls back to the system font.

import SwiftUI

// MARK: - Design System

enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        /// Deep terminal background. Use .ignoresSafeArea() on the background layer only.
        static let background = Color(hex: "041302")

        /// Bright tappable — ONLY on elements the user can currently tap.
        static let tappable = Color(hex: "12F6A1")

        /// Dim — all non-interactive text and decoration.
        static let dim = Color(hex: "1C835B")

        // ── Increase Contrast variants ──
        // Both colors shift UP together so the bright/dim gap is preserved.
        // Standard dim is ~4.1:1 vs background; HC dim clears 4.5:1.
        // HC tappable lifts toward pale near-white green.

        /// High-contrast dim — modest lift from #1C835B, ~4.9:1 vs #041302.
        static let dimHighContrast = Color(hex: "239168")

        /// High-contrast tappable — pale near-white green, ~15.8:1 vs #041302.
        static let tappableHighContrast = Color(hex: "80FFCC")

        /// Returns the correct dim color for the current accessibility contrast setting.
        static func dim(for contrast: ColorSchemeContrast) -> Color {
            contrast == .increased ? dimHighContrast : dim
        }

        /// Returns the correct tappable color for the current accessibility contrast setting.
        static func tappable(for contrast: ColorSchemeContrast) -> Color {
            contrast == .increased ? tappableHighContrast : tappable
        }
    }

    // MARK: - Typography

    enum Typography {
        // PostScript names for the bundled Intel One Mono typeface.
        // If the font isn't installed yet, SwiftUI silently falls back to the system font.
        static let fontNameRegular = "IntelOneMono-Regular"
        static let fontNameBold    = "IntelOneMono-Bold"

        /// Letter spacing multiplier (em units). Spec: ~0.08em.
        /// Apply as: font size × letterSpacingEm = tracking points.
        static let letterSpacingEm: Double = 0.08

        /// Minimum size for dim / decorative text. Spec: 17pt.
        static let minDimSize: CGFloat = 17

        /// Leader dot repeating unit. Period + single space (2 columns per dot). Tunable.
        static let leaderDotUnit = ". "

        /// Rule dash repeating unit. Hyphen + space. Tunable.
        static let ruleDashUnit = "- "

        /// Descender-to-line-height ratio for the terminal font.
        /// All-caps labels have no descenders, so the glyphs sit in the upper
        /// portion of the line box. Symmetric padding looks bottom-heavy.
        /// This ratio is used to shift chip backgrounds up so letterforms
        /// appear optically centered. Computed from the font's actual metrics
        /// so it scales with Dynamic Type.
        static var capsVerticalBias: CGFloat {
            let font = UIFont(name: fontNameRegular, size: minDimSize)
                ?? .monospacedSystemFont(ofSize: minDimSize, weight: .regular)
            let scaled = UIFontMetrics.default.scaledFont(for: font)
            // descender is negative; we want the magnitude as a fraction of line height
            return abs(scaled.descender) / scaled.lineHeight
        }

        // MARK: Font helpers

        /// Returns the terminal font at the given size and weight.
        static func terminal(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            let name = weight == .bold ? fontNameBold : fontNameRegular
            return Font.custom(name, size: size)
        }

        /// Title font — bold at body size. Used for emphasis only, not as an affordance signal.
        static var title: Font { terminal(minDimSize, weight: .bold) }

        /// Tracking (letter spacing) in points for a given font size.
        /// Pass the same size you used for the font.
        static func tracking(for size: CGFloat) -> CGFloat {
            CGFloat(letterSpacingEm) * size
        }
    }

    // MARK: - Metrics (column grid)

    enum Metrics {
        /// Width of one monospace column at the current Dynamic Type scale.
        /// Measured from a 50-character sample so tracking error doesn't compound.
        /// The trailing kern after the last character is subtracted before dividing,
        /// since it adds invisible space that doesn't correspond to a visible column.
        ///
        /// This is a computed property (not a stored constant) because Dynamic Type
        /// can change at any time. The measurement must use the same scaled font
        /// that SwiftUI renders with `Font.custom(_:size:)`.
        static var columnWidth: CGFloat {
            let baseFont = UIFont(name: Typography.fontNameRegular, size: Typography.minDimSize)
                ?? .monospacedSystemFont(ofSize: Typography.minDimSize, weight: .regular)
            let scaledFont = UIFontMetrics.default.scaledFont(for: baseFont)
            let scaledSize = scaledFont.pointSize
            let tracking = Typography.tracking(for: scaledSize)
            let sample = String(repeating: "X", count: 50)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: scaledFont,
                .kern: tracking
            ]
            let totalWidth = (sample as NSString).size(withAttributes: attrs).width
            // Subtract the trailing kern — it's applied after the last character
            // but doesn't correspond to a visible glyph column.
            let usableWidth = totalWidth - tracking
            return usableWidth / 50
        }

        /// Minimum horizontal margin per side. The actual margin will be
        /// at least this large; any leftover fractional-column space is
        /// split evenly between the two sides.
        static let minHorizontalMargin: CGFloat = 16

        /// Strict floor — guaranteed to fit within the given width.
        static func columns(fittingWidth width: CGFloat) -> Int {
            max(0, Int(width / columnWidth))
        }
    }

    // MARK: - Blink

    enum Blink {
        /// Duration of each visible / hidden phase in seconds.
        /// Spec: ~530ms per phase (1.06s cycle). Step change, never a fade.
        static let phaseSeconds: Double = 0.530

        /// Full on/off cycle duration.
        static let cycleSeconds: Double = phaseSeconds * 2  // 1.06s
    }

    // MARK: - Typewriter (Batch 1 explainer)

    enum Typewriter {
        /// Delay between each printed character (milliseconds). Spec: ~33ms.
        static let charDelayMs: Double = 33

        /// Extra delay inserted at each line break (milliseconds). Spec: +120ms.
        static let lineBreakExtraMs: Double = 120

        /// Delay between each of the four trailing dots (milliseconds). Spec: ~200ms.
        static let trailingDotDelayMs: Double = 200

        /// Pause before the bright closing line appears (milliseconds). Spec: ~800ms.
        static let closingPauseMs: Double = 800

        /// Duration the block cursor blinks alone in the header before body printing begins (seconds).
        /// Spec: ~1.5s.
        static let headerCursorDuration: Double = 1.5
    }
}

// MARK: - Color hex init

extension Color {
    /// Initialises a Color from a 6-digit hex string (with or without leading #).
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - View modifier helpers

extension View {
    /// Applies the terminal font, all-caps tracking, and foreground color in one shot.
    func terminalStyle(
        size: CGFloat = DesignSystem.Typography.minDimSize,
        color: Color = DesignSystem.Colors.dim,
        weight: Font.Weight = .regular
    ) -> some View {
        self
            .font(DesignSystem.Typography.terminal(size, weight: weight))
            .tracking(DesignSystem.Typography.tracking(for: size))
            .foregroundStyle(color)
    }

    /// All-caps chip with optically centered background.
    /// Compensates for the descender space in the line box so the background
    /// hugs the cap-height glyphs rather than sitting low. The correction
    /// steals from bottom padding and adds to top, shifting the text up
    /// within the chip to counteract the invisible descender space.
    /// Scales with Dynamic Type via `capsVerticalBias`.
    func terminalChip(
        textColor: Color,
        backgroundColor: Color,
        verticalPadding: CGFloat = 7
    ) -> some View {
        let bias = DesignSystem.Typography.capsVerticalBias
        // Less top padding, more bottom — counteracts the descender
        // space inside the line box that already sits below the caps.
        let correction = verticalPadding * bias * 0.5
        let topPad = verticalPadding - correction
        let bottomPad = verticalPadding + correction
        let _ = print("[CHIP] bias=\(bias) correction=\(correction) topPad=\(topPad) bottomPad=\(bottomPad)")

        return self
            .terminalStyle(
                size: DesignSystem.Typography.minDimSize,
                color: textColor
            )
            .textCase(.uppercase)
            .fixedSize()
            .padding(.top, topPad)
            .padding(.bottom, bottomPad)
            .background(backgroundColor)
    }
}
