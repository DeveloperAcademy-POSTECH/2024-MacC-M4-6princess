import SwiftUI

class ImageListModel: ObservableObject {
    
    @Published var imageList: [SubjectImage] = []
}

