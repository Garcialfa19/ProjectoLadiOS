import SwiftUI

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.68))
            }

            Spacer()
        }
    }
}

struct AuthButton: View {
    let title: String
    let systemImage: String
    let background: Color
    let foreground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
        }
    }
}

struct CapsuleInfo: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.68))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

struct EventCardView: View {
    let theme: BrandTheme
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [theme.accent.opacity(0.92), theme.secondaryAccent.opacity(0.75), Color.black.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 250)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.14), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(event.badgeText.uppercased())
                            .font(.caption2.weight(.bold))
                            .tracking(1.2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())

                        Spacer()

                        Image(systemName: event.imageName)
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.95))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(event.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.78))

                        Text(event.hostName)
                            .font(.footnote)
                            .foregroundStyle(Color.white.opacity(0.60))
                    }
                }
                .padding(22)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 18) {
                    EventMetaView(icon: "calendar", title: event.dateText)
                    EventMetaView(icon: "clock", title: event.timeText)
                }

                HStack {
                    Text("From \(event.basePriceText)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Spacer()

                    HStack(spacing: 8) {
                        Text("View event")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "arrow.up.right")
                    }
                    .foregroundStyle(theme.secondaryAccent)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(18)
        .glassCard()
        .padding(.horizontal, 20)
    }
}

struct EventMetaView: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(Color.white.opacity(0.78))
    }
}

struct DetailPill: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .lineLimit(1)
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

struct TicketTierRow: View {
    let tier: TicketTier
    let theme: BrandTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(tier.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(tier.perks)
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.68))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(tier.priceText)
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? theme.secondaryAccent : Color.white.opacity(0.38))
                }
            }
            .padding(18)
            .background(isSelected ? theme.accent.opacity(0.22) : Color.white.opacity(0.05))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? theme.secondaryAccent : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .frame(width: 38, height: 38)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.65))
            }

            Spacer()
        }
    }
}
