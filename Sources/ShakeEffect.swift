// ShakeEffect.swift
import SwiftUI

/// Scossa orizzontale che si smorza: funziona su tutti i dispositivi
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat   // da 0 a 1
    var amplitude: CGFloat = 10

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = amplitude * (1 - animatableData) * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}
