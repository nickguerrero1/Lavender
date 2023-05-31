import SwiftUI
import Firebase
import FirebaseFirestore

struct FriendView: View {
    
    let userEmail: String
    @State private var friendRequests: [User] = []
    
    var body: some View {
        
        VStack{
            List(friendRequests, id: \.id) { user in
                Text(user.email)
            }
            Button {
                sendFriendRequest()
            } label: {
                ZStack{
                    Rectangle()
                        .foregroundColor(.blue.opacity(0.15))
                        .frame(width: 200, height: 50)
                        .cornerRadius(20)
                    Text("Connect")
                        .bold()
                }
            }
                .buttonStyle(.plain)
            Spacer()
        }
    }
    
    func sendFriendRequest() {
        let userID = Auth.auth().currentUser!.uid
        
        let sender = User(id: userID, email: userEmail)
        let receiver = User(id: userID, email: "friend's email")
        
        let friendRequest = FriendRequest(sender: sender, receiver: receiver)
            
        let db = Firestore.firestore()
        db.collection("friendRequests").document().setData([
            "sender": [
                "id": friendRequest.sender.id,
                "name": friendRequest.sender.email
            ],
            "receiver": [
                "id": friendRequest.receiver.id,
                "name": friendRequest.receiver.email
            ]
        ])
    }
}

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        FriendView(userEmail: "example@example.com")
    }
}

struct User {
    let id: String
    let email: String
}

struct FriendRequest {
    let sender: User
    let receiver: User
}
