import SwiftUI

struct TimeWheel: View {
    @Binding var time: ClockTime
    let hours: ClosedRange<Int>
    let minuteStep: Int

    private enum Layout {
        static let wheelHeight: CGFloat = 150
        static let font: CGFloat = 20
    }

    var body: some View {
        HStack(spacing: 0) {
            Picker("timeWheel.hours", selection: $time.hour) {
                ForEach(hours, id: \.self) { hour in
                    Text(String(hour))
                        .font(.elmsSans(.regular, Layout.font))
                        .tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .clipped()

            Picker("timeWheel.minutes", selection: $time.minute) {
                ForEach(minuteOptions, id: \.self) { minute in
                    Text(minute.formatted(.number.precision(.integerLength(2))))
                        .font(.elmsSans(.regular, Layout.font))
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .frame(height: Layout.wheelHeight)
    }

    private var minuteOptions: [Int] {
        Array(stride(from: 0, to: 60, by: minuteStep))
    }
}

#Preview {
    @Previewable @State var time = ClockTime(minutesOfDay: 11 * 60 + 30)

    TimeWheel(
        time: $time,
        hours: 8...21,
        minuteStep: 15
    )
        .padding()
        .background(Color.background)
}
