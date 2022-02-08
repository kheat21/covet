//
//  PromptedUserInput.swift
//  Covet
//
//  Created by Brendan Manning on 12/29/21.
//

import UIKit
import SwiftUI

struct PromptedUserInput: View {
    
    var prompt: String;
    var placeholder: String?;
    var inputColor: Color?;
    @Binding var text: String;
    var autocapitalization: UITextAutocapitalizationType? = nil;
    var autocorrect: Bool? = true
    
    var body: some View {
        HStack {
            Text(prompt)
                .frame(width: 72, height: nil, alignment: .leading)
            TextField(placeholder ?? "", text: $text)
                .padding(EdgeInsets(top: 8, leading: 16,
                                    bottom: 8, trailing: 16))
                .background(Color.white)
                .shadow(color: Color.gray.opacity(0.4),
                        radius: 3, x: 1, y: 2)
                .foregroundColor(inputColor ?? Color.black)
                .autocapitalization(self.autocapitalization ?? UITextAutocapitalizationType.sentences)
                .disableAutocorrection(self.autocorrect != nil ? !self.autocorrect! : false)
        }.padding(Edge.Set.horizontal, 16)
    }
}

struct PromptedDateInput: View {
    
    // Config parameters
    var prompt: String;
    var noDateSelectedMessage: String;
    var buttonColor: Color?;
    
    // Send data back to the parent
    @Binding var date: Date;
    @Binding var dateSet: Bool;
    
    // Internal state management
    @State private var isShowingPicker = false
    
    var body: some View {
        HStack {
            Text(prompt)
                .frame(width: 92, height: nil, alignment: .leading)
            Spacer()
            HStack {
                if isShowingPicker {
                    DatePicker("", selection: $date, displayedComponents: .date)
//                        .padding(EdgeInsets(top: 8, leading: 0,
//                                            bottom: 8, trailing: 0))
                }
                Button(
                    action: {
                        self.isShowingPicker = true
                        self.dateSet = true
                    },
                    label: {
                        Text(
                            dateSet ? "" : noDateSelectedMessage
                        ).foregroundColor(buttonColor ?? Color.black)
                    }
                )
                    .padding(EdgeInsets(top: 7, leading: 0,
                                        bottom: 7, trailing: 0))
                if dateSet {
                    Button(
                        action: {
                            self.isShowingPicker = false
                            self.dateSet = false
                        },
                        label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    )
                }
            }
        }
        .padding(Edge.Set.horizontal, 16)
    }
}

struct PromptedRadioInput: View {
   
    // Config parameters
    var prompt: String;
    var toggleBackgroundColor: Color?;
    
    // Send data back to the parent
    @Binding var value: Bool;
    
    var leftEdgePadding: CGFloat = 16.0
    var rightEdgePadding: CGFloat = 16.0
    
    var body: some View {
        HStack {
            VStack {
                
            }
            Text(prompt)
                .frame(width: 250, height: nil, alignment: .leading)
            Spacer()
            HStack {
                Toggle("", isOn: $value)
            }
        }
        .padding([.leading], leftEdgePadding)
        .padding([.trailing], rightEdgePadding)
    }
}

struct ExplainedPromptedRadioInput: View {
   
    // Config parameters
    var primaryPrompt: String;
    var secondaryPrompt: String;
    var toggleBackgroundColor: Color?;
    
    // Send data back to the parent
    @Binding var value: Bool;
    
    var leftEdgePadding: CGFloat = 16.0
    var rightEdgePadding: CGFloat = 16.0
    
    var body: some View {
        HStack {
            VStack {
                Group {
                    Text("Require permission to be a ")
                    +
                    Text(primaryPrompt)
                    .fontWeight(.bold)
                }
                .frame(width: 250, height: nil, alignment: .leading)
                .padding([.bottom], 2)
                Text(secondaryPrompt)
                    .italic()
                    .frame(width: 250, height: nil, alignment: .leading)
            }
            Spacer()
            HStack {
                Toggle("", isOn: $value)
            }
        }
        .padding([.leading], leftEdgePadding)
        .padding([.trailing], rightEdgePadding)
    }
}

struct PromptedUserInput_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            PromptedUserInput(prompt: "Your name", text: .constant("123"))
            PromptedRadioInput(prompt: "Your name 12345678910", value: .constant(true))
        }
    }
}
