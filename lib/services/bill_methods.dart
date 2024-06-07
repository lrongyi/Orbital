import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/services/models/bill.dart';
import 'package:ss/services/user_methods.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';
const String BUDGET_COLLECTION = 'Budgets';
const String BILL_COLLECTION = 'Bills';

class BillMethods {
  
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Bill> getBillsRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(BILL_COLLECTION)
      .withConverter<Bill>(fromFirestore: (snapshots, _) => Bill.fromJson(snapshots.data() as Map<String, Object?>), 
        toFirestore: (bill, _) => bill.toJson());
  }

  Stream<QuerySnapshot> getBills() {
    return getBillsRef(UserMethods().getCurrentUserId()).snapshots();
  }

  void addBill(Bill bill) async {
    await getBillsRef(UserMethods().getCurrentUserId()).add(bill);
  }

  void updateBill(String billId, Bill bill) async {
    await getBillsRef(UserMethods().getCurrentUserId()).doc(billId).update(bill.toJson());
  }

  void deleteBill(String billId) async {
    await getBillsRef(UserMethods().getCurrentUserId()).doc(billId).delete();
  }

  Future<List<Bill>> getBillsForDay(DateTime day) async {
    QuerySnapshot query = await getBillsRef(UserMethods().getCurrentUserId())
      .where('due', isEqualTo: Timestamp.fromDate(day)).get();

    return query.docs.map((doc) => doc.data() as Bill).toList();
  }
}