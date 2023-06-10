import SwiftUI
import Firebase
import FirebaseFirestore

struct IncomingView: View {
    
    let userPassed: String
    @State private var incomingUsers: [QueryDocumentSnapshot] = []
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack{
                Spacer().frame(height: UIScreen.main.bounds.height*0.1)
                
                HStack{
                    Text("Friend Requests")
                        .font(.system(size: UIScreen.main.bounds.width * 0.06))
                        .bold()
                        .padding(.trailing, 4)
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundColor(.red.opacity(0.5))
                            .frame(width: measureTextWidth(text: "\(String(incomingUsers.count))", fontSize: UIScreen.main.bounds.width * 0.04) + UIScreen.main.bounds.width * 0.04, height: UIScreen.main.bounds.width * 0.06)
                        Text("\(incomingUsers.count)")
                            .bold()
                            .font(.system(size: UIScreen.main.bounds.width * 0.04))
                    }
                }
                .padding(.bottom)
                
                ForEach(0..<incomingUsers.count, id: \.self) { index in
                    
                    if let senderData = incomingUsers[index].data()["sender"] as? [String: Any],
                        let friendid = senderData["id"] as? String,
                        let email = senderData["email"] as? String {
                        HStack{
                            Spacer()
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.green.opacity(0.4))
                                    .frame(width: 280, height: 90)
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.white.opacity(0.2))
                                    .frame(width: 250, height: 80)
                                VStack{
                                    Text(email)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
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
                                                "email": userPassed
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
                                                    .foregroundColor(.blue.opacity(0.8))
                                                    .frame(width: 100, height: 30)
                                                Text("Confirm")
                                                    .foregroundColor(.white)
                                                    .bold()
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        Button {
                                            let db = Firestore.firestore()
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
                                                    .foregroundColor(.white)
                                                    .frame(width: 100, height: 30)
                                                Text("Delete")
                                                    .bold()
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .frame(width: 215)
                            }
                            Spacer()
                        }
                        .padding(.top)
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
    
    func measureTextWidth(text: String, fontSize: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()
        return size.width
    }
}

struct IncomingView_Previews: PreviewProvider {
    static var previews: some View {
        IncomingView(userPassed: "example@example.com")
    }
}
