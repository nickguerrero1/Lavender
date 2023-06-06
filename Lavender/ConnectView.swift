import SwiftUI
import Firebase
import FirebaseFirestore

struct ConnectView: View {
    
    let userEmail: String
    
    @State private var searchEmail = ""
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
                
                TextField("Search by email", text: $searchEmail)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(30)
                    .padding(.horizontal, 30)
                    .autocapitalization(.none)
                    .padding(.bottom, 20)
                
                ForEach(searchResults.prefix(5), id: \.id) { result in
                    if result.email != userEmail {
                        HStack{
                            Spacer()
                            ZStack(alignment: .leading){
                                Text(result.email)
                            }
                            .frame(width: 170)
                            Spacer()
                            Button(action: {
                                sendFriendRequest(friendID: result.id, friendEmail: result.email)
                            }) {
                                Text("Request")
                                    .foregroundColor(.white)
                                    .frame(width: 150, height: 40)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(20)
                            }
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 80)
            .onChange(of: searchEmail) { newValue in
                DataFetcher.searchUsers(searchEmail: newValue) { fetchedResults in
                    searchResults = fetchedResults
                }
            }
        }
    }
    
    func allowRequest(friendID: String, friendEmail: String, completion: @escaping (Bool) -> Void) {
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
                
                errorMessage = "You are already friends with \(friendEmail)"
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
                            errorMessage = "Friend request already sent to \(friendEmail)"
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
                                        errorMessage = "\(friendEmail) has already sent a friend request to you"
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
    
    func sendFriendRequest(friendID: String, friendEmail: String) {
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let friendRequestsCollection = db.collection("friendRequests")
        
        allowRequest(friendID: friendID, friendEmail: friendEmail) { allowed in
            if allowed {
                let sender = DataFetcher.User(id: userID, email: userEmail)
                let receiver = DataFetcher.User(id: friendID, email: friendEmail)
                let friendRequest = FriendRequest(sender: sender, receiver: receiver)
                
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

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView(userEmail: "example@example.com")
    }
}

struct FriendRequest {
    let sender: DataFetcher.User
    let receiver: DataFetcher.User
}

