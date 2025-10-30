# Implementation Tasks - YES SIR

This document outlines a high-level breakdown of tasks and sub-tasks required to implement the features and business logic described in the PRD.

## 1. Core Setup & Enhancements

### Task: Enhance Authentication and Session Management
*   **Sub-task 1.1**: Update `AuthCallback.tsx` to handle role-based redirection comprehensively after `exchangeCodeForSessionToken`.
    *   Implement fetching user profile after session token exchange to get `role` and `organizationSetup` status.
    *   Redirect to `/admin/signup?step=organization` if `signup_flow` flag is set AND `organizationSetup` is false.
    *   Redirect to `/admin/dashboard` for `org_admin`/`team_admin`.
    *   Redirect to `/employee/home` for `employee`.
*   **Sub-task 1.2**: Refine `/employee/login` and `/admin/login` page redirection logic for `AuthCallback.tsx`.
    *   Ensure `admin_login_attempt` flag correctly directs back to `/admin/login` on OAuth failure.
*   **Sub-task 1.3**: Implement Email/Password login flow in `src/worker/index.ts`.
    *   Add login endpoint `/api/login` to verify email/password against stored hash.
    *   Set `user_info` cookie upon successful email/password login.
    *   Ensure custom auth middleware prioritizes `user_info` cookie over OAuth for session.
*   **Sub-task 1.4**: Implement `change-password` functionality.
    *   Create API endpoint in `src/worker/index.ts` to update user's password hash.
    *   Update `EmployeeChangePassword.tsx` to call this API.
    *   Ensure password strength validation in frontend and backend.
*   **Sub-task 1.5**: Integrate `must_change_password` flag.
    *   Modify `/api/login` and `AuthCallback.tsx` to check `must_change_password` flag on user.
    *   If `true`, redirect user to `/employee/change-password` immediately after login.
    *   Update flag to `false` after successful password change.

### Task: Implement Admin Signup Flow
*   **Sub-task 2.1**: Update `AdminSignup.tsx` for two-step process.
    *   Initial view: "Continue with Google" button only. Sets `signup_flow` flag in local storage.
    *   Second view (after Google Auth, if `signup_flow` and no organization): Form for "Organization Name".
*   **Sub-task 2.2**: Backend `/api/create-organization` endpoint.
    *   Ensure it correctly assigns the Google-authenticated user as `org_admin` to the new organization.
    *   Handle cases where user might already be in an organization.

## 2. Admin Portal - Role-Based Access Control (RBAC) Implementation

### Task: Implement Org Admin RBAC
*   **Sub-task 3.1**: Ensure existing Admin Portal pages grant full access to `org_admin` role. (This is generally the baseline, verify no accidental restrictions).

### Task: Implement Team Admin RBAC
*   **Sub-task 4.1**: Create/Update utility functions or middleware to filter data based on `user.team_id` (if Team Admin).
*   **Sub-task 4.2**: Modify API endpoints in `src/worker/index.ts` to enforce team-specific filtering for Team Admins.
    *   `/api/users`: Filter to return only users from the Team Admin's team(s).
    *   `/api/teams`: Filter to return only the Team Admin's team(s) for edit/delete.
    *   `/api/locations`: Filter to return only locations linked to the Team Admin's team's default location.
    *   `/api/geofences`: Filter to return only geofences relevant to the Team Admin's team(s).
    *   `/api/holidays`: Filter to return all holidays (view-only).
    *   `/api/leave-requests`: Filter to return only leave requests from the Team Admin's team members.
    *   `/api/reports/*`: Filter report generation based on the Team Admin's team(s).
*   **Sub-task 4.3**: Update frontend components (`AdminDashboard.tsx`, `AdminUsers.tsx`, `AdminTeams.tsx`, `AdminLocations.tsx`, `AdminGeofences.tsx`, `AdminHolidays.tsx`, `AdminLeaveRequests.tsx`, `AdminReports.tsx`) to reflect Team Admin's restricted view and actions.
    *   Disable/hide "Create" buttons for items outside their scope (e.g., new teams, new locations).
    *   Disable/hide "Edit/Delete" buttons for items outside their scope.
    *   Apply UI filters for data tables and dashboards.
