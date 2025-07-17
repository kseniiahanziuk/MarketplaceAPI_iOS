import SwiftUI

struct ProductImageView: View {
    let imageUrl: String?
    let placeholderIcon: String
    let aspectRatio: CGFloat
    @State private var imageLoadingState: ImageLoadingState = .loading
    
    enum ImageLoadingState {
        case loading
        case loaded(Image)
        case failed
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .aspectRatio(aspectRatio, contentMode: .fit)
            
            switch imageLoadingState {
            case .loading:
                ProgressView()
                    .scaleEffect(0.8)
                    .foregroundColor(.accentColor)
            
            case .loaded(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            
            case .failed:
                Image(systemName: placeholderIcon)
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: imageUrl) { _, _ in
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let imageUrlString = imageUrl,
              imageUrlString != "photo",
              !imageUrlString.isEmpty,
              let url = URL(string: imageUrlString) else {
            imageLoadingState = .loaded(Image(systemName: placeholderIcon))
            return
        }
        
        imageLoadingState = .loading
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let uiImage = UIImage(data: data) {
                    imageLoadingState = .loaded(Image(uiImage: uiImage))
                } else {
                    imageLoadingState = .failed
                }
            }
        }.resume()
    }
}
