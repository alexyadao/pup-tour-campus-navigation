# PUP Tour — Interactive Campus Navigation System

[![Flutter Web](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Database%20%26%20RLS-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Vercel Deployment](https://img.shields.io/badge/Vercel-Live%20Production-black?logo=vercel&logoColor=white)](https://pup-tour-campus-navigation.vercel.app)
[![CI/CD Keep-Alive](https://img.shields.io/badge/GitHub%20Actions-Cron%20Automated-2088FF?logo=github-actions&logoColor=white)](https://github.com/alexyadao/pup-tour-campus-navigation/actions)

An interactive campus navigation and digital tour web application designed for the Polytechnic University of the Philippines (PUP) Main Campus. Built with Flutter Web, backed by Supabase PostgreSQL, and deployed via Vercel Edge Network.

---

## 🌐 Live Production Demo

- **Production URL:** [https://pup-tour-campus-navigation.vercel.app](https://pup-tour-campus-navigation.vercel.app)
- **Target Platform:** Progressive Web Application (PWA) / Responsive Desktop & Mobile Web

---

## ✨ Key Features

- **Interactive Campus Directory:** Browse notable university landmarks and buildings (Main Building, Charlie Del Rosario Building, Library) with operational hours and historical details.
- **Campus Events Feed:** Real-time query integration fetching verified university events with date tags, descriptions, and location mapping.
- **Role-Based Access Control:** Configured with public guest access alongside authenticated role segregation using Supabase Row-Level Security (RLS).
- **Responsive UI Architecture:** Custom dark maroon university color scheme (`RGB 136, 0, 21`) optimized with glassmorphic cards and dynamic mobile drawer navigation.

---

## 🛠️ Tech Stack & System Architecture

| Layer | Technology | Details |
| :--- | :--- | :--- |
| **Frontend Framework** | Flutter 3.x (Dart) | Compiles to single-page WebAssembly / JavaScript bundle |
| **Backend / Database** | Supabase (PostgreSQL) | Managed database, REST API engine, and Row-Level Security policies |
| **Hosting & Edge Delivery**| Vercel | Global CDN edge caching and static bundle distribution |
| **Automation & CI/CD** | GitHub Actions | Automated keep-alive cron pipeline preventing free-tier dormancy |

---

## 🚀 Getting Started Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.24+ recommended)
- [Google Chrome](https://www.google.com/chrome/) for local web debugging
- Git

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/alexyadao/pup-tour-campus-navigation.git](https://github.com/alexyadao/pup-tour-campus-navigation.git)
   cd pup-tour-campus-navigation
