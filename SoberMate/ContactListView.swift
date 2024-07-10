import SwiftUI

struct ContactListView: View {
    @Binding var showMessageCompose: Bool
    @Binding var selectedPhones: [String]
    var deleteContact: (IndexSet) -> Void
    @FetchRequest(
        entity: CDEmergencyContacts.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CDEmergencyContacts.name, ascending: true)]
    ) var contacts: FetchedResults<CDEmergencyContacts>

    var body: some View {
        List {
            ForEach(contacts, id: \.self) { contact in
                HStack {
                    VStack(alignment: .leading) {
                        Text(contact.name ?? "Unknown")
                            .font(.headline)
                        Text(contact.mobile ?? "No phone number")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        selectedPhones = [contact.mobile ?? ""]
                        showMessageCompose = true
                    }) {
                        Image(systemName: "message.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .onDelete(perform: deleteContact)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Emergency Contacts")
        .navigationBarItems(trailing: EditButton())
    }
}
