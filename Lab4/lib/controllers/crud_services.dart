import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUDService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _contactsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User is not logged in');
    }
    return _firestore.collection('users').doc(uid).collection('contacts');
  }

  Future addNewContact(String name, String phone, String email) {
    return _contactsRef.add({
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getContacts(String searchQuery) {
    final query = searchQuery.trim();
    Query<Map<String, dynamic>> contacts = _contactsRef.orderBy('name');

    if (query.isNotEmpty) {
      contacts = contacts
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff');
    }

    return contacts.snapshots();
  }

  Future updateContact(String name, String phone, String email, String docID) {
    return _contactsRef.doc(docID).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future deleteContact(String docID) {
    return _contactsRef.doc(docID).delete();
  }
}
