# Authentication Flow and Initial Screen Display

This document explains how the Workshop-Foreman Management System determines the user's authentication state and displays the appropriate initial screens upon application launch. The core technologies involved are Firebase Authentication for user management and `go_router` for declarative routing.

## 1. Core Components

### `AuthService` (`lib/services/auth_service.dart`)

The `AuthService` class acts as an abstraction layer for Firebase Authentication. It provides methods to interact with Firebase Auth and exposes the authentication state.

*   **`Stream<User?> get authStateChanges`**: This stream emits a `User` object whenever the user's sign-in state changes (e.g., user logs in, logs out, or the session expires). While not directly used for the *initial* redirect in our `go_router` setup, it's crucial for reacting to authentication changes dynamically within the app.
*   **`User? getCurrentUser()`**: This method provides a synchronous way to get the currently logged-in Firebase `User` object. If no user is logged in, it returns `null`. This is primarily used by `go_router` for the initial routing decision.

### `GoRouter` Configuration (`lib/config/router.dart`)

`go_router` is used for managing the application's navigation stack. The initial routing logic is handled by the `redirect` property of the root route (`/`).

The `router.dart` file defines the `GoRouter` instance:

```dart
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) {
        final authService = Provider.of<AuthService>(context, listen: false);
        // If no user is currently logged in, redirect to the welcome screen.
        // Otherwise, redirect to the home screen.
        return authService.getCurrentUser() == null ? '/welcome' : '/home';
      },
    ),
    // ... other routes
  ],
);
```

**Explanation of the `redirect` logic:**

1.  When the application starts, `go_router` attempts to navigate to the root path (`/`).
2.  The `redirect` function for the `/` route is immediately executed.
3.  Inside the `redirect` function, it accesses the `AuthService` instance using `Provider.of<AuthService>(context, listen: false)`.
4.  It then calls `authService.getCurrentUser()` to check if there's an authenticated user.
5.  **If `authService.getCurrentUser()` returns `null`**: This indicates no user is currently logged in. The `redirect` function returns `'/welcome'`, instructing `go_router` to navigate to the `WelcomeView`.
6.  **If `authService.getCurrentUser()` returns a `User` object**: This indicates a user is logged in. The `redirect` function returns `'/home'`, instructing `go_router` to navigate to the `HomeScreen` (the main application dashboard).

### `main.dart` Integration

The `main.dart` file is the entry point of the Flutter application. It initializes Firebase, sets up the `Provider` for `AuthService` (and other services/repositories), and configures the `MaterialApp.router` to use the `go_router` instance.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // ... other providers
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        // ... other providers
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Uses the global router instance from config/router.dart
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
```

## 2. Initial Screen Flow (When Not Logged In)

1.  **Application Launch**: The Flutter app starts.
2.  **Firebase Initialization**: `Firebase.initializeApp()` is called.
3.  **Provider Setup**: `AuthService` and other dependencies are made available via `MultiProvider`.
4.  **`MyApp` Widget Builds**: `MaterialApp.router` is built, which uses the `router` instance.
5.  **`GoRouter` Root Route Evaluation**: `go_router` attempts to navigate to the default path (`/`).
6.  **`redirect` Function Execution**: The `redirect` function in `lib/config/router.dart` is triggered.
7.  **Authentication Check**: `authService.getCurrentUser()` is called. Since no user is logged in, it returns `null`.
8.  **Redirection to Welcome Screen**: The `redirect` function returns `'/welcome'`.
9.  **`WelcomeView` Displayed**: `lib/views/auth/welcome_view.dart` is rendered, presenting the "Login" and "Register" buttons to the user.
    *   Clicking "Login" navigates to `/login`.
    *   Clicking "Register" navigates to `/register/foreman`.

## 3. Initial Screen Flow (When Logged In)

1.  **Application Launch**: The Flutter app starts.
2.  **Firebase Initialization**: `Firebase.initializeApp()` is called.
3.  **Provider Setup**: `AuthService` and other dependencies are made available via `MultiProvider`.
4.  **`MyApp` Widget Builds**: `MaterialApp.router` is built, which uses the `router` instance.
5.  **`GoRouter` Root Route Evaluation**: `go_router` attempts to navigate to the default path (`/`).
6.  **`redirect` Function Execution**: The `redirect` function in `lib/config/router.dart` is triggered.
7.  **Authentication Check**: `authService.getCurrentUser()` is called. Since a user is logged in (e.g., from a previous session), it returns a `User` object.
8.  **Redirection to Home Screen**: The `redirect` function returns `'/home'`.
9.  **`HomeScreen` Displayed**: The `HomeScreen` (a placeholder in `lib/config/router.dart` for now) is rendered, indicating the user is logged in.

## 4. Summary

This setup ensures that the application intelligently directs users to the appropriate starting screen based on their authentication status. The `go_router`'s `redirect` mechanism, combined with `AuthService`'s synchronous user check, provides a clean and effective way to manage the initial navigation flow. For dynamic changes after the initial load (e.g., a user logging out from within the app), the `signOut()` method in `AuthService` explicitly navigates the user back to the welcome screen.
