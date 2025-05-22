//
//  View+Ext.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI

extension View {
    func alignView(to: HorizontalAlignment) -> some View {
        var result: some View {
            HStack {
                if to != .leading {
                    Spacer()
                }
                
                self
                
                if to != .trailing {
                    Spacer()
                }
            }
        }
        
        return result
    }
    
    func alignViewVertically(to: VerticalAlignment) -> some View {
        var result: some View {
            VStack {
                if to != .top {
                    Spacer()
                }
                
                self
                
                if to != .bottom {
                    Spacer()
                }
            }
        }
        
        return result
    }
    
    func customFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.font(.system(size: size, weight: weight, design: design))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func standardColor(colorScheme: ColorScheme) -> Color {
        let result = (colorScheme == .light ? Color.black : .white)
        
        return result
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
