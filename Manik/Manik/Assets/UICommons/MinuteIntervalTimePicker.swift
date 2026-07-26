import SwiftUI
import UIKit

struct MinuteIntervalTimePicker: UIViewRepresentable {
    @Binding var date: Date
    let minuteInterval: Int

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.minuteInterval = minuteInterval
        picker.date = date
        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateChanged(_:)),
            for: .valueChanged
        )
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(date: $date)
    }

    final class Coordinator: NSObject {
        let date: Binding<Date>

        init(date: Binding<Date>) {
            self.date = date
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            date.wrappedValue = sender.date
        }
    }
}

#Preview {
    @Previewable @State var date = Date()

    MinuteIntervalTimePicker(date: $date, minuteInterval: 15)
        .padding()
        .background(Color.background)
}
