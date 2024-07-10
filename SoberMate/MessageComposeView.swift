import SwiftUI
import MessageUI

struct MessageComposeView: UIViewControllerRepresentable {
    var recipients: [String]
    var body: String
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.recipients = recipients
        messageComposeVC.body = body
        messageComposeVC.messageComposeDelegate = context.coordinator
        return messageComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposeView
        
        init(_ parent: MessageComposeView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
        }
    }
}
