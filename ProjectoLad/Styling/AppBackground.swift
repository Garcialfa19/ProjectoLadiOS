import SwiftUI
import UIKit

struct AppBackground: View {
    let theme: BrandTheme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(uiColor: colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    theme.accent.opacity(colorScheme == .dark ? 0.18 : 0.12),
                    theme.secondaryAccent.opacity(colorScheme == .dark ? 0.12 : 0.08),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(theme.accent.opacity(colorScheme == .dark ? 0.18 : 0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: -120, y: -260)

            Circle()
                .fill(theme.secondaryAccent.opacity(colorScheme == .dark ? 0.16 : 0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: 170, y: -200)

            RoundedRectangle(cornerRadius: 120, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.24))
                .frame(width: 260, height: 220)
                .blur(radius: 45)
                .rotationEffect(.degrees(12))
                .offset(x: 150, y: 320)
        }
    }
}

private struct LiquidGlassBackground: View {
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.regularMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.24 : 0.55),
                                Color.white.opacity(colorScheme == .dark ? 0.10 : 0.16),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.18 : 0.48), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.16 : 0.06), radius: 24, x: 0, y: 16)
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
                .fill(.thinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
