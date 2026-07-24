import SwiftUI

struct AuthFieldView: View {
    private let label: LocalizedStringKey
    @Binding private var text: String
    private let isSecure: Bool
    private let focusField: AuthFocusField?
    private let focusedField: FocusState<AuthFocusField?>.Binding
    private let textContentType: UITextContentType?
    private let keyboardType: UIKeyboardType
    private let autocapitalization: TextInputAutocapitalization
    private let autocorrectionDisabled: Bool

    init(
        _ label: LocalizedStringKey,
        text: Binding<String>,
        isSecure: Bool = false,
        focusField: AuthFocusField? = nil,
        focusedField: FocusState<AuthFocusField?>.Binding,
        textContentType: UITextContentType? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false
    ) {
        self.label = label
        self._text = text
        self.isSecure = isSecure
        self.focusField = focusField
        self.focusedField = focusedField
        self.textContentType = textContentType
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AuthMetrics.Spacing.fieldLabelToBox) {
            Text(label)
                .font(.elmsSans(.semiBold, AuthMetrics.FontSize.fieldLabel))
                .foregroundStyle(Color.textSecondary)
                .tracking(AuthMetrics.FontSize.labelTracking)
                .textCase(.uppercase)

            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .focused(focusedField, equals: focusField)
            .textContentType(textContentType)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled(autocorrectionDisabled)
            .font(.elmsSans(.regular, AuthMetrics.FontSize.fieldValue))
            .foregroundStyle(Color.ink)
            .padding(AuthMetrics.Spacing.fieldPadding)
            .background(Color.fieldBackground, in: .rect(cornerRadius: AuthMetrics.CornerRadius.field))
            .overlay(
                RoundedRectangle(cornerRadius: AuthMetrics.CornerRadius.field)
                    .stroke(Color.surface, lineWidth: 1)
            )
        }
    }
}
