//
//  CustomTeam.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 08/11/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class CustomTeam {
    var id: UUID
    var name: String
    var country: String
    var division: String
    var logoImageData: Data?
    var createdDate: Date
    
    init(name: String, country: String, division: String, logoImageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.country = country
        self.division = division
        self.logoImageData = logoImageData
        self.createdDate = Date()
    }
}
