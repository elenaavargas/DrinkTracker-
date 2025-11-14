//
//  Ruler.swift
//  Drink Tracker 1
//
//  Created by Elena Vargas on 13/11/25.
//

import SwiftUI
import UIKit


struct RulerView: View {
    let maxLiters: Double = 2.0
    let steps: Int = 4
    
    let waterColor: Color
    
    @Binding var fillFraction: Double

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            
            let verticalPadding: CGFloat = 20.0
            let usableHeight = totalHeight - (verticalPadding * 2)
            let stepHeight = usableHeight / CGFloat(steps)

            ZStack(alignment: .trailing) {
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: totalHeight)

                ForEach(0...steps, id: \.self) { index in
                    
                    let literValue = Double(index) * (maxLiters / Double(steps))
                    let yPosition = CGFloat(index) * stepHeight

                    HStack(spacing: 2) {
                        
                        Text(String(format: "%.1f L", literValue))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 1)
                    }
                    .position(x: 25, y: totalHeight - verticalPadding - yPosition)
                }
            }
        }
        .frame(width: 50)
        .ignoresSafeArea(.all)
    }
}


