import FirebaseFirestore
import FirebaseAuth

class DataFetcher {
    static func loadPetalCount(completion: @escaping ([Int]) -> Void) {
        var rarity: [Int] = Array(repeating: 0, count: 8)

        if let userID = Auth.auth().currentUser?.uid {
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
        }
    }
    
    static func loadFlowerInv(completion: @escaping ([Int]) -> Void) {
        var flowerInv: [Int] = Array(repeating: 0, count: 10)

        if let userID = Auth.auth().currentUser?.uid {
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
        }
    }
}
