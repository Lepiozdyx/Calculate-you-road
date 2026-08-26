import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Car.name) private var cars: [Car]

    @State private var showEditProfile = false
    @State private var showAddCar = false
    @State private var carToEdit: Car?
    @State private var carToDelete: Car?
    @State private var showDeleteAlert = false
    @State private var profileName = ProfileStorage.displayName
    @State private var profileStatus = ProfileStorage.displayStatus
    @State private var avatarImage = ProfileStorage.loadAvatar()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    profileCard
                    garageSection
                    footerCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(AppTheme.background)
            .navigationTitle("Profile")
            .onAppear(perform: loadProfile)
            .sheet(isPresented: $showEditProfile, onDismiss: loadProfile) {
                ProfileEditorSheet()
            }
            .sheet(isPresented: $showAddCar) {
                CarEditorSheet(mode: .add)
            }
            .sheet(item: $carToEdit) { car in
                CarEditorSheet(mode: .edit(car))
            }
            .alert("Remove Car?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    carToDelete = nil
                }
                Button("Remove", role: .destructive) {
                    if let carToDelete {
                        modelContext.delete(carToDelete)
                        try? modelContext.save()
                    }
                    carToDelete = nil
                }
            } message: {
                Text("This will remove the car from your garage.")
            }
        }
    }

    private var profileCard: some View {
        Button {
            showEditProfile = true
        } label: {
            AppCard {
                HStack(spacing: 16) {
                    profileAvatar

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profileName)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(ProfileStorage.isNamePlaceholder ? AppTheme.secondaryText : .white)
                        Text(profileStatus)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var profileAvatar: some View {
        if let avatarImage {
            Image(uiImage: avatarImage)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
        } else {
            Text(ProfileStorage.avatarInitial)
                .font(.title2.weight(.bold))
                .foregroundStyle(.black)
                .frame(width: 56, height: 56)
                .background(AppTheme.gold)
                .clipShape(Circle())
        }
    }

    private func loadProfile() {
        profileName = ProfileStorage.displayName
        profileStatus = ProfileStorage.displayStatus
        avatarImage = ProfileStorage.loadAvatar()
    }

    private var garageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader(title: "Garage")
                Spacer()
                Button {
                    showAddCar = true
                } label: {
                    Text("+ Add Car")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.gold)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            if cars.isEmpty {
                AppCard {
                    Text("No cars in your garage yet.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            } else {
                ForEach(cars) { car in
                    carCard(car)
                }
            }
        }
    }

    private func carCard(_ car: Car) -> some View {
        AppCard {
            HStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(car.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(String(format: "%.1f L/100km · %@", car.consumptionPer100km, car.fuelType.rawValue))
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                Button {
                    carToEdit = car
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    carToDelete = car
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(AppTheme.destructive)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.destructive.opacity(0.5), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var footerCard: some View {
        AppCard {
            VStack(spacing: 6) {
                Text("Calculate You Road · v1.0")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)
                Text("Your road. Your budget. Everything calculated.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Car.self, Trip.self], inMemory: true)
}
