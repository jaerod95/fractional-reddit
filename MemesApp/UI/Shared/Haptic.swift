//
//  Haptic.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit

/// Helper class that provides simple API for haptic feedback.
public struct Haptic {
    /// Generator used for creating specific system haptic feedback.
    static let generator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    /// Generator used for creating specific system haptic feedback of style light.
    static let lightFeedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    /// Generator used for creating specific system haptic feedback of style medium.
    static let mediumFeedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    /// Generator used for creating specific system haptic feedback of style heavy.
    static let heavyFeedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    /// Performs a success haptic feedback event.
    public static func success() {
        generator.notificationOccurred(.success)
    }
    
    /// Performs a info haptic feedback event.
    public static func info() {
        lightFeedbackGenerator.impactOccurred()
    }
    
    /// Performs a warning haptic feedback event.
    public static func warning() {
        generator.notificationOccurred(.warning)
    }
    
    /// Performs a error haptic feedback event.
    public static func error() {
        generator.notificationOccurred(.error)
    }
    
    /// Performs a light haptic feedback event.
    public static func light() {
        lightFeedbackGenerator.impactOccurred()
    }
    
    /// Performs a medium haptic feedback event.
    public static func medium() {
        mediumFeedbackGenerator.impactOccurred()
    }
    
    /// Performs a heavy haptic feedback event.
    public static func heavy() {
        heavyFeedbackGenerator.impactOccurred()
    }
}
