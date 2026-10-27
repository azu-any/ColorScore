//
//  CameraFilter.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/8/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

/// Accessibility and Magnifier-inspired camera filters for users with daltonism and low vision.
enum CameraFilter: String, CaseIterable, Identifiable {
    case none = "None"
    case protanopia = "Protanopia"
    case deuteranopia = "Deuteranopia"
    case tritanopia = "Tritanopia"
    case yellowBlue = "YellowBlue"
    case yellowBlack = "YellowBlack"
    case whiteBlue = "WhiteBlue"
    case redBlack = "RedBlack"
    case grayscale = "Grayscale"
    case inverted = "Inverted"
    
    var id: String { rawValue }
    
    /// Localized Spanish name for UI and VoiceOver
    var localizedName: String {
        switch self {
        case .none: return "Sin filtro"
        case .protanopia: return "Protanopía"
        case .deuteranopia: return "Deuteranopía"
        case .tritanopia: return "Tritanopía"
        case .yellowBlue: return "Amarillo / Azul"
        case .yellowBlack: return "Amarillo / Negro"
        case .whiteBlue: return "Blanco / Azul"
        case .redBlack: return "Rojo / Negro"
        case .grayscale: return "Escala de grises"
        case .inverted: return "Invertido"
        }
    }
    
    /// Short localized category or subtitle for accessibility hints
    var localizedDescription: String {
        switch self {
        case .none:
            return "Muestra los colores originales de la cámara"
        case .protanopia:
            return "Realza el contraste rojo-verde para dificultad con el color rojo"
        case .deuteranopia:
            return "Separa tonos verdes y rojos para dificultad con el color verde"
        case .tritanopia:
            return "Realza el contraste azul-amarillo para tritanopía"
        case .yellowBlue:
            return "Filtro estilo Lupa de alto contraste en amarillo y azul"
        case .yellowBlack:
            return "Filtro estilo Lupa de alto contraste en amarillo sobre negro"
        case .whiteBlue:
            return "Filtro estilo Lupa de alto contraste en blanco sobre azul"
        case .redBlack:
            return "Filtro estilo Lupa de alto contraste en rojo sobre negro"
        case .grayscale:
            return "Elimina los colores del campo para destacar los marcadores de jugadores"
        case .inverted:
            return "Invierte los colores de la imagen de la cámara"
        }
    }
    
    /// Representative dual colors for the filter swatch preview in the UI
    var swatchColors: (primary: Color, secondary: Color) {
        switch self {
        case .none:
            return (Color(red: 0.25, green: 0.78, blue: 0.40), Color(red: 0.20, green: 0.55, blue: 0.95))
        case .protanopia:
            return (Color(red: 0.95, green: 0.45, blue: 0.75), Color(red: 0.15, green: 0.75, blue: 0.65))
        case .deuteranopia:
            return (Color(red: 0.95, green: 0.65, blue: 0.10), Color(red: 0.15, green: 0.50, blue: 0.90))
        case .tritanopia:
            return (Color(red: 0.90, green: 0.20, blue: 0.45), Color(red: 0.05, green: 0.75, blue: 0.70))
        case .yellowBlue:
            return (Color(red: 1.0, green: 0.92, blue: 0.15), Color(red: 0.05, green: 0.22, blue: 0.65))
        case .yellowBlack:
            return (Color(red: 1.0, green: 0.92, blue: 0.10), Color(red: 0.10, green: 0.10, blue: 0.12))
        case .whiteBlue:
            return (Color.white, Color(red: 0.05, green: 0.25, blue: 0.70))
        case .redBlack:
            return (Color(red: 0.95, green: 0.25, blue: 0.20), Color(red: 0.10, green: 0.10, blue: 0.12))
        case .grayscale:
            return (Color(white: 0.88), Color(white: 0.28))
        case .inverted:
            return (Color(red: 0.15, green: 0.85, blue: 0.95), Color(red: 0.90, green: 0.20, blue: 0.80))
        }
    }
    
    /// Icon name representing the filter type
    var iconName: String {
        switch self {
        case .none:
            return "camera.filters"
        case .protanopia, .deuteranopia, .tritanopia:
            return "eye.circle.fill"
        case .yellowBlue, .yellowBlack, .whiteBlue, .redBlack:
            return "circle.lefthalf.filled"
        case .grayscale:
            return "circle.lefthalf.filled.righthalf.striped.horizontal"
        case .inverted:
            return "circle.lefthalf.filled.inverse"
        }
    }
    
