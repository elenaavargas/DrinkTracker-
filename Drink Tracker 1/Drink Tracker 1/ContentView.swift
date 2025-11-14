//
//  ContentView.swift
//  Drink Tracker 1
//
//  Created by Elena Vargas on 07/11/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
 
    @AppStorage("waterFillLevel") private var fillFraction: Double = 0.0
    
    @State private var goalRemaining: Int = 2100
    
    let waterColor = Color(red: 0.2, green: 0.6, blue: 0.9)
    
    @State private var timer: Timer? = nil
    @State private var isPressing: Bool = false
    
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
                    
                
                    ZStack(alignment: .top) {
                        
                        Group {
                            
                            waterColor
                                .opacity(0.8)
                                .ignoresSafeArea(.all)
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
                                .font(.system(size: 20, weight: .bold))
                            
                            Spacer ()
                            
                            VStack(spacing: 8) {
                                Text("Time to drink!")
                                    .font(.system(size: 30, weight: .bold))
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
                            
                            
                            Button {
                                resetWaterLevel()
                            } label: {
                                Text("RESET")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 25)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.8))
                                            .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                                    )
                                    .foregroundColor(Color.red.opacity(0.8))
                            }
                            .padding(.top, 20)

                            Spacer()
                            
                            
                        }
                    }
                    
                   
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
    
    func resetWaterLevel() {
        withAnimation(.easeOut(duration: 0.5)) {
            // Reimposta la variabile @AppStorage
            fillFraction = 0.0
            goalRemaining = Int(maxGoal)
            HapticFeedback.vibrate(style: .heavy)
        }
        stopSipTimer()
    }
    
    private func createWaterMask(geometry: GeometryProxy, phaseOffset: Double, yOffset: CGFloat) -> some View {
        let totalHeight = geometry.size.height
        let waveHeight: CGFloat = 70.0
        
        let totalMaskHeight = (totalHeight * fillFraction) + waveHeight
        
        let initialLoweringOffset: CGFloat = 80.0
        
        let yShift = totalHeight - totalMaskHeight + initialLoweringOffset
        
        return VStack(spacing: 0) {
            
            // Assicurati che Wave sia definito e implementi Shape
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
    
    // TIMER
    
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
