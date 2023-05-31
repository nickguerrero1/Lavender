import SwiftUI
import Firebase
import FirebaseFirestore

struct FriendView: View {
    
    let userEmail: String
    @State private var friendRequests: [User] = []
    
    @State private var searchEmail = ""
    @State private var searchResults: [DataFetcher.User] = []
    
    var currentTab: Binding<Int>
    
    var body: some View {
        VStack{
            Spacer()
            Text("Discovery")
                .bold()
            TextField("Search by email", text: $searchEmail)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(30)
                .padding(.horizontal, 30)
                .autocapitalization(.none)
            VStack{
                ForEach(searchResults.prefix(5), id: \.id) { result in
                    Button {
                        sendFriendRequest(friendID: result.id, friendEmail: result.email)
                    } label: {
                        HStack{
                            Spacer().frame(width: UIScreen.main.bounds.width * 0.05)
                            Text(result.email)
                            Spacer().frame(width: UIScreen.main.bounds.width * 0.05)
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.blue.opacity(0.50))
                                    .frame(width: 200, height: 40)
                                Text("Send Friend Request")
                            }
                            Spacer().frame(width: UIScreen.main.bounds.width * 0.05)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top)
            Spacer()
        }
        .onChange(of: searchEmail) { newValue in
            DataFetcher.searchUsers(searchEmail: newValue) { fetchedResults in
                searchResults = fetchedResults
            }
        }
    }
    
    func sendFriendRequest(friendID: String, friendEmail: String) {
        let userID = Auth.auth().currentUser!.uid
        
        let db = Firestore.firestore()
        let friendRequestsCollection = db.collection("friendRequests")
        
        let sender = DataFetcher.User(id: userID, email: userEmail)
        let receiver = DataFetcher.User(id: friendID, email: friendEmail)
        
        let friendRequest = FriendRequest(sender: sender, receiver: receiver)
        
        friendRequestsCollection
            .whereField("sender.id", isEqualTo: userID)
            .whereField("receiver.id", isEqualTo: friendID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking friend request: \(error)")
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    print("Friend request already sent to this user")
                } else {
                    friendRequestsCollection.document().setData([
                        "sender": [
                            "id": friendRequest.sender.id,
                            "name": friendRequest.sender.email
                        ],
                        "receiver": [
                            "id": friendRequest.receiver.id,
                            "name": friendRequest.receiver.email
                        ]
                    ]) { error in
                        if let error = error {
                            print("Error sending friend request: \(error)")
                        } else {
                            print("Friend request sent")
                        }
                    }
                }
            }
    }
}

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        FriendView(userEmail: "example@example.com", currentTab: .constant(2))
    }
}

struct FriendRequest {
    let sender: DataFetcher.User
    let receiver: DataFetcher.User
}