# Firebase Integration Issues - FlixFilm Movie App

**Ngày tạo:** 2026-04-24  
**Mô tả:** Tracker cho việc tích hợp Firebase vào ứng dụng movie streaming FlixFilm sau khi đã bổ sung và làm lại database.

---

## 📋 Tổng quan dự án

### Phân công công việc

| Thành viên | Vai trò | File phụ trách |
|------------|---------|----------------|
| **A - Trần Anh Sơn** | Data & Model | movie.dart, movie_data.dart, pubspec.yaml, main.dart |
| **B - Đỗ Hoàng Nam** | Auth & Onboarding | login_screen.dart, register_screen.dart, landing_screen.dart, home_screen.dart |
| **C - Vũ Hải Quân** | Detail & Trailer | detail_screen.dart |
| **D - Trịnh Gia Bảo** | Watch & Player | watch_screen.dart, webview_flutter integration |

---

## 🔧 Issues chi tiết

### Issue #1: [SETUP] Cấu hình Firebase cho dự án

**Assignee:** A - Trần Anh Sơn  
**Labels:** `setup`, `firebase`, `priority:high`  
**Milestone:** Firebase Setup

#### Mô tả
Thiết lập cấu hình Firebase cơ bản cho ứng dụng Flutter.

#### Checklist công việc
- [ ] Tạo project Firebase trên Firebase Console
- [ ] Thêm Android app vào Firebase project
- [ ] Thêm iOS app vào Firebase project
- [ ] Download `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
- [ ] Cấu hình `android/app/build.gradle` với Firebase SDK
- [ ] Cấu hình `ios/Runner/*` với Firebase SDK
- [ ] Thêm dependencies vào `pubspec.yaml`:
  ```yaml
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  firebase_analytics: ^latest
  google_sign_in: ^latest
  ```
- [ ] Khởi tạo FirebaseApp trong `main.dart`

#### Acceptance Criteria
- Firebase initialized thành công khi app start
- Không có lỗi khi build Android/iOS
- Firebase Console hiển thị app đã kết nối

---

### Issue #2: [DATA] Tạo Firestore Collections và Seed dữ liệu

**Assignee:** A - Trần Anh Sơn  
**Labels:** `data`, `firestore`, `seed`  
**Milestone:** Data Layer

#### Mô tả
Tạo cấu trúc Firestore collections và seed 12+ phim từ `movie_data.dart` lên database.

#### Firestore Schema

**Collection: `movies`**
```
movies/
  └── {movieId}/
      ├── id: number
      ├── title: string
      ├── poster: string (URL)
      ├── backdrop: string (URL)
      ├── description: string
      ├── year: string
      ├── genre: string
      ├── rating: string
      ├── trailerKey: string
      ├── director: string?
      ├── cast: array<string>
      ├── country: string?
      ├── duration: string?
      ├── studio: string?
      ├── views: number
      ├── contentRating: string (P, C13, C18)
      ├── createdAt: timestamp
      └── updatedAt: timestamp
```

**Collection: `movies/{movieId}/episodes`** (subcollection cho series)
```
episodes/
  └── {episodeId}/
      ├── number: number
      ├── title: string
      ├── description: string?
      ├── duration: string?
      ├── videoUrl: string?
      ├── thumbnailUrl: string?
      └── order: number
```

#### Checklist công việc
- [ ] Tạo collections `movies` trên Firestore
- [ ] Viết script seed data từ `movie_data.dart`
- [ ] Seed 12+ movies với đầy đủ thông tin
- [ ] Seed episodes cho phim "One Piece" (8 episodes)
- [ ] Tạo indexes cho các fields thường query (genre, year, rating)
- [ ] Tạo Security Rules cho collection movies

#### Acceptance Criteria
- Tất cả movies hiển thị trong Firestore Console
- Episodes được tạo đúng cấu trúc subcollection
- Security Rules chặn write không authorized

---

### Issue #3: [MODEL] Refactor Movie Model cho Firebase

**Assignee:** A - Trần Anh Sơn  
**Labels:** `model`, `refactor`, `firebase`  
**Milestone:** Data Layer

#### Mô tả
Cập nhật model `Movie` và `Episode` để serialize/deserialize từ Firestore.

#### Checklist công việc
- [ ] Thêm `fromFirestore()` factory constructor cho `Movie`
- [ ] Thêm `toFirestore()` method cho `Movie`
- [ ] Thêm `fromFirestore()` factory constructor cho `Episode`
- [ ] Thêm `toFirestore()` method cho `Episode`
- [ ] Handle nullable fields đúng cách
- [ ] Thêm validation cho required fields
- [ ] Update unit tests cho model

#### Acceptance Criteria
- Model có thể convert từ/to Firestore DocumentSnapshot
- Không có data loss khi serialize/deserialize
- Type safety được đảm bảo

---

### Issue #4: [REPOSITORY] Tạo MovieRepository cho Firebase data access

**Assignee:** A - Trần Anh Sơn  
**Labels:** `repository`, `data`, `firebase`  
**Milestone:** Data Layer

#### Mô tả
Tạo Repository pattern để fetch data từ Firebase thay vì hardcoded.

#### Checklist công việc
- [ ] Tạo interface `MovieRepository`
- [ ] Implement `FirebaseMovieRepository`:
  - `Future<List<Movie>> getAllMovies()`
  - `Future<Movie?> getMovieById(int id)`
  - `Future<List<Movie>> getMoviesByGenre(String genre)`
  - `Future<List<Movie>> getTrendingMovies({int limit = 10})`
  - `Future<List<Episode>> getEpisodes(String movieId)`
  - `Stream<Movie?> watchMovie(String movieId)` (real-time)
- [ ] Thêm error handling
- [ ] Thêm loading states
- [ ] Thêm caching mechanism (optional)
- [ ] Inject repository vào `main.dart`

#### Acceptance Criteria
- Repository fetch data thành công từ Firestore
- Error states được handle đúng
- Real-time updates hoạt động khi data thay đổi

---

### Issue #5: [AUTH] Enable Firebase Authentication

**Assignee:** B - Đỗ Hoàng Nam  
**Labels:** `auth`, `firebase`, `priority:high`  
**Milestone:** Authentication

#### Mô tả
Thiết lập Firebase Authentication với Email/Password và Google Sign-In.

#### Checklist công việc
- [ ] Enable Email/Password trong Firebase Console
- [ ] Enable Google Sign-In trong Firebase Console
- [ ] Cấu hình SHA-1 fingerprint cho Android
- [ ] Cấu hình URL schemes cho iOS
- [ ] Tạo `AuthService` class với methods:
  - `Future<User?> signInWithEmail(String email, String password)`
  - `Future<User?> signUpWithEmail(String email, String password)`
  - `Future<User?> signInWithGoogle()`
  - `Future<void> signOut()`
  - `Stream<User?> get authStateChanges`
- [ ] Lưu user session với `FirebaseAuth.instance.authStateChanges()`
- [ ] Tạo user document trong Firestore khi đăng ký

#### Acceptance Criteria
- Đăng nhập Email/Password hoạt động
- Google Sign-In hoạt động trên cả Android và iOS
- User session được persist qua app restarts
- User document được tạo trong Firestore

---

### Issue #6: [AUTH] Implement Login Screen với Firebase

**Assignee:** B - Đỗ Hoàng Nam  
**Labels:** `auth`, `ui`, `login`  
**Milestone:** Authentication

#### Mô tả
Implement login functionality trong `login_screen.dart` với Firebase Auth.

#### Checklist công việc
- [ ] Connect login form với `AuthService.signInWithEmail()`
- [ ] Implement Google Sign-In button
- [ ] Thêm loading state khi đang login
- [ ] Thêm error handling và hiển thị error messages
- [ ] Validate email format
- [ ] Validate password length
- [ ] Thêm "Forgot Password" feature (optional)
- [ ] Navigate to home sau khi login thành công
- [ ] Handle back button trên Android

#### Acceptance Criteria
- Login form submit thành công với Firebase
- Error messages hiển thị đúng (sai email, sai password)
- Loading spinner hiển thị khi đang process
- Auto navigate sau khi login thành công

---

### Issue #7: [AUTH] Implement Register Screen với Firebase

**Assignee:** B - Đỗ Hoàng Nam  
**Labels:** `auth`, `ui`, `register`  
**Milestone:** Authentication

#### Mô tả
Implement registration functionality trong `register_screen.dart` với Firebase Auth.

#### Checklist công việc
- [ ] Connect register form với `AuthService.signUpWithEmail()`
- [ ] Validate email format
- [ ] Validate password strength (min 6 characters)
- [ ] Validate password confirmation match
- [ ] Thêm loading state
- [ ] Thêm error handling
- [ ] Tạo user profile document trong Firestore sau khi đăng ký
- [ ] Auto login sau khi đăng ký thành công
- [ ] Navigate to home sau khi register thành công

#### Acceptance Criteria
- Registration thành công với Firebase
- User document được tạo trong Firestore
- Auto login sau khi register
- Validation errors hiển thị đúng

---

### Issue #8: [AUTH] Protect Routes - Authentication Guard

**Assignee:** B - Đỗ Hoàng Nam  
**Labels:** `auth`, `navigation`, `routing`  
**Milestone:** Authentication

#### Mô tả
Bảo vệ routes - chỉ cho phép xem phim khi đã login.

#### Checklist công việc
- [ ] Tạo `AuthGate` widget check auth state
- [ ] Implement auth state listener trong `main.dart`
- [ ] Refactor `landing_screen.dart` để check auth state
- [ ] Tạo route guards cho:
  - `/home` - yêu cầu auth
  - `/detail/:id` - yêu cầu auth
  - `/watch/:id` - yêu cầu auth
- [ ] Redirect to login nếu chưa authenticated
- [ ] Lưu last visited route để redirect back sau login
- [ ] Handle deep links với auth guard

#### Acceptance Criteria
- Unauthenticated users bị redirect to login
- Authenticated users vào thẳng home
- Last visited route được lưu và redirect back

---

### Issue #9: [DETAIL] Fetch Movie Details từ Firestore

**Assignee:** C - Vũ Hải Quân  
**Labels:** `detail`, `firestore`, `data`  
**Milestone:** UI Integration

#### Mô tả
Fetch movie details từ Firestore thay vì hardcoded data.

#### Checklist công việc
- [ ] Connect `detail_screen.dart` với `MovieRepository`
- [ ] Fetch movie data theo ID từ route arguments
- [ ] Handle loading state
- [ ] Handle error state (movie not found)
- [ ] Implement real-time updates với streams
- [ ] Cache movie data với `flutter_cache_manager`
- [ ] Optimize image loading
- [ ] Add pull-to-refresh

#### Acceptance Criteria
- Movie details load từ Firestore
- Loading/error states hiển thị đúng
- Real-time updates khi data thay đổi
- Cached data hiển thị khi offline

---

### Issue #10: [DETAIL] Fetch Episodes List từ Firestore

**Assignee:** C - Vũ Hải Quân  
**Labels:** `detail`, `episodes`, `firestore`  
**Milestone:** UI Integration

#### Mô tả
Fetch episode list từ subcollection `episodes` cho series.

#### Checklist công việc
- [ ] Fetch episodes từ `movies/{id}/episodes`
- [ ] Sort episodes theo order/number
- [ ] Hiển thị episode list trong detail screen
- [ ] Handle movies vs series (empty episodes = movie)
- [ ] Add loading state cho episodes
- [ ] Handle error state
- [ ] Navigate to watch screen với episode selected

#### Acceptance Criteria
- Episodes load đúng từ Firestore
- Series hiển thị danh sách tập
- Movies không hiển thị episode list
- Episode selection navigate đúng

---

### Issue #11: [DETAIL] Add Loading & Error States

**Assignee:** C - Vũ Hải Quân  
**Labels:** `ui`, `error-handling`, `loading`  
**Milestone:** UI Integration

#### Mô tả
Thêm loading và error states khi fetch data từ Firebase.

#### Checklist công việc
- [ ] Tạo reusable loading widget
- [ ] Tạo error widget với retry button
- [ ] Implement loading state khi fetch movie details
- [ ] Implement error state với error messages
- [ ] Handle network errors
- [ ] Handle Firestore permission errors
- [ ] Handle timeout errors
- [ ] Add retry logic

#### Acceptance Criteria
- Loading spinner hiển thị khi loading
- Error messages rõ ràng, dễ hiểu
- Retry button fetch lại data thành công
- UI không bị crash khi có lỗi

---

### Issue #12: [WATCH] Fetch Video URL từ Firestore

**Assignee:** D - Trịnh Gia Bảo  
**Labels:** `watch`, `video`, `firestore`  
**Milestone:** Video Player

#### Mô tả
Fetch video URL/trailer key từ Firestore cho video player.

#### Checklist công việc
- [ ] Fetch trailer key từ movie document
- [ ] Fetch episode video URLs từ episodes collection
- [ ] Handle YouTube embed URLs
- [ ] Handle direct video URLs (nếu có)
- [ ] Cache video URLs
- [ ] Handle invalid/missing URLs

#### Acceptance Criteria
- Trailer key load đúng từ Firestore
- Episode video URLs fetch thành công
- YouTube embed hoạt động
- Error handling cho invalid URLs

---

### Issue #13: [WATCH] Fix YouTube Player trên Android

**Assignee:** D - Trịnh Gia Bảo  
**Labels:** `android`, `youtube`, `webview`, `bug`  
**Milestone:** Video Player

#### Mô tả
Fix YouTube player trên Android với INTERNET permission và WebView configuration.

#### Checklist công việc
- [ ] Thêm INTERNET permission trong `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  ```
- [ ] Cấu hình WebView với JavaScript enabled
- [ ] Handle YouTube iframe API
- [ ] Test trên Android device/emulator
- [ ] Fix fullscreen mode
- [ ] Handle network errors

#### Acceptance Criteria
- YouTube videos play được trên Android
- Fullscreen hoạt động đúng
- Không có permission errors
- Network errors được handle

---

### Issue #14: [WATCH] Implement Video Progress Tracking

**Assignee:** D - Trịnh Gia Bảo  
**Labels:** `watch`, `progress`, `firestore`  
**Milestone:** Video Player

#### Mô tả
Track video progress và lưu vào Firestore.

#### Firestore Schema

**Collection: `users/{userId}/watchHistory`**
```
watchHistory/
  └── {movieId}/
      ├── movieId: string
      ├── episodeId: string?
      ├── progress: number (seconds)
      ├── duration: number (seconds)
      ├── completed: boolean
      ├── lastWatchedAt: timestamp
      └── updatedAt: timestamp
```

#### Checklist công việc
- [ ] Track video progress khi đang xem
- [ ] Lưu progress mỗi 5-10 seconds
- [ ] Lưu progress khi pause/stop
- [ ] Fetch progress khi mở video
- [ ] Seek to last position khi resume
- [ ] Mark episode/movie as completed
- [ ] Tạo Security Rules cho watchHistory

#### Acceptance Criteria
- Progress được lưu vào Firestore
- Resume từ vị trí cũ hoạt động
- Completed status update đúng
- Security Rules chặn access không authorized

---

### Issue #15: [WATCH] Feature "Tiếp tục xem"

**Assignee:** D - Trịnh Gia Bảo  
**Labels:** `watch`, `continue-watching`, `ui`  
**Milestone:** Video Player

#### Mô tả
Implement feature "tiếp tục xem" từ episode cuối.

#### Checklist công việc
- [ ] Fetch watch history từ Firestore
- [ ] Lọc các movies/episodes chưa completed
- [ ] Sort theo lastWatchedAt (mới nhất lên đầu)
- [ ] Hiển thị "Continue Watching" row trên home screen
- [ ] Show progress bar cho mỗi item
- [ ] Navigate to đúng episode/movie
- [ ] Seek to last position
- [ ] Handle deleted movies

#### Acceptance Criteria
- Continue Watching row hiển thị đúng
- Progress bars accurate
- Navigate và resume đúng vị trí
- Empty state khi không có history

---

### Issue #16: [WATCH] Optimize Video Player

**Assignee:** D - Trịnh Gia Bảo  
**Labels:** `video`, `performance`, `optimization`  
**Milestone:** Video Player

#### Mô tả
Optimize video player với `better_player` hoặc `chewie` package.

#### Checklist công việc
- [ ] Đánh giá `better_player` vs `chewie` vs `video_player`
- [ ] Install package được chọn
- [ ] Replace WebView với native player (nếu dùng direct URLs)
- [ ] Implement controls (play, pause, seek, volume)
- [ ] Implement fullscreen toggle
- [ ] Implement quality selector (nếu có multiple qualities)
- [ ] Implement playback speed control
- [ ] Handle background audio (optional)
- [ ] Optimize buffering
- [ ] Add loading indicators

#### Acceptance Criteria
- Video playback mượt mà
- Controls responsive
- Fullscreen hoạt động đúng
- Buffering optimized
- Memory usage hợp lý

---

## 📊 Progress Tracking

| Milestone | Issues | Completed | Progress |
|-----------|--------|-----------|----------|
| Firebase Setup | 1 | 0 | 0% |
| Data Layer | 3 (2,3,4) | 0 | 0% |
| Authentication | 4 (5,6,7,8) | 0 | 0% |
| UI Integration | 3 (9,10,11) | 0 | 0% |
| Video Player | 5 (12,13,14,15,16) | 0 | 0% |
| **TOTAL** | **16** | **0** | **0%** |

---

## 🔗 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/manage-data/structure-data)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Security Rules](https://firebase.google.com/docs/rules)

---

## 📝 Notes

- Tất cả issues cần được test trên cả Android và iOS
- Code cần follow existing code style trong project
- Commit messages theo convention: `[TAG] description`
- PRs cần được review trước khi merge
