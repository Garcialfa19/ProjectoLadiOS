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
        accent: Color(red: 0.17, green: 0.46, blue: 0.96),
        secondaryAccent: Color(red: 0.34, green: 0.76, blue: 0.88),
        backgroundTop: Color(red: 0.92, green: 0.95, blue: 0.99),
        backgroundBottom: Color(red: 0.98, green: 0.99, blue: 1.0),
        cardBackground: Color.white.opacity(0.50),
        textPrimary: .primary,
        textSecondary: .secondary,
        logoSystemName: "ticket.fill"
    )

    static let tropicalBar = BrandTheme(
        barName: "Sunset Terrace",
        accent: Color(red: 0.89, green: 0.47, blue: 0.22),
        secondaryAccent: Color(red: 0.95, green: 0.72, blue: 0.28),
        backgroundTop: Color(red: 0.99, green: 0.95, blue: 0.90),
        backgroundBottom: Color(red: 1.0, green: 0.98, blue: 0.95),
        cardBackground: Color.white.opacity(0.50),
        textPrimary: .primary,
        textSecondary: .secondary,
        logoSystemName: "sun.max.fill"
    )
}
