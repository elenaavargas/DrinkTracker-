//
//  Statistics.swift
//  Drink Tracker 1
//
//  Created by Elena Vargas on 10/11/25.
//

import SwiftUI

// Just an example, not working

struct DrinkRecord: Identifiable {
    let id = UUID()
    let day: String
    let amount: Int
    
   
    var amountInLiters: String {
        return String(format: "%.3f ml", Double(amount))
    }
}


struct StatisticsView: View {
    
   
    let mockData: [DrinkRecord] = [
        DrinkRecord(day: "Tuesday", amount: 1),
        DrinkRecord(day: "Monday", amount: 2)
    ]
    
    var body: some View {
        NavigationView {
            List {
                
                
                Section(header: Text("Your saves")) {
                    
                    ForEach(mockData) { record in
                        HStack {
                            Text(record.day)
                                .font(.headline)
                            
                            Spacer()
                            
                            
                            Text(record.amountInLiters)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9)) // Stesso colore dell'acqua
                        }
                        .padding(.vertical, 4)
                    }
                }
                
            }
            
            .navigationTitle("Statistics 📊")
            .listStyle(.insetGrouped)
        }
    }
}


struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
