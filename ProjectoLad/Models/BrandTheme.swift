import SwiftUI

struct BrandTheme: Identifiable, Hashable {
    let id = UUID()
    let barName: String
    let accent: Color
    let secondaryAccent: Color
    let backgroundTop: Color
    let backgroundBottom: Color
    let cardBackground: Color
    let textPrimary: Color
    let textSecondary: Color
    let logoSystemName: String

    static let demoBar = BrandTheme(
        barName: "NightLife Pass",
        accent: Color(red: 0.49, green: 0.34, blue: 1.0),
        secondaryAccent: Color(red: 1.0, green: 0.39, blue: 0.56),
        backgroundTop: Color(red: 0.07, green: 0.08, blue: 0.13),
        backgroundBottom: Color(red: 0.02, green: 0.03, blue: 0.06),
        cardBackground: Color.white.opacity(0.08),
        textPrimary: .white,
        textSecondary: Color.white.opacity(0.72),
        logoSystemName: "sparkles.tv.fill"
    )

    static let tropicalBar = BrandTheme(
        barName: "Sunset Terrace",
        accent: Color.orange,
        secondaryAccent: Color(red: 1.0, green: 0.68, blue: 0.22),
        backgroundTop: Color(red: 0.15, green: 0.10, blue: 0.10),
        backgroundBottom: Color.black,
        cardBackground: Color.white.opacity(0.08),
        textPrimary: .white,
        textSecondary: Color.white.opacity(0.72),
        logoSystemName: "sun.max.fill"
    )
}
