//
//  Untitled.swift
//  Drink Tracker 1
//
//  Created by Elena Vargas on 07/11/25.
//

import UIKit


struct HapticFeedback {
    static func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
