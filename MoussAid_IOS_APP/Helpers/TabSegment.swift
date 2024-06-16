


enum TabSegment: String, CaseIterable {
    case categories = "Categories"
        case chats = "Chats"
        case orders = "Orders" // Assumant que 'commandes' est traduit par 'orders'

       
        var systemImage: String {
            switch self {
            case .categories:
                return "list.dash" // Remplacer par l'icône souhaitée
            case .chats:
                return "bubble.left.and.bubble.right" // Remplacer par l'icône souhaitée
            case .orders:
                return "cart" // Remplacer par l'icône souhaitée
            }
        }

}
