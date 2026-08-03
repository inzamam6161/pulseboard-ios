import SwiftUI
import UIKit

enum AppTheme {
    static let navy = Color(
        uiColor: UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return UIColor(
                    red: 241 / 255,
                    green: 243 / 255,
                    blue: 255 / 255,
                    alpha: 1
                )
            }

            return UIColor(
                red: 11 / 255,
                green: 18 / 255,
                blue: 49 / 255,
                alpha: 1
            )
        }
    )

    static let indigo = Color(
        red: 79 / 255,
        green: 70 / 255,
        blue: 229 / 255
    )

    static let coral = Color(
        red: 255 / 255,
        green: 107 / 255,
        blue: 94 / 255
    )

    static let orange = Color(
        red: 255 / 255,
        green: 154 / 255,
        blue: 60 / 255
    )

    static let lavender = Color(
        uiColor: UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return UIColor(
                    red: 36 / 255,
                    green: 32 / 255,
                    blue: 68 / 255,
                    alpha: 1
                )
            }

            return UIColor(
                red: 237 / 255,
                green: 233 / 255,
                blue: 254 / 255,
                alpha: 1
            )
        }
    )

    static let pageBackground = Color(
        uiColor: .systemGroupedBackground
    )

    static let cardBackground = Color(
        uiColor: .secondarySystemGroupedBackground
    )

    static let primaryGradient = LinearGradient(
        colors: [
            coral,
            orange
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 18
        static let large: CGFloat = 24
    }
}

extension View {
    func dashboardCard() -> some View {
        padding(AppTheme.Spacing.medium)
            .background(AppTheme.cardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium,
                    style: .continuous
                )
            )
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 10,
                y: 4
            )
    }
}
