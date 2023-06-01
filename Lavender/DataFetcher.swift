import FirebaseFirestore
import FirebaseAuth

class DataFetcher {
    static func loadPetalCount(completion: @escaping ([Int]) -> Void) {
        var rarity: [Int] = Array(repeating: 0, count: 8)

        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let rarityCount = document.data()?["rarity"] as? [Int] {
                        rarity = rarityCount
                    }
                } else {
                    print("Document does not exist")
                }
                completion(rarity)
            }
        }   else {
            completion(rarity)
        }
    }
    
    static func loadFlowerInv(completion: @escaping ([Int]) -> Void) {
        var flowerInv: [Int] = Array(repeating: 0, count: 10)

        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let flowerInvData = document.data()?["flowerInv"] as? [Int] {
                        flowerInv = flowerInvData
                    }
                } else {
                    print("Document does not exist")
                }
                completion(flowerInv)
            }
        }   else {
            completion(flowerInv)
        }
    }
    
    static func loadUnlocked(completion: @escaping ([Bool]) -> Void) {
        var unlocked: [Bool] = [true] + Array(repeating: false, count: recipeCount - 1)

        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let unlockedData = document.data()?["unlocked"] as? [Bool] {
                        unlocked = unlockedData
                    }
                } else {
                    print("Document does not exist")
                }
                completion(unlocked)
            }
        }   else {
            completion(unlocked)
        }
    }
    
    struct User {
        let id: String
        let email: String
    }
    
    static func searchUsers(searchEmail: String, completion: @escaping ([User]) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        
        usersCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                completion([])
            }   else{
                if let snapshot = snapshot {
                    var searchResults: [User] = []
                    
                    for document in snapshot.documents {
                        if let email = document.data()["email"] as? String {
                            if email.contains(searchEmail.lowercased()) {
                                let user = User(id: document.documentID, email: email)
                                searchResults.append(user)
                            }
                        }
                    }
                    completion(searchResults)
                }   else{
                    print("snapshot is nil")
                    completion([])
                }
            }
        }
    }
    
    static func loadOutgoing(completion: @escaping ([String]) -> Void) {
        var outgoing: [String] = []

        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let friendRequestsRef = db.collection("friendRequests")
            
            friendRequestsRef.whereField("sender.id", isEqualTo: userID).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error loading incoming friend requests: \(error)")
                }   else {
                    if let documents = snapshot?.documents {
                        for document in documents {
                            if let receiverData = document.data()["receiver"] as? [String: Any],
                               let receiverEmail = receiverData["name"] as? String {
                                outgoing.append(receiverEmail)
                            }
                        }
                    }
                }
                completion(outgoing)
            }
        }   else {
            completion(outgoing)
        }
    }
}
