import SwiftUI

struct PaginationView: View {
    let currentPage: Int
    let totalPages: Int
    let hasMoreProducts: Bool
    let isLoading: Bool
    let onPageChange: (Int) -> Void
    let onLoadMore: () -> Void
    
    private var visiblePages: [Int] {
        let maxVisiblePages = 5
        let halfRange = maxVisiblePages / 2
        
        let startPage = max(0, min(currentPage - halfRange, totalPages - maxVisiblePages))
        let endPage = min(totalPages - 1, startPage + maxVisiblePages - 1)
        
        return Array(startPage...endPage)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if totalPages > 1 {
                paginationControls
            }
            
            if isLoading {
                loadingIndicator
            }
            
            if totalPages > 0 {
                pageInfo
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var paginationControls: some View {
        HStack(spacing: 8) {
            Button(action: {
                if currentPage > 0 {
                    onPageChange(currentPage - 1)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                    Text("Previous")
                        .font(.caption)
                }
                .foregroundColor(currentPage > 0 ? .accentColor : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(currentPage > 0 ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                )
            }
            .disabled(currentPage <= 0)
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(visiblePages, id: \.self) { page in
                    Button(action: {
                        onPageChange(page)
                    }) {
                        Text("\(page + 1)")
                            .font(.caption)
                            .fontWeight(page == currentPage ? .bold : .regular)
                            .foregroundColor(page == currentPage ? .white : .accentColor)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(page == currentPage ? Color.accentColor : Color.accentColor.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
            
            Button(action: {
                if currentPage < totalPages - 1 {
                    onPageChange(currentPage + 1)
                }
            }) {
                HStack(spacing: 4) {
                    Text("Next")
                        .font(.caption)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(currentPage < totalPages - 1 ? .accentColor : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(currentPage < totalPages - 1 ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                )
            }
            .disabled(currentPage >= totalPages - 1)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var loadingIndicator: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var pageInfo: some View {
        Text("Page \(currentPage + 1) of \(totalPages)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
