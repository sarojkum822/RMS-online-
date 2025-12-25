import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kirayabook/data/repositories/rent_repository_impl.dart';
import 'package:kirayabook/data/repositories/tenant_repository_impl.dart';

// class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {} // Sealed class, cannot mock
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  group('RentRepository Mapping Logic', () {
    late RentRepositoryImpl repository;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      repository = RentRepositoryImpl(MockFirebaseFirestore(), auth: mockAuth);
    });

    test('parseDate should handle Timestamp properly', () {
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);
      final result = repository.parseDate(timestamp);
      expect(result!.year, now.year);
      expect(result.month, now.month);
      expect(result.day, now.day);
    });

    test('parseDate should handle String properly', () {
      final dateStr = '2023-12-25T10:30:00.000Z';
      final result = repository.parseDate(dateStr);
      expect(result!.year, 2023);
      expect(result.month, 12);
      expect(result.day, 25);
    });

    test('parseDate should handle null and invalid properly', () {
      expect(repository.parseDate(null), isNull);
      expect(repository.parseDate(123), isNull);
      expect(repository.parseDate('invalid-date'), isNull);
    });

    // test('mapToDomain should not crash with missing or bad numeric fields', () {
    //   final mockDoc = MockDocumentSnapshot();
    //   final now = DateTime.now();
      
    //   when(() => mockDoc.data()).thenReturn({
    //     'id': 'test_id',
    //     'billGeneratedDate': Timestamp.fromDate(now),
    //     'baseRent': null, 
    //     'totalDue': '1000', // String number
    //     'totalPaid': 500, // Int number
    //     'status': null,
    //   });
    //   when(() => mockDoc.id).thenReturn('doc_id');

    //   final result = repository.mapToDomain(mockDoc);
      
    //   expect(result.id, 'test_id');
    //   expect(result.baseRent, 0.0);
    //   expect(result.totalDue, 1000.0); // Now supports parsing strings
    //   expect(result.totalPaid, 500.0);
    //   expect(result.status, domain.RentStatus.pending);
    // });
  });

  group('TenantRepository Mapping Logic', () {
    late TenantRepositoryImpl repository;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseStorage mockStorage;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockStorage = MockFirebaseStorage();
      repository = TenantRepositoryImpl(MockFirebaseFirestore(), auth: mockAuth, storage: mockStorage);
    });

    // test('mapToTenancyDomain should handle mixed date types without crashing', () {
    //   final mockDoc = MockDocumentSnapshot();
    //   final startDateStr = '2024-01-01';
    //   final endDateTimestamp = Timestamp.fromDate(DateTime(2024, 12, 31));
      
    //   when(() => mockDoc.data()).thenReturn({
    //     'id': 'tenancy_1',
    //     'startDate': startDateStr, 
    //     'endDate': endDateTimestamp, 
    //     'agreedRent': 1500,
    //     'status': 1, 
    //   });
    //   when(() => mockDoc.id).thenReturn('tenancy_doc');

    //   final result = repository.mapToTenancyDomain(mockDoc);
      
    //   expect(result.id, 'tenancy_1');
    //   expect(result.startDate.year, 2024);
    //   expect(result.endDate!.year, 2024);
    //   expect(result.agreedRent, 1500.0);
    // });
  });
}
