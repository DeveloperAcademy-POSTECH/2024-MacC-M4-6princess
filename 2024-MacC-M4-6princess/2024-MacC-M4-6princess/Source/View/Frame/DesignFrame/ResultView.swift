import SwiftUI

struct ResultView: View {
    @Binding var image: UIImage?
    
    var body: some View {
        VStack {
            Image(uiImage: image!)
                .resizable()
                .scaledToFit()
        }
    }
}
