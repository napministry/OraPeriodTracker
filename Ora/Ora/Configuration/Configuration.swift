//
//  Configuration.swift
//  Ora
//
//  Created by Theresa Nguyen on 4/24/23.
//

import Foundation
import SwiftUI

class AppConfig {
    // MARK: - UI Styles
    static let darkGrayColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    static let lightGrayColor: Color = Color(#colorLiteral(red: 0.9715679288, green: 0.9767021537, blue: 0.9764299989, alpha: 1))
    static let bottomViewGradient: [Color] = [Color(#colorLiteral(red: 0.9330931306, green: 0.9175280929, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.7744475007, green: 0.3476321101, blue: 0.418612957, alpha: 1))]
    static let dashboardGradient: [Color] = [Color(#colorLiteral(red: 0.9330931306, green: 0.9175280929, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.7828599811, green: 0.3512490094, blue: 0.4224076867, alpha: 1))]
    
    // MARK: - Ovulation
    static let ovulationDay = 14 /// an esimated/average day when a woman ovulates based on the first day of the period
}
