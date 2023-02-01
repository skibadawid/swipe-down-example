//
//  ConfigurationsView.swift
//  SwipeDownExtension
//
//  Created by Dawid on 1/29/23.
//

import SwiftUI

struct ConfigurationsView: View {
    
    typealias TestAction = (ConfigurationsView) -> ()
    
    @State private(set) var isSticky = false
    @State private(set) var shouldFade = true
    @State private(set) var minimumVelocityToHide: Double = 1400
    @State private(set) var minimumScreenRatioToHide = 0.3
    @State private(set) var animationDuration = 0.2
    private let testAction: TestAction?
    private let targetFont = Font.body
    private let targetColor = Color.green
    
    init(testAction: TestAction?) {
        self.testAction = testAction
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Spacer(minLength: 20)
                Toggle("is sticky", isOn: $isSticky)
                    .toggleStyle(SwitchToggleStyle(tint: targetColor))
                    .font(targetFont)
                Toggle("should fade", isOn: $shouldFade)
                    .toggleStyle(SwitchToggleStyle(tint: targetColor))
                    .font(targetFont)
                Group {
                    Spacer()
                        .frame(height: 50)
                    Slider(value: $minimumVelocityToHide, in: 1000...5000, step: 200)
                        .tint(targetColor)
                    (Text("minimum velocity to hide ") +
                     Text("\(Int(minimumVelocityToHide))").foregroundColor(targetColor)
                        .bold()).font(targetFont)
                }
                Group {
                    Spacer()
                        .frame(height: 50)
                    Slider(value: $minimumScreenRatioToHide, in: 0.1...0.8, step: 0.1)
                        .tint(targetColor)
                    (Text("minimum screen ratio to hide ") + Text("\(Int((isSticky ? minimumScreenRatioToHide/2 : minimumScreenRatioToHide) * 100))%").foregroundColor(RulerView.targetColor).bold()).font(targetFont)
                }
                Group {
                    Spacer()
                        .frame(height: 50)
                    Slider(value: $animationDuration, in: 0...1.5, step: 0.1)
                        .tint(targetColor)
                    (Text("dismiss animation duration ") + Text("\(animationDuration, specifier: "%.1f") seconds").foregroundColor(targetColor).bold()).font(targetFont)
                }
                Group {
                    Spacer()
                        .frame(height: 100)
                    Button("TEST") {
                        testAction?(self)
                    }.buttonStyle(.bordered).tint(targetColor)
                }
            }.padding(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
        }
    }
}

struct ConfigurationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationsView(testAction: nil)
    }
}
