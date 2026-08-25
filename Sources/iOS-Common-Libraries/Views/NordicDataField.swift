//
//  NordicDataField.swift
//  nRF-Connect
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 5/10/23.
//  Created by Dinesh Harjani on 29/5/25.
//  Copyright © 2025 Nordic Semiconductor. All rights reserved.
//

import SwiftUI

// MARK: - NordicDataField

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
public struct NordicDataField: View {
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    public static let DefaultBackgroundColor: Color = Color(.systemGray6)
    #else
    public static let DefaultBackgroundColor: Color.secondarySystemBackground
    #endif
    
    // MARK: Properties
    
    @Binding private var data: Data
    @Binding private var selectedParser: CommonDataParser
    
    @State private var dataBool: Bool
    @State private var dataString: String
    
    private let dataParsers: [CommonDataParser]
    private let backgroundColor: Color
    private let dataParserPickerEnabled: Bool
    
    // MARK: init
    
    public init(data: Binding<Data>, dataParser: Binding<CommonDataParser>,
                dataParsers: [CommonDataParser], backgroundColor: Color = Self.DefaultBackgroundColor,
                parserIsUserSelectable: Bool = true) {
        self._data = data
        self._selectedParser = dataParser
        self.dataBool = false
        self.dataString = dataParser.wrappedValue(data.wrappedValue) ?? ""
        self.dataParsers = dataParsers
        self.backgroundColor = backgroundColor
        self.dataParserPickerEnabled = parserIsUserSelectable
    }
    
    // MARK: view
    
    public var body: some View {
        VStack {
            if selectedParser == .boolean {
                Toggle(dataBool ? "True" : "False", isOn: $dataBool)
                    .onChange(of: dataBool) { newValue in
                        updateData()
                    }
            } else {
                TextField("", text: $dataString)
                    .padding(4)
                    .background(backgroundColor)
                    .cornerRadius(8)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    #if os(iOS)
                    .keyboardType(.asciiCapable)
                    #endif
                    .onChange(of: dataString) { newString in
                        updateData()
                    }
            }
            
            Text("Preview: \(data.isEmpty ? "N/A" : data.hexEncodedString(options: [.prepend0x, .upperCase]))")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(.secondary)
                .font(.footnote)
            

            Divider()
            
            Picker("Format", selection: $selectedParser) {
                ForEach(dataParsers, id: \.self) { value in
                    Text(value.description)
                        .tag(value)
                }
            }
            .pickerStyle(.menu)
            .disabled(!dataParserPickerEnabled)
            .onChange(of: selectedParser) { _ in
                updateData()
            }
        }
        .padding(.vertical, 2.0)
    }
    
    // MARK: updateData(from:)
    
    private func updateData() {
        switch selectedParser {
        case .byteArray:
            data = Data(hexString: dataString) ?? Data()
        case .anyUnsignedInt:
            guard let number = UInt8(dataString) else { return }
            data = Data(repeating: number, count: 1)
        case .boolean:
            data = Data(repeating: dataBool ? 1 : 0, count: 1)
        case .utf8:
            data = dataString.data(using: .utf8) ?? Data()
        default:
            return
        }
    }
}
