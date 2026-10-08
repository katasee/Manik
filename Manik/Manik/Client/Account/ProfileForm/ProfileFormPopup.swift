import SwiftUI

struct ProfileFormPopup: View {
    private enum Field {
        case name
        case phone
        case instagram
        case telegram
    }

    @State private var viewModel: ProfileFormViewModel
    @FocusState private var focusedField: Field?

    let onSaved: (UserProfile) -> Void
    let onDismiss: () -> Void

    init(
        viewModel: ProfileFormViewModel,
        onSaved: @escaping (UserProfile) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(
            dismissLabel: "common.action.cancel",
            onDismiss: onDismiss
        ) { dismiss in
            title
            nameField
            phoneField
            phoneHint

            handleField(
                "account.field.instagram",
                text: $viewModel.instagram,
                field: .instagram,
                next: .telegram
            )

            handleField(
                "account.field.telegram",
                text: $viewModel.telegram,
                field: .telegram,
                next: nil
            )

            errorText
            actions(dismiss: dismiss)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("common.action.done", action: dismissKeyboard)
            }
        }
    }

    private var title: some View {
        Text("account.form.title")
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)
    }

    private var nameField: some View {
        fieldRow("account.field.name") {
            TextField("account.form.namePlaceholder", text: $viewModel.name)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .phone }
        }
    }

    private var phoneField: some View {
        fieldRow("account.field.phone") {
            HStack(spacing: AccountMetrics.Spacing.prefixSpacing) {
                Text(PhoneFormat.countryCode)
                    .foregroundStyle(Color.textSecondary)

                TextField("account.form.phonePlaceholder", text: $viewModel.phone)
                    .keyboardType(.phonePad)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .phone)
                    .fixedSize()
                    .onChange(of: viewModel.phone) {
                        viewModel.normalizePhone()
                    }
            }
        }
    }

    private func handleField(
        _ labelKey: LocalizedStringKey,
        text: Binding<String>,
        field: Field,
        next: Field?
    ) -> some View {
        fieldRow(labelKey) {
            TextField("account.form.handlePlaceholder", text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: field)
                .submitLabel(next == nil ? .done : .next)
                .onSubmit { focusedField = next }
        }
    }

    @ViewBuilder
    private var phoneHint: some View {
        if viewModel.showsPhoneError {
            message("account.form.phoneHint")
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @ViewBuilder
    private var errorText: some View {
        if viewModel.hasFailed {
            message("account.error.generic")
        }
    }

    private func message(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.elmsSans(.regular, 13))
            .foregroundStyle(Color.destructive)
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            CapsuleButton(
                titleKey: "account.form.submit",
                role: .primary,
                isLoading: viewModel.isSaving,
                isEnabled: viewModel.canSubmit,
                action: { save(then: dismiss) }
            )
        }
    }

    private func save(then dismiss: @escaping () -> Void) {
        focusedField = nil

        Task { @MainActor in
            if let profile = await viewModel.submit() {
                onSaved(profile)
                dismiss()
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }

    private func fieldRow(
        _ labelKey: LocalizedStringKey,
        @ViewBuilder control: () -> some View
    ) -> some View {
        HStack {
            Text(labelKey)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)

            Spacer()

            control()
        }
        .font(.elmsSans(.regular, 15))
    }
}

#if DEBUG
#Preview("Редагування") {
    Color.background
        .overlay {
            ProfileFormPopup(
                viewModel: ProfileFormViewModel(
                    profile: AccountPreviewData.profile,
                    userRepository: FakeUserRepository(profiles: AccountPreviewData.profiles)
                ),
                onSaved: { _ in },
                onDismiss: {}
            )
        }
}

#Preview("Помилка збереження") {
    Color.background
        .overlay {
            ProfileFormPopup(
                viewModel: ProfileFormViewModel(
                    profile: AccountPreviewData.profile,
                    userRepository: FakeUserRepository(profiles: [:])
                ),
                onSaved: { _ in },
                onDismiss: {}
            )
        }
}
#endif
