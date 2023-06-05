import SwiftUI

struct FriendListView: View {
    
    @State private var friends: [DataFetcher.User] = []
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack{
                Spacer().frame(height: UIScreen.main.bounds.height*0.1)
                
                HStack{
                    Text("Friends")
                        .font(.system(size: 25))
                        .bold()
                        .padding(.trailing, 5)
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundColor(.red.opacity(0.5))
                            .frame(width: measureTextWidth(text: "\(String(friends.count))", fontSize: 25) + 20, height: 30)
                        Text("\(friends.count)")
                            .bold()
                            .font(.system(size: 25))
                    }
                }
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
                //friends = Array(repeating: DataFetcher.User(id: "1", email: "h"), count: 100)
                //uncomment to add test friends
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
}

struct FriendListView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListView()
    }
}
