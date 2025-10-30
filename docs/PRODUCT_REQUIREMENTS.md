# Product Requirements Document (PRD) - YES SIR

## 1. Introduction
This document outlines the functional and non-functional requirements for the YES SIR application, focusing on user authentication, authorization, and role-based access control. It incorporates feedback and clarifications regarding the signup, sign-in, and administrative processes to ensure a consistent and secure user experience across all defined roles.

## 2. Goals
*   Establish clear user roles with distinct access permissions.
*   Define a robust and intuitive signup and sign-in process for both administrators and employees, supporting multiple authentication methods.
*   Implement granular access control for Team Admins within the Admin Portal, limiting their scope to their assigned team(s).
*   Ensure a secure and reliable system for managing user accounts, teams, locations, geofences, holidays, and leave requests.

## 3. Target Audience
*   **Organization Administrators (Org Admins)**: Responsible for the overall management of the organization within YES SIR.
*   **Team Administrators (Team Admins)**: Responsible for managing specific teams under an Org Admin, while also acting as regular employees.
*   **Employees**: Primary users who interact with the system for daily attendance, tasks, and leave requests.

## 4. User Roles and Permissions

### 4.1. Org Admin (Level 1)
*   **Access**: Full access to all features in both the Admin Portal and Employee Portal.
*   **Admin Portal Capabilities**:
    *   **Dashboard**: View all organization-wide statistics and data.
    *   **Organization -> Users**:
        *   Create, edit, delete any user within the organization.
        *   Assign any role (Employee, Team Admin, Org Admin) to any user.
        *   Assign users to any team or geofence.
        *   Perform bulk actions (activate, deactivate, reset device, reset password, delete).
    *   **Organization -> Teams**:
        *   Create, edit, delete any team.
        *   Manage team configurations (description, timezone, default location, tracking settings).
    *   **Organization -> Shifts**: Full access (when implemented).
    *   **Locations**: Create, edit, delete any location.
    *   **Geofences**: Create, edit, delete any geofence.
    *   **Holidays**: Create, edit, delete organization-wide or team-specific holidays.
    *   **Leave Requests**: View, approve, reject all leave requests across the organization.
    *   **Reports**: Generate comprehensive reports for any user or team.
    *   **Settings**: Full access to all organizational settings.
*   **Employee Portal Capabilities**: Full access to all employee features (check-in/out, tasks, history, chat, etc.).

### 4.2. Team Admin (Level 2)
*   **Access**: Access to both the Admin Portal (restricted) and the Employee Portal (full).
*   **Admin Portal Capabilities (Restricted to Assigned Team(s))**:
    *   **Dashboard**: View statistics and data *filtered only for their assigned team(s)*. No organization-wide stats directly.
    *   **Organization -> Users**:
        *   Can only view, create, edit, or delete users who belong to *their assigned team(s)*.
        *   Cannot change a user's role to Team Admin or Org Admin. Can only manage roles within the Employee scope (e.g., changing position).
        *   Cannot perform actions on users outside their assigned team(s).
    *   **Organization -> Teams**:
        *   Can only edit or delete *their own assigned team(s)*. Cannot manage other teams or create new ones.
    *   **Locations**: Can only view locations associated with *their team's default location*. Editing/deleting is restricted based on team association.
    *   **Geofences**: Can only view geofences relevant to *their assigned team(s)*. Editing/deleting is restricted based on team association.
    *   **Holidays**: View only. Cannot create, edit, or delete holidays.
    *   **Leave Requests**: Can only see leave requests submitted by members of *their assigned team(s)*. Can approve or reject these specific leave requests.
    *   **Reports**: Can generate reports, but these reports will be strictly filtered to include data only for *their assigned team members* and/or *their team's activities*.
    *   **Settings**: No access. This page is restricted to Org Admins.
*   **Employee Portal Capabilities**: Full access to all standard employee features (check-in/out, tasks, history, chat, etc.).

