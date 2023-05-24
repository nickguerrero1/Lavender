import SwiftUI

enum Screen{
    case one
    case two
}

final class TabRouter: ObservableObject {
    @Published var screen: Screen = .one
    func change(to screen: Screen){
        self.screen = screen
    }
}

@main
struct LavenderApp: App {
    
    @StateObject var router = TabRouter()
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $router.screen){
                ContentView()
                    .tag(Screen.one)
                    .environmentObject(router)
                MainView()
                    .tag(Screen.two)
            }
        }
    }
}
