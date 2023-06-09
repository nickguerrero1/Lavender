import SwiftUI
import Firebase
import FirebaseFirestore

struct ContentView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var wrongEmail = 0
    @State private var wrongPassword = 0
    @State private var userIsLoggedIn = false
    @State private var userSignUp = false
    @State private var errorMessage = ""
    
    var body: some View {
        if userIsLoggedIn {
            MainView(userEmail: email)
        }
        else if userSignUp {
            SignUpView()
        }
        else {
            content
        }
    }
    
    var content: some View {
        ZStack{
            Color.green
                .ignoresSafeArea()
            Circle()
                .scale(2.0)
                .foregroundColor(.white.opacity(0.15))
            Circle()
                .scale(1.8)
                .foregroundColor(.white)
            VStack{
                Image("Lavender")
                    .resizable()
                    .frame(width: 100, height: 100)
                Text("Lavender")
                    .font(.largeTitle)
                    .padding(.bottom)
                Text(errorMessage)
                    .foregroundColor(.red)
                TextField("Username or Email" , text: $email)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.black.opacity(0.05))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: CGFloat(wrongEmail))
                    )
                    .autocapitalization(.none)
                    .onChange(of: email) { newValue in
                        email = newValue.lowercased()
                    }
                SecureField("Password", text: $password)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.black.opacity(0.05))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: CGFloat(wrongPassword))
                    )
                
                Button(action: {
                    login()
                }) {
                    Text("LOGIN")
                        .foregroundColor(.white)
                        .frame(width: 300, height: 45)
                        .background(Color.blue)
                        .cornerRadius(50)
                        .padding(.top)
                }
                
                Button {
                    register()
                } label: {
                    Text("Don't have an account? ")
                        .foregroundColor(.blue)
                    +
                    Text("Sign up")
                        .bold()
                }
                    .padding(.top)
            }
        }
    }
    func login() {
        wrongPassword = 0
        wrongEmail = 0
        errorMessage = ""

        guard !email.isEmpty else {
            errorMessage = "Username or Email address must be provided"
            wrongEmail = 2
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Password must be provided"
            wrongPassword = 2
            return
        }

        // Check if the provided identifier is an email or username
        let isEmail = email.contains("@")
        var queryField = "email"

        if !isEmail {
            queryField = "username"
        }

        let db = Firestore.firestore()
        let usersRef = db.collection("users")

        // Query the users collection to find a user with the provided email/username
        let query = usersRef.whereField(queryField, isEqualTo: email).limit(to: 1)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }

            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // User found, proceed with authentication
                let document = documents[0]
                let userId = document.documentID

                Auth.auth().signIn(withEmail: document.data()["email"] as? String ?? "", password: password) { result, error in
                    if let error = error as NSError? {
                        switch error.code {
                        case AuthErrorCode.wrongPassword.rawValue:
                            errorMessage = "Incorrect password"
                            wrongPassword = 2
                        default:
                            print("Login error: \(error.localizedDescription)")
                        }
                    } else {
                        userIsLoggedIn.toggle()
                    }
                }
            } else {
                // No user found with the provided email/username
                errorMessage = "No user found"
                wrongEmail = 2
                wrongPassword = 2
            }
        }
    }

//    func login() {
//        wrongPassword = 0
//        wrongEmail = 0
//        errorMessage = ""
//
//        guard !email.isEmpty else {
//            errorMessage = "Email address must be provided"
//            wrongEmail = 2
//            return
//        }
//        guard !password.isEmpty else {
//            errorMessage = "Password must be provided"
//            wrongPassword = 2
//            return
//        }
//
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error as NSError? {
//                switch error {
//                case AuthErrorCode.wrongPassword:
//                    errorMessage = "Incorrect password"
//                    wrongPassword = 2
//                case AuthErrorCode.invalidEmail:
//                    errorMessage = "Invalid email format"
//                    wrongEmail = 2
//                case AuthErrorCode.userNotFound:
//                    errorMessage = "No user found"
//                    wrongEmail = 2
//                    wrongPassword = 2
//                default:
//                    print("Login error: \(error.localizedDescription)")
//                }
//            } else {
//                userIsLoggedIn.toggle()
//            }
//        }
//    }
    
    func register() {
        userSignUp.toggle()
        SignUpView()
//        wrongPassword = 0
//        wrongEmail = 0
//        errorMessage = ""
//
//        guard !email.isEmpty else {
//            errorMessage = "Email address must be provided"
//            wrongEmail = 2
//            return
//        }
//        guard !password.isEmpty else {
//            errorMessage = "Password must be provided"
//            wrongPassword = 2
//            return
//        }
//
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error as NSError? {
//                switch error {
//                case AuthErrorCode.invalidEmail:
//                    errorMessage = "Invalid email format"
//                    wrongEmail = 2
//                case AuthErrorCode.emailAlreadyInUse:
//                    errorMessage = "Email already in use"
//                    wrongEmail = 2
//                case AuthErrorCode.weakPassword:
//                    errorMessage = "Password must be at least 6 characters long"
//                    wrongPassword = 2
//                default:
//                    print("Registration error: \(error.localizedDescription)")
//                }
//            } else {
//
//                if let currentUser = Auth.auth().currentUser {
//                    let userID = currentUser.uid
//                    let db = Firestore.firestore()
//                    let userRef = db.collection("users").document(userID)
//
//                    userRef.setData(["email": self.email]) { error in
//                        if let error = error {
//                            print("Error storing email in Firestore: \(error)")
//                        }   else {
//                            print("email updated in Firestore")
//                        }
//                    }
//                }
//                userIsLoggedIn.toggle()
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
