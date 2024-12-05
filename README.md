# COMP-49X-24-25-PhoneArt-intro-project

## Project Description

The PhoneArt Discussion App is a simple iOS discussion platform that enables registered users to create posts and engage with other users through comments. Users can create their own posts and comment on posts made by others, fostering an interactive community environment.

## Technologies Used

This application was developed using:
- Swift & SwiftUI - For building the native iOS application interface and logic
- Firebase - Backend database solution for storing and managing user posts and comments
- Xcode - Primary IDE for development, chosen for its seamless integration with Swift
- MVC (Model-View-Controller) Architecture - For organized and maintainable code structure

## Features

- User authentication (Test profiles created for this demonstration as there is no registration feature)
- Create posts (Only for logged in users)
- Comment on posts (Only for logged in users)
- View posts and comments (All users)
- Delete posts and comments (Only for the admin user)

## Installation

1. Clone the repository
2. Open the project in Xcode (This project was built using Version 16.1)
3. In addition to the dependencies already installed on your machine, you will need to install the Firebase SDK
    - You can do this by going to the 'File' menu and selecting 'Add Package Dependencies'
    - Search 'firebase-ios-sdk.' if this is not already installed, please install the available version.
4. Build and run the application

## Usage

1. You may login using either the test user, or the admin user. Their respective credentials are as follows:
    - Test User: Email: test@example.com Password: password123
    - Admin User: Email: admin@example.com Password: admin123
2. Upon logging in, you will be redirected to the main feed screen. From here you can navigate to the create post screen, or view posts made by other users.
3. If you would like to comment on a post, you may do so by clicking on the 'Comments' button, which will take you to the comments section for the chosen post
4. Similar to the post screen, the comments section allows the logged in user to create a comment, as well as view comments made by other users.
5. Please note that only the admin user is able to delete posts and comments.

## Contributors

Aditya Prakash, Zachary Letcher, Emmett de Bruin, and Noah Huang.
