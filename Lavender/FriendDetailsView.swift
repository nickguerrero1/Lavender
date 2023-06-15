import SwiftUI
import Firebase
import FirebaseFirestore

struct FriendDetailsView: View {
    
    let friend: DataFetcher.User
    @State private var level: Int = 0
    @State private var experience: Int = 0
    @Environment(\.presentationMode) var presentationMode
    var onRemoveFriend: (() -> Void)?
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text(friend.first + " " + friend.last)
                    .font(.title)
                    .bold()
                    .padding(.top, UIScreen.main.bounds.height * 0.07)
                HStack{
                    Text("username: ")
                        .bold()
                    Text(friend.username)
                }
                .padding(.top)
                HStack{
                    Text("email: ")
                        .bold()
                    Text(friend.email)
                }
                HStack{
                    Text("Level: ")
                        .bold()
                    Text("\(level)")
                }
                .padding(.top)
                HStack{
                    Text("XP: ")
                        .bold()
                    Text("\(experience)")
                }
                Spacer()
                Button {
                    showAlert = true
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
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            .onAppear {
                DataFetcher.loadLevel(user: friend) { fetchedLevel in
                    level = fetchedLevel
                }
                DataFetcher.loadFriendExperience(friend: friend) { fetchedExperience in
                    experience = fetchedExperience
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Remove Friend"),
                    message: Text("Are you sure you want to remove this friend?"),
                    primaryButton: .cancel(Text("Cancel")),
                    secondaryButton: .destructive(Text("Remove"), action: {
                        removeFriend()
                    })
                )
            }
            .padding(UIScreen.main.bounds.width * 0.1)
        }
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.title)
        }
    }
    
    private func removeFriend() {
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        let friendRef = db.collection("users").document(friend.id)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if var friendsArray = document.data()?["friends"] as? [[String: Any]] {
                    if let friendIndex = friendsArray.firstIndex(where: { ($0["id"] as? String) == friend.id }) {
                        friendsArray.remove(at: friendIndex)
                        
                        userRef.updateData(["friends": friendsArray]) { error in
                            if let error = error {
                                print("Error removing friend on user document: \(error)")
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
        onRemoveFriend?()
        presentationMode.wrappedValue.dismiss()
    }
}

struct FriendDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        //FriendDetailsView(friend: DataFetcher.User(id: "FriendID", email: "friend@gmail.com", username: "FriendName", first: "First", last: "Last"))
        FriendDetailsView(friend: DataFetcher.User(id: "FriendID", email: "LOOOOOOOOOOONNNNNNNNNNNGGGGGGGGG", username: "FriendNameLONGGGGGGGGGGGGGGGGGGGGGGGG", first: "LONGGGGGGGGG", last: "NNAAAAAAAAAAAAAmEEEEEEEE"))
    }
}
