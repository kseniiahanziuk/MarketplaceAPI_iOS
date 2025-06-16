import SwiftUI

struct HelpCenterView: View {
    var body: some View {
        List {
            Section("Frequently asked questions") {
                NavigationLink("How to place an order?", destination: FAQDetailView(question: "How to place an order?"))
                NavigationLink("Payment methods", destination: FAQDetailView(question: "Payment methods"))
                NavigationLink("Shipping information", destination: FAQDetailView(question: "Shipping information"))
                NavigationLink("Return policy", destination: FAQDetailView(question: "Return policy"))
            }
        }
        .navigationTitle("Help center")
    }
}
