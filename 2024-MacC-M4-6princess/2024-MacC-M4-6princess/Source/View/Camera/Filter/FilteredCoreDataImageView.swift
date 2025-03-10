//
//  File.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 3/10/25.
//

import SwiftUI
import CoreData

//카메라뷰에 뜨는 프레임 뷰를 따로 뺌(기존 frameManager.resultImage에서 CoreData 연동으로 변경)
struct FilteredCoreDataImageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let filterID: UUID

    @FetchRequest private var fetchedImages: FetchedResults<StoreImages>

    init(filterID: UUID) {
        self.filterID = filterID
        _fetchedImages = FetchRequest(
            entity: StoreImages.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "uuid == %@", filterID as CVarArg),
            animation: .default
        )
    }

    var body: some View {
        Group {
            if let imageData = fetchedImages.first?.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.clear // 이미지 없을 때 빈 화면 처리
            }
        }
        .allowsHitTesting(false)
    }
}

