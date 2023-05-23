//
//  ContentView.swift
//  Lavender
//
//  Created by Nicholas Guerrero on 5/23/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack{
            Image("Lavender")
                .resizable()
                .frame(width: 250, height: 250)
                .cornerRadius(50)
                .padding(.bottom, 60)
            Text("Lavender")
                .font(.title)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
