

import SwiftUI
import FirebaseAuth

struct HomePageView: View {
    @AppStorage("log_status") private var logStatus: Bool = false
    @State private var showMenu: Bool = false
    @State private var selectedTab: TabSegment?
    @Environment(\.colorScheme) private var scheme
    @State private var tabProgress: CGFloat = 1
    let nightBlueStart = Color(red: 0.10, green: 0.2, blue: 0.53)
    
    let categories = [
        Category(id: "1", name: "Santé", imageName: "1"),
        Category(id: "2", name: "Services à domicile", imageName: "2"),
        Category(id: "3", name: "Transport", imageName: "3"),
        Category(id: "4", name: "Alimentation", imageName: "4"),
        Category(id: "5", name: "Réparation", imageName: "5"),
        Category(id: "6", name: "Autres services", imageName: "logo")
    ]
      var body: some View {
          
          AnimatedSideBar(
            rotatesWhenExpands: true,
            disablesInteraction: true,
            sideMenuWidth: 180,
            cornerRadius: 25,
            showMenu: $showMenu
          )
           { safeArea in
               
               VStack{
                   
                   NavigationStack {
                       Text("MoussAid")
                           .font(.title)
                           .fontWeight(.black)
                           .foregroundColor(Color(red: 0.167, green: 0.228, blue: 0.598))
                           .offset(y:-43)
                       Button(action: { showMenu.toggle() }, label: {
                       })
                       .toolbar {
                           ToolbarItem(placement: .topBarLeading) {
                               Button(action: { showMenu.toggle() }, label: {
                                   Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                                       .foregroundColor(Color.primary)
                                       .contentTransition(.symbolEffect)
                               })
                           }
                       }
                       VStack{
                           CustomTabBar()
                           GeometryReader {
                             let size = $0.size
                             ScrollView(.horizontal) {
                               LazyHStack(spacing: 0) {
                                   VStack{
                                       ScrollView(.vertical) {
                                           LazyVGrid(columns: [GridItem(.flexible())]) {
                                               ForEach(categories, id: \.self) { category in
                                                   Button(action: {
                                                       // Action à effectuer lorsque l'image est cliquée
                                                   }) {
                                                       ZStack {
                                                           Image(category.imageName)
                                                               .resizable()
                                                               .scaledToFill()
                                                               .frame(height: 250)
                                                               .clipped()
                                                               .cornerRadius(15)
                                                        VStack{
                                                           Text(category.name)
                                                                   .font(.title)
                                                                   .fontWeight(.bold)
                                                                   .foregroundColor(.white)
                                                                   .multilineTextAlignment(.leading)
                                                                   .padding()
                                                           } .background(Color.black.opacity(0.4))
                                                               .cornerRadius(95)

                                                               .frame(width: 300, height: 90, alignment: Alignment.leading)
                                                               .offset(x:-30,y:78)
                                                            
                                                       }
                                                       .frame(maxWidth: .infinity)
                                                       .background(Color.white)
                                                       .cornerRadius(15)
                                                       .shadow(radius: 5)
                                                   }
                                               }
                                           }
                                           .padding(.horizontal)
                                       }
                                   }
                                    .id(TabSegment.categories)
                                    .containerRelativeFrame(.horizontal)

                                 SampleView(.red)
                                   .id(TabSegment.chats)
                                   .containerRelativeFrame(.horizontal)

                                 SampleView(.blue)
                                   .id(TabSegment.orders)
                                   .containerRelativeFrame(.horizontal)
                                 
                               }
                               .scrollTargetLayout()
                               .offsetX { value in
                                 /// Converting Offset into Progress
                                 let progress = -value / (size.width * CGFloat(TabSegment.allCases.count - 1))
                                 /// Capping Progress BTW 0-1
                                 tabProgress = max(min(progress, 1), 0)
                               }
                             }
                             .scrollPosition(id: $selectedTab)
                             .scrollIndicators(.hidden)
                             .scrollTargetBehavior(.paging)
                             .scrollClipDisabled()
                           }

                       }.offset(y:-27)
                        
                       

                   }
                   
               }

           } menuView: { safeArea in
               SideBarMenuView(safeArea)
           } background: {
            
             Rectangle()
                 LinearGradient(gradient: Gradient(colors: [Color.brown, nightBlueStart]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
        }

    }
    
    
 @ViewBuilder
  func SideBarMenuView(_ safeArea: UIEdgeInsets) -> some View {
      VStack(alignment: .leading, spacing: 12) {
        Text("Side Menu")
            .font(.largeTitle.bold())
            .padding(.bottom, 10)
            
          SideBarButton(tab: .home)
          SideBarButton(tab: .bookmark)
          SideBarButton(tab: .favourites)
          SideBarButton(tab: .profile)
            
        Spacer(minLength: 0)
            
          SideBarButton(tab: .logout){do{
              try Auth.auth().signOut()
              logStatus = false
              showMenu = false
              } catch let signOutError as NSError {
              print("Erreur de déconnexion: %@", signOutError)
              }
           }
      }
      .padding(.horizontal, 15)
      .padding(.vertical, 20)
      .padding(.top, safeArea.top)
      .padding(.bottom, safeArea.bottom)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .environment(\.colorScheme, .dark)
    }

  @ViewBuilder
    func SideBarButton(tab: Tab, onTap: @escaping () -> () = {  }) -> some View {
      Button(action: onTap, label: {
        HStack(spacing: 12) {
          Image(systemName: tab.rawValue)
            .font(.title3)
          Text(tab.title)
            .font(.callout)
          Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .foregroundStyle(Color.primary)
      })
    }

    enum Tab: String, CaseIterable {
      case home = "house.fill"
      case bookmark = "book.fill"
      case favourites = "heart.fill"
      case profile = "person.crop.circle"
      case logout = "rectangle.portrait.and.arrow.forward.fill"
      
      var title: String {
        switch self {
        case .home: return "Home"
        case .bookmark: return "Bookmark"
        case .favourites: return "Favourites"
        case .profile: return "Profile"
        case .logout: return "Logout"
        }
      }
    }

    @ViewBuilder
    func CustomTabBar() -> some View {
      HStack(spacing: 0) {
        ForEach(TabSegment.allCases, id: \.rawValue) { tab in
          HStack(spacing: 10) {
            Image(systemName: tab.systemImage)
            Text(tab.rawValue)
              .font(.callout)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .contentShape(Rectangle())
          .onTapGesture {
            // Updating Tab
            withAnimation(.snappy) {
              selectedTab = tab
            }
          }
        }
      }
      .tabMask(tabProgress)
      .background {
          GeometryReader { geometry in
            let size = geometry.size
            let capsuleWidth = size.width / CGFloat(TabSegment.allCases.count)
            Capsule()
              .fill(scheme == .dark ? Color.black : Color.white)
              .frame(width: capsuleWidth)
              .offset(x: tabProgress * (size.width - capsuleWidth))
          }
        }
      .background(.gray.opacity(0.1), in: .capsule)
      .padding(.horizontal, 15)
    }

    @ViewBuilder
    func SampleView(_ color: Color) -> some View {
      ScrollView(.vertical) {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 1), content: {
          ForEach(1...5, id: \.self) { _ in
            RoundedRectangle(cornerRadius: 15)
              .fill(color.gradient)
              .frame(height: 50)
          }
        })
        .padding(15)
      }
      .scrollIndicators(.hidden)
      .scrollContentBackground(.hidden)
      .mask {
        Rectangle()
          .padding(.bottom, -100)
      }
    }

    
    
}

// Defines a PreferenceKey to hold the offset value
struct OffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

// View extension that adds a method to extract the horizontal offset
extension View {
  @ViewBuilder
  func offsetX(completion: @escaping (CGFloat) -> ()) -> some View {
    self
      .overlay(
        GeometryReader { geometry in
          Color.clear
            .preference(key: OffsetKey.self, value: geometry.frame(in: .global).minX)
        }
      )
      .onPreferenceChange(OffsetKey.self, perform: completion)
  }
    
    
    @ViewBuilder
    func tabMask(_ tabProgress: CGFloat) -> some View {
      ZStack {
        self
          .foregroundStyle(.gray)

        self
          .symbolVariant(.fill)
          .mask {
            GeometryReader { geometry in
              let size = geometry.size
              let capsuleWidth = size.width / CGFloat(TabSegment.allCases.count)
              Capsule()
                .frame(width: capsuleWidth)
                .offset(x: tabProgress * (size.width - capsuleWidth))
            }
          }
      }
    }
}
// Structure pour représenter une catégorie
struct Category: Hashable, Identifiable {
    let id: String
    let name: String
    let imageName: String
}

#Preview {
    HomePageView()
}
