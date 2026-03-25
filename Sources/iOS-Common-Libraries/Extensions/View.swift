//
//  View.swift
//  iOS-Common-Libraries
//
//  Created by Dinesh Harjani on 9/8/22.
//  Copyright © 2022 Nordic Semiconductor. All rights reserved.
//

import SwiftUI

// MARK: - FormIniOSListInMacOS

#if os(iOS)
public typealias FormIniOSListInMacOS = Form
#elseif os(macOS)
public typealias FormIniOSListInMacOS = List
#endif

// MARK: - View

public extension View {
    
    // MARK: frame
    
    @inlinable func centered() -> some View {
        // Hack.
        return frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
    
    @inlinable func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        return frame(width: size.width, height: size.height, alignment: alignment)
    }
    
    @inlinable func centerTextInsideForm() -> some View {
        // Hack.
        return frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
    
    @inlinable func setListRowInsets(horizontal: CGFloat, vertical: CGFloat) -> some View {
        return listRowInsets(.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal))
    }
    
    @inlinable func withoutListRowInsets() -> some View {
        return listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    @available(iOS 16.0, macCatalyst 16.0, macOS 13.0, *)
    @inlinable func fixedListRowSeparatorPadding() -> some View {
        return alignmentGuide(.listRowSeparatorLeading) { dimension in
            dimension[.leading]
        }
    }
    
    // MARK: setAccent
    
    @inlinable func setAccent(_ color: Color) -> some View {
        return accentColor(color)
    }
    
    // MARK: - NavBar
    
    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *)
    func setTitle(_ title: String) -> some View {
        #if os(iOS)
        return navigationBarTitle(title, displayMode: .inline)
        #else
        return navigationTitle(title)
        #endif
    }
    
    func setupNavBarBackground(with color: Color) -> some View {
        #if os(iOS)
        let appearance = UINavigationBarAppearance()
        let attributes: [NSAttributedString.Key: Any] = [
           .foregroundColor: UIColor.white
        ]
        appearance.titleTextAttributes = attributes
        appearance.largeTitleTextAttributes = attributes
        if #available(iOS 14.0, macCatalyst 14.0, *) {
            appearance.backgroundColor = color.uiColor // Dynamic Color.
        }
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        #endif
        return self
    }
    
    func setupTranslucentBackground() -> some View {
        #if os(iOS)
        let navBarAppearance = UINavigationBarAppearance()
        let navigationBar = UINavigationBar.appearance()
        
        navigationBar.barStyle = .default
        
        navigationBar.isTranslucent = true
        navigationBar.prefersLargeTitles = true
        
        navBarAppearance.configureWithTransparentBackground()
        
        navigationBar.compactAppearance = navBarAppearance
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
        
        if #available(iOS 16.0, *) {
            if #unavailable(iOS 26.0) {
                navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.dynamicColor(light: UIColor(.nordicBlue), dark: UIColor.white)]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.dynamicColor(light: UIColor(.nordicBlue), dark: UIColor.white)]
                navigationBar.tintColor = UIColor(.nordicBlue)
                
                return AnyView(self.tint(Color(UIColor.dynamicColor(light: UIColor(.nordicBlue), dark: UIColor.white)))
                    .setAccent(Color(UIColor.dynamicColor(light: UIColor(.nordicBlue), dark: UIColor.white))))
            }
        }
        return AnyView(self)
        #else
        AnyView(self)
        #endif
    }

    // MARK: - NavigationView
    
    @ViewBuilder
    func wrapInNavigationViewForiOS(with color: Color) -> some View {
        #if os(iOS)
        NavigationView {
            self
        }
        .setSingleColumnNavigationViewStyle()
        .setupNavBarBackground(with: color)
        .accentColor(.white)
        #else
        self
        #endif
    }
    
    // MARK: - UITextField
    
    func disableAllAutocorrections() -> some View {
        disableAutocorrection(true)
        #if os(iOS)
            .autocapitalization(.none)
        #endif
    }
}

// MARK: - dynamicColor()

#if os(iOS) || targetEnvironment(macCatalyst)
extension UIColor {
    
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
}
#endif

// MARK: - doOnce()

public extension View {
    
    func doOnce(_ action: @escaping () -> Void) -> some View {
        modifier(OnceOnly(action: action))
    }
}

private struct OnceOnly: ViewModifier {
    
    let action: () -> Void
    
    @State private var doneAlready = false
    
    func body(content: Content) -> some View {
        // And then, track it here
        content.onAppear {
            guard !doneAlready else { return }
            doneAlready = true
            action()
        }
    }
}

// MARK: - taskOnce()

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
public extension View {
    
    func taskOnce(_ asyncAction: @escaping () async -> Void) -> some View {
        modifier(TaskOnceOnly(asyncAction: asyncAction))
    }
}

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
private struct TaskOnceOnly: ViewModifier {
    
    @State private var doneAlready = false
    
    let asyncAction: () async -> Void
    
    func body(content: Content) -> some View {
        content.task {
            guard !doneAlready else { return }
            doneAlready = true
            await asyncAction()
        }
    }
}

// MARK: - Picker

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *)
public extension Picker {
    
    @ViewBuilder
    func setAsComboBoxStyle() -> some View {
        self
        #if os(iOS)
            .pickerStyle(MenuPickerStyle())
            .accentColor(.primary)
        #endif
    }
    
    func setAsSegmentedControlStyle() -> some View {
        self
        #if os(iOS)
            .pickerStyle(SegmentedPickerStyle())
        #endif
    }
}

// MARK: - DisclosureGroup

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, *)
public struct FixedOnTheRightStyle: DisclosureGroupStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .firstTextBaseline) {
                configuration.label
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(size: CGSize(asSquare: 12.0))
                    .rotationEffect(.degrees(configuration.isExpanded ? 0 : 90))
                    .foregroundColor(.universalAccentColor)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

        if configuration.isExpanded {
            configuration.content
                .padding(.leading)
                .transition(.move(edge: .top).combined(with: .asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.6)), removal: .opacity.animation(.easeOut(duration: 0.1)))))
        }
    }
}

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, *)
public extension DisclosureGroupStyle where Self == FixedOnTheRightStyle {
    
    static var fixedOnTheRight: FixedOnTheRightStyle { .init() }
}

// MARK: - NavigationView

public extension NavigationView {
    
    func setSingleColumnNavigationViewStyle() -> some View {
        self
        #if os(iOS)
            .navigationViewStyle(.stack)
        #endif
    }
}
