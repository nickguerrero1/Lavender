import SwiftUI

struct FriendView: View {
    
    let userPassed: String
    @State var currentTab: Int = 0
    
    var body: some View {
        ZStack{
            if currentTab == 0 {
                FriendListView()
            } else if currentTab == 1 {
                ConnectView(userPassed: userPassed)
            } else if currentTab == 2 {
                IncomingView(userPassed: userPassed)
            }
            VStack{
                ZStack(alignment: .top){
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 55)
                    FriendTabBarView(currentTab: self.$currentTab)
                        .padding(.bottom, 10)
                }
                Spacer().frame(height: UIScreen.main.bounds.height * 0.842)
            }
        }
    }
}

struct FriendTabBarView: View {
    @Binding var currentTab: Int
    var tabBarOptions: [Image] = [Image(systemName: "heart.fill"), Image(systemName: "magnifyingglass"), Image(systemName: "bell.fill")]
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Array(zip(self.tabBarOptions.indices, self.tabBarOptions)), id: \.0, content: {
                index, name in
                FriendTabBarItem(currentTab: self.$currentTab, tabLogo: name, tab: index)
                }
            )
        }
        .padding(.horizontal)
        .frame(alignment: .center)
    }
}

struct FriendTabBarItem: View {
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
                        Color.purple.opacity(0.15)
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

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        FriendView(userPassed: "example@example.com")
    }
}
