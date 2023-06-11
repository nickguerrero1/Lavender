import SwiftUI
import Firebase
import FirebaseFirestore

struct FriendListView: View {
    
    @State private var friends: [DataFetcher.User] = []
    @State private var displayed: [Bool] = []
    @State private var levels: [Int?] = []
    
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
                    HStack{
                        Spacer()
                        Button {
                            displayed[index].toggle()
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.green.opacity(0.4))
                                    .frame(width: 280, height: displayed[index] ? 160 : 50)
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.white.opacity(0.2))
                                    .frame(width: 250, height: displayed[index] ? 150 : 40)
                                VStack{
                                    Text(friends[index].first + " " + friends[index].last)
                                        .frame(width: 220, height: 40)
                                        .bold()
                                    
                                    if displayed[index] {
                                        Group {
                                            if let level = levels[index] {
                                                Text("Level: \(level)")
                                                Button {
                                                    let userID = Auth.auth().currentUser!.uid
                                                    let db = Firestore.firestore()
                                                    let userRef = db.collection("users").document(userID)
                                                    let friendRef = db.collection("users").document(friends[index].id)
                                                    
                                                    userRef.getDocument { (document, error) in
                                                        if let document = document, document.exists {
                                                            if var friendsArray = document.data()?["friends"] as? [[String: Any]] {
                                                                if let friendIndex = friendsArray.firstIndex(where: { ($0["id"] as? String) == friends[index].id }) {
                                                                    friendsArray.remove(at: friendIndex)
                                                                    
                                                                    userRef.updateData(["friends": friendsArray]) { error in
                                                                        if let error = error {
                                                                            print("Error removing friend on user document: \(error)")
                                                                        }   else {
                                                                            friends.remove(at: index)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            print("User document does not exist")
                                                        }
                                                    }
                                                    
                                                    friendRef.getDocument { (document, error) in
                                                        if let document = document, document.exists {
                                                            if var friendsArray = document.data()?["friends"] as? [[String: Any]] {
                                                                if let friendIndex = friendsArray.firstIndex(where: { ($0["id"] as? String) == userID }) {
                                                                    friendsArray.remove(at: friendIndex)
                                                                    
                                                                    friendRef.updateData(["friends": friendsArray]) { error in
                                                                        if let error = error {
                                                                            print("Error removing friend on friend document: \(error)")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            print("Friend document does not exist")
                                                        }
                                                    }
                                                } label: {
                                                    ZStack{
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .frame(width: 150, height: 40)
                                                            .foregroundColor(.red.opacity(0.80))
                                                        Text("Remove Friend")
                                                            .bold()
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                .padding(.bottom)
                                            } else {
                                                Text("Loading...")
                                                    .onAppear {
                                                        DataFetcher.loadLevel(user: friends[index]) { fetchedLevel in
                                                            levels[index] = fetchedLevel
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.top)
                }
            }
        }
        .onAppear {
            DataFetcher.loadFriends { fetchedFriends in
                friends = fetchedFriends
                displayed = Array(repeating: false, count: friends.count)
                levels = Array(repeating: nil, count: friends.count)
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
