import SwiftUI

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
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(foreground)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(background)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(isSelected ? Color.accentColor : Color.clear))
                .overlay {
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : Color.secondary.opacity(0.18), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

struct SummaryMetricView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }
}

struct FeaturedEventCard: View {
    let event: Event
    let theme: BrandTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(event.badgeText, systemImage: "sparkles")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(theme.accent)

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(event.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(event.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                EventInfoPill(icon: "calendar", title: event.startsDayText)
                EventInfoPill(icon: "clock", title: event.startTimeText)
            }

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(event.locationSummary)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(event.priceFromText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 26)
    }
}

struct EventRowCard: View {
    let event: Event
    let theme: BrandTheme

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: event.heroSymbol)
                .font(.title3)
                .foregroundStyle(theme.accent)
                .frame(width: 42, height: 42)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    if event.status == .soldOut {
                        Text("Sold out")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.orange)
                    }
                }

                Text(event.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(event.startTimeText, systemImage: "clock")
                    Label(event.venueName, systemImage: "mappin")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                HStack {
                    Text(event.priceFromText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.accent)
                    Spacer()
                    Text(event.availabilityText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

struct EventInfoPill: View {
    let icon: String
    let title: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .liquidGlassCapsule()
    }
}

struct DetailSectionCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            content
        }
        .padding(20)
        .glassCard(cornerRadius: 24)
    }
}

struct DetailValueRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
    }
}

struct TicketTierRow: View {
    let tier: TicketTier
    let theme: BrandTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(tier.name)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)
                            if tier.isRecommended {
                                Text("Recommended")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(theme.accent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .liquidGlassCapsule()
                            }
                        }

                        Text(tier.inventoryText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(tier.priceText)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? theme.accent : Color.secondary)
                    }
                }

                Text(tier.perksSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isSelected ? theme.accent.opacity(0.12) : Color.clear)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(isSelected ? theme.accent.opacity(0.40) : Color.secondary.opacity(0.15), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .frame(width: 34, height: 34)
                .glassCard(cornerRadius: 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        AuthButton(
            title: "Continue with Google",
            systemImage: "globe",
            background: Color(uiColor: .secondarySystemBackground),
            foreground: .primary
        ) { }

        EventRowCard(event: Event.sampleEvents[0], theme: .demoBar)

        TicketTierRow(
            tier: Event.sampleEvents[0].ticketTiers[1],
            theme: .demoBar,
            isSelected: true
        ) { }
    }
    .padding()
}
#endif
