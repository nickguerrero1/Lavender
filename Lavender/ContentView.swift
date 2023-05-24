import SwiftUI
import Firebase

struct ContentView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var wrongEmail = 0
    @State private var wrongPassword = 0
    @State private var userIsLoggedIn = false
    
    var body: some View {
        if userIsLoggedIn {
            MainView()
        } else {
            content
        }
    }
    
    var content: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            Circle()
                .scale(1.7)
                .foregroundColor(.white.opacity(0.15))
            Circle()
                .scale(1.35)
                .foregroundColor(.white)
            VStack{
                Text("Welcome")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                TextField("Email" , text: $email)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongEmail))
                SecureField("Password", text: $password)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongPassword))
                Button("Sign up"){
                    register()
                }
                .foregroundColor(.white)
                .frame(width: 300, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top)
                
                Button {
                    login()
                } label: {
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundColor(.blue)
                }
                    .padding(.top)
            }
        }
    }
    
    func login() {
        wrongPassword = 0
        wrongEmail = 0
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                switch error {
                case AuthErrorCode.wrongPassword:
                    wrongPassword = 2
                case AuthErrorCode.invalidEmail:
                    wrongEmail = 2
                default:
                    print("Login error: \(error.localizedDescription)")
                }
            } else {
                userIsLoggedIn.toggle()
            }
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print (error!.localizedDescription)
            } else {
                userIsLoggedIn.toggle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
