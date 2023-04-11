//
//  CurrencyConverterView.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/15/22.
//

import SwiftUI

struct CurrencyConverterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.code, order: .forward)],
        animation: .default)
    private var currencies: FetchedResults<Currency>
    
    @State var convertedCurrencies: [CurrencyData] = []
    
    @StateObject var viewModel = CurrencyConverterViewModel()
    
    @State var menuLabel: String = AppConstants.usDollar
    
    @State var showSuccessToast = false
    @State var successMessage: String = ""
    @State var showErrorToast = false
    @State var errorMessage: String = ""
    
    @State private var showLoader = false
    
    @State var showErrorMessage = false
    
    @State var spinCircle = false
     
    private var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Currency Amount", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                    .submitLabel(.done)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue))
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                
                HStack(spacing: 10) {
                    Spacer()
                    Text("Currency:")
                        .foregroundColor(Color("textColor4"))
                    Menu {
                        ForEach(currencies.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    viewModel.selectedCurrency = currencies[index].code ?? "Invalid Currency"
                                    menuLabel = viewModel.selectedCurrency
                                    calculateAllCurrencies(amount: viewModel.amount)
                                }
                            }) {
                                Text("\(currencies[index].code ?? "Invalid Currency")")
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(menuLabel)
                                .foregroundColor(Color("textColor3"))
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color("textColor3"))
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .frame(width: 130, height: 40, alignment: .center)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("textColor4")))
                            
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                ZStack {
                    if showErrorMessage {
                        VStack {
                            Spacer()
                            Text("You have to enter a valid amount 🙂")
                                .font(.system(size: 20, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color("textColor1"))
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: gridItemLayout, spacing: 8) {
                                ForEach(convertedCurrencies.indices, id: \.self) { index in
                                    VStack(spacing: 5) {
                                        Text(convertedCurrencies[index].code)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color("textColor1"))
                                        Text("\(convertedCurrencies[index].amount)")
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color("textColor2"))
                                            
                                    }.padding(4)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.bottom, 30)
                            .padding(.horizontal, 8)
                            .padding(.top, 5)
                        }
                    }
                    
                    if showLoader {
                        VStack {
                            Spacer()
                            Circle()
                                .trim(from: 0.3, to: 1)
                                .stroke(Color.green, lineWidth:4)
                                .frame(width:40, height: 40)
                                .padding(.all, 8)
                                .rotationEffect(.degrees(spinCircle ? 0 : -360), anchor: .center)
                                .animation(Animation.linear(duration: 0.6).repeatForever(autoreverses: false), value: spinCircle)
                                .onAppear {
                                    self.spinCircle = true
                                }
                            
                            Text("Loading data please wait... 🙂")
                                .font(.system(size: 20, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color("textColor1"))
                            Spacer()
                        }.padding(.bottom, 60)
                    }
                    
                    if self.showSuccessToast {
                        SuccessToast(message: self.successMessage).onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation() {
                                    self.showSuccessToast = false
                                    self.successMessage = ""
                                }
                            }
                        }
                    }

                    if showErrorToast {
                        ErrorToast(message: self.errorMessage).onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation() {
                                    self.showErrorToast = false
                                    self.errorMessage = ""
                                }
                            }
                        }
                    }
                }.onTapGesture {
                    self.hideKeyboard()
                }
            }.background(Color("Background Color"))
                .navigationTitle("Currency Converter")
            .onAppear {
                viewModel.startCurrencyUpdate()
            }.onReceive(self.viewModel.latestCurrencyUpdateListPublisher.receive(on: RunLoop.main)) { rates in
                for key in rates.keys {
                    saveCurrencyInDatabase(code: key, rate: rates[key] ?? 0.0)
                }
                saveContext()
                viewModel.shouldRefreshData.send(true)
            }.onReceive(currencies.publisher.collect()) { list in
                var allCurrency: [String : Double] = [:]
                for item in list {
                    if let currencyCode = item.code {
                        allCurrency[currencyCode] = item.rate
                    }
                }
                viewModel.currencyDataDict = allCurrency
            }.onReceive(viewModel.$amount.receive(on: RunLoop.main)) { amount in
                withAnimation {
                    calculateAllCurrencies(amount: amount)
                }
            }.onReceive(viewModel.shouldRefreshData.receive(on: RunLoop.main)) { shouldRefreshData in
                if shouldRefreshData {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            calculateAllCurrencies(amount: viewModel.amount)
                        }
                    }
                }
            }.onReceive(viewModel.showLoader.receive(on: RunLoop.main)) { showLoader in
                withAnimation {
                    if showLoader && convertedCurrencies.isEmpty {
                        self.showLoader = true
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                self.showLoader = false
                            }
                        }
                    }
                }
            }.onReceive(self.viewModel.successToastPublisher.receive(on: RunLoop.main)) {
                showToast, message in
                self.successMessage = message
                withAnimation() {
                    self.showSuccessToast = showToast
                }
            }.onReceive(self.viewModel.errorToastPublisher.receive(on: RunLoop.main)) {
                showToast, message in
                self.errorMessage = message
                withAnimation() {
                    self.showErrorToast = showToast
                }
            }
        }
    }
    
    private func calculateAllCurrencies(amount: String) {
        if amount.count > AppConstants.maxAllowedDigit {
            return
        }
        
        if CurrencyConverter.isValid(amount: amount) {
            prepareConvertedCurrencies(currencyCode: viewModel.selectedCurrency)
            showErrorMessage = false
        } else {
            showErrorMessage = true
        }
    }
    
    private func prepareConvertedCurrencies(currencyCode: String) {
        guard !viewModel.currencyDataDict.isEmpty, !viewModel.amount.isEmpty else {
            return
        }
        
        var currencyDataList: [CurrencyData] = []
        for code in viewModel.currencyDataDict.keys {
            guard let fromCurrencyRate = viewModel.currencyDataDict[currencyCode], let toCurrencyRate = viewModel.currencyDataDict[code], let amount = Double(viewModel.amount) else {
                continue
            }
            
            let convertedAmount = CurrencyConverter.convert(fromCurrency: currencyCode, toCurrency: code, fromCurrencyRate: fromCurrencyRate, toCurrencyRate: toCurrencyRate, amount: amount)
            
            currencyDataList.append(CurrencyData(code: code, amount: convertedAmount.round(toPlaces: 4)))
        }
        convertedCurrencies = currencyDataList.sorted { (lhs: CurrencyData, rhs: CurrencyData) -> Bool in
            return lhs.code < rhs.code
        }
    }
                                    
    private func saveCurrencyInDatabase(code: String, rate: Double) {
        withAnimation {
            let currency = Currency(context: viewContext)
            currency.code = code
            currency.rate = rate
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            viewModel.errorToastPublisher.send((true, "Unresolved error \(nsError), \(nsError.userInfo)"))
        }
    }
}

struct CurrencyConverterView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyConverterView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
