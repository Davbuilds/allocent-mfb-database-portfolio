// Allocent MFB - Portfolio 4: create the expenses collection
// Run: docker exec allocent-mongo mongosh --quiet /scripts/01_setup.js

const db = connect("mongodb://localhost:27017/allocent");

db.expenses.drop();

// Schema validation: required core fields are enforced,
// while "details" is left flexible so each category can differ.
db.createCollection("expenses", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [
        "company_id",
        "department",
        "wallet_id",
        "requester",
        "vendor",
        "amount",
        "category",
        "status",
        "created_at",
      ],
      properties: {
        company_id: { bsonType: "int" },
        department: {
          bsonType: "object",
          required: ["department_id", "name"],
          properties: {
            department_id: { bsonType: "int" },
            name: { bsonType: "string" },
          },
        },
        wallet_id: { bsonType: "int" },
        requester: {
          bsonType: "object",
          required: ["staff_id", "name"],
        },
        vendor: {
          bsonType: "object",
          required: ["vendor_id", "name"],
        },
        amount: {
          bsonType: "decimal",
          minimum: 0,
          exclusiveMinimum: true,
          description: "Money as Decimal128, must be positive",
        },
        category: {
          enum: [
            "TRAVEL",
            "SOFTWARE",
            "EQUIPMENT",
            "FUEL",
            "UTILITIES",
            "OTHER",
          ],
        },
        status: {
          enum: ["PENDING", "APPROVED", "REJECTED", "PAID"],
        },
        details: {
          bsonType: "object",
          description: "Category-specific fields; structure varies by category",
        },
        approvals: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["level", "approver", "decision", "decided_at"],
            properties: {
              level: { enum: [1, 2] },
              decision: { enum: ["APPROVED", "REJECTED"] },
              decided_at: { bsonType: "date" },
            },
          },
        },
        receipts: { bsonType: "array" },
        created_at: { bsonType: "date" },
      },
    },
  },
  validationLevel: "strict",
  validationAction: "error",
});

// Indexes for the main access patterns
db.expenses.createIndex(
  { company_id: 1, status: 1, created_at: -1 },
  { name: "idx_company_status_created" },
);
db.expenses.createIndex(
  { company_id: 1, category: 1 },
  { name: "idx_company_category" },
);
// Partial index: only fuel expenses have a vehicle plate
db.expenses.createIndex(
  { "details.vehicle_plate": 1 },
  { name: "idx_fuel_vehicle", partialFilterExpression: { category: "FUEL" } },
);

print("Collections:");
printjson(db.getCollectionNames());
print("Indexes on expenses:");
printjson(db.expenses.getIndexes().map((i) => i.name));
