//
//  ToastNotification.swift
//  Repomance
//
//  Created by Cagri Gokpinar on 22.12.2025.
//

import SwiftUI

struct ToastNotification: View {
    let message: String
    let borderColor: Color

    var body: some View {
        HStack {
            Spacer()
            Text(message)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .textCase(.uppercase)
                .foregroundColor(borderColor)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color.appBackgroundLight)
        .overlay(
            Rectangle()
                .strokeBorder(borderColor, lineWidth: BrutalistStyle.borderThin)
        )
        .brutalistShadow(BrutalistStyle.Shadow.small)
    }
}

#Preview {
    ToastNotification(message: "Successfully starred Repomance!", borderColor: .green)
        .preferredColorScheme(.light)
}
