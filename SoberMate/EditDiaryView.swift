import SwiftUI

struct EditDiaryView: View {
    @State var entry: DiaryEntry
    var onSave: (DiaryEntry) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Thoughts")) {
                    TextField("Enter your thoughts", text: $entry.content)
                }
                Section(header: Text("How are you feeling?")) {
                    TextField("Enter your feeling", text: $entry.feeling)
                }
                Section(header: Text("Date")) {
                    DatePicker("Select date", selection: $entry.date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            .navigationBarTitle("Edit Diary Entry", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                onSave(entry)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
