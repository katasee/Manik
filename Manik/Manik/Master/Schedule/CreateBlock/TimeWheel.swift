import SwiftUI

struct TimeWheel: View {
    @Binding var time: ClockTime
    let hours: ClosedRange<Int>

    var body: some View {
        HStack(spacing: 0) {
            Picker("schedule.createSlot.hours", selection: $time.hour) {
                ForEach(hours, id: \.self) { hour in
                    Text(String(hour))
                        .font(.elmsSans(.regular, 20))
                        .tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .clipped()

            Picker("schedule.createSlot.minutes", selection: $time.minute) {
                ForEach(minuteOptions, id: \.self) { minute in
                    Text(minute.formatted(.number.precision(.integerLength(2))))
                        .font(.elmsSans(.regular, 20))
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .frame(height: ScheduleMetrics.CreatePopup.wheelHeight)
    }

    private var minuteOptions: [Int] {
        if time.hour == WorkHours.working.upperBound { return [0] }

        return Array(stride(from: 0, to: 60, by: WorkHours.slotStepMinutes))
    }
}

#Preview {
    @Previewable @State var time = ClockTime(minutesOfDay: 21 * 60 + 30)

    VStack {
        Text(DateFormat.storageTime(minutesOfDay: time.minutesOfDay))
        TimeWheel(time: $time, hours: 8...22)
    }
    .padding()
    .background(Color.background)
}
