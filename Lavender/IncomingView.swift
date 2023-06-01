import SwiftUI

struct IncomingView: View {
    
    @State private var incomingEmails: [String] = []
    
    var body: some View {
        VStack{
            HStack{
                Text("Friend Requests \(incomingEmails.count)")
                    .bold()
                    .padding(.top, UIScreen.main.bounds.height*0.06)
                    .padding(.leading)
                Spacer()
            }
            ScrollView(showsIndicators: false) {
                VStack{
                    ForEach(Array(0..<incomingEmails.count), id: \.self) { index in
                        VStack{
                            Text(incomingEmails[index])
                            HStack{
                                Button {
                                    //confirm
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
        .onAppear {
            DataFetcher.loadIncoming { fetchedIncoming in
                incomingEmails = fetchedIncoming
                incomingEmails = ["nicholasmeap@gmail.com","poopy@gmail.com","eggypop@yahoo.com"]
            }
        }
    }
}

struct IncomingView_Previews: PreviewProvider {
    static var previews: some View {
        IncomingView()
    }
}
