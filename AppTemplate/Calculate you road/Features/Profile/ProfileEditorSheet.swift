import SwiftUI
import PhotosUI
import UIKit

struct ProfileEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ProfileStorage.name
    @State private var status = ProfileStorage.status
    @State private var avatarImage = ProfileStorage.loadAvatar()
    @State private var showAvatarOptions = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    avatarSection

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        TextField("Username", text: $name)
                            .padding(12)
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        TextField("Status", text: $status)
                            .padding(12)
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(20)
            }
            .background(AppTheme.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
            }
            .keyboardDoneToolbar()
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Save Profile") {
                    saveProfile()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .confirmationDialog("Change Photo", isPresented: $showAvatarOptions, titleVisibility: .visible) {
                Button("Camera") {
                    showCamera = true
                }
                Button("Photo Library") {
                    showPhotoPicker = true
                }
                if avatarImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        avatarImage = nil
                        ProfileStorage.removeAvatar()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadSelectedPhoto(newItem)
                }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera) { image in
                    avatarImage = image
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    private var avatarSection: some View {
        HStack {
            Spacer()
            Button {
                showAvatarOptions = true
            } label: {
                avatarView
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        if let avatarImage {
            Image(uiImage: avatarImage)
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppTheme.gold, lineWidth: 2)
                )
        } else {
            Text(avatarInitial)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.black)
                .frame(width: 96, height: 96)
                .background(AppTheme.gold)
                .clipShape(Circle())
        }
    }

    private var avatarInitial: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "U" }
        return String(trimmed.prefix(1)).uppercased()
    }

    private func saveProfile() {
        ProfileStorage.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        ProfileStorage.status = status.trimmingCharacters(in: .whitespacesAndNewlines)

        if let avatarImage {
            ProfileStorage.saveAvatar(avatarImage)
        }

        dismiss()
    }

    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }

        await MainActor.run {
            avatarImage = image
            selectedPhotoItem = nil
        }
    }
}

private struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case camera
        case photoLibrary

        var uiKitSource: UIImagePickerController.SourceType {
            switch self {
            case .camera: return .camera
            case .photoLibrary: return .photoLibrary
            }
        }
    }

    let sourceType: SourceType
    let onImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType.uiKitSource
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        let dismiss: DismissAction

        init(onImagePicked: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

#Preview {
    ProfileEditorSheet()
}
