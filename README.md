# product-crud-app

This project implements a complete CRUD (Create, Read, Update, Delete) system for managing products, featuring a Node.js Express API backend and a Flutter frontend.

#  Objective
he primary goal is to demonstrate a full-stack application using:
-  SQL Server as the database.
-  Express.js (Node.js) as the REST API backend.
-  Flutter with Provider for state management as the mobile frontend.

#  Technologies Used
-  Backend: Node.js, Express.js, mssql (for SQL Server connectivity), cors, dotenv.
-  Database: SQL Server.
-  Frontend: Flutter, Provider (for state management and API calls), http, rxdart (for debouncing search).

#  Database Structure
-The application uses a PRODUCTS table in SQL Server with the following schema:

![image](https://github.com/user-attachments/assets/1b5cb9f9-2886-49fc-94d2-1fdfa27e5f3d)

![image](https://github.com/user-attachments/assets/c724583a-59a2-4a6e-b772-f0ea987cc0c4)
![image](https://github.com/user-attachments/assets/b152f7e0-7799-4e8a-8c2e-7999df2555d0)

#  Backend API Endpoints
The Express.js backend provides the following RESTful API endpoints:

![image](https://github.com/user-attachments/assets/ca8909d4-50ff-42b1-9ccd-3ef22ac9e5ab)

#  Setup & Run Instructions

## 1. Backend Setup (Node.js + Express + SQL Server)
Prerequisites:

-  Node.js (LTS version recommended) and npm installed.
-  SQL Server instance (e.g., SQL Server Express, Developer Edition) installed and running.
-  SQL Server Management Studio (SSMS) or Azure Data Studio for database management.

###  Configure Database Credentials:

-  Locate the .env.example file in the backend directory.
-  Rename this file to .env (important: no .example extension).
-  Open the newly created .env file and fill in your actual SQL Server connection details.

![image](https://github.com/user-attachments/assets/e37a865f-71b4-4666-9cea-8f821c1d4cae)
###  Start the Backend Server:

- Command : npm server.js
  ![image](https://github.com/user-attachments/assets/fbab0b9f-2680-4f0a-8ce8-fc0127f8012b)
-  after test can test data in Chrome,Browser...and postman
- link: http://localhost:3000/api/products
![image](https://github.com/user-attachments/assets/bbf4ca21-e1e7-4eb9-8fdc-6de39a9fe757)
![image](https://github.com/user-attachments/assets/c316eb32-7814-42d9-ad2c-e6f62c79fdbf)

##  2. Frontend Setup (Flutter App)
for dependencies have : http,provider,rxdart
![image](https://github.com/user-attachments/assets/686cc71f-12d7-4e8b-93a4-c065bd976976)

  1.  Navigate to the frontend directory
    - command : cd frontend
  2.  Install Flutter dependencies:
    - command : flutter pub get
  3.  Configure API Base URL:
    -Open frontend/lib/providers/product_provider.dart.
    -Update the _baseUrl constant based on your testing environment:
    -For Android Emulator: static const String _baseUrl = 'http://10.0.2.2:3000/api/products';
    -For iOS Simulator: static const String _baseUrl = 'http://localhost:3000/api/products';
    -For Real Android/iOS Device: You must use your development machine's actual local IP address (e.g., http://192.168.1.100:3000/api/products). Ensure your device and computer are on the same Wi-Fi network.
  4.  Run the Flutter Application:
     -  command :flutter run


#  app
![image](https://github.com/user-attachments/assets/184421ca-d2ff-49be-8be1-1cf4d2709e8d)

![image](https://github.com/user-attachments/assets/bdd974c5-0fa3-4788-b74b-24e7560b725a)

![image](https://github.com/user-attachments/assets/6bb47bf2-61b1-41eb-8c4a-b30c13c1031b)

![image](https://github.com/user-attachments/assets/8e70288b-bbc0-45c2-bc29-00c219caa7f0)














