import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:everyday_christian/features/auth/services/auth_service.dart';
import 'package:everyday_christian/features/auth/services/secure_storage_service.dart';
import 'package:everyday_christian/features/auth/services/biometric_service.dart';
import 'package:everyday_christian/features/auth/models/user_model.dart';
import 'package:everyday_christian/core/database/database_helper.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([SecureStorageService, BiometricService, DatabaseHelper])
void main() {
  late MockSecureStorageService mockSecureStorage;
  late MockBiometricService mockBiometric;
  late MockDatabaseHelper mockDatabase;
  late AuthService authService;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    mockBiometric = MockBiometricService();
    mockDatabase = MockDatabaseHelper();
    authService = AuthService(mockSecureStorage, mockBiometric, mockDatabase);
  });

  group('AuthService Initialization', () {
    test('should initialize with unauthenticated state when no user data', () async {
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => null);

      await authService.initialize();

      bool isUnauthenticated = false;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () => isUnauthenticated = true,
        error: (_) {},
      );
      expect(isUnauthenticated, isTrue);
    });

    test('should initialize with authenticated state when user data exists', () async {
      final userData = {
        'id': '123',
        'email': 'test@example.com',
        'date_joined': DateTime.now().millisecondsSinceEpoch,
      };
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);

      await authService.initialize();

      User? authenticatedUser;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (user) => authenticatedUser = user,
        unauthenticated: () {},
        error: (_) {},
      );
      expect(authenticatedUser, isNotNull);
      expect(authenticatedUser!.email, equals('test@example.com'));
    });

    test('should handle initialization error', () async {
      when(mockSecureStorage.getUserData())
          .thenThrow(const SecureStorageException('Storage error'));

      await authService.initialize();

      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, isNotNull);
      expect(errorMessage, contains('Failed to initialize'));
    });
  });

  group('AuthService Sign Up', () {
    test('should successfully sign up new user', () async {
      when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);
      when(mockSecureStorage.storeUserCredentials(any, any))
          .thenAnswer((_) async {});
      when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {});

      final result = await authService.signUp(
        email: 'newuser@example.com',
        password: 'password123',
        name: 'New User',
      );

      expect(result, isTrue);
      verify(mockSecureStorage.storeUserCredentials('newuser@example.com', any))
          .called(1);
      verify(mockSecureStorage.storeUserData(any)).called(1);
    });

    test('should reject invalid email', () async {
      final result = await authService.signUp(
        email: 'invalid-email',
        password: 'password123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('valid email'));
    });

    test('should reject short password', () async {
      final result = await authService.signUp(
        email: 'test@example.com',
        password: '12345',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('6 characters'));
    });

    test('should reject duplicate email', () async {
      final existingUser = {'email': 'test@example.com'};
      when(mockSecureStorage.getUserByEmail('test@example.com'))
          .thenAnswer((_) async => existingUser);

      final result = await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('already exists'));
    });
  });

  group('AuthService Sign In', () {
    test('should successfully sign in with valid credentials', () async {
      // Calculate the expected hash for 'password123' using the same algorithm
      final password = 'password123';
      const salt = 'everyday_christian_salt_2024';
      final bytes = utf8.encode(password + salt);
      final expectedHash = sha256.convert(bytes).toString();

      final userData = {
        'id': '123',
        'email': 'test@example.com',
        'date_joined': DateTime.now().millisecondsSinceEpoch,
      };
      when(mockSecureStorage.getUserByEmail('test@example.com'))
          .thenAnswer((_) async => userData);
      when(mockSecureStorage.getStoredPassword('test@example.com'))
          .thenAnswer((_) async => expectedHash);
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      User? authenticatedUser;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (user) => authenticatedUser = user,
        unauthenticated: () {},
        error: (_) {},
      );
      expect(authenticatedUser, isNotNull);
    });

    test('should reject sign in with non-existent user', () async {
      when(mockSecureStorage.getStoredPassword('test@example.com'))
          .thenAnswer((_) async => null);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
    });

    test('should handle biometric sign in when supported', () async {
      final userData = {
        'id': '123',
        'email': 'test@example.com',
        'date_joined': DateTime.now().millisecondsSinceEpoch,
      };
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => true);
      when(mockBiometric.authenticate()).thenAnswer((_) async => true);
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);
      when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {});

      final result = await authService.signIn(
        email: 'test@example.com',
        password: '',
        useBiometric: true,
      );

      expect(result, isTrue);
      verify(mockBiometric.authenticate()).called(1);
    });
  });

  group('AuthService Sign Out', () {
    test('should successfully sign out', () async {
      when(mockSecureStorage.clearUserData()).thenAnswer((_) async {});

      await authService.signOut();

      bool isUnauthenticated = false;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () => isUnauthenticated = true,
        error: (_) {},
      );
      expect(isUnauthenticated, isTrue);
      verify(mockSecureStorage.clearUserData()).called(1);
    });

    test('should handle sign out error', () async {
      when(mockSecureStorage.clearUserData())
          .thenThrow(const SecureStorageException('Clear error'));

      await authService.signOut();

      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, isNotNull);
    });
  });

  group('AuthService Delete Account', () {
    test('should delete account successfully', () async {
      final currentUser = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: DateTime.now(),
      );
      authService.state = AuthState.authenticated(currentUser);

      when(mockSecureStorage.clearAllData()).thenAnswer((_) async {});
      when(mockDatabase.deleteOldChatMessages(0)).thenAnswer((_) async => 1);

      final result = await authService.deleteAccount();

      expect(result, isTrue);
      bool isUnauthenticated = false;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () => isUnauthenticated = true,
        error: (_) {},
      );
      expect(isUnauthenticated, isTrue);
      verify(mockSecureStorage.clearAllData()).called(1);
      verify(mockDatabase.deleteOldChatMessages(0)).called(1);
    });
  });

  group('AuthService Continue as Guest', () {
    test('should continue as guest', () async {
      await authService.continueAsGuest();

      User? guestUser;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (user) => guestUser = user,
        unauthenticated: () {},
        error: (_) {},
      );
      expect(guestUser, isNotNull);
      expect(guestUser!.isAnonymous, isTrue);
    });
  });

  group('AuthService Biometric Authentication', () {
    test('should enable biometric authentication', () async {
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => true);
      when(mockBiometric.authenticate()).thenAnswer((_) async => true);
      when(mockDatabase.setSetting('biometric_enabled', true))
          .thenAnswer((_) async {});

      final result = await authService.enableBiometric();

      expect(result, isTrue);
      verify(mockDatabase.setSetting('biometric_enabled', true)).called(1);
    });

    test('should disable biometric authentication', () async {
      when(mockDatabase.setSetting('biometric_enabled', false))
          .thenAnswer((_) async {});

      await authService.disableBiometric();

      verify(mockDatabase.setSetting('biometric_enabled', false)).called(1);
    });

    test('should check if biometric is enabled', () async {
      when(mockDatabase.getSetting<bool>('biometric_enabled',
              defaultValue: anyNamed('defaultValue')))
          .thenAnswer((_) async => true);

      final result = await authService.isBiometricEnabled();

      expect(result, isTrue);
    });
  });

  group('AuthService Update Profile', () {
    test('should update user profile successfully', () async {
      final updatedUser = User(
        id: '123',
        email: 'test@example.com',
        name: 'Updated Name',
        dateJoined: DateTime.now(),
      );

      when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {});

      final result = await authService.updateUserProfile(updatedUser);

      expect(result, isTrue);
      verify(mockSecureStorage.storeUserData(any)).called(1);
    });
  });
}
