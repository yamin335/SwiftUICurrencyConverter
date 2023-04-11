//
//  ErrorToast.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/20/22.
//

import Foundation
import SwiftUI

// MARK: - ErrorToast
struct ErrorToast: View {
    @State var message = ""
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                Spacer()
                Text(self.message)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 8)
            .padding(.top, 8)
            .background(Color.red.blur(radius: 5))
            .cornerRadius(8)
            .shadow(color: .gray, radius: 10)
            .transition(.slide)
        }
        .padding(.leading, 32)
        .padding(.trailing, 32)
        .padding(.bottom, 20)
        .padding(.top, 20)
    }
}
