# Application Navigation (Flutter Mobile)

This guide describes the navigation structure for the YES SIR Flutter
application. Navigation is role-aware and adapts to authenticated state sourced
from Firebase.

## 1. Navigation Primitives
- **AuthGate**: Entry widget loaded after Firebase initialization. Listens to
  `AuthController` to route users to the correct experience.
- **Navigator 1.0**: Initial implementation uses a single `MaterialApp` with
  named routes. Migrating to `GoRouter` is straightforward once deep linking is
  required.
- **Bottom Navigation**: Employees access features through a three-tab layout
  (Today, Tasks, Profile). Admins access a segmented dashboard with quick links.

## 2. High-Level Flow
1. App starts → Firebase initialization → `AuthGate`.
2. `AuthGate` states:
   - `unauthenticated`: show `SignInScreen`.
   - `needsProfile`: show `ProfileSetupScreen` with instructions.
   - `authenticated`: push role-based shell (`EmployeeShell` or `AdminShell`).
   - `error`: fallback scaffold with retry.
3. Shell widgets manage their own tab stacks and surface contextual actions.

## 3. Routes & Widgets
| Route / Widget | Description | Access |
| --- | --- | --- |
| `/sign-in` (`SignInScreen`) | Email/Google sign-in, password reset link. | Public |
| `/employee` (`EmployeeShell`) | Container for employee tabs. | Employee, Team Admin |
| `/employee/home` (`EmployeeHomeScreen`) | Dashboard, check-in/out, timeline entry points. | Employee, Team Admin |
| `/employee/tasks` (`EmployeeTasksScreen`, TBD) | Task list & details. | Employee, Team Admin |
| `/employee/profile` (`EmployeeProfileScreen`, TBD) | Settings, device health, notifications. | Employee, Team Admin |
| `/admin` (`AdminShell`) | Container for admin quick actions. | Org Admin, Team Admin (scoped) |
| `/admin/dashboard` (`AdminDashboardScreen`) | KPIs, live attendance summary. | Org Admin, Team Admin |
| `/admin/people` (`AdminUsersScreen`, TBD) | Invite/manage members. | Org Admin, Team Admin (limited) |
| `/admin/locations` (`AdminLocationsScreen`, TBD) | Manage sites & geofences. | Org Admin, Team Admin (view) |
| `/admin/leave` (`AdminLeaveScreen`, TBD) | Approve leave & overrides. | Org Admin, Team Admin |
| `/admin/settings` (`AdminSettingsScreen`, TBD) | Org-wide controls. | Org Admin |
| `/profile/setup` (`ProfileSetupScreen`) | Guidance when Firestore profile missing. | Authenticated without profile |

## 4. Navigation Behaviors
- **Deep Links**: Invitation emails open `/profile/setup` or `/sign-in` with
  pre-filled email via Firebase Dynamic Links (future work).
- **Back Navigation**: Android system back pops current tab stack. On root tab,
  another back press prompts to exit.
- **Role Switch**: Team Admins can switch between Employee and Admin shells via
  menu; navigation state is preserved per shell.
- **Offline Mode**: Navigation works offline using cached data; certain screens
  show banners when network is unavailable.

## 5. Future Enhancements
- Adopt `GoRouter` with declarative routes and guards for complex flows.
- Add onboarding walkthrough for first-time users.
- Integrate push notification deep links to jump directly to approvals or
  overrides.
