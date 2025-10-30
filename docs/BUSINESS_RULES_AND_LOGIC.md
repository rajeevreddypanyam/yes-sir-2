# Business Rules and Logic - YES SIR

This document details the core business rules and logical constraints that govern the behavior of the YES SIR application, particularly focusing on user interactions, authentication, authorization, and data management across different user roles.

## 1. Authentication and Authorization

### 1.1. User Account Provisioning
*   **Org Admin Signup**:
    *   Only Google OAuth can be used to create the initial organization and become the first Org Admin.
    *   The user must provide a unique organization name.
*   **New User Creation (by Org Admin)**:
    *   Org Admins create all other user types (Employee, Team Admin, additional Org Admin).
    *   New users are assigned a system-generated temporary password and an invitation email is sent.
    *   New users can also log in via Google OAuth if their registered email matches.
*   **Temporary Password Policy**:
    *   Users logging in with a temporary password *must* change their password immediately after their first successful login. They are redirected to a dedicated password change page.
    *   Temporary passwords meet basic strength requirements (length, character types).

### 1.2. Password Management
*   **Password Complexity**: New passwords must meet minimum complexity requirements: at least 8 characters, including uppercase, lowercase, and numbers.
*   **Password Reset**: Admin-initiated password resets generate a new temporary password and send it via email, requiring a mandatory password change on first login.

## 2. User Role-Based Access Control (RBAC)

### 2.1. Org Admin (Level 1)
*   **Unrestricted Access**: Full read/write/delete access to all data and features across the entire organization.
*   **User Management**: Can create, edit, delete any user and assign any role (Employee, Team Admin, Org Admin).
*   **Organization Structure**: Can create, edit, delete any team, location, or geofence.
*   **Reporting**: Can generate reports for any user or team.
*   **Settings**: Full control over organization-wide settings.

### 2.2. Team Admin (Level 2)
*   **Dual Access**: Has full access to the Employee Portal and restricted access to the Admin Portal.
*   **Admin Portal - Data Visibility & Actions (Team-Specific)**:
    *   **Dashboard**: Displays only statistics and data pertaining to their assigned team(s).
    *   **Organization -> Users**:
        *   Can only *view* users belonging to their assigned team(s).
        *   Can only *edit* or *delete* users within their assigned team(s).
        *   **Cannot** change a user's role to Team Admin or Org Admin. Role changes are restricted to Employee-level adjustments (e.g., position, phone).
    *   **Organization -> Teams**:
        *   Can only *edit* or *delete* their *own* assigned team(s).
        *   Cannot create new teams or modify other teams.
    *   **Locations**:
        *   Can only *view* locations that are configured as the `default_location_id` for their assigned team(s).
        *   Cannot create, edit, or delete any locations.
    *   **Geofences**:
        *   Can only *view* geofences that are explicitly assigned to or relevant to their assigned team(s).
        *   Cannot create, edit, or delete geofences.
    *   **Holidays**: Can only *view* existing holidays. Cannot create, edit, or delete holidays.
    *   **Leave Requests**:
        *   Can only *view* leave requests submitted by members of their assigned team(s).
        *   Can *approve* or *reject* leave requests from their assigned team members.
    *   **Reports**: Can only generate reports for users or activities within their assigned team(s).
    *   **Settings**: No access to the Admin Portal's "Settings" page.

### 2.3. Employee (Level 3)
*   **Employee Portal Only**: No access to any Admin Portal features or pages.
*   **Personal Data Management**: Can manage their own profile, tasks, and leave requests.
*   **Attendance**: Can perform check-in/check-out.
*   **Settings**: Can manage personal settings (profile, appearance, notifications, password).

## 3. Data Integrity and Relationships

### 3.1. Organization
*   Each user belongs to exactly one organization.
*   All data (teams, users, locations, geofences, attendance, tasks, notifications, leave requests, holidays) is scoped to an `organization_id`.
*   Deleting an organization implies deleting all associated data.

### 3.2. Teams
*   Each team belongs to one organization.
*   A user is assigned to either one team (`team_id`) or no team.
*   Teams can have a `default_location_id` and specific `timezone` and tracking settings.

### 3.3. Users
*   Each user has a unique email within the organization.
*   Users are assigned a `role` (`org_admin`, `team_admin`, `employee`).
*   Users can be `is_active` or `is_inactive`. Inactive users cannot log in.
*   Users can be optionally assigned to a `geofence_id` and a `team_id`.

### 3.4. Locations & Geofences
*   Locations and Geofences are organization-scoped.
*   A team can have a `default_location_id` pointing to an existing location.
*   Geofences can be `circle` or `polygon` type.
*   Geofences can be optionally assigned to a specific `team_id` or `user_id`.

### 3.5. Attendance
*   **Attendance Day**: Records overall status for a user on a given date (`present`, `absent`, `late`, `half_day`, `public_holiday`, `weekly_off`).
*   **Attendance Sessions**: Records individual check-in/check-out periods within an attendance day. A user can have multiple sessions in a day.
*   **Attendance Pings**: Detailed location data points (latitude, longitude, accuracy, battery, timestamp) associated with an `attendance_day_id` and `attendance_session_id`.
*   **Override Requests**: Employees can submit requests to change their attendance status for a specific date, which requires admin approval.

### 3.6. Tasks
*   Tasks are organization-scoped.
*   Tasks are assigned to a specific `assigned_to_user_id` and optionally to a `team_id`.
*   Tasks can be `parent_task_id` for subtasks.
*   Tasks have `priority` and `status` fields.

### 3.7. Holidays
*   Holidays are organization-scoped.
*   Holidays can apply to the entire `organization` or to specific `teams`.
*   Team-specific holidays are managed via the `team_holidays` junction table.

## 4. System Behavior

### 4.1. Location Tracking
*   Location pings are recorded only when a user is `checked-in`.
*   Location pings include latitude, longitude, accuracy, and battery level.
*   Intelligent ping logic: Pings are sent if the user moves a significant distance (e.g., >20m) or if a configured time interval has passed.
*   Organization-level settings (e.g., `location_interval`, `high_accuracy_mode`, `min_dwell_minutes`, `move_speed_threshold`) determine tracking behavior.

### 4.2. Notifications
*   Notifications are user-specific and organization-scoped.
*   Triggered by events like geofence crossing, task assignment, attendance status changes.
*   Users can configure their notification preferences in their settings.

### 4.3. Data Export
*   Reports and individual "My Day" data can be exported to CSV.

## 5. Third-Party Integrations
*   **Mocha Users Service**: Centralized authentication provider.
*   **Google Maps Platform**: Critical for map visualization, geocoding, reverse geocoding, and timezone services.
*   **OpenAI**: Powers the AI chat assistants in both Admin and Employee portals.
*   **ZeptoMail**: Used for sending transactional emails (e.g., welcome emails, password resets).
