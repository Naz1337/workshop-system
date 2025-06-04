# Main Menu Implementation Plan

## 1. Introduction

*   Purpose: To define the structure, features, and implementation strategy for the main navigation menu that users will see after logging in.
*   Goal: Provide users with clear and role-specific navigation paths to key application features.

## 2. Current State & Problem Statement

*   Briefly describe the current post-login screen (only a logout option).
*   Explain the need for a more comprehensive main menu to enhance user experience and provide access to new functionalities.

## 3. Proposed Main Menu Structure

*   The main menu will be the primary screen displayed after successful user authentication.
*   It will dynamically render navigation options based on the authenticated user's role (Foreman or Workshop Owner).
*   A common "Profile" option will be available to all users.
*   A "Logout" option will remain accessible.

## 4. Menu Items and Navigation

### 4.1. Common Menu Items (All Roles)

*   **Profile Page:**
    *   **Button Text:** "My Profile"
    *   **Navigation:** `context.push('/profile')` (assuming `/profile` is the route for the user's profile screen).
    *   **Description:** Allows users to view and potentially edit their profile information.

### 4.2. Foreman-Specific Menu Items

*   **Workshop List:**
    *   **Button Text:** "Browse Workshops"
    *   **Navigation:** `context.push('/workshops')` (placeholder route)
    *   **Description:** Leads to a list of all available workshops that the foreman can view or apply to.
*   **Available Workshops (Immediate Work):**
    *   **Button Text:** "Available Now" / "Immediate Work"
    *   **Navigation:** `context.push('/workshops/available')` (placeholder route)
    *   **Description:** Shows workshops where the foreman can start working immediately (e.g., already whitelisted and workshop has open slots).
*   **Pending Applications:**
    *   **Button Text:** "My Applications" / "Pending Workshops"
    *   **Navigation:** `context.push('/foreman/applications/pending')` (placeholder route)
    *   **Description:** Lists workshops the foreman has applied to and are awaiting workshop owner approval.

### 4.3. Workshop Owner-Specific Menu Items

*   **Foreman Requests:**
    *   **Button Text:** "Foreman Requests"
    *   **Navigation:** `context.push('/workshop/foremen/requests')` (placeholder route)
    *   **Description:** Displays a list of foremen who have requested to work at this workshop.
*   **Whitelisted Foremen:**
    *   **Button Text:** "My Approved Foremen"
    *   **Navigation:** `context.push('/workshop/foremen/whitelisted')` (placeholder route)
    *   **Description:** Shows a list of foremen who are approved (whitelisted) to work at this workshop.
*   **Manage Schedule:**
    *   **Button Text:** "Manage Workshop Schedule"
    *   **Navigation:** `context.push('/workshop/schedule/manage')` (placeholder route)
    *   **Description:** Allows the workshop owner to manage their workshop's work schedule, which will be visible to their approved foremen.

## 5. Technical Implementation Details

### 5.1. Determining User Role

*   The user's role will be fetched upon login (likely stored in `AppUserModel` or a similar model).
*   The `AuthService` or a dedicated `UserViewModel` will provide the current user's role to the Main Menu View.

### 5.2. View and ViewModel (MVVM)

*   **View:** `main_menu_view.dart`
    *   Responsible for displaying the menu options based on the ViewModel's state.
    *   Will use `Consumer` or `Selector` from the `provider` package to listen to changes in the `MainMenuViewModel`.
*   **ViewModel:** `main_menu_viewmodel.dart`
    *   Holds the logic to determine which menu items to display based on the user's role.
    *   Exposes properties for each menu item's visibility and navigation action.
    *   Will interact with `AuthService` or `UserRepository` to get user role information.

### 5.3. Routing (`go_router`)

*   New routes will need to be defined in `lib/config/router.dart` for each new screen linked from the main menu.
*   Navigation will primarily use `context.push()` to allow users to navigate back from sub-screens to the main menu.
*   `context.go('/main_menu')` might be used after login to ensure the main menu is the new base of the navigation stack.

## 6. UI/UX Considerations (Initial Thoughts)

*   The menu should be visually clear and easy to navigate.
*   Consider using a `ListView` or `Column` of `ElevatedButton` or `ListTile` widgets for menu items.
*   Icons could be added to menu items for better visual appeal.

## 7. Future Considerations

*   Adding a dashboard summary to the main menu.
*   Notifications or alerts section.

## 8. Action Plan (for actual code changes later)

1.  Create `MainMenuViewModel` (`lib/viewmodels/main_menu_viewmodel.dart`).
2.  Create `MainMenuView` (`lib/views/main_menu_view.dart`).
3.  Update `AuthViewModel` or `LoginViewModel` to navigate to `MainMenuView` after successful login using `context.go('/main_menu')`.
4.  Define new routes in `lib/config/router.dart`.
5.  Create placeholder views for each new screen linked from the main menu.
6.  Implement logic in `MainMenuViewModel` to fetch user role and control menu item visibility.
7.  Implement UI in `MainMenuView` to display menu items and handle navigation.
