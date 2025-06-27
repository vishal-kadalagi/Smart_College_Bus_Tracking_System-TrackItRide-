# 🚌 Smart College Bus Tracking System 🚀

> Real-Time Location, Seamless Commute – Built for Students, Drivers, and Admins

## 🌟 Overview

The **Smart College Bus Tracking System** revolutionizes how students interact with college transportation. Built using **Flutter** and **Firebase**, it provides **real-time GPS tracking**, **route management**, and **admin controls** — all from the palm of your hand.

📍 **Track your bus live**  
📆 **See schedules and routes in real-time**  
📊 **Admin dashboard for smarter route planning**  

> No more waiting endlessly. Know where your bus is. Anytime. Anywhere.

---

## 🔧 Tech Stack

| Component        | Technology Used              |
|------------------|------------------------------|
| Frontend         | Flutter                      |
| Backend          | Firebase Realtime Database, Cloud Firestore |
| Authentication   | Firebase Auth                |
| Location Tracking| Google Maps API, Geolocation API |
| APIs             | REST API, WebSockets, GeoFencing API |

---

## 🏗️ System Architecture

```mermaid
graph TD
    A[Student App (Flutter)] --> B[Firebase]
    C[Driver App (Flutter)] --> B
    D[Admin Dashboard (Web)] --> B
    B --> E[Google Maps API]
