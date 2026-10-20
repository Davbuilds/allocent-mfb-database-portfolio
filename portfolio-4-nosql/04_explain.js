// Allocent MFB - Portfolio 4: execution plans with explain()
// Run: docker exec allocent-mongo mongosh --quiet /scripts/04_explain.js
// Shows which queries use an index and which scan the whole collection,
// in the same way EXPLAIN ANALYZE was used in Portfolio 2.

const db = connect("mongodb://localhost:27017/allocent");

// List the stages of the winning plan, e.g. "LIMIT <- FETCH <- IXSCAN"
function stages(plan) {
  const out = [];
  let p = plan;
  while (p) {
    out.push(p.stage + (p.indexName ? " (" + p.indexName + ")" : ""));
    p = p.inputStage;
  }
  return out.join(" <- ");
}

function show(label, cursor) {
  const e = cursor.explain("executionStats");
  const s = e.executionStats;
  print("\n===== " + label + " =====");
  print("Plan:          " + stages(e.queryPlanner.winningPlan));
  print("Returned:      " + s.nReturned);
  print("Keys examined: " + s.totalKeysExamined);
  print("Docs examined: " + s.totalDocsExamined);
  print("Time (ms):     " + s.executionTimeMillis);
}

print("Documents in collection: " + db.expenses.countDocuments());

show(
  "Q1: fuel expenses for one vehicle (partial index idx_fuel_vehicle)",
  db.expenses.find({ category: "FUEL", "details.vehicle_plate": "LND-482-KJ" }),
);

show(
  "Q6: manager's inbox, newest pending first (idx_company_status_created)",
  db.expenses
    .find({ company_id: 1, status: "PENDING" })
    .sort({ created_at: -1 })
    .limit(5),
);

show(
  "Q2: trips to Abuja of 2+ nights (no index on details.destination)",
  db.expenses.find({
    category: "TRAVEL",
    "details.destination": "Abuja",
    "details.nights": { $gte: 2 },
  }),
);


