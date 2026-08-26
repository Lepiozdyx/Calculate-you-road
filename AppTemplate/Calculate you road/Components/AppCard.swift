import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.gold)
            .textCase(.uppercase)
    }
}

struct StatusBadge: View {
    let status: TripStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.statusGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(AppTheme.statusGreenBackground)
            .clipShape(Capsule())
    }
}

struct RouteTimeline: View {
    let origin: String
    let destination: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(AppTheme.gold)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(AppTheme.gold.opacity(0.6))
                    .frame(width: 2, height: 28)
                Circle()
                    .fill(AppTheme.gold)
                    .frame(width: 10, height: 10)
            }
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 20) {
                Text(origin)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(destination)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
            Text(value)
                .foregroundStyle(valueColor)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
