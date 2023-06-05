import SwiftUI
import Firebase
import FirebaseFirestore

struct IncomingView: View {
    
    let userEmail: String
    @State private var incomingUsers: [QueryDocumentSnapshot] = []
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Text("Friend Requests")
                    .bold()
                    .padding(.top, UIScreen.main.bounds.height*0.06)
                    .padding(.leading)
                ZStack{
                    Circle()
                        .foregroundColor(.red.opacity(0.5))
                        .frame(width: 30, height: 25)
                    Text("\(incomingUsers.count)")
                        .bold()
                }
                .padding(.top, UIScreen.main.bounds.height*0.06)
                Spacer()
            }
            ScrollView(showsIndicators: false) {
                VStack{
                    ForEach(0..<incomingUsers.count, id: \.self) { index in
                        
                        if let senderData = incomingUsers[index].data()["sender"] as? [String: Any],
                            let friendid = senderData["id"] as? String,
                            let email = senderData["name"] as? String {
                            
                            VStack{
                                Text(email)
                                HStack{
                                    Button {
                                        let userID = Auth.auth().currentUser!.uid
                                        let db = Firestore.firestore()
                                        let usersCollection = db.collection("users")
                                        
                                        let friendData: [String: Any] = [
                                            "id": friendid,
                                            "email": email
                                        ]
                                        
                                        let userDocument = usersCollection.document(userID)
                                        userDocument.updateData([
                                            "friends": FieldValue.arrayUnion([friendData])
                                        ]) { error in
                                            if let error = error {
                                                print("Error updating friends: \(error)")
                                            }
                                        }
                                        
                                        let userData: [String: Any] = [
                                            "id": userID,
                                            "email": userEmail
                                        ]
                                        
                                        let friendDocument = usersCollection.document(friendid)
                                        friendDocument.updateData([
                                            "friends": FieldValue.arrayUnion([userData])
                                        ]) { error in
                                            if let error = error {
                                                print("Error updating friends: \(error)")
                                            }
                                        }
                                        
                                        let friendReqCollection = db.collection("friendRequests")
                                        
                                        friendReqCollection.document(incomingUsers[index].documentID).delete { error in
                                            if let error = error {
                                                print("Error deleting friend request: \(error)")
                                            }
                                        }
                                        
                                        incomingUsers.remove(at: index)
                                    } label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 30)
                                                .foregroundColor(.blue)
                                                .frame(width: 100, height: 30)
                                            Text("Confirm")
                                                .foregroundColor(.white)
                                                .bold()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    Button {
                                        //delete
                                    } label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 30)
                                                .foregroundColor(.gray.opacity(0.20))
                                                .frame(width: 100, height: 30)
                                            Text("Delete")
                                                .bold()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(15)
                        }
                    }
                }
            }
        }
        .onAppear {
            DataFetcher.loadIncoming { fetchedIncoming in
                incomingUsers = fetchedIncoming
            }
        }
    }
}

struct IncomingView_Previews: PreviewProvider {
    static var previews: some View {
        IncomingView(userEmail: "example@example.com")
    }
}
