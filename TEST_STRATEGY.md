# Test Strategy - Everyday Christian App

## Overview

This document outlines the comprehensive testing strategy for the Everyday Christian Flutter application, covering test types, methodologies, and best practices.

## Test Architecture

### Test Pyramid

```
                    /\
                   /  \
                  / E2E\
                 /------\
                /        \
               /Integration\
              /------------\
             /              \
            /  Widget Tests  \
           /------------------\
          /                    \
         /     Unit Tests       \
        /------------------------\
```

**Distribution**:
- 70% Unit Tests (Services, Models, Utilities)
- 20% Widget Tests (Screens, Components)
- 10% Integration Tests (User Flows)

## Test Types

### 1. Unit Tests

**Purpose**: Test individual functions, methods, and classes in isolation.

**Coverage Areas**:
- Service layer logic
- Model validation and serialization
- Utility functions
- Business logic

**Example**:
```dart
test('should save message to database', () async {
  final message = ChatMessage.user(content: 'Test', sessionId: 'session-1');
  await conversationService.saveMessage(message);

  final messages = await conversationService.getMessages('session-1');
  expect(messages.length, 1);
  expect(messages.first.content, 'Test');
});
```

**Best Practices**:
- One assertion per test (when possible)
- Clear test names describing behavior
- Use mocks for external dependencies
- Test both success and failure paths
- Cover edge cases and boundaries

### 2. Widget Tests

**Purpose**: Test UI components, screens, and user interactions.

**Coverage Areas**:
- Screen rendering
- Widget composition
- User interactions (taps, scrolls)
- State management
- Responsive design

**Example**:
```dart
testWidgets('should display greeting message', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(home: HomeScreen()),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.textContaining('Friend'), findsOneWidget);
});
```

**Best Practices**:
- Test user-visible behavior, not implementation
- Use `pumpAndSettle()` for animations
- Test different screen sizes
- Verify navigation behavior
- Check accessibility features

### 3. Integration Tests

**Purpose**: Test complete user workflows and feature interactions.

**Coverage Areas**:
- End-to-end user flows
- Multi-service interactions
- Data persistence
- Cross-feature integration
- Error recovery

**Example**:
```dart
test('should complete full conversation flow', () async {
  // 1. Create session
  final sessionId = await conversationService.createSession();

  // 2. Add messages
  await conversationService.saveMessage(userMessage);
  await conversationService.saveMessage(aiResponse);

  // 3. Verify history
  final messages = await conversationService.getMessages(sessionId);
  expect(messages.length, 2);

  // 4. Export conversation
  final export = await conversationService.exportConversation(sessionId);
  expect(export, contains('Conversation Export'));
});
```

**Best Practices**:
- Test realistic user scenarios
- Verify data consistency
- Test across service boundaries
- Include error scenarios
- Clean up test data

## Test Organization

### Directory Structure

```
test/
├── integration/          # Integration tests
│   └── user_flow_test.dart
├── screens/              # Screen widget tests
│   ├── home_screen_test.dart
│   └── chat_screen_test.dart
├── services/             # Service tests
│   ├── unified_verse_service_test.dart
│   └── ...
├── models/               # Model tests
│   ├── bible_verse_test.dart
│   └── ...
├── *_test.dart          # Root-level tests
└── README.md            # Test documentation
```

### Naming Conventions

**Test Files**: `{feature}_test.dart`
- `conversation_service_test.dart`
- `home_screen_test.dart`
- `user_flow_test.dart`

**Test Groups**: Describe the component/feature
```dart
group('ConversationService', () {
  group('Session Management', () {
    test('should create a new session', () {});
  });
});
```

**Test Names**: Should read like specifications
- ✅ "should save message to database"
- ✅ "should display error when network fails"
- ❌ "test save message"
- ❌ "error test"

## Testing Patterns

### 1. Arrange-Act-Assert (AAA)

