//
//  ScoreRing.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftUI

struct ScoreRing: View {
    let progress: Double

    private var normalizedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    AppTheme.indigo.opacity(0.12),
                    lineWidth: 13
                )

            Circle()
                .trim(from: 0, to: normalizedProgress)
                .stroke(
                    AppTheme.indigo,
                    style: StrokeStyle(
                        lineWidth: 13,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            Text(
                normalizedProgress,
                format: .percent.precision(.fractionLength(0))
            )
            .font(.title2.bold())
            .foregroundStyle(AppTheme.navy)
        }
        .animation(
            .smooth(duration: 0.7),
            value: normalizedProgress
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weekly focus score")
        .accessibilityValue(
            Text(normalizedProgress, format: .percent)
        )
    }
}

#Preview {
    ScoreRing(progress: 0.78)
        .frame(width: 130, height: 130)
        .padding()
}
