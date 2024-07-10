import SwiftUI
import CoreData
import Contacts
import ContactsUI
import MessageUI

struct EmergencyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: CDEmergencyContacts.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CDEmergencyContacts.name, ascending: true)]
    ) var contacts: FetchedResults<CDEmergencyContacts>
    
    @State private var newName = ""
    @State private var newPhoneNumber = ""
    @State private var isShowingMessageCompose = false
    @State private var isShowingContactsPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add New Contact").font(.headline)) {
                        TextField("Name", text: $newName)
                            .textContentType(.name)
                            .padding(.vertical, 5)
                        TextField("Phone Number", text: $newPhoneNumber)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                            .padding(.vertical, 5)
                        Button(action: addContact) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Contact")
                            }
                        }
                        Button(action: {
                            isShowingContactsPicker = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                Text("Pick from Contacts")
                            }
                        }
                    }
                }
                
                List {
                    ForEach(contacts) { contact in
                        VStack(alignment: .leading) {
                            Text(contact.name ?? "Unknown")
                                .font(.body)
                            Text(contact.mobile ?? "No phone number")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: deleteContacts)
                }
                .listStyle(InsetGroupedListStyle())
                
                if !contacts.isEmpty {
                    Button(action: {
                        self.isShowingMessageCompose = true
                    }) {
                        Text("Send Emergency Message")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 10)
                    }
                    .disabled(!MFMessageComposeViewController.canSendText())
                    .sheet(isPresented: $isShowingMessageCompose) {
                        MessageComposeView(recipients: self.contacts.map { $0.mobile ?? "" }, body: "I'm sober, but I want to have a drink. Help me out")
                    }
                } else {
                    Text("Please add an emergency contact first.")
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }
            }
            .padding()
            .navigationTitle("Emergency Contacts")
            .sheet(isPresented: $isShowingContactsPicker) {
                ContactsPicker { contact in
                    self.newName = contact.name
                    self.newPhoneNumber = contact.phoneNumber
                    addContact()
                }
            }
        }
    }
    
    private func addContact() {
        let newContact = CDEmergencyContacts(context: viewContext)
        newContact.name = newName
        newContact.mobile = newPhoneNumber
        
        do {
            try viewContext.save()
            newName = ""
            newPhoneNumber = ""
        } catch {
            // Handle the error appropriately
            print("Failed to save contact: \(error.localizedDescription)")
        }
    }
    
    private func deleteContacts(offsets: IndexSet) {
        withAnimation {
            offsets.map { contacts[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Handle the error appropriately
                print("Failed to delete contact: \(error.localizedDescription)")
            }
        }
    }
}
