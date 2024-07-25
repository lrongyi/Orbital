import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ss/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

// Unable to work 'PlatformException'

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Ensure Firebase is initialized before tests run
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['API_KEY']!,
        appId: dotenv.env['APP_ID']!, 
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!, 
        projectId: dotenv.env['PROJECT_ID']!,
      )
    );
  });

  late MockFirebaseAuth mockFirebaseAuth;
  late AuthMethods authMethods;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authMethods = AuthMethods();
    authMethods.auth = mockFirebaseAuth; // Replace the FirebaseAuth instance with the mock
  });

  group('AuthMethods', () {
    test('Sign in with Google', () async {
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential();

      when(mockUser.uid).thenReturn('123');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUserCredential.user).thenReturn(mockUser);

      final credential = GoogleAuthProvider.credential(idToken: 'idToken', accessToken: 'accessToken');
      when(mockFirebaseAuth.signInWithCredential(credential)).thenAnswer((_) async => mockUserCredential);

      await authMethods.signInWithGoogle(MockBuildContext());

      verify(mockFirebaseAuth.signInWithCredential(credential)).called(1);

      final currentUser = mockFirebaseAuth.currentUser;
      expect(currentUser, mockUser);
    });

    test('Login', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockUserCredential.user).thenReturn(mockUser);

      const testEmail = 'test@example.com';
      const testPassword = 'password';

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      await authMethods.login(MockBuildContext(), testEmail, testPassword);

      verify(mockFirebaseAuth.signInWithEmailAndPassword(email: testEmail, password: testPassword)).called(1);

      final currentUser = mockFirebaseAuth.currentUser;
      expect(currentUser, mockUser);
    });

    test('Registration', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockUserCredential.user).thenReturn(mockUser);

      const testEmail = 'test@example.com';
      const testPassword = 'password';
      const testName = 'Test User';

      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      await authMethods.registration(MockBuildContext(), testName, testEmail, testPassword);

      verify(mockFirebaseAuth.createUserWithEmailAndPassword(email: testEmail, password: testPassword)).called(1);

      final currentUser = mockFirebaseAuth.currentUser;
      expect(currentUser, mockUser);
    });

    test('Reset Password', () async {
      const testEmail = 'test@example.com';

      await authMethods.resetPassword(MockBuildContext(), testEmail);

      verify(mockFirebaseAuth.sendPasswordResetEmail(email: testEmail)).called(1);
    });

    test('Sign Out', () async {
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential();

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      )).thenAnswer((_) async => mockUserCredential);

      await authMethods.login(MockBuildContext(), 'test@example.com', 'password');

      final currentUser = mockFirebaseAuth.currentUser;
      expect(currentUser, mockUser);

      await authMethods.signOut(MockBuildContext());

      verify(mockFirebaseAuth.signOut()).called(1);

      final signedOutUser = mockFirebaseAuth.currentUser;
      expect(signedOutUser, isNull);
    });
  });
}

// Mock BuildContext class to use in the tests
class MockBuildContext extends Mock implements BuildContext {}
