//
//  FlowerView.swift
//  Lavender
//
//  Created by Nicholas Guerrero on 5/25/23.
//

import SwiftUI

struct FlowerView: View {
    var body: some View {
        VStack{
            Spacer()
            ZStack{
                Circle()
                    .frame(height: 0.2 * UIScreen.main.bounds.width)
                    .foregroundColor(.purple.opacity(0.15))
                Button {
                    
                } label: {
                    Image("Lavender")
                        .resizable()
                        .frame(width: 0.15 * UIScreen.main.bounds.width, height: 0.15 * UIScreen.main.bounds.width)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 80)
        }
    }
}

struct FlowerView_Previews: PreviewProvider {
    static var previews: some View {
        FlowerView()
    }
}
