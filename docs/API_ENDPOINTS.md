# API Endpoints - YES SIR

This document outlines the RESTful API endpoints exposed by the Cloudflare Worker backend for the YES SIR application. These endpoints facilitate communication between the React frontend and the D1 database, implementing the various features and business logic.

## 1. Authentication & Core User Management

### `GET /`
*   **Description**: Root endpoint, a simple health check.
*   **Access**: Public
*   **Response**: `{"message": "YES SIR API is running"}`

### `GET /health`
*   **Description**: Health check endpoint.
*   **Access**: Public
*   **Response**: `{"status": "healthy", "timestamp": "..."}`

### `GET /api/oauth/google/redirect_url`
*   **Description**: Retrieves the Google OAuth redirect URL.
*   **Access**: Public
*   **Response**: `{"redirectUrl": "https://accounts.google.com/o/oauth2/v2/auth?..."}`

### `POST /api/sessions`
*   **Description**: Exchanges an OAuth authorization code for a session token.
*   **Access**: Public
*   **Request Body**: `{"code": "your_auth_code"}`
*   **Response**: `{"success": true}` (sets HTTP-only cookie with session token)

### `GET /api/users/me`
*   **Description**: Retrieves the authenticated user's profile, role, and organization status.
*   **Access**: Authenticated
*   **Response**: `{"id": ..., "email": "...", "role": "...", "organization_id": "...", "organizationName": "...", "organizationSetup": true/false, "authType": "email_password"|"oauth", ...}`

### `GET /api/logout`
*   **Description**: Logs out the current user by invalidating the session token and clearing cookies.
*   **Access**: Authenticated
*   **Response**: `{"success": true}`

### `POST /api/login`
*   **Description**: Authenticates a user using email and password.
*   **Access**: Public
*   **Request Body**: `{"email": "user@example.com", "password": "password123"}`
*   **Response**: `{"success": true, "redirectUrl": "/admin/dashboard"|"employee/home"}` (sets HTTP-only `user_info` cookie)
*   **Notes**: Checks `must_change_password` flag and can redirect to `/employee/change-password`.

### `POST /api/change-password`
*   **Description**: Allows a user to change their password.
*   **Access**: Authenticated
*   **Request Body**: `{"currentPassword": "old_password", "newPassword": "new_password", "email": "user@example.com"}`
*   **Response**: `{"success": true}`
*   **Notes**: If `isMandatory` (first login with temp password), `currentPassword` is the temporary one, `email` must be provided. Updates `must_change_password` to `FALSE`.

### `POST /api/create-organization`
*   **Description**: Creates a new organization and assigns the current user as an `org_admin`.
*   **Access**: Authenticated (user must not already be in an organization)
*   **Request Body**: `{"organizationName": "My New Company"}`
*   **Response**: `{"success": true, "organizationId": ..., "message": "Organization created successfully"}`

## 2. Admin Portal APIs

### 2.1. User Management
*   **Middleware**: Requires `authMiddleware` and potentially `org_admin`/`team_admin` role checks.
*   `GET /api/users`
    *   **Description**: Retrieves a list of users for the authenticated user's organization.
    *   **Access**: Org Admin (all users), Team Admin (only users in their team(s))
    *   **Response**: `{"users": [...]}`
*   `POST /api/users`
    *   **Description**: Creates a new user. Assigns temporary password and sends invitation email.
    *   **Access**: Org Admin (any role), Team Admin (only employees in their team(s))
    *   **Request Body**: `{"name": "...", "email": "...", "role": "employee"|"team_admin"|"org_admin", "teamId": "...", ...}`
    *   **Response**: `{"success": true, "userId": ..., "message": "User created successfully. Temporary password: ..."}`
*   `PUT /api/users/:id`
    *   **Description**: Updates an existing user's details.
    *   **Access**: Org Admin (any user), Team Admin (only users in their team(s))
    *   **Request Body**: `{"name": "...", "email": "...", "role": "employee"|"team_admin"|"org_admin", "teamId": "...", ...}`
    *   **Response**: `{"success": true}`
