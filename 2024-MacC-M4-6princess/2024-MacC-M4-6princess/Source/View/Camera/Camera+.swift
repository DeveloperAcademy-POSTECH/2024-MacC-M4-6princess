//
//  Camera+.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/11/24.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreData

extension CameraView {
    //이미지 렌더링해서 불러오기
    func loadSelectedFrame() {
        guard let frameId = frameManager.selectedFrame else {
            frameManager.resultImage = nil
            return
        }
        
        let fetchRequest: NSFetchRequest<StoreImages> = StoreImages.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", frameId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let storedImage = results.first, let imageData = storedImage.image {
                frameManager.resultImage = UIImage(data: imageData)
            } else {
                frameManager.resultImage = nil
            }
        } catch {
            print("Error fetching frame: \(error)")
            frameManager.resultImage = nil
        }
    }
    
//    func 
}
