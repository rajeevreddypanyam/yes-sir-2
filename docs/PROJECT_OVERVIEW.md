# YES SIR Project Overview

## 🌟 Vision
"YES SIR" is a comprehensive web application designed to streamline employee management by integrating attendance tracking, geofencing, task management, and AI-powered assistance. Its core vision is to provide a robust, intuitive, and efficient platform for organizations to manage their workforce effectively.

## ✨ Core Features

### Employee Portal
*   **Secure Authentication**: Email/password and Google OAuth login options.
*   **Real-time Attendance**: GPS-based check-in/check-out with location tracking.
*   **Geofence Monitoring**: Automatic notifications for location boundary crossings.
*   **Task Management**: Personal task dashboard with priority levels and due dates.
*   **My Day Timeline**: Detailed daily activity tracking with movement analysis.
*   **Attendance History**: Historical view with calendar interface and export options.
*   **AI Chat Assistant**: Intelligent assistant for leave requests and queries.
*   **User Settings**: Profile management and notification preferences.

### Admin Portal
*   **Organization Management**: Complete setup and configuration for new organizations.
*   **User Administration**: Create, edit, delete users with bulk operations.
*   **Team Management**: Organize employees into teams with location assignments.
*   **Location Management**: Define office locations and client sites.
*   **Geofence Control**: Create circular and polygon geofences for area monitoring.
*   **Holidays Management**: Define organization-wide or team-specific holidays.
*   **Leave Request Management**: Review, approve, or reject employee leave requests.
*   **Advanced Reports**: Detailed attendance reports and timeline analysis.
*   **AI Assistant**: Administrative tasks automation (user creation, leave approvals).
*   **System Settings**: Organization-wide configuration options.

## 🏗️ Technical Stack

### Frontend
*   **React 18**: For building dynamic user interfaces.
*   **TypeScript**: For type-safe development.
*   **Tailwind CSS**: For utility-first styling and responsive design.
*   **Vite**: For fast development and optimized builds.
*   **React Router**: For client-side routing.
*   **Lucide React**: For consistent iconography.

### Backend
*   **Hono**: A lightweight web framework for Cloudflare Workers.
*   **Cloudflare D1**: SQLite database for persistent storage.
*   **Cloudflare Workers**: Serverless compute for API endpoints.

### Authentication & APIs
*   **Mocha Users Service**: For OAuth and session management (Google OAuth supported).
*   **Google Maps Platform**: (Maps, Geocoding, Timezone APIs) for location-based features.
*   **OpenAI GPT-4**: For AI assistant functionality.
*   **ZeptoMail**: For transactional email delivery.

## 🚀 Deployment
The application is designed for optimized deployment on Cloudflare's edge network, leveraging Cloudflare Workers, D1, and Pages for a globally performant and scalable solution.

## 🔒 Security
Focuses on secure authentication (OAuth, bcrypt hashing), role-based access control, and data protection practices.
