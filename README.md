# Photo Gallery

An iOS image gallery app that fetches photos from the Unsplash API, displays them in an adaptive grid, and allows users to browse, view details, and mark images as favorites.

## Contact

**Nikita Harkavy**
- Email: nikita.harkavy@appshero.io
- GitHub: [github.com/nikitaharkavy](https://github.com/nikitaharkavy)

## Project Overview

Photo Gallery is a native iOS application built entirely with UIKit and programmatic UI (no storyboards). The app demonstrates proficiency in networking, asynchronous programming, data persistence, and modern iOS architecture patterns.

### Key Functionalities

- **Adaptive Grid Gallery** — a responsive collection view that automatically calculates the number of columns based on screen width (target cell width of 190pt, minimum 2 columns), ensuring optimal layout across all device sizes and orientations.
- **Infinite Scroll Pagination** — seamlessly loads 30 images per page as the user scrolls, with a prefetch threshold of 2x the screen height for a smooth experience.
- **Interactive Detail View** — full-screen image display with a draggable bottom sheet panel featuring two states (peek and expanded), spring animations, and velocity-based gesture snapping.
- **Swipe Navigation** — horizontal swipe gestures to navigate between photos in the detail view using `UIPageViewController`.
- **Favorites System** — users can mark photos as favorites with a heart-shaped button; favorites persist locally and display a visual indicator on gallery thumbnails.
- **In-Memory Image Caching** — `NSCache`-based caching (200 item limit) with synchronous cache lookup to prevent flickering during cell reuse.
- **Dark Theme** — the app uses a dark color scheme with blur effects and semi-transparent overlays for a modern aesthetic.

### Assumptions & Additional Features

- The app forces dark mode (`overrideUserInterfaceStyle = .dark`) for a consistent visual experience.
- The detail screen uses a custom back button with a blurred circular background instead of the default navigation bar, providing a more immersive full-screen image viewing experience.
- The bottom sheet panel in the detail view features a "More..." hint label that fades out as the panel expands, guiding the user to discover additional content.
- Photo titles are derived from the Unsplash `slug` field (formatted into a readable string) with a fallback to the photographer's name.
- Error states in the gallery include a descriptive message and a retry button.

## Architecture & Patterns

### MVVM + Coordinator

The app follows the **MVVM (Model-View-ViewModel)** pattern combined with the **Coordinator** pattern for navigation:

| Layer | Responsibility |
|---|---|
| **Model** | Data models (`UnsplashPhoto`), networking (`APIClient`), persistence (`FavoritesStore`), image loading (`ImageLoader`) |
| **ViewModel** | Business logic, state management, data transformation (`GalleryViewModel`, `DetailViewModel`) |
| **View** | UI rendering and user interaction (`GalleryViewController`, `DetailPageViewController`, `DetailContentViewController`) |
| **Coordinator** | Navigation flow, dependency creation and injection (`AppCoordinator`) |

### SOLID Principles

| Principle | Application |
|---|---|
| **Single Responsibility** | Each class has one clear purpose — `APIClient` handles networking, `FavoritesStore` manages persistence, `ImageLoader` handles image fetching and caching |
| **Open/Closed** | The `Endpoint` protocol is open for extension — adding a new API endpoint only requires a new enum case, no changes to `APIClient` |
| **Liskov Substitution** | All protocol conformances (`APIClientProtocol`, `FavoritesStoreProtocol`, `ImageLoaderProtocol`) can be substituted with mocks without affecting behavior |
| **Interface Segregation** | Protocols are small and focused: `APIClientProtocol` (1 method), `FavoritesStoreProtocol` (2 methods), `ImageLoaderProtocol` (2 methods) |
| **Dependency Inversion** | ViewModels and ViewControllers depend on protocol abstractions, not concrete types; all dependencies are injected from `AppCoordinator` |

### Frameworks & Technologies

| Technology | Usage |
|---|---|
| **UIKit** | Entire UI built programmatically |
| **URLSession** | Networking with `async/await` |
| **NSCache** | In-memory image caching |
| **UserDefaults** | Local persistence for favorites |
| **NotificationCenter** | Cross-screen favorites synchronization |
| **UICollectionViewCompositionalLayout** | Adaptive gallery grid |
| **UIPageViewController** | Swipe-based detail navigation |
| **Swift Testing** | Unit tests |
| **SwiftLint** | Code style enforcement |

No third-party dependencies are used.

### Project Structure

```
Photo Gallery/
├── App/
│   ├── AppDelegate.swift            # Application entry point
│   ├── SceneDelegate.swift          # Window and coordinator bootstrap
│   └── AppCoordinator.swift         # Navigation and dependency injection
├── Models/
│   └── UnsplashPhoto.swift          # API response data models
├── Model/
│   ├── Network/
│   │   ├── Endpoint.swift           # Endpoint protocol
│   │   ├── UnsplashEndpoint.swift   # Unsplash API endpoints
│   │   ├── APIClient.swift          # Generic async network client
│   │   ├── APIKeyProvider.swift     # Secure API key access
│   │   └── NetworkError.swift       # Typed error handling
│   ├── ImageLoading/
│   │   └── ImageLoader.swift        # Async image loader with NSCache
│   └── Persistence/
│       └── FavoritesStore.swift     # UserDefaults-backed favorites
└── Scenes/
    ├── Gallery/
    │   ├── GalleryViewModel.swift   # Gallery state and pagination
    │   ├── GalleryViewController.swift  # Grid UI with infinite scroll
    │   └── GalleryCell.swift        # Thumbnail cell with favorite badge
    └── Detail/
        ├── DetailViewModel.swift    # Detail data mapping
        ├── DetailPageViewController.swift   # Swipe navigation
        └── DetailContentViewController.swift # Image + bottom sheet
```

## Screenshots

<!-- Add screenshots of the app here -->

| Gallery Screen | Detail Screen (Collapsed) | Detail Screen (Expanded) |
|---|---|---|
| ![Gallery](screenshots/gallery.png) | ![Detail Collapsed](screenshots/detail_collapsed.png) | ![Detail Expanded](screenshots/detail_expanded.png) |

## Configuration

### Unsplash API Key

The app requires a free Unsplash API access key. To configure it:

1. Register at [unsplash.com/developers](https://unsplash.com/developers) and create a new application.
2. Copy your **Access Key**.
3. Open `Photo Gallery/Info.plist`.
4. Set the value of the `UNSPLASH_ACCESS_KEY` key to your access key.

> **Note:** The API key is stored in `Info.plist` and is read at runtime via `APIKeyProvider`. The app will crash with a descriptive error message if the key is missing or not configured.

### Requirements

- **iOS 15.6+**
- **Xcode 15+**
- **Swift 5.9+**

### Build & Run

1. Clone the repository.
2. Open `Photo Gallery.xcodeproj` in Xcode.
3. Configure the Unsplash API key (see above).
4. Select a simulator or device and press **Run** (⌘R).

### Running Tests

Press **⌘U** in Xcode or run from the **Product → Test** menu. The test suite includes:

- `FavoritesStoreTests` — persistence and toggle logic
- `DetailViewModelTests` — data mapping and state management
- `UnsplashPhotoTests` — display title and description formatting

## License

This project was created as a test task for an iOS Intern position.
