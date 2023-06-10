import SwiftUI
import Firebase
import FirebaseFirestore

struct SignUpView: View {
    
    @State private var first = ""
    @State private var last = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var wrongFirst = 0
    @State private var wrongLast = 0
    @State private var wrongUsername = 0
    @State private var wrongEmail = 0
    @State private var wrongPassword = 0
    
    @State private var userIsLoggedIn = false
    @State private var userHasAccount = false
    @State private var errorMessage = ""
    
    var body: some View {
        if userIsLoggedIn {
            MainView(userPassed: email)
        }
        else if userHasAccount {
            ContentView()
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
                Text("Sign Up")
                    .font(.title)
                    .padding(.bottom)
                Text(errorMessage)
                    .foregroundColor(.red)
                TextField("First Name" , text: $first)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.black.opacity(0.05))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: CGFloat(wrongFirst))
                    )
                TextField("Last Name" , text: $last)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.black.opacity(0.05))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: CGFloat(wrongLast))
                    )
                TextField("Username" , text: $username)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.black.opacity(0.05))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: CGFloat(wrongUsername))
                    )
                    .autocapitalization(.none)
                TextField("Email" , text: $email)
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
                    register()
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(width: 300, height: 45)
                        .background(Color.blue)
                        .cornerRadius(50)
                        .padding(.top, 40)
                }
                
                Button {
                    login()
                } label: {
                    Text("Already have an account? ")
                        .foregroundColor(.blue)
                    +
                    Text("Log in")
                        .bold()
                }
                    .padding(.top)
            }
        }
    }
    
    func login() {
        userHasAccount.toggle()
    }

    func register() {
        wrongFirst = 0
        wrongLast = 0
        wrongUsername = 0
        wrongEmail = 0
        wrongPassword = 0
        errorMessage = ""
        
        guard !first.isEmpty else {
            errorMessage = "First name must be provided"
            wrongFirst = 2
            return
        }
        guard !last.isEmpty else {
            errorMessage = "Last name must be provided"
            wrongLast = 2
            return
        }
        guard !username.isEmpty else {
            errorMessage = "Username must be provided"
            wrongUsername = 2
            return
        }
        guard !email.isEmpty else {
            errorMessage = "Email address must be provided"
            wrongEmail = 2
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Password must be provided"
            wrongPassword = 2
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                switch error {
                case AuthErrorCode.invalidEmail:
                    errorMessage = "Invalid email format"
                    wrongEmail = 2
                case AuthErrorCode.emailAlreadyInUse:
                    errorMessage = "Email already in use"
                    wrongEmail = 2
                case AuthErrorCode.weakPassword:
                    errorMessage = "Password must be at least 6 characters long"
                    wrongPassword = 2
                default:
                    print("Registration error: \(error)")
                }
            } else {
                if let currentUser = Auth.auth().currentUser {
                    let userID = currentUser.uid
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(userID)

                    let userData = [
                        "first": self.first,
                        "last": self.last,
                        "username": self.username,
                        "email": self.email
                    ]

                    userRef.setData(userData) { error in
                        if let error = error {
                            print("Error storing user data in Firestore: \(error)")
                        } else {
                            print("User data updated in Firestore")
                        }
                    }
                }
                userIsLoggedIn.toggle()
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
