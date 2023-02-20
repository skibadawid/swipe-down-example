//
//  RulerView.swift
//  SwipeDownExtension
//
//  Created by Dawid on 1/30/23.
//

import SwiftUI

struct RulerView: View {
    
    static let targetColor = Color.orange
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(1..<11) { percentage in
                    VStack {
                        Rectangle().foregroundColor(Color(.systemBackground))
                        Text("\(percentage * 10)%").foregroundColor(Self.targetColor).font(.callout).bold().frame(alignment: .centerLastTextBaseline)
                        Rectangle()
                            .frame(height: 2).foregroundColor(Self.targetColor)
                    }.frame(maxHeight: .infinity)
                }
            }.frame(maxHeight: .infinity).ignoresSafeArea()
            Text("SCREEN % RULLER")
                .font(.title).bold().foregroundColor(Self.targetColor)
                .background(Color(.systemBackground)).rotationEffect(Angle(degrees: 270), anchor: .leading)
        }
    }
}

struct RulerView_Previews: PreviewProvider {
    static var previews: some View {
        RulerView()
    }
}