```dart
test('should mark prayer as answered', () async {
  // Arrange
  final prayer = PrayerRequest(
    id: 'p1',
    title: 'Test Prayer',
    answered: false,
  );
  await prayerService.createPrayer(prayer);

  // Act
  await prayerService.markPrayerAnswered('p1');

  // Assert
  final prayers = await prayerService.getAnsweredPrayers();
  expect(prayers.first.answered, true);
});
```

### 2. Given-When-Then (BDD Style)

```dart
test('given active session, when saving message, then message count increases', () async {
  // Given
  final sessionId = await conversationService.createSession();

  // When
  await conversationService.saveMessage(
    ChatMessage.user(content: 'Test', sessionId: sessionId),
  );

  // Then
  final count = await conversationService.getMessageCount(sessionId);
  expect(count, 1);
});
```

### 3. Setup and Teardown

```dart
group('ConversationService', () {
  late ConversationService service;

  setUp(() async {
    service = ConversationService();
    await DatabaseHelper.instance.resetDatabase();
  });

  tearDown(() async {
    await DatabaseHelper.instance.resetDatabase();
  });

  test('should work correctly', () async {
    // Test implementation
  });
});
```

## Test Data Management

### Test Fixtures

Create reusable test data:

```dart
class TestFixtures {
  static ChatMessage createUserMessage({
    String content = 'Test message',
    String? sessionId,
  }) {
    return ChatMessage.user(
      content: content,
      sessionId: sessionId ?? 'test-session',
    );
  }

  static PrayerRequest createPrayer({
    String title = 'Test Prayer',
  }) {
    return PrayerRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: 'Test',
      createdAt: DateTime.now(),
      answered: false,
    );
  }
}
```

### Database Isolation

Each test should have a clean database state:

```dart
setUp(() async {
  await DatabaseHelper.instance.resetDatabase();
});

tearDown() async {
  await DatabaseHelper.instance.resetDatabase();
});
```

## Mocking Strategy

### When to Mock

- External APIs (weather, Bible APIs)
- Network calls
- File system operations
- System services (notifications, GPS)
- Time-dependent operations

### When NOT to Mock

- Database (use in-memory database)
- Business logic
- Data models
- Internal services (for integration tests)

### Mockito Example

```dart
@GenerateMocks([SecureStorage])
void main() {
  late MockSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockSecureStorage();
  });

  test('should save token securely', () async {
    when(mockStorage.write(key: 'token', value: 'abc123'))
        .thenAnswer((_) async => null);

    await authService.saveToken('abc123');

    verify(mockStorage.write(key: 'token', value: 'abc123')).called(1);
  });
}
```

## Edge Cases & Error Handling

### Test Edge Cases

1. **Empty Inputs**
```dart
test('should handle empty message content', () async {
  final message = ChatMessage.user(content: '', sessionId: 'session');
  await conversationService.saveMessage(message);

  final messages = await conversationService.getMessages('session');
  expect(messages.first.content, '');
});
```

2. **Boundary Values**
```dart
test('should handle very long content', () async {
  final longContent = 'A' * 10000;
  final message = ChatMessage.user(content: longContent, sessionId: 'session');
  await conversationService.saveMessage(message);

  final messages = await conversationService.getMessages('session');
  expect(messages.first.content.length, 10000);
});
```

3. **Null Values**
```dart
test('should handle null session ID gracefully', () async {
  final message = ChatMessage.user(content: 'Test');
  await conversationService.saveMessage(message);
  // Should not crash
});
```

4. **Special Characters**
```dart
test('should handle special characters', () async {
  final specialContent = "Test 'quotes\" \nNewlines\t\tTabs";
  final message = ChatMessage.user(content: specialContent, sessionId: 'session');
  await conversationService.saveMessage(message);

  final messages = await conversationService.getMessages('session');
  expect(messages.first.content, specialContent);
});
```

### Test Error Scenarios

```dart
test('should handle database errors gracefully', () async {
  final messages = await conversationService.getMessages('invalid-id');
  expect(messages, isEmpty);
});

test('should return error response on network failure', () async {
  // Mock network failure
  when(api.fetchData()).thenThrow(SocketException('No internet'));

  final result = await service.getData();
  expect(result.hasError, true);
});
```

## Concurrent Testing

