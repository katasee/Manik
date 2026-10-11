import SwiftUI

struct ClientCardView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var draft = ClientFormFields()

    let card: ClientCard
    let editFields: ClientFormFields

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(onBack: goBack) {
                RoundIconButton(
                    systemImage: "pencil",
                    size: .small,
                    accessibilityLabel: "clients.action.edit",
                    action: edit
                )
            }

            ScrollView {
                VStack(spacing: ClientsMetrics.Spacing.cardSectionSpacing) {
                    profile
                    contact
                }
                .padding(.horizontal, ClientsMetrics.Spacing.horizontalPadding)
                .padding(.top, ClientsMetrics.Spacing.cardTopPadding)
                .padding(.bottom, ClientsMetrics.Spacing.listBottomPadding)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $isEditing) {
            ClientFormPopup(
                fields: $draft,
                mode: .edit,
                errors: ClientFormErrors(),
                isSaving: false,
                onSubmit: { true },
                onDelete: { true },
                onDismiss: dismissForm
            )
            .presentationBackground(.clear)
        }
    }

    private var profile: some View {
        VStack(spacing: ClientsMetrics.Spacing.cardProfileSpacing) {
            ClientAvatar(initial: card.initial, size: ClientsMetrics.Size.cardAvatar)

            Text(verbatim: card.title)
                .font(.elmsSans(.semiBold, ClientsMetrics.Size.cardName))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            if let details = card.details {
                Text(verbatim: details)
                    .font(.elmsSans(.regular, ClientsMetrics.Size.cardDetails))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var contact: some View {
        if card.contacts.isEmpty {
            Text("clients.card.noContacts")
                .font(.elmsSans(.regular, ClientsMetrics.Size.cardDetails))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .cardSurface(
                    padding: ClientsMetrics.Spacing.noContactsPadding,
                    cornerRadius: ClientsMetrics.Size.noContactsCornerRadius
                )
        } else {
            ClientContactMenu(contacts: card.contacts) {
                contactLabel
            }
        }
    }

    private var contactLabel: some View {
        HStack(spacing: ClientsMetrics.Spacing.contactIconSpacing) {
            Image(systemName: "bubble.left")
                .font(.elmsSans(.bold, ClientsMetrics.Size.contactIcon))
                .accessibilityHidden(true)

            Text("clients.contact.action")
                .font(.elmsSans(.semiBold, ClientsMetrics.Size.contactTitle))
                .lineLimit(1)
        }
        .foregroundStyle(Color.onPrimary)
        .frame(maxWidth: .infinity, minHeight: ClientsMetrics.Size.contactMinHeight)
        .background {
            Capsule()
                .fill(Color.primaryFill)
                .brandShadow()
        }
        .contentShape(.capsule)
    }

    private func goBack() {
        dismiss()
    }

    private func edit() {
        draft = editFields

        withoutPresentationAnimation {
            isEditing = true
        }
    }

    private func dismissForm() {
        withoutPresentationAnimation {
            isEditing = false
        }
    }
}

#if DEBUG
#Preview {
    let client = ClientsPreviewData.clients[0]

    NavigationStack {
        ClientCardView(
            card: ClientCard(client: client),
            editFields: ClientFormFields(client: client)
        )
    }
}
#endif
