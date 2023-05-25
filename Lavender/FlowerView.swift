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
            Spacer().frame(height: 600)
            ZStack{
                Circle()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.purple.opacity(0.15))
                Button {
                    
                } label: {
                    Image("Lavender")
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct FlowerView_Previews: PreviewProvider {
    static var previews: some View {
        FlowerView()
    }
}