Test race conditions and concurrent operations:

```dart
test('should handle concurrent message saves', () async {
  final sessionId = await conversationService.createSession();

  final futures = List.generate(
    10,
    (i) => conversationService.saveMessage(
      ChatMessage.user(content: 'Message $i', sessionId: sessionId),
    ),
  );

  await Future.wait(futures);

  final count = await conversationService.getMessageCount(sessionId);
  expect(count, 10);
});
```

## Performance Testing

Add performance assertions for critical operations:

```dart
test('should search messages within reasonable time', () async {
  // Add 1000 messages
  for (int i = 0; i < 1000; i++) {
    await conversationService.saveMessage(
      ChatMessage.user(content: 'Message $i', sessionId: 'session'),
    );
  }

  final stopwatch = Stopwatch()..start();
  final results = await conversationService.searchMessages('Message');
  stopwatch.stop();

  expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // < 1 second
});
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v2
        with:
          files: coverage/lcov.info
```

## Coverage Goals

### Target Coverage by Category

| Category | Target | Priority |
|----------|--------|----------|
| Services | 85%+ | High |
| Models | 90%+ | High |
| Business Logic | 90%+ | High |
| UI Widgets | 75%+ | Medium |
| Integration | 80%+ | High |
| Database | 85%+ | High |

### Measuring Coverage

```bash
# Generate coverage report
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html
```

### Coverage Metrics

- **Line Coverage**: % of executed lines
- **Branch Coverage**: % of executed branches
- **Function Coverage**: % of executed functions

## Best Practices

### DO ✅

1. **Write descriptive test names**
   - "should save message to database"
   - "should return error when network fails"

2. **Test behavior, not implementation**
   - Test what the user sees/experiences
   - Don't test private methods directly

3. **Keep tests independent**
   - No test should depend on another
   - Each test should clean up after itself

4. **Use proper assertions**
   - `expect(actual, matcher)`
   - Use specific matchers (`equals`, `contains`, `greaterThan`)

5. **Test edge cases**
   - Empty inputs, null values
   - Boundary conditions
   - Error scenarios

6. **Mock external dependencies**
   - Network calls, file system
   - System services

### DON'T ❌

1. **Don't test framework code**
   - Don't test Flutter's built-in widgets
   - Trust the framework works

2. **Don't make tests dependent**
   - Each test should run independently
   - No shared state between tests

3. **Don't ignore failing tests**
   - Fix or remove failing tests
   - Don't use `skip` permanently

4. **Don't test implementation details**
   - Test public API only
   - Allow refactoring without breaking tests

5. **Don't use real external services**
   - Mock APIs, databases (except in-memory)
   - Keep tests fast and reliable

## Debugging Tests

### Running Single Test

```bash
flutter test test/conversation_service_test.dart
```

### Running Specific Test Case

```bash
flutter test test/conversation_service_test.dart --name "should save message"
```

### Debug Mode

```dart
test('debug test', () async {
  debugPrint('Value: $value');
  expect(value, expectedValue);
});
```

### Using Breakpoints

Run tests in debug mode in your IDE and set breakpoints.

## Maintenance

### Regular Tasks

1. **Review test coverage monthly**
   - Check for uncovered code
   - Add tests for new features

2. **Refactor tests with code**
   - Keep tests in sync with implementation
   - Update tests when refactoring

3. **Remove obsolete tests**
   - Delete tests for removed features
   - Clean up unused test utilities

4. **Update dependencies**
   - Keep test packages up to date
   - Test after dependency updates

### Test Code Quality

- Keep tests simple and readable
- Extract common setup into helpers
- Document complex test scenarios
- Use consistent naming conventions
- Review test code like production code

## Resources

### Documentation
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Test Coverage Best Practices](https://martinfowler.com/bliki/TestCoverage.html)

### Tools
- `flutter_test`: Flutter testing framework
- `mockito`: Mocking library
- `sqflite_common_ffi`: SQLite testing
- `flutter_riverpod`: State management testing

---

**Last Updated**: October 6, 2025
**Maintained By**: Development Team
