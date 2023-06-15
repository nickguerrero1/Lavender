import SwiftUI
import Firebase
import FirebaseFirestore

struct FriendListView: View {
    
    @State private var friends: [DataFetcher.User] = []
    @State private var selectedFriend: DataFetcher.User?
    
    var body: some View {
            ScrollView (showsIndicators: false) {
                VStack{
                    Spacer().frame(height: UIScreen.main.bounds.height*0.1)
                    
                    HStack{
                        Text("Friends")
                            .font(.system(size: UIScreen.main.bounds.width * 0.06))
                            .bold()
                            .padding(.trailing, 5)
                        ZStack{
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundColor(.red.opacity(0.5))
                                .frame(width: measureTextWidth(text: "\(String(friends.count))", fontSize: UIScreen.main.bounds.width * 0.04) + UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.width * 0.06)
                            Text("\(friends.count)")
                                .bold()
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                        }
                    }
                    .padding(.bottom)
                    
                    ForEach(friends.indices, id: \.self) { index in
                        HStack {
                            Spacer()
                            Button(action: {
                                selectedFriend = friends[index]
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundColor(.green.opacity(0.4))
                                        .frame(width: 280, height: 60)
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundColor(.white.opacity(0.2))
                                        .frame(width: 270, height: 50)
                                    VStack {
                                        Text(friends[index].first + " " + friends[index].last)
                                            .frame(width: 220, height: 40)
                                            .bold()
                                        Text(friends[index].username)
                                            .frame(width: 220, height: 40)
                                            .padding(.top, -UIScreen.main.bounds.height * 0.03)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .fullScreenCover(item: $selectedFriend) { friend in
                                FriendDetailsView(friend: friend, onRemoveFriend: {
                                    removeFriend(friend: friend)
                                })
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
                    friends = [DataFetcher.User(id: "desmondid", email: "example@example.com", username: "jaymond1990", first: "Desmond", last: "Jones"), DataFetcher.User(id: "pattyid", email: "example@example.com", username: "pwalters", first: "Patty", last: "Walters")]
                    //uncomment for testing
                }
            }
    }
    
    func measureTextWidth(text: String, fontSize: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()
        return size.width
    }
    
    func removeFriend(friend: DataFetcher.User) {
        if let index = friends.firstIndex(where: { $0.id == friend.id }) {
            friends.remove(at: index)
        }
    }
}

struct FriendListView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListView()
    }
}

extension DataFetcher.User: Identifiable {}
