import SwiftUI

enum CabinetKind {
    case master(selection: Binding<MasterTab>, badge: (MasterTab) -> Int?)
    case client(selection: Binding<ClientTab>)
}
