import SwiftUI

/// Главный навигационный контейнер с 4 вкладками: Главная, История, Статистика, Настройки.
struct MainTabView: View {
    @State private var selectedTab: TabItem = .home

    enum TabItem: Hashable {
        case home
        case history
        case analytics
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "heart.text.square.fill")
                }
                .tag(TabItem.home)

            HistoryView()
                .tabItem {
                    Label("История", systemImage: "clock.arrow.circlepath")
                }
                .tag(TabItem.history)

            AnalyticsView()
                .tabItem {
                    Label("Статистика", systemImage: "chart.bar.xaxis")
                }
                .tag(TabItem.analytics)

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(TabItem.settings)
        }
    }
}
