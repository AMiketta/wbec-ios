//
//  ColorButtonStyle.swift
//  wbec-ios-app
//
//  Created by Andreas Miketta on 21.02.22.
//

import SwiftUI

struct ColorButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .padding()
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
