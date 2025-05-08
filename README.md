# Cynk

Cynk is a real-time communication application designed for quick and easy messaging. It supports standard text messages and image sharing.
(PL: Żeby dawać sobie cynka)

## Key Features
*   **User Authentication:** Register and log in using email/password or Google Sign-In.
*   **Profile Management:**
    *   View and update your profile picture and display name.
    *   View other users' profiles.
*   **Contact Management:**
    *   Add new contacts by their email address.
    *   View a sorted list of contacts.
    *   Search through contacts.
    *   Remove contacts.
*   **Real-time Chat:**
    *   Engage in one-on-one chats with your contacts.
    *   View chat history, with older messages loaded on scroll (lazy loading).
    *   Send multi-line text messages.
    *   Send and receive images within chats.
    *   See when a user was "last seen" in the app.
*   **Image Handling:**
    *   Upload profile pictures.
    *   Send images in chats.
    *   Download/view images from chat.
*   **Offline Support:** Access to data even when offline.
*   **Internationalization:** Support for changing the application language.

![image](https://github.com/user-attachments/assets/85904ab6-4c65-4f69-834e-8b8a5b4cd881)
![image](https://github.com/user-attachments/assets/9d37bdb5-a862-4d8e-8ac1-9a0ba21b4ab9)
![3138141a-5408-4624-b117-0b88c361ed54](https://github.com/user-attachments/assets/6ea42818-5dbb-4e7d-b6b2-f9ddb6c26754)


## Technologies Used
*   **Firebase Authentication:** For user sign-up, login (email/password, Google).
*   **Firestore Database:** For storing user data (username, profile picture, last seen, contacts) and chat data (messages, participants).
*   **Firebase Storage:** For storing profile pictures and images sent in chats.

## Supported Platforms
*   Android
*   Web

## Firestore Database Schema
*   User data, contacts: `/users/:id/` (includes contacts subcollection)
*   Chat data: `/chats/:id/`
    *   Chat IDs are generated as `{userId1}-{userId2}` (lexicographically smaller ID first).
    *   Chats include a `members` array with participant IDs.
    *   Designed with future support for group chats in mind (type "group" and more members).
*   Messages within a chat: `/chats/:id/messages/:id/`
*   **Indexes:** An index on `lastMessage.date` and an array index on `members` are required for chat querying.
