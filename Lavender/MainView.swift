import SwiftUI

struct MainView: View {
    
    @State var currentTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: self.$currentTab) {
                PetView().tag(0)
                CalendarView().tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            TabBarView(currentTab: self.$currentTab)
        }
    }
}

struct TabBarView: View {
    @Binding var currentTab: Int
    var tabBarOptions: [String] = ["Pet", "Calendar"]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(zip(self.tabBarOptions.indices, self.tabBarOptions)),
                    id: \.0,
                    content: {
                    index, name in
                    TabBarItem(currentTab: self.$currentTab, tabBarItemName: name, tab: index)
                    }
                )
            }
            .padding(.horizontal)
        }
        .background(Color.purple.opacity(0.12))
        .frame(height: 0)
        .edgesIgnoringSafeArea(.all)
    }
}

struct TabBarItem: View {
    @Binding var currentTab: Int
    @Namespace var namespace
    
    var tabBarItemName: String
    var tab: Int
    
    var body: some View {
        Button {
            self.currentTab = tab
        } label: {
            VStack{
                Spacer()
                Text(tabBarItemName)
                    .font(.custom("Arial", size: 22))
                if currentTab == tab {
                    Color.black
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