    /// Visual swatch view for buttons and pickers
    @ViewBuilder
    func swatchView(size: CGFloat = 28) -> some View {
        let colors = swatchColors
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [colors.primary, colors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            if self == .none {
                Image(systemName: "slash.circle")
                    .font(.system(size: size * 0.55, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
            } else {
                // Diagonal split effect like Magnifier filter icons
                Circle()
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.2)
                    .frame(width: size, height: size)
            }
        }
        .accessibilityHidden(true)
    }
    
    /// Applies the Core Image filter to a live camera frame
    func apply(to image: CIImage) -> CIImage {
        switch self {
        case .none:
            return image
            
        case .protanopia:
            // Daltonization enhancement for Protanopia (Red-blindness):
            // Shifts red-green differences into visible blue/green channels and boosts contrast
            let matrix = CIFilter.colorMatrix()
            matrix.inputImage = image
            matrix.rVector = CIVector(x: 1.0, y: 0.0, z: 0.0, w: 0.0)
            matrix.gVector = CIVector(x: 0.32, y: 0.68, z: 0.0, w: 0.0)
            matrix.bVector = CIVector(x: 0.65, y: -0.65, z: 1.0, w: 0.0)
            matrix.aVector = CIVector(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            guard let matrixOutput = matrix.outputImage else { return image }
            
            let controls = CIFilter.colorControls()
            controls.inputImage = matrixOutput
            controls.contrast = 1.12
            controls.saturation = 1.15
            return controls.outputImage ?? matrixOutput
            
        case .deuteranopia:
            // Daltonization enhancement for Deuteranopia (Green-blindness):
            // Separates green pitch from red/orange jerseys by routing red-green delta into blue/red
            let matrix = CIFilter.colorMatrix()
            matrix.inputImage = image
            matrix.rVector = CIVector(x: 1.0, y: 0.22, z: -0.22, w: 0.0)
            matrix.gVector = CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0)
            matrix.bVector = CIVector(x: 0.65, y: -0.65, z: 1.0, w: 0.0)
            matrix.aVector = CIVector(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            guard let matrixOutput = matrix.outputImage else { return image }
            
            let controls = CIFilter.colorControls()
            controls.inputImage = matrixOutput
            controls.contrast = 1.15
            controls.saturation = 1.2
            return controls.outputImage ?? matrixOutput
            
        case .tritanopia:
            // Daltonization enhancement for Tritanopia (Blue-Yellow blindness):
            // Shifts blue-yellow differences into cyan/red channels
            let matrix = CIFilter.colorMatrix()
            matrix.inputImage = image
            matrix.rVector = CIVector(x: 1.0, y: -0.35, z: 0.35, w: 0.0)
            matrix.gVector = CIVector(x: -0.25, y: 1.0, z: 0.25, w: 0.0)
            matrix.bVector = CIVector(x: 0.0, y: 0.0, z: 1.0, w: 0.0)
            matrix.aVector = CIVector(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            guard let matrixOutput = matrix.outputImage else { return image }
            
            let controls = CIFilter.colorControls()
            controls.inputImage = matrixOutput
            controls.contrast = 1.15
            controls.saturation = 1.15
            return controls.outputImage ?? matrixOutput
            
        case .yellowBlue:
            // Magnifier-style Yellow / Blue high-contrast duotone filter
            let falseColor = CIFilter.falseColor()
            falseColor.inputImage = image
            falseColor.color0 = CIColor(red: 0.02, green: 0.14, blue: 0.48)
            falseColor.color1 = CIColor(red: 1.0, green: 0.92, blue: 0.15)
            return falseColor.outputImage ?? image
            
        case .yellowBlack:
            // Magnifier-style Yellow / Black high-contrast duotone filter
            let falseColor = CIFilter.falseColor()
            falseColor.inputImage = image
            falseColor.color0 = CIColor(red: 0.0, green: 0.0, blue: 0.0)
            falseColor.color1 = CIColor(red: 1.0, green: 0.92, blue: 0.10)
            return falseColor.outputImage ?? image
            
        case .whiteBlue:
            // Magnifier-style White / Blue high-contrast duotone filter
            let falseColor = CIFilter.falseColor()
            falseColor.inputImage = image
            falseColor.color0 = CIColor(red: 0.0, green: 0.16, blue: 0.52)
            falseColor.color1 = CIColor(red: 1.0, green: 1.0, blue: 1.0)
            return falseColor.outputImage ?? image
            
        case .redBlack:
            // Magnifier-style Red / Black high-contrast duotone filter
            let falseColor = CIFilter.falseColor()
            falseColor.inputImage = image
            falseColor.color0 = CIColor(red: 0.0, green: 0.0, blue: 0.0)
            falseColor.color1 = CIColor(red: 1.0, green: 0.24, blue: 0.18)
            return falseColor.outputImage ?? image
            
        case .grayscale:
            // Magnifier-style Grayscale with enhanced contrast
            let controls = CIFilter.colorControls()
            controls.inputImage = image
            controls.saturation = 0.0
            controls.contrast = 1.18
            return controls.outputImage ?? image
            
        case .inverted:
            // Magnifier-style Color Invert
            let invert = CIFilter.colorInvert()
            invert.inputImage = image
            return invert.outputImage ?? image
        }
    }
}
