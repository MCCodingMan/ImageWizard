//
//  WizardOCRManager.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/8/12.
//

import UIKit
import TesseractOCR
import BBMetalImage
import Harbeth

class WizardOCRManager {
    func OCR(_ image: UIImage) -> String? {
        let tesseract = G8Tesseract(language: "chi_sim")
        tesseract?.engineMode = .tesseractCubeCombined
        // 3
        tesseract?.pageSegmentationMode = .auto
        // 4
        tesseract?.image = image
        // 5
        tesseract?.recognize()
        // 6
        return tesseract?.recognizedText
    }
}
