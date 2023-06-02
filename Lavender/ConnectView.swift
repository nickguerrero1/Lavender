import SwiftUI
import Firebase
import FirebaseFirestore

struct ConnectView: View {
    
    let userEmail: String
    @State private var friendRequests: [User] = []
    
    @State private var searchEmail = ""
    @State private var searchResults: [DataFetcher.User] = []
    @State private var errorMessage = ""
    
    var body: some View {
        VStack{
            Spacer()
            Text("Connect")
                .bold()
                .padding(.bottom)
            Text(errorMessage)
                .foregroundColor(.red)
                .padding(.bottom)
                .padding(.horizontal)
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
                        errorMessage = ""
                    } label: {
                        HStack(alignment: .center, spacing: 16){
                            Spacer()
                            Text(result.email)
                            Spacer()
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.blue.opacity(0.50))
                                    .frame(width: 200, height: 40)
                                Text("Send Friend Request")
                            }
                            Spacer()
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
    
    func allowRequest(friendID: String, friendEmail: String, completion: @escaping (Bool) -> Void) {
        var allowReq = false
        
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let friendRequestsCollection = db.collection("friendRequests")
        
        friendRequestsCollection
            .whereField("sender.id", isEqualTo: userID)
            .whereField("receiver.id", isEqualTo: friendID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking friend request: \(error)")
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    errorMessage = "Friend request already sent to \(friendEmail)"
                } else {
                    friendRequestsCollection
                        .whereField("sender.id", isEqualTo: friendID)
                        .whereField("receiver.id", isEqualTo: userID)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                print("Error checking friend request: \(error)")
                            } else if let documents = snapshot?.documents, !documents.isEmpty {
                                errorMessage = "\(friendEmail) has already sent a friend request to you"
                            } else {
                                allowReq = true
                                completion(allowReq)
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

