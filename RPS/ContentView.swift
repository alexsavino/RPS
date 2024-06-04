//
//  ContentView.swift
//  RPS
//
//  Created by Alexandra Savino on 6/4/24.
//

import SwiftUI
import CoreHaptics


class Card: ObservableObject, Identifiable, Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }

    let id = UUID()
    @Published var flipped: Bool = false
    @Published var chosen: Bool = false

    var word: String
    var emoji: String

    init(word: String, emoji: String) {
        self.word = word
        self.emoji = emoji
    }
}


struct CardFront: View {
    @ObservedObject var card: Card
    @Binding var userChoice: String
    @Binding var CPUChoice: String
    @Binding var result: String
    @Binding var resultFadeOut: Bool
    @Binding var subtitleFadeOut: Bool

    func calculateResult(userChoice: String, CPUChoice: String) -> String {
        var CPUChoiceword = CPUChoice.dropLast(2)
        if CPUChoiceword == userChoice {
            return "A TIE"
        } else if CPUChoiceword == "Rock" && userChoice == "Paper" {
            return "YOU WIN"
        } else if CPUChoiceword == "Rock" && userChoice == "Scissors" {
            return "YOU LOSE"
        } else if CPUChoiceword == "Paper" && userChoice == "Rock" {
            return "YOU LOSE"
        } else if CPUChoiceword == "Paper" && userChoice == "Scissors" {
            return "YOU WIN"
        } else if CPUChoiceword == "Scissors" && userChoice == "Rock" {
            return "YOU WIN"
        } else if CPUChoiceword == "Scissors" && userChoice == "Paper" {
            return "YOU LOSE"
        }
        return ""
    }

    var body: some View {
        Rectangle()
            .foregroundColor(Color.white)
            .frame(width: 104, height: 143)
            .scaleEffect(card.chosen ? 1.15 : 1.0)
            .overlay(
                Button(action: {
                    if card.word == "Rock" {
                        userChoice = "Rock"
                    } else if card.word == "Paper" {
                        userChoice = "Paper"
                    } else if card.word == "Scissors" {
                        userChoice = "Scissors"
                    }

                    CPUChoice = ["Rock 👊", "Paper 📄", "Scissors ✂️"].randomElement() ?? ""
                    result = calculateResult(userChoice: userChoice, CPUChoice: CPUChoice)
                    
                    withAnimation {
                        rockCard.flipped = userChoice != "Rock"
                        paperCard.flipped = userChoice != "Paper"
                        scissorCard.flipped = userChoice != "Scissors"
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        flipBackAllCards()
                    }
                }) {
                    VStack {
                        Text(card.word)
                            .foregroundColor(Color.black)
                        Spacer().frame(height: 10)
                        Text(card.emoji)
                            .font(.system(size: 65))
                    }
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    )
                }
            )
    }

    func flipBackAllCards() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                rockCard.flipped = false
                paperCard.flipped = false
                scissorCard.flipped = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    rockCard.chosen = false
                    paperCard.chosen = false
                    scissorCard.chosen = false
                }
                withAnimation {
                    resultFadeOut = true
                    subtitleFadeOut = true
                }
            }
        }
    }


}


struct CardBack: View {
    var body: some View {
        Rectangle()
            .foregroundColor(Color.gray.opacity(0.3))
            .frame(width: 106, height: 142)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 9)
            )
    }
}

struct CardView: View {
    @ObservedObject var card: Card
    @Binding var userChoice: String
    @Binding var CPUChoice: String
    @Binding var result: String
    @Binding var resultFadeOut: Bool
    @Binding var subtitleFadeOut: Bool

    @State private var degrees: Double = 0.0
    @State private var isFrontVisible: Bool = true
    @State private var scaleFactor: CGFloat = 1.0

    var body: some View {
        ZStack {
            if isFrontVisible {
                CardFront(card: card, userChoice: $userChoice, CPUChoice: $CPUChoice, result: $result, resultFadeOut: $resultFadeOut, subtitleFadeOut: $subtitleFadeOut)
            } else {
                CardBack()
            }
        }
        .cornerRadius(8)
        .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
        .scaleEffect(scaleFactor) // Apply scale effect here
        .onChange(of: card.flipped) { newValue in
            withAnimation(.easeInOut(duration: 1.5)) {
                if newValue {
                    degrees += 180
                    withAnimation(.easeInOut(duration: 4)) {
                        scaleFactor = 0.8
                    }
                } else {
                    degrees -= 180
                    withAnimation(.easeInOut(duration: 2.0)) {
                        scaleFactor = 1.0
                    }
                }
                isFrontVisible.toggle()
            }
        }
        .frame(width: 104, height: 160)
    }
}


struct ContentView: View {
    @State private var userChoice: String = ""
    @State private var CPUChoice: String = ""
    @State private var result: String = ""
    @State private var resultFadeOut: Bool = false
    @State private var subtitleFadeOut: Bool = false
    @State private var resultOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var resultOffset: CGFloat = 25
    @State private var subtitleOffset: CGFloat = 25
    
    let generator = UINotificationFeedbackGenerator()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    if result != "" {
                        Text(result)
                            .font(.system(size: 70, weight: .heavy, design: .rounded))
                            .opacity(resultOpacity)
                            .offset(y: resultOffset)
                            .animation(.easeInOut(duration: 1.0))
                            .onAppear {
                                withAnimation {
                                    resultOpacity = 1
                                    resultOffset = 0
                                }
                            }
                    }
                    if CPUChoice != "" {
                        Text("CPU chose \(CPUChoice)")
                            .opacity(subtitleOpacity)
                            .offset(y: subtitleOffset)
                            .animation(.easeInOut(duration: 1.9))
                            .onAppear {
                                withAnimation {
                                    subtitleOpacity = 1
                                    subtitleOffset = 0
                                }
                            }
                    }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height > geometry.size.width ? 155 : 10)


                HStack {
                    CardView(card: rockCard, userChoice: $userChoice, CPUChoice: $CPUChoice, result: $result, resultFadeOut: $resultFadeOut, subtitleFadeOut: $subtitleFadeOut)
                    CardView(card: paperCard, userChoice: $userChoice, CPUChoice: $CPUChoice, result: $result, resultFadeOut: $resultFadeOut, subtitleFadeOut: $subtitleFadeOut)
                    CardView(card: scissorCard, userChoice: $userChoice, CPUChoice: $CPUChoice, result: $result, resultFadeOut: $resultFadeOut, subtitleFadeOut: $subtitleFadeOut)
                }
            }
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .position(x: geometry.size.width / 2, y: geometry.size.height > geometry.size.width ? geometry.size.height/2 : geometry.size.height-100)
            .onChange(of: result) { newValue in
                
                if newValue == "YOU WIN" {
                    generator.notificationOccurred(.success)
                }
                
                if newValue != "" {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            subtitleOpacity = 0
                            subtitleOffset = 25
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        withAnimation {
                            resultOpacity = 0
                            resultOffset = 25
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        result = ""
                        CPUChoice = ""

                    }
                    
                }

            }
            
        }
    }
}


var rockCard = Card(word: "Rock", emoji: "👊")
var paperCard = Card(word: "Paper", emoji: "📄")
var scissorCard = Card(word: "Scissors", emoji: "✂️")



#Preview {
    ContentView()
}
