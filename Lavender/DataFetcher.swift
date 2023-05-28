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
                    let firebaseRar = ["rarity1","rarity2","rarity3","rarity4","rarity5","rarity6","rarity7","rarity8"]
                    for index in 0...7 {
                        if let rarityCount = document.data()?[firebaseRar[index]] as? Int {
                            rarity[index] = rarityCount
                        }
                    }
                } else {
                    print("Document does not exist")
                }
                completion(rarity)
            }
        } else {
            for index in 0...7 {
                rarity[index] = 0
            }
            completion(rarity)
        }
    }
}
