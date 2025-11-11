//
//  ContentView.swift
//  Drink Tracker 1
//
//  Created by Elena Vargas on 07/11/25.
//

import SwiftUI
import UIKit

// MARK: - Nuova View per il Metro (RulerView)
// La definizione di RulerView è stata aggiornata per accettare un Double.
struct RulerView: View {
    let maxLiters: Double = 2.0 // 2 litri (goal finale)
    let steps: Int = 4 // 5 tacche/etichette (0.0, 0.5, 1.0, 1.5, 2.0)
        
    let waterColor: Color
    
    // Accetta Double per coerenza con @AppStorage
    @Binding var fillFraction: Double

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            
            let verticalPadding: CGFloat = 20.0
            let usableHeight = totalHeight - (verticalPadding * 2)
            let stepHeight = usableHeight / CGFloat(steps)

            ZStack(alignment: .trailing) {
                
                // Linea del metro (verticale, copre l'intera altezza, da bordo a bordo)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: totalHeight)

                // Etichette (da 0.0L a 2.0L)
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


//
struct ContentView: View {
    // === MODIFICA CHIAVE PER LA PERSISTENZA ===
    // Sostituito @State con @AppStorage per salvare il valore sul dispositivo.
    @AppStorage("waterFillLevel") private var fillFraction: Double = 0.0
    
    // Per una persistenza completa, andrebbe salvato anche goalRemaining, ma non è stato richiesto.
    // L'uso di fillFraction per calcolare goalRemaining è una logica dell'app esistente.
    @State private var goalRemaining: Int = 2100
    
    let waterColor = Color(red: 0.2, green: 0.6, blue: 0.9)
    
    @State private var timer: Timer? = nil
    @State private var isPressing: Bool = false
    
    //
    @State private var selectedTab: Int = 1
    let sipAmount = 5
    let maxGoal: CGFloat = 2100
    let fillStep: CGFloat = 20 / 2100.0
    
    @State private var wavePhase: Double = 0
    
    let fillAnimationDuration: Double = 0.1
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            
            GeometryReader { geometry in
                
                ZStack(alignment: .trailing) {
                    
                    // 1. Contenuto Principale del Tab Home
                    ZStack(alignment: .top) {
                        
                        
                        Group {
                            
                            waterColor
                                .opacity(0.8)
                                .ignoresSafeArea(.all)
                                // fillFraction (Double) viene usato come CGFloat
                                .animation(.easeInOut(duration: fillAnimationDuration), value: fillFraction)
                                .mask(createWaterMask(geometry: geometry, phaseOffset: 0.0, yOffset: 0.0))
                            
                            
                            waterColor
                                .opacity(0.6)
                                .ignoresSafeArea(.all)
                                .mask(createWaterMask(geometry: geometry, phaseOffset: 1.0, yOffset: 5.0))
                        }
                        .onAppear {
                            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                wavePhase = .pi * 2
                                
                            }
                        }
                        
                        
                        VStack(alignment: .center) {
                            
                            Text("November 5, 2025")
                                .padding(.top, 85)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            Spacer ()
                            VStack(spacing: 8) {
                                
                        
                                
                                Text("Time to drink!")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                
                                Text("Your goal is 2.0 liters")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 3)
                            
                            Spacer()
                            
                            
                            Text("Drink water")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.vertical, 18)
                                .padding(.horizontal, 40)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: Color.gray.opacity(0.4), radius: 10, x: 0, y: 5)
                                )
                                .foregroundColor(waterColor)
                                .scaleEffect(isPressing ? 1.05 : 1.0)
                                .animation(.easeOut(duration: 0.1), value: isPressing)
                                
                                
                                .highPriorityGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            if !self.isPressing {
                                                self.isPressing = true
                                                
                                                startSipTimer()
                                            }
                                        }
                                        .onEnded { _ in
                                            
                                            self.isPressing = false
                                            stopSipTimer()
                                        }
                                )
                            
                            Spacer()
                            
                            
                        }
                    }
                    
                    // 2. Metro (RulerView)
                    // fillFraction (Double) passato come Binding
                    RulerView(waterColor: waterColor, fillFraction: $fillFraction)
                    
                }
            }
            .ignoresSafeArea(.all)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(1)
            
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            
            
            Text("Settings Content")
                .foregroundColor(.black)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(waterColor)
        
    }
    
    //
    private func createWaterMask(geometry: GeometryProxy, phaseOffset: Double, yOffset: CGFloat) -> some View {
        let totalHeight = geometry.size.height
        let waveHeight: CGFloat = 70.0
        
        // fillFraction (Double) viene usato come CGFloat
        let totalMaskHeight = (totalHeight * fillFraction) + waveHeight
        
        let initialLoweringOffset: CGFloat = 80.0
        
        let yShift = totalHeight - totalMaskHeight + initialLoweringOffset
        
        return VStack(spacing: 0) {
            
            Wave(strength: 0.1, frequency: 3.5, phase: wavePhase + phaseOffset)
                .frame(height: waveHeight)
            
            
            Rectangle()
                .frame(height: totalHeight)
        }
        .offset(y: yShift)
        .offset(y: yOffset)
        .frame(height: totalHeight, alignment: .top)
        .clipped()
    }
    
    //
    
    func startSipTimer() {
        timer?.invalidate()
        
        
        let scheduledTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            
            
            if self.isPressing {
                performSip()
            } else {
                
                stopSipTimer()
            }
        }
        
        RunLoop.current.add(scheduledTimer, forMode: .common)
        self.timer = scheduledTimer
    }
    
    func stopSipTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func performSip() {
        
        HapticFeedback.vibrate(style: .light)
        
        if goalRemaining > 0 {
            
            // fillFraction (Double) viene modificato
            fillFraction = min(1.0, fillFraction + Double(fillStep))
            goalRemaining = max(0, goalRemaining - sipAmount)
        } else {
            
            stopSipTimer()
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
        
    }
    
}
