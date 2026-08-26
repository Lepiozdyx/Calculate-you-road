import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let goldTitle: String
    let whiteTitle: String
    let subtitle: String
    let buttonTitle: String
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onbContainer1",
            goldTitle: "YOUR ROAD.",
            whiteTitle: "YOUR BUDGET.",
            subtitle: "Plan the full cost of your trip before you hit the road.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            imageName: "onbContainer2",
            goldTitle: "KNOW THE",
            whiteTitle: "REAL COST",
            subtitle: "Calculate fuel, food, stays, tolls and other expenses in one place.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            imageName: "onbContainer3",
            goldTitle: "SPLIT THE",
            whiteTitle: "COST",
            subtitle: "Add your travel companions and instantly see how much each person pays.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            imageName: "onbContainer4",
            goldTitle: "SEE WHERE",
            whiteTitle: "YOU GO",
            subtitle: "Save your trips and analyze spending, mileage and fuel costs over time.",
            buttonTitle: "Get Started"
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundStyle(AppTheme.secondaryText)
                    .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                PageIndicator(count: pages.count, currentIndex: currentPage)
                    .padding(.bottom, 24)

                PrimaryButton(title: pages[currentPage].buttonTitle) {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)
                .padding(.top, 8)

            VStack(spacing: 8) {
                Text(page.goldTitle)
                    .font(.title.weight(.heavy))
                    .foregroundStyle(AppTheme.gold)
                Text(page.whiteTitle)
                    .font(.title.weight(.heavy))
                    .foregroundStyle(.white)
            }
            .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private func completeOnboarding() {
        OnboardingStorage.hasCompleted = true
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
