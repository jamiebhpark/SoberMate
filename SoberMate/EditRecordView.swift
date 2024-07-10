import SwiftUI

struct EditRecordView: View {
    @State var record: DrinkRecord
    var onSave: (DrinkRecord) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Drink Details")) {
                    TextField("Enter drink details", text: $record.details)
                }
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: Binding(
                        get: { String(record.amount) },
                        set: { record.amount = Int($0) ?? record.amount }
                    ))
                    .keyboardType(.numberPad)
                }
                Section(header: Text("Content")) {
                    TextField("Enter content", text: $record.content)
                }
                Section(header: Text("Feeling")) {
                    TextField("Enter your feeling", text: $record.feeling)
                }
                Section(header: Text("Location")) {
                    TextField("Enter location", text: $record.location)
                }
            }
            .navigationBarTitle("Edit Record", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                onSave(record)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
