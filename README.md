<!-- ├── users (collection)
│   └── <userId> (document)
│       ├── name
│       ├── email
│       ├── joinedQuizzes: [quizId, quizId]
│       └── attempts (subcollection)
│           └── <quizId> (document)
│               ├── score
│               ├── timestamp
│               └── answers: [{qId: ..., selected: ..., correct: ...}]
│
├── admins (collection)
│   └── <adminId> (document)
│       ├── name
│       ├── email
│       └── createdQuizzes: [quizId, quizId]
│
├── quizzes (collection)
│   └── <quizId> (document)
│       ├── title
│       ├── subject
│       ├── date
│       ├── createdBy (adminId)
│       ├── maxMarks
│       ├── accessCode
│       ├── link
│       ├── qrUrl (optional)
│       ├── timeLimit
│       └── questions (subcollection)
│           └── <questionId> (document)
│               ├── question
│               ├── options: [A, B, C, D]
│               ├── correctAnswer
│               ├── imageUrl (optional)
│
│       └── results (subcollection)
│           └── <userId> (document)
│               ├── name
│               ├── email
│               ├── score
│               ├── timestamp
│               └── answers: [{qId, selectedAns, correctAns}]
│
├── default_quizzes (collection)
│   └── <quizId> (document)
│       ├── subject
│       ├── title
│       ├── description
│       └── questions (subcollection)
│           └── <questionId> -->


lib/
│
├── main.dart
├── firebase_options.dart
│
├── models/
│   ├── user_model.dart            // User data model (role, name, email, etc.)
│   ├── quiz_model.dart            // Quiz info (title, subject, code, deadline, etc.)
│   ├── question_model.dart        // Question structure
│   ├── result_model.dart          // Stores user's result for a quiz
│
├── services/
│   ├── auth_service.dart          // Firebase Auth logic (login, signup, role check)
│   ├── quiz_service.dart          // Create, fetch, manage quizzes
│   ├── result_service.dart        // Store and fetch quiz results
│   ├── qr_service.dart            // Generate QR codes for quiz codes
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── splash_screen.dart
│   │
│   ├── admin/
│   │   ├── admin_dashboard.dart       // Admin home
│   │   ├── create_quiz_screen.dart    // Enter subject, points, deadline
│   │   ├── manage_quizzes_screen.dart // List of admin's quizzes to edit/delete
│   │   ├── quiz_report_screen.dart    // Results for each quiz
│   │
│   ├── user/
│   │   ├── user_dashboard.dart        // User home
│   │   ├── join_quiz_screen.dart      // Enter code or scan QR
│   │   ├── quiz_history_screen.dart   // List of past quizzes attended
│   │
│   ├── quiz/
│   │   ├── quiz_play_screen.dart      // Attempt quiz
│   │   ├── result_screen.dart         // Show result after quiz
│
│   ├── settings/
│   │   ├── settings_screen.dart
│
├── widgets/
│   ├── custom_button.dart
│   ├── quiz_card.dart
│   ├── result_card.dart
│
└── utils/
    ├── constants.dart
    ├── helpers.dart
