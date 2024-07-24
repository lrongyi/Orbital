import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ss/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' as mockito;

class MockFirebaseAuth extends Mock implements FirebaseAuth{}
class MockUser extends Mock implements User{}
class MockUserCredential extends Mock implements UserCredential{}

//needs fixing

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

      // Mocking Google Sign-In flow
      final credential = GoogleAuthProvider.credential(idToken: 'idToken', accessToken: 'accessToken');
      when(mockFirebaseAuth.signInWithCredential(credential)).thenAnswer((_) async => mockUserCredential);

      // Call the method to be tested
      await authMethods.signInWithGoogle(MockBuildContext());

      // Verify the interactions and assertions
      verify(mockFirebaseAuth.signInWithCredential(credential)).called(1);
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

      await authMethods.login(MockBuildContext(), 'test@example.com', 'password');

      verify(mockFirebaseAuth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password')).called(1);
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
    });

    test('Reset Password', () async {
      await authMethods.resetPassword(MockBuildContext(), 'test@example.com');

      verify(mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com')).called(1);
    });

    test('Sign Out', () async {
      await authMethods.signOut(MockBuildContext());

      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });
}

// Mock BuildContext class to use in the tests
class MockBuildContext extends Mock implements BuildContext {}
