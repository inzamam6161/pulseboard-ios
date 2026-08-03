//
//  MetricCard.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let message: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.12))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.navy)

            Text(message)
                .font(.caption)
                .foregroundStyle(.green)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dashboardCard()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    MetricCard(
        title: "Deep Work",
        value: "12h 40m",
        message: "18% more than last week",
        systemImage: "target",
        tint: AppTheme.indigo
    )
    .padding()
}
