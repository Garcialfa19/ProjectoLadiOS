import SwiftUI
import UIKit

struct AppBackground: View {
    let theme: BrandTheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    theme.backgroundTop,
                    theme.backgroundTop.mix(with: theme.accent, by: 0.18),
                    theme.backgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                RadialGradient(
                    colors: [Color.white.opacity(0.16), .clear],
                    center: .topLeading,
                    startRadius: 30,
                    endRadius: 380
                )
                .blendMode(.screen)
            }
            .ignoresSafeArea()

            Circle()
                .fill(theme.accent.opacity(0.26))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(x: -150, y: -260)

            Circle()
                .fill(theme.secondaryAccent.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 95)
                .offset(x: 160, y: -170)

            RoundedRectangle(cornerRadius: 120, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.13), Color.white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 260, height: 280)
                .blur(radius: 45)
                .rotationEffect(.degrees(-18))
                .offset(x: 155, y: 310)

            RoundedRectangle(cornerRadius: 140, style: .continuous)
                .fill(theme.secondaryAccent.opacity(0.08))
                .frame(width: 220, height: 240)
                .blur(radius: 40)
                .rotationEffect(.degrees(20))
                .offset(x: -170, y: 260)
        }
    }
}

private struct LiquidGlassBackground: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
            }
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.60), Color.white.opacity(0.10), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blur(radius: 0.2)
            }
            .overlay(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    .blur(radius: 6)
                    .offset(x: 4, y: 6)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: cornerRadius * 2.4, height: 10)
                    .blur(radius: 10)
                    .offset(y: 3)
            }
            .shadow(color: Color.black.opacity(0.24), radius: 30, x: 0, y: 20)
    }
}

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 28

    func body(content: Content) -> some View {
        content
            .background {
                LiquidGlassBackground(cornerRadius: cornerRadius)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 28) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }

    func liquidGlassCapsule() -> some View {
        background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.24), Color.white.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)
                }
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 10)
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.68))
        }
    }
}

private extension Color {
    func mix(with color: Color, by amount: CGFloat) -> Color {
        let uiColor1 = UIColor(self)
        let uiColor2 = UIColor(color)

        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0

        uiColor1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        uiColor2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return Color(
            red: red1 + ((red2 - red1) * amount),
            green: green1 + ((green2 - green1) * amount),
            blue: blue1 + ((blue2 - blue1) * amount),
            opacity: alpha1 + ((alpha2 - alpha1) * amount)
        )
    }
}
