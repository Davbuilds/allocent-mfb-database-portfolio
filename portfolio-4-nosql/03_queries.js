// Allocent MFB - Portfolio 4: queries and aggregations
// Run: docker exec allocent-mongo mongosh --quiet /scripts/03_queries.js

const db = connect("mongodb://localhost:27017/allocent");

// Q7 below approves the "Team lunch" request. Put it back to PENDING first,
// so this script gives the same results every time it is run.
db.expenses.updateOne(
  { description: "Team lunch" },
  { $set: { status: "PENDING", approvals: [] } },
);

print(
  "===== Q1: Fuel expenses for one vehicle (category-specific field, partial index) =====",
);
printjson(
  db.expenses
    .find(
      { category: "FUEL", "details.vehicle_plate": "LND-482-KJ" },
      { _id: 0, description: 1, amount: 1, details: 1, status: 1 },
    )
    .toArray(),
);

print(
  "\n===== Q2: Trips to Abuja of 2+ nights (fields only travel expenses have) =====",
);
print(
  "Count: " +
    db.expenses.countDocuments({
      category: "TRAVEL",
      "details.destination": "Abuja",
      "details.nights": { $gte: 2 },
    }),
);
printjson(
  db.expenses
    .find(
      {
        category: "TRAVEL",
        "details.destination": "Abuja",
        "details.nights": { $gte: 2 },
      },
      {
        _id: 0,
        description: 1,
        amount: 1,
        "details.nights": 1,
        "details.transport": 1,
      },
    )
    .limit(3)
    .toArray(),
);

print("\n===== Q3: One complete expense in a single read (no joins) =====");
printjson(
  db.expenses.findOne({ description: "Client meeting in Abuja" }, { _id: 0 }),
);

print("\n===== Q4: Paid spend per department for company 1 =====");
printjson(
  db.expenses
    .aggregate([
      { $match: { company_id: 1, status: "PAID" } },
      {
        $group: {
          _id: "$department.name",
          payments: { $sum: 1 },
          total_spent: { $sum: "$amount" },
        },
      },
      { $sort: { total_spent: -1 } },
    ])
    .toArray(),
);

print("\n===== Q5: Spend by category for company 1 =====");
printjson(
  db.expenses
    .aggregate([
      { $match: { company_id: 1, status: "PAID" } },
      {
        $group: {
          _id: "$category",
          payments: { $sum: 1 },
          total_spent: { $sum: "$amount" },
          average: { $avg: "$amount" },
        },
      },
      { $sort: { total_spent: -1 } },
    ])
    .toArray(),
);

print(
  "\n===== Q6: Manager's inbox - 5 newest pending requests for company 1 =====",
);
printjson(
  db.expenses
    .find(
      { company_id: 1, status: "PENDING" },
      { _id: 0, description: 1, amount: 1, "requester.name": 1, created_at: 1 },
    )
    .sort({ created_at: -1 })
    .limit(5)
    .toArray(),
);

print(
  "\n===== Q7: Approve a request by adding to its embedded approval history =====",
);
const filter = { description: "Team lunch" };
print("Before:");
printjson(db.expenses.findOne(filter, { _id: 0, status: 1, approvals: 1 }));
db.expenses.updateOne(filter, {
  $set: { status: "APPROVED" },
  $push: {
    approvals: {
      level: NumberInt(1),
      approver: { staff_id: NumberInt(8), name: "Chinedu Okafor" },
      decision: "APPROVED",
      decided_at: new Date(),
    },
  },
});
print("After:");
printjson(db.expenses.findOne(filter, { _id: 0, status: 1, approvals: 1 }));

print(
  "\n===== Q8: Rule check - approved/paid requests above NGN 100,000 without finance approval =====",
);
print(
  "Violations found: " +
    db.expenses.countDocuments({
      status: { $in: ["APPROVED", "PAID"] },
      amount: { $gt: NumberDecimal("100000") },
      "approvals.level": { $ne: 2 },
    }),
);
