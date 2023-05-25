import SwiftUI

struct MainView: View {
    
    @State private var selectedDate = Date()
    
    var body: some View {
        
        VStack{
            Text("Select Anniversary Date")
                .font(.custom("Arial", size: 25))
            Spacer()
                .frame(height: 30)
            DatePicker("Anniversary", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.top, 15)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
