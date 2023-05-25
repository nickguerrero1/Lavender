import SwiftUI

struct MainView: View {
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content:{
            VStack{
                Image("Lavender")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(50)
                    .padding(.bottom, 60)
                Text("Lavender")
                    .font(.title)
                Spacer()
                Image("Lavender")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(50)
                    .padding(.bottom, 60)
                Text("Lavender")
                    .font(.title)
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
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