### 4.3. Employee (Level 3)
*   **Access**: Access only to the Employee Portal. No access to the Admin Portal.
*   **Employee Portal Capabilities**:
    *   Check-in/Check-out.
    *   View and manage personal tasks.
    *   View "My Day" activity timeline.
    *   View attendance history.
    *   Request leave.
    *   Interact with AI Chat Assistant.
    *   Manage personal settings (profile, appearance, notifications, password).

## 5. Authentication and Onboarding Flow

### 5.1. Initial Application Visit (Root URL: `/`)
*   Any user accessing the application's root URL will be redirected to the `/employee/login` page by default.

### 5.2. Employee Login (`/employee/login`)
*   **Login Options**:
    *   Email/Password: Users can log in using credentials provided in their invitation email or their updated password.
    *   Google Sign-in: Users can log in using their Google account, provided the email address matches the one registered by an Admin.
*   **Navigation Links**:
    *   "Admin Portal" link: Directs to `/admin/login`.
*   **Post-Login Redirection**:
    *   Upon successful authentication, the system checks the user's role:
        *   If `role` is `employee`, redirect to `/employee/home`.
        *   If `role` is `team_admin` or `org_admin`, redirect to `/admin/dashboard`.

### 5.3. Admin Login (`/admin/login`)
*   **Login Options**:
    *   Email/Password: Users can log in using credentials.
    *   Google Sign-in: Users can log in using their Google account, provided the email address matches the one registered by an Admin.
*   **Navigation Links**:
    *   "Don't have an organization yet? Create one here" link: Directs to `/admin/signup`.
    *   "Employee Portal" link: Directs to `/employee/login`.
*   **Post-Login Redirection**:
    *   Upon successful authentication, the system checks the user's role:
        *   If `role` is `team_admin` or `org_admin`, redirect to `/admin/dashboard`.
        *   If `role` is `employee`, redirect to `/employee/home`.

### 5.4. Admin Signup (Organization Creation) (`/admin/signup`)
*   **Entry**: Accessible via the "Create one here" link from `/admin/login`.
*   **Authentication**: *Only Google Sign-in* is allowed for the initial organization setup.
*   **Process**:
    1.  User clicks "Continue with Google".
    2.  After successful Google authentication, the user is directed to a form to enter the "Organization Name".
    3.  Upon submitting the organization name, the system creates the organization and assigns the logged-in Google user as an `org_admin`.
    4.  Redirects the newly created Org Admin to `/admin/dashboard`.

### 5.5. User Creation by Admin
*   **Method**: Org Admins can create new users (Employee, Team Admin, Org Admin) via the Admin Portal's User Management page.
*   **Invitation Email**:
    *   When a new user is created, an invitation email is automatically sent to their registered email address.
    *   **Contents**: Application URL, user's email, a system-generated *temporary password*.
    *   **Mandatory Password Change**: The email will explicitly state that the user *must* change their password upon their first login.
*   **Initial Login for Created Users**:
    *   Upon their very first successful login using the temporary password, the user will be immediately redirected to a password change page (`/employee/change-password` for employees/Team Admins) before accessing any other part of the application. They must set a new password.

## 6. General Behavior

### 6.1. Single User Per Organization
*   Each user (identified by email) can only belong to one organization.

### 6.2. Team Admin Role Handling (Multiple Teams)
*   The current database schema design assumes a user belongs to a single team (`team_id` in `users` table). If a Team Admin needs to manage multiple teams, the schema and logic will require adjustment (e.g., a many-to-many relationship between users and teams, or an array of team IDs for a user). For now, we will assume a Team Admin is associated with a single team for management purposes.

## 7. Non-Functional Requirements
*   **Performance**: Application must be responsive, with API calls completing quickly.
*   **Security**: All user data must be protected, authentication robust, and role-based access strictly enforced.
*   **Scalability**: Designed to handle a growing number of users and organizations via Cloudflare's platform.
*   **Usability**: Intuitive and easy-to-navigate interfaces for all user roles.
*   **Maintainability**: Codebase should be clean, well-structured, and documented.
