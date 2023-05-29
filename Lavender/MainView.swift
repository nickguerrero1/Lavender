import SwiftUI

struct MainView: View {
    
    @State var currentTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: self.$currentTab) {
                PetView().tag(0)
                FlowerView().tag(1)
                CalendarView().tag(2)
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
    var tabBarOptions: [String] = ["Pet", "Flower", "Calendar"]
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Array(zip(self.tabBarOptions.indices, self.tabBarOptions)), id: \.0, content: {
                index, name in
                TabBarItem(currentTab: self.$currentTab, tabBarItemName: name, tab: index)
                }
            )
        }
        .padding(.horizontal)
        .frame(alignment: .center)
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
                ZStack{
                    Text(tabBarItemName)
                        .font(.custom("Arial", size: 22))
                        .fontWeight(currentTab == tab ? .bold : .regular)
                    if currentTab == tab {
                        Color.green.opacity(0.15)
                            .cornerRadius(20)
                            .frame(height: 35)
                            .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                    }
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