*   `DELETE /api/users/:id`
    *   **Description**: Deletes a user.
    *   **Access**: Org Admin (any user), Team Admin (only users in their team(s))
    *   **Response**: `{"success": true}`
*   `DELETE /api/users/bulk`
    *   **Description**: Deletes multiple users.
    *   **Access**: Org Admin, Team Admin (only users in their team(s))
    *   **Request Body**: `{"userIds": [1, 2, 3]}`
    *   **Response**: `{"success": true, "deletedCount": ...}`
*   `PUT /api/users/bulk/status`
    *   **Description**: Activates or deactivates multiple users.
    *   **Access**: Org Admin, Team Admin (only users in their team(s))
    *   **Request Body**: `{"userIds": [1, 2, 3], "isActive": true/false}`
    *   **Response**: `{"success": true, "updatedCount": ...}`
*   `POST /api/users/bulk/reset-device`
    *   **Description**: Resets device settings for multiple users (placeholder for actual device management logic).
    *   **Access**: Org Admin, Team Admin (only users in their team(s))
    *   **Request Body**: `{"userIds": [1, 2, 3]}`
    *   **Response**: `{"success": true, "resetCount": ...}`
*   `POST /api/users/bulk/reset-password`
    *   **Description**: Resets passwords for multiple users, generates new temporary passwords, and sends emails.
    *   **Access**: Org Admin, Team Admin (only users in their team(s))
    *   **Request Body**: `{"userIds": [1, 2, 3]}`
    *   **Response**: `{"success": true, "message": "..."}`

### 2.2. Team Management
*   `GET /api/teams`
    *   **Description**: Retrieves a list of teams for the organization.
    *   **Access**: Org Admin (all teams), Team Admin (only their team(s))
    *   **Response**: `{"teams": [...]}`
*   `POST /api/teams`
    *   **Description**: Creates a new team.
    *   **Access**: Org Admin
    *   **Request Body**: `{"name": "...", "description": "...", "timezone": "...", "defaultLocationId": "...", "tracking_interval_minutes": ..., "high_accuracy_mode": true/false}`
    *   **Response**: `{"success": true, "teamId": ...}`
*   `PUT /api/teams/:id`
    *   **Description**: Updates a team's details.
    *   **Access**: Org Admin (any team), Team Admin (only their team(s))
    *   **Request Body**: `{"name": "...", "description": "...", "timezone": "...", "defaultLocationId": "...", "tracking_interval_minutes": ..., "high_accuracy_mode": true/false}`
    *   **Response**: `{"success": true}`
*   `DELETE /api/teams/:id`
    *   **Description**: Deletes a team.
    *   **Access**: Org Admin (any team), Team Admin (only their team(s))
    *   **Response**: `{"success": true}`

