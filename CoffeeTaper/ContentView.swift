import SwiftUI
import UIKit

private enum Palette {
    static let background = Color(red: 0.98, green: 0.95, blue: 0.89)
    static let ink = Color(red: 0.22, green: 0.16, blue: 0.12)
    static let coffee = Color(red: 0.40, green: 0.23, blue: 0.13)
    static let muted = Color(red: 0.43, green: 0.36, blue: 0.29)
}

struct ContentView: View {
    @StateObject private var store = TaperStore()

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("COFFEE TAPER")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .tracking(3)
                        Text("A little less.")
                            .font(.system(.largeTitle, design: .serif, weight: .medium))
                    }
                    .padding(.top, 20)

                    VStack(spacing: 0) {
                        Text(store.label)
                            .font(.system(size: 76, weight: .regular, design: .serif))
                            .monospacedDigit()
                            .accessibilityHidden(true)
                        Text(store.eighths == 0 ? "No coffee" : "of your usual cup")
                            .foregroundStyle(Palette.muted)
                            .accessibilityHidden(true)
                    }

                    CupSlider(store: store)
                        .frame(width: min(320, screen.size.width - 48),
                               height: max(220, min(410, screen.size.height - 335)))

                    VStack(spacing: 8) {
                        Text("Slide the coffee level. Take your time.")
                        Label("Your level is saved on this iPhone", systemImage: "checkmark")
                            .font(.caption)
                    }
                    .foregroundStyle(Palette.muted)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
            }
        }
        .foregroundStyle(Palette.ink)
        .background(Palette.background.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

private struct CupSlider: View {
    @ObservedObject var store: TaperStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let feedback = UISelectionFeedbackGenerator()

    var body: some View {
        GeometryReader { geometry in
            let cupWidth = geometry.size.width - 48
            let liquidHeight = geometry.size.height - 48
            let levelY = 24 + liquidHeight * (1 - store.fraction)

            ZStack(alignment: .topLeading) {
                // The handle sits behind the cup; the whole cup is the control.
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Palette.ink, lineWidth: 7)
                    .frame(width: 64, height: geometry.size.height * 0.36)
                    .position(x: cupWidth + 9, y: geometry.size.height * 0.43)

                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(red: 0.93, green: 0.88, blue: 0.79))
                    .frame(width: cupWidth, height: geometry.size.height)

                Rectangle()
                    .fill(Palette.coffee.gradient)
                    .frame(width: cupWidth, height: liquidHeight * store.fraction)
                    .offset(y: levelY)

                // Marks are inset so the rounded bottom does not hide them.
                ForEach(0...8, id: \.self) { step in
                    Capsule()
                        .fill(Double(step) / 8 <= store.fraction && step != 8
                              ? Color.white.opacity(0.7) : Palette.ink.opacity(0.4))
                        .frame(width: step.isMultiple(of: 2) ? 22 : 12, height: 2)
                        .offset(x: 18, y: 24 + liquidHeight * (1 - Double(step) / 8))
                }

                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(Palette.ink, lineWidth: 4)
                    .frame(width: cupWidth, height: geometry.size.height)

                Capsule()
                    .fill(Palette.ink)
                    .frame(width: cupWidth - 16, height: 4)
                    .offset(x: 8, y: levelY - 2)

                Capsule()
                    .fill(Palette.background)
                    .frame(width: 70, height: 40)
                    .overlay {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                    }
                    .overlay(Capsule().stroke(Palette.ink, lineWidth: 2))
                    .position(x: cupWidth / 2, y: levelY)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let next = TaperStore.level(
                            at: Double(value.location.y - 24), height: Double(liquidHeight))
                        setLevel(next)
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Coffee level")
            .accessibilityValue(store.spokenLabel)
            .accessibilityHint("Swipe up or down to change by one eighth of your usual cup.")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: setLevel(store.eighths + 1)
                case .decrement: setLevel(store.eighths - 1)
                @unknown default: break
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: store.eighths)
        }
    }

    private func setLevel(_ next: Int) {
        let previous = store.eighths
        store.setEighths(next)
        if previous != store.eighths {
            feedback.selectionChanged()
        }
    }
}
