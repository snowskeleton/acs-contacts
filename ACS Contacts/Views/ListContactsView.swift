//
//  ListContactsView.swift
//  ACS Contacts
//
//  Created by snow on 9/27/24.
//  https://stackoverflow.com/a/69755635/13919791
//


import SwiftUI
import SwiftData
import Blackbird

struct ListContactsView: View {
    @Environment(\.blackbirdDatabase) var db

    @BlackbirdLiveModels({ try await Contact.read(from: $0, orderBy: .ascending(\.$lastName)) }) var contacts
    @BlackbirdLiveModels({ try await Phone.read(from: $0) }) var phones
//    @BlackbirdLiveModels var contacts: Blackbird.LiveResults<Contact>
    @Binding var searchText: String
    
    init(searchText: Binding<String>) {
        _searchText = searchText
//        _contacts = BlackbirdLiveModels<Contact> { db in
//            let queryText = "%" + searchText.wrappedValue.lowercased() + "%"
//            return try await Contact.read(
//                from: db,
//                sqlWhere: "LOWER(displayName) LIKE ? OR LOWER(fullName) LIKE ? ORDER BY lastName",
//                queryText
//            )
//        }
        
    }
    
    var presentableContacts: [Contact] {
        if searchText.isEmpty {
            return contacts.results
        } else {
            let matchingPhones = phones.results.filter { phone in
                phone.searchablePhoneNumber.lowercased().contains(searchText.lowercased())
            }
            
            let matchingIndvIds = Set(matchingPhones.map { $0.indvId })
            
            return contacts.results.filter { contact in
                contact.displayName.lowercased().contains(searchText.lowercased()) ||
                matchingIndvIds.contains(contact.indvId)
            }
        }
    }
    
    var body: some View {
        ScrollViewReader { scrollView in
            HStack {
                ScrollView {
                    LazyVStack(pinnedViews: .sectionHeaders) {
                        ForEach(String.alphabeta, id: \.self) { letter in
                            let contactsWithLetter = presentableContacts
                                .filter {
                                    ($0.lastName ?? $0.firstName ?? $0.displayName)
                                        .lowercased()
                                        .hasPrefix(letter.description.lowercased())
                                }
                            if !contactsWithLetter.isEmpty {
                                Section {
                                    ForEach(contactsWithLetter, id: \.self) { contact in
                                        NavigationLink {
                                            SingleContactView(contact: contact)
                                        } label: {
                                            HStack {
                                                Text(contact.displayName)
                                                    .padding(.leading)
                                                Spacer()
                                            }
                                            .foregroundStyle(Color.primary)
                                        }.id(contact.indvId)
                                        Divider()
                                    }
                                } header: {
                                    HStack {
                                        Text(letter.description)
                                            .font(.headline)
                                            .bold()
                                            .padding(.leading, 9)
                                            .padding(.bottom, 2)
                                        Spacer()
                                    }
                                    .background(Color.gray.opacity(0.5))
                                    Divider()
                                }
                                .id(letter.description.uppercased())
                            }
                        }
                    }
                }
               
                SectionIndexTitles(proxy: scrollView, titles: retrieveSectionTitles())
                    .font(.footnote)
                    .padding(.trailing, 5)
                    .background(Color.clear)
                    .contentShape(Rectangle())
            }
        }
        .scrollIndicators(.hidden)
    }
    
    func retrieveSectionTitles() ->[String] {
        var titles = [String]()
        titles.append("@")
        for item in self.contacts.results {
            let name = (item.lastName ?? item.firstName ?? item.displayName)
            if !name.starts(with: titles.last!){
                titles.append(String(name.first!))
            }
        }
        titles.remove(at: 0)
        if titles.count > 1 && titles.first! == "#" {
            titles.append("#")
            titles.removeFirst(1)
        }
        return titles
    }
}


struct SectionIndexTitles: View {
    class IndexTitleState: ObservableObject {
        var currentTitleIndex = 0
        var titleSize: CGSize = .zero
    }
    
    let proxy: ScrollViewProxy
    let titles: [String]
    @GestureState private var dragLocation: CGPoint = .zero
    @StateObject var indexState = IndexTitleState()
    
    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .foregroundColor(.blue)
                    .modifier(SizeModifier())
                    .onPreferenceChange(SizePreferenceKey.self) {
                        self.indexState.titleSize = $0
                    }
                    .onTapGesture {
                        proxy.scrollTo(title, anchor: .top)
                    }
            }
        }
        .gesture(
            DragGesture(minimumDistance: indexState.titleSize.height, coordinateSpace: .named(titles.first))
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                    scrollTo(location: state)
                }
        )
    }
    
    private func scrollTo(location: CGPoint){
        if self.indexState.titleSize.height > 0{
            let index = Int(location.y / self.indexState.titleSize.height)
            if index >= 0 && index < titles.count {
                if indexState.currentTitleIndex != index {
                    indexState.currentTitleIndex = index
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(titles[indexState.currentTitleIndex], anchor: .top)
                        }
                    }
                }
            }
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
    
    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

extension String {
    static var alphabeta: [String] {
        var chars = [String]()
        for char in "abcdefghijklmnopqrstuvwxyz#".uppercased() {
            chars.append(String(char))
        }
        return chars
    }
}

