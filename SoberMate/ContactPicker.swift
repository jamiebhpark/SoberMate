import SwiftUI
import ContactsUI

struct ContactsPicker: UIViewControllerRepresentable {
    var completion: (Contact) -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, completion: completion)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactsPicker
        var completion: (Contact) -> Void
        
        init(_ parent: ContactsPicker, completion: @escaping (Contact) -> Void) {
            self.parent = parent
            self.completion = completion
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let name = "\(contact.givenName) \(contact.familyName)"
            let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
            let selectedContact = Contact(name: name, phoneNumber: phoneNumber)
            completion(selectedContact)
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            // Handle cancel action
        }
    }
}

struct Contact {
    var name: String
    var phoneNumber: String
}
