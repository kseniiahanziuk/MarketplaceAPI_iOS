import SwiftUI

struct FAQDetailView: View {
    let question: String
    
    var answer: String {
        switch question {
        case "How to place an order?":
            return """
            Placing an order is simple and straightforward:
            
            1. Browse our catalog or use the search function to find products
            2. Tap on any product to view its details
            3. Select the quantity you want and tap "Add to cart"
            4. Continue shopping or go to your cart by tapping the cart icon
            5. In the cart, review your items and tap "Proceed to checkout"
            6. Enter your shipping address and payment information
            7. Review your order and confirm the purchase
            
            You'll receive an order confirmation email once your order is successfully placed.
            """
            
        case "Payment methods":
            return """
            We accept the following payment methods:
            
            • Credit Cards (Visa, Mastercard, American Express)
            • Debit Cards
            • PayPal
            • Apple Pay
            • Google Pay
            • Bank Transfer
            
            All payments are processed securely using industry-standard encryption. Your payment information is never stored on our servers.
            
            For credit and debit cards, you can save your payment method for faster checkout in future orders.
            """
            
        case "Shipping information":
            return """
            Shipping Details:
            
            Delivery Times:
            • Standard shipping: 3-7 business days
            • Express shipping: 1-3 business days
            • Overnight shipping: Next business day
            
            Shipping Costs:
            • Free shipping on orders over ₴1000
            • Standard shipping: ₴99
            • Express shipping: ₴199
            • Overnight shipping: ₴399
            
            We ship to all regions within Ukraine. International shipping is available for select countries.
            
            You'll receive a tracking number via email once your order ships, allowing you to monitor your package's progress.
            """
            
        case "Return policy":
            return """
            Our return policy is designed to ensure your satisfaction:
            
            Return Period:
            • 30 days from the date of delivery
            • Items must be in original condition and packaging
            • Electronics must include all original accessories
            
            How to Return:
            1. Contact our support team to initiate a return
            2. Package the item securely in original packaging
            3. Use the prepaid return label we provide
            4. Drop off at any authorized shipping location
            
            Refund Process:
            • Refunds are processed within 5-7 business days
            • Original payment method will be credited
            • Shipping costs are non-refundable (except for defective items)
            
            Some items like personalized products or opened software cannot be returned.
            """
            
        default:
            return "Detailed information for this question is not available. Please contact our support team for assistance."
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(question)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                Text(answer)
                    .font(.body)
                    .lineSpacing(4)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    Text("Still have questions?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Contact our support team for additional help: marketplacesupport@gmail.com")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}