### 2.3. Location Management
*   `GET /api/locations`
    *   **Description**: Retrieves a list of locations for the organization.
    *   **Access**: Org Admin (all locations), Team Admin (only locations associated with their team's default location)
    *   **Response**: `{"locations": [...]}`
*   `POST /api/locations`
    *   **Description**: Creates a new location.
    *   **Access**: Org Admin
    *   **Request Body**: `{"name": "...", "address": "...", "latitude": ..., "longitude": ..., "radius_meters": ..., "location_type": "office", "timezone": "..."}`
    *   **Response**: `{"success": true, "locationId": ...}`
*   `PUT /api/locations/:id`
    *   **Description**: Updates a location's details.
    *   **Access**: Org Admin
    *   **Request Body**: `{"name": "...", "address": "...", "latitude": ..., "longitude": ..., "radius_meters": ..., "location_type": "office", "timezone": "..."}`
    *   **Response**: `{"success": true}`
*   `DELETE /api/locations/:id`
    *   **Description**: Deletes a location.
    *   **Access**: Org Admin
    *   **Response**: `{"success": true}`
*   `POST /api/admin/update-timezones`
    *   **Description**: Triggers a batch update to detect and fill timezones for locations without them.
    *   **Access**: Org Admin
    *   **Response**: `{"success": true}`

### 2.4. Geofence Management
*   `GET /api/geofences`
    *   **Description**: Retrieves a list of geofences for the organization.
    *   **Access**: Org Admin (all geofences), Team Admin (only geofences relevant to their team(s))
    *   **Response**: `{"geofences": [...]}`
*   `POST /api/geofences`
    *   **Description**: Creates a new geofence.
    *   **Access**: Org Admin
    *   **Request Body**: `{"name": "...", "geofence_type": "circle"|"polygon", "latitude": ..., "longitude": ..., "radius_meters": ..., "polygon_data": "..."}`
    *   **Response**: `{"success": true, "geofenceId": ...}`
*   `PUT /api/geofences/:id`
    *   **Description**: Updates a geofence's details.
    *   **Access**: Org Admin
    *   **Request Body**: `{"name": "...", "geofence_type": "circle"|"polygon", "latitude": ..., "longitude": ..., "radius_meters": ..., "polygon_data": "..."}`
    *   **Response**: `{"success": true}`
*   `DELETE /api/geofences/:id`
    *   **Description**: Deletes a geofence.
    *   **Access**: Org Admin
    *   **Response**: `{"success": true}`

### 2.5. Holiday Management
*   `GET /api/holidays`
    *   **Description**: Retrieves a list of holidays for the organization.
    *   **Access**: Org Admin (all holidays), Team Admin (view only)
    *   **Response**: `{"holidays": [...]}`
*   `POST /api/holidays`
    *   **Description**: Creates a new holiday.
    *   **Access**: Org Admin
    *   **Request Body**: `{"name": "...", "date": "YYYY-MM-DD", "description": "...", "assignment_type": "organization"|"teams", "team_ids": [...]}`
    *   **Response**: `{"success": true, "holidayId": ...}`
*   `PUT /api/holidays/:id`
    *   **Description**: Updates a holiday's details.
    *   **Access**: Org Admin
    *   **Request Body**: `{"name": "...", "date": "YYYY-MM-DD", "description": "...", "assignment_type": "organization"|"teams", "team_ids": [...]}`
    *   **Response**: `{"success": true}`
*   `DELETE /api/holidays/:id`
    *   **Description**: Deletes a holiday.
    *   **Access**: Org Admin
    *   **Response**: `{"success": true}`

### 2.6. Leave Request Management
*   `GET /api/admin/leave-requests`
    *   **Description**: Retrieves a list of leave requests.
    *   **Access**: Org Admin (all requests), Team Admin (only requests from their team members)
    *   **Query Params**: `status=pending|approved|rejected|all`, `startDate=YYYY-MM-DD`, `endDate=YYYY-MM-DD`
    *   **Response**: `{"leaveRequests": [...]}`
*   `PUT /api/admin/leave-requests/:id/approve`
    *   **Description**: Approves a specific leave request.
    *   **Access**: Org Admin (any request), Team Admin (only requests from their team members)
    *   **Request Body**: `{"comment": "..."}` (optional)
    *   **Response**: `{"success": true}`
*   `PUT /api/admin/leave-requests/:id/reject`
    *   **Description**: Rejects a specific leave request.
    *   **Access**: Org Admin (any request), Team Admin (only requests from their team members)
    *   **Request Body**: `{"comment": "..."}` (optional)
    *   **Response**: `{"success": true}`

### 2.7. Dashboard & Reports
*   `GET /api/admin/dashboard/users`
    *   **Description**: Retrieves live user status and location data for the dashboard.
    *   **Access**: Org Admin (all users), Team Admin (only users in their team(s))
    *   **Response**: `{"users": [...]}`
*   `GET /api/admin/dashboard/stats`
    *   **Description**: Retrieves summary statistics for the dashboard.
    *   **Access**: Org Admin (org-wide stats), Team Admin (only stats from their team(s))
    *   **Response**: `{"stats": {"usersIn": ..., "totalDistance": ..., ...}}`
*   `GET /api/admin/dashboard/activity`
    *   **Description**: Retrieves recent check-in/check-out activities.
    *   **Access**: Org Admin (all activity), Team Admin (only activity from their team members)
    *   **Response**: `{"activities": [...]}`
*   `GET /api/reports/user-timeline`
    *   **Description**: Generates a detailed activity timeline for a single user on a specific date.
    *   **Access**: Org Admin (any user), Team Admin (only users in their team(s))
    *   **Query Params**: `user_id=...`, `date=YYYY-MM-DD`
    *   **Response**: `{"attendanceDays": [...], "userTimeline": {...}, ...}`
*   `GET /api/reports/attendance-summary`
    *   **Description**: Generates an attendance summary report.
    *   **Access**: Org Admin (any user/team), Team Admin (only users/teams they manage)
    *   **Query Params**: `user_id=...` (optional), `team_id=...` (optional), `start_date=YYYY-MM-DD`, `end_date=YYYY-MM-DD`
    *   **Response**: `{"attendanceDays": [...], "totalWorkingHours": ..., ...}`
*   `GET /api/reports/team-summary`
    *   **Description**: Generates a summary report for a specific team.
    *   **Access**: Org Admin (any team), Team Admin (only their team(s))
    *   **Query Params**: `team_id=...`, `start_date=YYYY-MM-DD`, `end_date=YYYY-MM-DD`
    *   **Response**: `{"attendanceDays": [...], "totalWorkingHours": ..., ...}`

### 2.8. Organization Settings
*   `GET /api/organization/settings`
    *   **Description**: Retrieves organization-wide settings.
    *   **Access**: Org Admin
    *   **Response**: `{"settings": {"locationInterval": ..., "minDwellMins": ..., ...}}`
*   `PUT /api/organization/settings`
    *   **Description**: Updates organization-wide settings.
    *   **Access**: Org Admin
    *   **Request Body**: `{"settings": {"locationInterval": ..., "minDwellMins": ..., ...}}`
    *   **Response**: `{"success": true}`

## 3. Employee Portal APIs

### 3.1. Profile & Settings
*   `GET /api/users/profile`
    *   **Description**: Retrieves the current user's detailed profile.
    *   **Access**: Authenticated User
    *   **Response**: `{"profile": {"name": "...", "email": "...", "phone": "...", ...}, "settings": {"notifications": {...}}}`
*   `PUT /api/users/profile`
    *   **Description**: Updates the current user's profile details (e.g., phone, avatar).
    *   **Access**: Authenticated User
    *   **Request Body**: `{"phone": "...", "avatarUrl": "..."}`
    *   **Response**: `{"success": true}`
*   `PUT /api/users/settings`
    *   **Description**: Updates the current user's personal settings (e.g., notification preferences).
    *   **Access**: Authenticated User
    *   **Request Body**: `{"notifications": {"taskReminders": true/false, ...}}`
    *   **Response**: `{"success": true}`

### 3.2. Attendance
*   `GET /api/attendance/status`
    *   **Description**: Retrieves the current day's attendance status for the user.
    *   **Access**: Authenticated User
    *   **Response**: `{"status": "present"|"absent", "isCheckedIn": true/false, "checkInTime": "...", "totalWorkingHours": ..., "totalDistanceM": ..., ...}`
*   `POST /api/attendance/check-in`
    *   **Description**: Records a user's check-in.
    *   **Access**: Authenticated User
    *   **Request Body**: `{"latitude": ..., "longitude": ..., "accuracy": ...}`
    *   **Response**: `{"success": true, "message": "...", "checkInTime": "...", "sessionId": ..., "attendanceDayId": ...}`
*   `POST /api/attendance/check-out`
    *   **Description**: Records a user's check-out.
    *   **Access**: Authenticated User (must be currently checked in)
    *   **Request Body**: `{"latitude": ..., "longitude": ..., "accuracy": ...}`
    *   **Response**: `{"success": true, "message": "...", "checkOutTime": "...", "totalWorkingHours": ..., "sessionWorkingHours": ...}`
*   `POST /api/attendance/ping`
    *   **Description**: Records a location ping for an actively checked-in user.
    *   **Access**: Authenticated User (must be currently checked in)
    *   **Request Body**: `{"latitude": ..., "longitude": ..., "accuracy": ..., "batteryLevel": ..., "isMockLocation": false}`
    *   **Response**: `{"success": true}`
*   `GET /api/attendance/calendar`
    *   **Description**: Retrieves attendance data for a user for a specific month/year.
    *   **Access**: Authenticated User
    *   **Query Params**: `year=YYYY`, `month=MM`
    *   **Response**: `{"attendanceData": {"YYYY-MM-DD": "status", ...}}`
*   `GET /api/my-day`
    *   **Description**: Retrieves detailed timeline data and summary for a specific day.
    *   **Access**: Authenticated User
    *   **Query Params**: `date=YYYY-MM-DD`
    *   **Response**: `{"timeline": {...}, "summary": {...}}`
*   `GET /api/my-day/export`
    *   **Description**: Exports detailed timeline data for a specific day as CSV.
    *   **Access**: Authenticated User
    *   **Query Params**: `date=YYYY-MM-DD`
    *   **Response**: CSV file download.
*   `POST /api/attendance/override-request`
    *   **Description**: Submits an attendance override request.
    *   **Access**: Authenticated User
    *   **Request Body**: `{"date": "YYYY-MM-DD", "currentStatus": "...", "requestedStatus": "...", "reason": "..."}`
    *   **Response**: `{"success": true, "message": "..."}`

### 3.3. Tasks
*   `GET /api/tasks`
    *   **Description**: Retrieves all tasks assigned to the current user.
    *   **Access**: Authenticated User
    *   **Response**: `{"tasks": [...]}`
*   `POST /api/tasks`
    *   **Description**: Creates a new task (or subtask).
    *   **Access**: Authenticated User
    *   **Request Body**: `{"title": "...", "description": "...", "priority": "...", "due_date": "...", "parent_task_id": ...}`
    *   **Response**: `{"success": true, "task": {...}}`
*   `PUT /api/tasks/:id/status`
    *   **Description**: Updates the status of a specific task.
    *   **Access**: Authenticated User (must be assigned to the task)
    *   **Request Body**: `{"status": "pending"|"in_progress"|"completed"|"cancelled"}`
    *   **Response**: `{"success": true, "data": {"completed_at": "...", "updated_at": "..."}}`

### 3.4. Leave Requests
*   `GET /api/leave-requests`
    *   **Description**: Retrieves all leave requests submitted by the current user.
    *   **Access**: Authenticated User
    *   **Response**: `{"leaveRequests": [...]}`
*   `POST /api/leave-requests`
    *   **Description**: Submits a new leave request.
    *   **Access**: Authenticated User
    *   **Request Body**: `{"start_date": "YYYY-MM-DD", "end_date": "YYYY-MM-DD", "reason": "..."}`
    *   **Response**: `{"success": true, "leaveRequestId": ...}`

### 3.5. Notifications
*   `GET /api/notifications`
    *   **Description**: Retrieves notifications for the current user.
    *   **Access**: Authenticated User
    *   **Response**: `{"notifications": [...]}`
*   `PUT /api/notifications/:id/read`
    *   **Description**: Marks a specific notification as read.
    *   **Access**: Authenticated User (must own the notification)
    *   **Response**: `{"success": true}`

## 4. AI Chat Assistant APIs

### `POST /api/chat`
*   **Description**: Endpoint for communicating with the AI chat assistant.
*   **Access**: Authenticated User (both Admin and Employee portals)
*   **Request Body**: `{"message": "User's query", "action": "confirm"|"cancel", "toolCall": {...}}`
*   **Response**: `{"type": "assistant"|"confirmation"|"success"|"error"|"info", "message": "...", "toolCall": {...}, "details": {...}}`
