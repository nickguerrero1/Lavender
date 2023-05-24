//
//  MainView.swift
//  Lavender
//
//  Created by Nicholas Guerrero on 5/23/23.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        VStack{
            Text("You are logged in!")
                .padding(.bottom, 0)
            Spacer()
            Image("Lavender")
                .resizable()
                .frame(width: 250, height: 250)
                .cornerRadius(50)
                .padding(.bottom, 60)
            Text("Lavender")
                .font(.title)
            Spacer()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}