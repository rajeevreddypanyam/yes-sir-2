# Application Navigation Paths

This document outlines the main navigation paths and routing logic for the YES SIR application, detailing how users move between different sections and portals based on their role and authentication status.

## 1. Core Principles

*   **Role-Based Redirection**: After successful authentication, users are redirected to their appropriate portal (`/admin/dashboard` or `/employee/home`) based on their assigned role.
*   **Default Landing**: The application's root (`/`) defaults to the Employee Login page.
*   **Clear Portal Separation**: Distinct login pages and navigation structures for Admin and Employee portals.

## 2. Main Entry Points & Redirection

| Path | Description | Default Redirects To | Notes |
| :--- | :---------- | :------------------- | :---- |
| `/` | Application Root | `/employee/login` | Unauthenticated users land here. |
| `/auth/callback` | OAuth Callback | `admin/dashboard` or `employee/home` | Handles Google OAuth post-authentication. Role-based redirection occurs here. |

## 3. Employee Portal Navigation

**Base Path: `/employee`**

| Path | Page Component | Access | Notes |
| :--- | :------------- | :----- | :---- |
| `/employee/login` | `EmployeeLogin` | Public | Employee sign-in via email/password or Google. Contains link to `admin/login`. |
| `/employee/change-password` | `EmployeeChangePassword` | Authenticated | Mandatory for first-time login with temporary password; also accessible from settings. |
| `/employee/home` | `EmployeeHome` | Employee, Team Admin, Org Admin | User's daily dashboard, attendance status, live tracking view. |
| `/employee/my-day` | `EmployeeMyDay` | Employee, Team Admin, Org Admin | Detailed daily activity timeline and route map. |
| `/employee/tasks` | `EmployeeTasks` | Employee, Team Admin, Org Admin | Personal task management. |
| `/employee/leave-requests` | `EmployeeLeaveRequests` | Employee, Team Admin, Org Admin | Submit and track personal leave requests. |
| `/employee/history` | `EmployeeHistory` | Employee, Team Admin, Org Admin | Historical attendance and activity overview. |
| `/employee/chat` | `EmployeeChat` | Employee, Team Admin, Org Admin | AI Chat Assistant for queries and requests. |
| `/employee/settings` | `EmployeeSettings` | Employee, Team Admin, Org Admin | Manage profile, appearance, notifications, and security. |
| `*` | Catch-all | `/employee/login` | Any unhandled employee path redirects to login. |

## 4. Admin Portal Navigation

**Base Path: `/admin`**

| Path | Page Component | Access | Notes |
| :--- | :------------- | :----- | :---- |
| `/admin/login` | `AdminLogin` | Public | Admin sign-in via email/password or Google. Contains link to `admin/signup` and `employee/login`. |
| `/admin/signup` | `AdminSignup` | Public | Org Admin initial setup: Google Auth only, then organization name input. |
| `/admin/organization-setup` | `AdminOrganizationSetup` | Authenticated (Org Admin pending setup) | Redirects here if Org Admin is logged in but organization not yet created. |
| `/admin/dashboard` | `AdminDashboard` | Org Admin, Team Admin (filtered) | Overview of organization/team activity, live user status, stats. |
| `/admin/organization` | `AdminOrganization` | Org Admin, Team Admin (filtered) | Tabbed interface for `Users`, `Teams`, `Shifts`. |
| `/admin/organization?tab=users` | `AdminUsers` (nested) | Org Admin, Team Admin (filtered) | Manage users within the organization/team. |
| `/admin/organization?tab=teams` | `AdminTeams` (nested) | Org Admin, Team Admin (filtered) | Manage teams within the organization/team. |
| `/admin/organization?tab=shifts` | `AdminShifts` (nested) | Org Admin (Team Admin - View only, if applicable) | Shift planning and assignment (future feature). |
| `/admin/locations` | `AdminLocations` | Org Admin, Team Admin (filtered) | Manage locations. |
| `/admin/geofences` | `AdminGeofences` | Org Admin, Team Admin (filtered) | Manage geofences. |
| `/admin/holidays` | `AdminHolidays` | Org Admin, Team Admin (view only) | Manage/view holidays. |
| `/admin/leave-requests` | `AdminLeaveRequests` | Org Admin, Team Admin (filtered) | Review and manage leave requests. |
| `/admin/reports` | `AdminReports` | Org Admin, Team Admin (filtered) | Generate various reports. |
| `/admin/chat` | `AdminChat` | Org Admin, Team Admin | AI Assistant for administrative tasks. |
| `/admin/settings` | `AdminSettings` | Org Admin only | Organization-wide configuration. |
| `*` | Catch-all | `/admin/login` | Any unhandled admin path redirects to login. |

## 5. Post-Authentication Redirection Logic (within `AuthCallback.tsx`)

After a user successfully authenticates via OAuth or traditional login, the `AuthCallback.tsx` (or similar logic after direct login) should perform the following steps:

1.  **Retrieve User Profile**: Fetch the authenticated user's profile and associated roles/organization status from the backend.
2.  **Check Signup Flow Flag**: If a `signup_flow` flag was set in local storage (indicating a user initiated the Admin Signup process), and the user's organization is not yet set up:
    *   Redirect to `/admin/signup?step=organization` to complete organization creation.
3.  **Role-Based Redirection**:
    *   If `user.role` is `org_admin` or `team_admin`: Redirect to `/admin/dashboard`.
    *   If `user.role` is `employee`: Redirect to `/employee/home`.
4.  **Error Handling**: If authentication fails or no role can be determined, redirect to a default login page (e.g., `/employee/login` or `/admin/login` if an admin login was attempted).

## 6. Layout Components

The `Layout.tsx` component handles the main application layout, including sidebar navigation, headers, and responsive behavior. The navigation items within `Layout.tsx` dynamically adjust based on the `type` prop (`admin` or `employee`) passed to it.

*   **Admin Layout**: Displays `adminNavItems`.
*   **Employee Layout**: Displays `employeeNavItems`.

**Note**: The `ProtectedRoute.tsx` component enforces authentication and role-based access before rendering any protected routes.