*   **Sub-task 4.4**: Restrict `AdminSettings.tsx` to Org Admins only.
    *   Implement frontend check using `user.role` to hide/redirect if not `org_admin`.
    *   Implement backend check on `/api/organization/settings` endpoints.

## 3. User Management Enhancements

### Task: Enhance User Creation and Invitation
*   **Sub-task 5.1**: Backend `/api/users` (POST) to generate temporary password and set `must_change_password`.
    *   Use `src/worker/utils/password.ts` to generate secure temporary passwords.
    *   Hash the temporary password and store it.
    *   Set `must_change_password` to `TRUE`.
*   **Sub-task 5.2**: Integrate ZeptoMail for invitation emails.
    *   Use `src/worker/utils/email.ts` to send welcome email with temporary password.
    *   Include login URL and instructions for password change.
*   **Sub-task 5.3**: Implement Admin-initiated password reset.
    *   Update `/api/users/bulk/reset-password` (POST) to generate new temporary password, update hash, set `must_change_password` to `TRUE`.
    *   Send new credentials via email using ZeptoMail.

## 4. General Feature Development

### Task: Google Maps API Key Management
*   **Sub-task 6.1**: Ensure `VITE_GOOGLE_MAPS_API_KEY` is consistently used in frontend components.
*   **Sub-task 6.2**: Ensure `GOOGLE_MAPS_API_KEY` is consistently used in backend worker for geocoding, reverse geocoding, and timezone APIs.

### Task: Location & Geofence Timezone Handling
*   **Sub-task 7.1**: Implement backend logic to auto-detect and store `timezone` for new locations (via Google Timezone API).
*   **Sub-task 7.2**: Implement batch timezone update endpoint `/api/admin/update-timezones` using `src/worker/batch-timezone-update.ts`.
*   **Sub-task 7.3**: Update `TeamFormModal.tsx` to auto-populate timezone when `defaultLocationId` is selected.
*   **Sub-task 7.4**: Update `AdminLocations.tsx` to display timezone.

### Task: Attendance Timeline Refinements
*   **Sub-task 8.1**: Review `src/worker/index.ts` (`/api/reports/user-timeline`) for accurate segment generation (check-in, check-out, move, stop).
*   **Sub-task 8.2**: Enhance `AdminTimelineView.tsx` and `DayTimelineComponent` (in `EmployeeHistory.tsx`, `EmployeeMyDay.tsx`) for robust display of timeline events.
*   **Sub-task 8.3**: Ensure `RouteMap.tsx` accurately displays the travel path and key location markers based on timeline data.

## 5. UI/UX Enhancements

### Task: Responsive Design for Admin Portal
*   **Sub-task 9.1**: Review and adjust `AdminUsers.tsx`, `AdminTeams.tsx`, `AdminLocations.tsx`, `AdminGeofences.tsx`, `AdminHolidays.tsx`, `AdminLeaveRequests.tsx`, `AdminReports.tsx` for optimal mobile responsiveness.
*   **Sub-task 9.2**: Ensure `Layout.tsx` handles mobile header content dynamically, switching between expanded and compact views as per design.

### Task: Toast Notifications
*   **Sub-task 10.1**: Implement a consistent toast notification system across the application for success/error messages.

### Task: Confirmation Modals
*   **Sub-task 11.1**: Use confirmation modals for sensitive actions (e.g., delete user/team, bulk actions).

## 6. Cleanup and Refactoring

### Task: Remove Unused Components
*   **Sub-task 12.1**: Remove `DeviceConflictModal.tsx` as it's no longer needed with Mocha Users Service.

### Task: Code Consistency
*   **Sub-task 13.1**: Review imports, naming conventions, and code style for consistency across the codebase.
