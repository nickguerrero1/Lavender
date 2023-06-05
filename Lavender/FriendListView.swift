import SwiftUI

struct FriendListView: View {
    
    @State private var friends: [DataFetcher.User] = []
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack{
                Spacer().frame(height: UIScreen.main.bounds.height*0.1)
                
                Text("Friends")
                    .font(.title)
                    .bold()
                    .padding(.bottom)
        
                ForEach(friends, id: \.id) { friend in
                    HStack{
                        Spacer()
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.green.opacity(0.4))
                                .frame(width: 280, height: 50)
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.white.opacity(0.2))
                                .frame(width: 250, height: 40)
                            Text(friend.email)
                                .frame(width: 220, height: 40)
                        }
                        Spacer()
                    }
                    .padding(.top)
                }
            }
        }
        .onAppear {
            DataFetcher.loadFriends { fetchedFriends in
                friends = fetchedFriends
            }
        }
    }
}

struct FriendListView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListView()
    }
}
