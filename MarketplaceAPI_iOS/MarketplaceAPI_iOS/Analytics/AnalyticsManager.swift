import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    func logAppLaunch() {
        Analytics.logEvent("app_launch", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func logScreenView(_ screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenName
        ])
        
        CrashlyticsManager.shared.log("Screen viewed: \(screenName)")
    }
    
    func logProductCardTapped(_ product: Product, position: Int) {
        let parameters: [String: Any] = [
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemName: product.name,
            AnalyticsParameterItemCategory: product.category,
            "position": position,
            "price": product.price
        ]
        
        Analytics.logEvent("product_card_tapped", parameters: parameters)
        CrashlyticsManager.shared.log("Product card tapped: \(product.name) at position \(position)")
    }
    
    func logProductView(_ product: Product) {
        let parameters: [String: Any] = [
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemName: product.name,
            AnalyticsParameterItemCategory: product.category,
            AnalyticsParameterItemBrand: product.brand,
            AnalyticsParameterPrice: product.price,
            AnalyticsParameterCurrency: "UAH",
            "availability": product.availability.rawValue,
            "rating": product.rating
        ]
        
        Analytics.logEvent(AnalyticsEventViewItem, parameters: parameters)
        CrashlyticsManager.shared.log("Product viewed: \(product.name)")
    }
    
    func logLikedProductRemoved(_ product: Product) {
        let parameters: [String: Any] = [
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemName: product.name,
            AnalyticsParameterItemCategory: product.category,
            AnalyticsParameterValue: product.price,
            AnalyticsParameterCurrency: "UAH"
        ]
        
        Analytics.logEvent("remove_from_wishlist", parameters: parameters)
        CrashlyticsManager.shared.log("Removed from liked: \(product.name)")
    }
    
    func logSearch(_ searchTerm: String, resultCount: Int) {
        let parameters: [String: Any] = [
            AnalyticsParameterSearchTerm: searchTerm,
            "result_count": resultCount,
            "search_timestamp": Date().timeIntervalSince1970
        ]
        
        Analytics.logEvent(AnalyticsEventSearch, parameters: parameters)
        CrashlyticsManager.shared.log("Search performed: '\(searchTerm)' - \(resultCount) results")
    }
    
    func logSearchResultInteraction(searchTerm: String, resultPosition: Int, productId: String) {
        Analytics.logEvent("search_result_clicked", parameters: [
            AnalyticsParameterSearchTerm: searchTerm,
            "result_position": resultPosition,
            AnalyticsParameterItemID: productId
        ])
    }
    
    func logEmptySearchResults(searchTerm: String) {
        Analytics.logEvent("search_no_results", parameters: [
            AnalyticsParameterSearchTerm: searchTerm,
            "search_length": searchTerm.count
        ])
    }
    
    func logAddToCart(_ product: Product, quantity: Int) {
        let parameters: [String: Any] = [
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemName: product.name,
            AnalyticsParameterItemCategory: product.category,
            AnalyticsParameterItemBrand: product.brand,
            AnalyticsParameterQuantity: quantity,
            AnalyticsParameterPrice: product.price,
            AnalyticsParameterCurrency: "UAH",
            AnalyticsParameterValue: product.price * Double(quantity)
        ]
        
        Analytics.logEvent(AnalyticsEventAddToCart, parameters: parameters)
        CrashlyticsManager.shared.log("Added to cart: \(product.name) x\(quantity)")
    }
    
    func logRemoveFromCart(_ productName: String, quantity: Int, value: Double) {
        let parameters: [String: Any] = [
            AnalyticsParameterItemName: productName,
            AnalyticsParameterQuantity: quantity,
            AnalyticsParameterValue: value,
            AnalyticsParameterCurrency: "UAH"
        ]
        
        Analytics.logEvent(AnalyticsEventRemoveFromCart, parameters: parameters)
        CrashlyticsManager.shared.log("Removed from cart: \(productName) x\(quantity)")
    }
    
    func logCartViewed(itemCount: Int, totalValue: Double) {
        let parameters: [String: Any] = [
            "item_count": itemCount,
            "cart_value": totalValue,
            "currency": "UAH"
        ]
        
        Analytics.logEvent("cart_viewed", parameters: parameters)
        CrashlyticsManager.shared.log("Cart viewed: \(itemCount) items, \(totalValue) UAH")
    }
    
    func logCheckoutStarted(items: [ProductItem], totalValue: Double) {
        var itemsArray: [[String: Any]] = []
        
        for item in items {
            itemsArray.append([
                AnalyticsParameterItemID: item.productId,
                AnalyticsParameterItemName: item.name,
                AnalyticsParameterQuantity: item.quantity,
                AnalyticsParameterPrice: item.price
            ])
        }
        
        let parameters: [String: Any] = [
            AnalyticsParameterCurrency: "UAH",
            AnalyticsParameterValue: totalValue,
            AnalyticsParameterItems: itemsArray
        ]
        
        Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: parameters)
        CrashlyticsManager.shared.log("Checkout started: \(totalValue) UAH")
    }
    
    func logPurchase(items: [ProductItem], totalValue: Double, transactionId: String? = nil) {
        var itemsArray: [[String: Any]] = []
        
        for item in items {
            itemsArray.append([
                AnalyticsParameterItemID: item.productId,
                AnalyticsParameterItemName: item.name,
                AnalyticsParameterQuantity: item.quantity,
                AnalyticsParameterPrice: item.price
            ])
        }
        
        var parameters: [String: Any] = [
            AnalyticsParameterCurrency: "UAH",
            AnalyticsParameterValue: totalValue,
            AnalyticsParameterItems: itemsArray,
            "item_count": items.count
        ]
        
        if let transactionId = transactionId {
            parameters[AnalyticsParameterTransactionID] = transactionId
        }
        
        Analytics.logEvent(AnalyticsEventPurchase, parameters: parameters)
        CrashlyticsManager.shared.log("Purchase completed: \(totalValue) UAH, \(items.count) items")
    }
    
    func logAddToLiked(_ product: Product) {
        let parameters: [String: Any] = [
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemName: product.name,
            AnalyticsParameterItemCategory: product.category,
            AnalyticsParameterItemBrand: product.brand,
            AnalyticsParameterValue: product.price,
            AnalyticsParameterCurrency: "UAH"
        ]
        
        Analytics.logEvent(AnalyticsEventAddToWishlist, parameters: parameters)
        CrashlyticsManager.shared.log("Added to liked: \(product.name)")
    }
    
    func logFilterApplied(categories: Set<String>, brands: Set<String>, priceRange: ClosedRange<Double>) {
        let parameters: [String: Any] = [
            "categories": Array(categories).joined(separator: ","),
            "brands": Array(brands).joined(separator: ","),
            "min_price": priceRange.lowerBound,
            "max_price": priceRange.upperBound,
            "filter_count": categories.count + brands.count + 1
        ]
        
        Analytics.logEvent("filter_applied", parameters: parameters)
        CrashlyticsManager.shared.log("Filters applied: \(categories.count) categories, \(brands.count) brands")
    }
    
    func logSortApplied(_ sortOption: SortOption) {
        Analytics.logEvent("sort_applied", parameters: [
            "sort_option": sortOption.rawValue
        ])
        CrashlyticsManager.shared.log("Sort applied: \(sortOption.rawValue)")
    }
    
    func logError(_ error: Error, context: String) {
        let parameters: [String: Any] = [
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code,
            "context": context
        ]
        
        Analytics.logEvent("app_error", parameters: parameters)
        CrashlyticsManager.shared.recordError(error, userInfo: ["context": context])
    }
    
    func logCustomEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(eventName, parameters: parameters)
        
        if let params = parameters {
            CrashlyticsManager.shared.log("Custom event: \(eventName) - \(params)")
        } else {
            CrashlyticsManager.shared.log("Custom event: \(eventName)")
        }
    }
}

