import SwiftUI
import Firebase
import FirebaseFirestore

struct ConnectView: View {
    
    let user: DataFetcher.User
    
    @State private var search = ""
    @State private var searchResults: [DataFetcher.User] = []
    @State private var errorMessage = ""
    @State private var friends: [DataFetcher.User] = []
    
    var body: some View {
        ScrollView{
            VStack {
                Spacer().frame(height: UIScreen.main.bounds.height*0.1)
                
                Text("Connect")
                    .font(.system(size: UIScreen.main.bounds.width * 0.06))
                    .bold()
                    .padding(.bottom, 20)
                
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                TextField("Search", text: $search)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(30)
                    .padding(.horizontal, 30)
                    .autocapitalization(.none)
                    .padding(.bottom, 20)
                
                ForEach(searchResults.prefix(5), id: \.id) { result in
                    if result.username != user.username {
                        ZStack{
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundColor(.green.opacity(0.4))
                                .frame(width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.height * 0.09)
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundColor(.white.opacity(0.2))
                                .frame(width: UIScreen.main.bounds.width - 70, height: UIScreen.main.bounds.height * 0.09 - 10)
                            HStack{
                                Spacer()
                                ZStack(alignment: .leading){
                                    VStack{
                                        Text(result.first + " " + result.last)
                                            .bold()
                                            .padding(.bottom, -5)
                                        Text(result.username)
                                    }
                                }
                                .frame(width: 170)
                                Button(action: {
                                    sendFriendRequest(friendID: result.id, friendEmail: result.email, friendUsername: result.username, friendFirst: result.first, friendLast: result.last)
                                }) {
                                    Text("Request")
                                        .foregroundColor(.white)
                                        .frame(width: 120, height: 40)
                                        .background(Color.blue.opacity(0.8))
                                        .cornerRadius(20)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .onChange(of: search) { newValue in
                DataFetcher.searchUsers(search: newValue) { fetchedResults in
                    searchResults = fetchedResults
                }
            }
        }
    }
    
    func allowRequest(friendID: String, friendUsername: String, completion: @escaping (Bool) -> Void) {
        var allowReq = false
        
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let friendRequestsCollection = db.collection("friendRequests")
        let usersCollection = db.collection("users")
        
        usersCollection.document(userID).getDocument { userDocument, error in
            if let error = error {
                print("Error checking friendship: \(error)")
                completion(false)
            } else if let userData = userDocument?.data(),
                let friends = userData["friends"] as? [[String: Any]],
                friends.contains(where: { $0["id"] as? String == friendID }) {
                
                errorMessage = "You are already friends with \(friendUsername)"
                completion(false)
            } else {
                friendRequestsCollection
                    .whereField("sender.id", isEqualTo: userID)
                    .whereField("receiver.id", isEqualTo: friendID)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error checking friend request: \(error)")
                            completion(false)
                        } else if let documents = snapshot?.documents, !documents.isEmpty {
                            errorMessage = "Friend request already sent to \(friendUsername)"
                            completion(false)
                        } else {
                            friendRequestsCollection
                                .whereField("sender.id", isEqualTo: friendID)
                                .whereField("receiver.id", isEqualTo: userID)
                                .getDocuments { snapshot, error in
                                    if let error = error {
                                        print("Error checking friend request: \(error)")
                                        completion(false)
                                    } else if let documents = snapshot?.documents, !documents.isEmpty {
                                        errorMessage = "\(friendUsername) has already sent a friend request to you"
                                        completion(false)
                                    } else {
                                        allowReq = true
                                        completion(allowReq)
                                    }
                                }
                        }
                    }
            }
        }
    }
    
    func sendFriendRequest(friendID: String, friendEmail: String, friendUsername: String, friendFirst: String, friendLast: String) {
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let friendRequestsCollection = db.collection("friendRequests")
        
        allowRequest(friendID: friendID, friendUsername: friendUsername) { allowed in
            if allowed {
                let sender = DataFetcher.User(id: userID, email: user.email, username: user.username, first: user.first, last: user.last)
                let receiver = DataFetcher.User(id: friendID, email: friendEmail, username: friendUsername, first: friendFirst, last: friendLast)
                let friendRequest = FriendRequest(sender: sender, receiver: receiver)
                
                friendRequestsCollection.document().setData([
                    "sender": [
                        "id": friendRequest.sender.id,
                        "email": friendRequest.sender.email,
                        "username": friendRequest.sender.username,
                        "first": friendRequest.sender.first,
                        "last": friendRequest.sender.last
                    ],
                    "receiver": [
                        "id": friendRequest.receiver.id,
                        "email": friendRequest.receiver.email,
                        "username": friendRequest.receiver.username,
                        "first": friendRequest.receiver.first,
                        "last": friendRequest.receiver.last
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

//struct ConnectView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectView(user: DataFetcher.User(id: "ID", email: "example@example.com", username: "User", first: "First", last: "Last"))
//    }
//}

//preview not working

struct FriendRequest {
    let sender: DataFetcher.User
    let receiver: DataFetcher.User
}

