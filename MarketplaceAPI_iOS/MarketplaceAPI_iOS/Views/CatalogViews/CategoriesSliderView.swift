import SwiftUI

struct CategoriesSliderView: View {
    @Binding var showingCategories: Bool
    @Binding var productFilter: ProductFilter
    @State private var tempFilter = ProductFilter()
    
    let categories = ["All", "Electronics", "Computers", "Accessories", "Smartphones", "Audio"]
    let brands = ["Apple", "Samsung", "Xiaomi", "Sony", "Microsoft", "Google"]
    let colors = ["Black", "White", "Silver", "Gold", "Blue", "Red", "Green"]
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(.systemBackground))
                .frame(height: 60)
            
            headerView
            
            ScrollView {
                VStack(spacing: 24) {
                    categoriesSection
                    priceRangeSection
                    brandsSection
                    colorsSection
                    availabilitySection
                    sortSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .padding(.bottom, 20)
            }
            
            bottomButtonsView
        }
        .onAppear {
            tempFilter = productFilter
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: closeSlider) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Text("Filters")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Categories")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        title: category,
                        isSelected: tempFilter.selectedCategories.contains(category),
                        action: { toggleCategory(category) }
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var priceRangeSection: some View {
        FilterSection(title: String(localized: "Price range"), icon: "dollarsign.circle") {
            RangeSlider(
                range: $tempFilter.priceRange,
                bounds: 0...100000,
                step: 1000
            )
        }
    }
    
    private var brandsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "tag")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Brands")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(brands, id: \.self) { brand in
                    FilterButton(
                        title: brand,
                        isSelected: tempFilter.selectedBrands.contains(brand),
                        action: { toggleBrand(brand) }
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "paintpalette")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Colors")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    ColorButton(
                        color: color,
                        isSelected: tempFilter.selectedColors.contains(color),
                        action: { toggleColor(color) }
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Availability")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(AvailabilityFilter.allCases, id: \.self) { availability in
                    availabilityButton(for: availability)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Sort by")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(SortOption.allCases, id: \.self) { sortOption in
                    sortButton(for: sortOption)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var bottomButtonsView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                Button(action: resetFilters) {
                    Text("Clear all")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: applyFilters) {
                    Text("Apply filters")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 20)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
    }
    
    private func availabilityButton(for availability: AvailabilityFilter) -> some View {
        Button(action: { tempFilter.availabilityFilter = availability }) {
            HStack {
                Image(systemName: tempFilter.availabilityFilter == availability ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(tempFilter.availabilityFilter == availability ? .accentColor : .secondary)
                
                Text(availability.displayName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tempFilter.availabilityFilter == availability ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sortButton(for sortOption: SortOption) -> some View {
        Button(action: { tempFilter.sortBy = sortOption }) {
            HStack {
                Image(systemName: tempFilter.sortBy == sortOption ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(tempFilter.sortBy == sortOption ? .accentColor : .secondary)
                
                Text(sortOption.displayName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tempFilter.sortBy == sortOption ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func closeSlider() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingCategories = false
        }
    }
    
    private func resetFilters() {
        tempFilter = ProductFilter()
    }
    
    private func applyFilters() {
        AnalyticsManager.shared.logFilterApplied(
            categories: tempFilter.selectedCategories,
            brands: tempFilter.selectedBrands,
            priceRange: tempFilter.priceRange
        )
        
        AnalyticsManager.shared.logSortApplied(tempFilter.sortBy)
        
        productFilter = tempFilter
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingCategories = false
        }
    }
    
    private func toggleCategory(_ category: String) {
        if tempFilter.selectedCategories.contains(category) {
            tempFilter.selectedCategories.remove(category)
        } else {
            tempFilter.selectedCategories.insert(category)
        }
    }
    
    private func toggleBrand(_ brand: String) {
        if tempFilter.selectedBrands.contains(brand) {
            tempFilter.selectedBrands.remove(brand)
        } else {
            tempFilter.selectedBrands.insert(brand)
        }
    }
    
    private func toggleColor(_ color: String) {
        if tempFilter.selectedColors.contains(color) {
            tempFilter.selectedColors.remove(color)
        } else {
            tempFilter.selectedColors.insert(color)
        }
    }
}
