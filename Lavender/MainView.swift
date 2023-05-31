import SwiftUI

struct MainView: View {
    
    let userEmail: String
    
    @State var currentTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: self.$currentTab) {
                PetView().tag(0)
                FlowerView().tag(1)
                FriendView(userEmail: userEmail).tag(2)
                CalendarView().tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 45)
            TabBarView(currentTab: self.$currentTab)
        }
    }
}

struct TabBarView: View {
    @Binding var currentTab: Int
    var tabBarOptions: [Image] = [Image(systemName: "pawprint.fill"), Image(systemName: "hammer.fill"), Image(systemName: "folder.fill"), Image(systemName: "clock.fill")]
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Array(zip(self.tabBarOptions.indices, self.tabBarOptions)), id: \.0, content: {
                index, name in
                TabBarItem(currentTab: self.$currentTab, tabLogo: name, tab: index)
                }
            )
        }
        .padding(.horizontal)
        .frame(alignment: .center)
    }
}

struct TabBarItem: View {
    @Binding var currentTab: Int
    
    var tabLogo: Image
    var tab: Int
    
    var body: some View {
        Button {
            self.currentTab = tab
        } label: {
            VStack{
                Spacer()
                ZStack{
                    if currentTab == tab {
                        Color.green.opacity(0.15)
                            .cornerRadius(20)
                            .frame(width: 100, height: 35)
                    }   else{
                        Color.white
                            .cornerRadius(20)
                            .frame(width: 50, height: 35)
                    }
                    tabLogo
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(userEmail: "example@example.com")
    }
}
