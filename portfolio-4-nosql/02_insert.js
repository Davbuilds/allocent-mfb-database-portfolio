// Allocent MFB - Portfolio 4: insert expense documents
// Run: docker exec allocent-mongo mongosh --quiet /scripts/02_insert.js

const db = connect("mongodb://localhost:27017/allocent");
db.expenses.deleteMany({});

const int = (n) => NumberInt(n);
const money = (n) => NumberDecimal(n.toFixed(2));
const D = (s) => new Date(s);
const approval = (level, staffId, name, decision, date) => ({
  level: int(level),
  approver: { staff_id: int(staffId), name },
  decision,
  decided_at: date,
});

// ---------- Part 1: six hand-written examples, one per category ----------
const examples = [
  {
    company_id: int(1),
    department: { department_id: int(1), name: "Operations" },
    wallet_id: int(1),
    requester: { staff_id: int(3), name: "Ada Obi" },
    vendor: {
      vendor_id: int(1),
      name: "FuelPoint Ikeja",
      bank_name: "Access Bank",
    },
    amount: money(45000),
    category: "FUEL",
    description: "Diesel for delivery van",
    status: "PAID",
    details: {
      litres: 45,
      fuel_type: "DIESEL",
      vehicle_plate: "LND-482-KJ",
      odometer_km: 85210,
    },
    approvals: [
      approval(1, 2, "Musa Bello", "APPROVED", D("2026-09-02T10:00:00Z")),
    ],
    receipts: [
      {
        file_path: "receipts/fuel-0001.jpg",
        uploaded_at: D("2026-09-02T12:00:00Z"),
      },
    ],
    created_at: D("2026-09-02T09:00:00Z"),
  },
  {
    company_id: int(1),
    department: { department_id: int(4), name: "Sales" },
    wallet_id: int(4),
    requester: { staff_id: int(7), name: "Ngozi Eze" },
    vendor: { vendor_id: int(2), name: "SkyTravels Ltd", bank_name: "GTBank" },
    amount: money(185000),
    category: "TRAVEL",
    description: "Client meeting in Abuja",
    status: "PAID",
    details: {
      destination: "Abuja",
      purpose: "Client meeting",
      transport: "FLIGHT",
      departure_date: D("2026-09-10"),
      return_date: D("2026-09-12"),
      nights: 2,
    },
    approvals: [
      approval(1, 6, "Femi Balogun", "APPROVED", D("2026-09-05T10:00:00Z")),
      approval(2, 1, "Kemi Adeyemi", "APPROVED", D("2026-09-05T15:00:00Z")),
    ],
    receipts: [
      {
        file_path: "receipts/travel-0001.pdf",
        uploaded_at: D("2026-09-13T09:00:00Z"),
      },
      {
        file_path: "receipts/travel-0002.pdf",
        uploaded_at: D("2026-09-13T09:05:00Z"),
      },
    ],
    created_at: D("2026-09-04T09:00:00Z"),
  },
  {
    company_id: int(1),
    department: { department_id: int(3), name: "IT" },
    wallet_id: int(3),
    requester: { staff_id: int(5), name: "Tunde Lawal" },
    vendor: { vendor_id: int(3), name: "CloudNaija", bank_name: "Zenith Bank" },
    amount: money(96000),
    category: "SOFTWARE",
    description: "Design tool licences",
    status: "APPROVED",
    details: {
      product: "Figma Professional",
      licences: 5,
      subscription_months: 12,
      billing: "ANNUAL",
      renewal_date: D("2027-09-15"),
    },
    approvals: [
      approval(1, 4, "Aisha Sani", "APPROVED", D("2026-09-15T11:00:00Z")),
    ],
    receipts: [],
    created_at: D("2026-09-15T09:00:00Z"),
  },
  {
    company_id: int(1),
    department: { department_id: int(3), name: "IT" },
    wallet_id: int(3),
    requester: { staff_id: int(5), name: "Tunde Lawal" },
    vendor: {
      vendor_id: int(4),
      name: "TechHub Computer Village",
      bank_name: "UBA",
    },
    amount: money(1240000),
    category: "EQUIPMENT",
    description: "Two laptops for new hires",
    status: "PAID",
    details: {
      item: "Dell Latitude 5440",
      quantity: 2,
      unit_price: 620000,
      serial_numbers: ["DL5440-001", "DL5440-002"],
      warranty_months: 24,
    },
    approvals: [
      approval(1, 4, "Aisha Sani", "APPROVED", D("2026-09-20T10:00:00Z")),
      approval(2, 1, "Kemi Adeyemi", "APPROVED", D("2026-09-20T16:00:00Z")),
    ],
    receipts: [
      {
        file_path: "receipts/equipment-0001.pdf",
        uploaded_at: D("2026-09-22T09:00:00Z"),
      },
    ],
    created_at: D("2026-09-19T09:00:00Z"),
  },
  {
    company_id: int(1),
    department: { department_id: int(1), name: "Operations" },
    wallet_id: int(1),
    requester: { staff_id: int(3), name: "Ada Obi" },
    vendor: {
      vendor_id: int(5),
      name: "Ikeja Electric",
      bank_name: "First Bank",
    },
    amount: money(78500),
    category: "UTILITIES",
    description: "Warehouse electricity, September",
    status: "PAID",
    details: {
      provider: "Ikeja Electric",
      meter_number: "45100293817",
      billing_period: "2026-09",
      units_kwh: 1250,
    },
    approvals: [
      approval(1, 2, "Musa Bello", "APPROVED", D("2026-10-01T10:00:00Z")),
    ],
    receipts: [
      {
        file_path: "receipts/utilities-0001.jpg",
        uploaded_at: D("2026-10-01T12:00:00Z"),
      },
    ],
    created_at: D("2026-10-01T09:00:00Z"),
  },
  {
    company_id: int(1),
    department: { department_id: int(2), name: "HR" },
    wallet_id: int(2),
    requester: { staff_id: int(9), name: "Zainab Usman" },
    vendor: {
      vendor_id: int(6),
      name: "Mama Put Catering",
      bank_name: "GTBank",
    },
    amount: money(36000),
    category: "OTHER",
    description: "Team lunch",
    status: "PENDING",
    details: { note: "Quarterly team lunch", attendees: 12 },
    approvals: [],
    receipts: [],
    created_at: D("2026-10-05T09:00:00Z"),
  },
];
db.expenses.insertMany(examples);
print("Inserted " + examples.length + " hand-written examples");

// ---------- Part 2: 5,000 generated expenses (reproducible) ----------
let seed = 42;
const rnd = () => {
  seed = (seed * 16807) % 2147483647;
  return seed / 2147483647;
};
const pick = (arr) => arr[Math.floor(rnd() * arr.length)];

const deptNames = ["Operations", "HR", "IT", "Sales"];
const firstNames = [
  "Ada",
  "Musa",
  "Kemi",
  "Tunde",
  "Ngozi",
  "Ibrahim",
  "Chinedu",
  "Aisha",
  "Femi",
  "Zainab",
];
const lastNames = [
  "Obi",
  "Bello",
  "Adeyemi",
  "Okafor",
  "Sani",
  "Eze",
  "Balogun",
  "Usman",
  "Nwosu",
  "Lawal",
];
const categories = [
  "TRAVEL",
  "SOFTWARE",
  "EQUIPMENT",
  "FUEL",
  "UTILITIES",
  "OTHER",
];
const vendorsByCategory = {
  TRAVEL: ["SkyTravels Ltd", "Arik Bookings", "GoNaija Trips"],
  SOFTWARE: ["CloudNaija", "DevStack Africa", "LicensePro"],
  EQUIPMENT: ["TechHub Computer Village", "OfficeMart", "DeskPro"],
  FUEL: ["FuelPoint Ikeja", "Total Lekki", "NNPC Mega Station"],
  UTILITIES: ["Ikeja Electric", "Lagos Water Corp", "Spectranet"],
  OTHER: ["Mama Put Catering", "CleanServe", "PrintHub"],
};

function detailsFor(category) {
  switch (category) {
    case "TRAVEL":
      return {
        destination: pick([
          "Abuja",
          "Port Harcourt",
          "Kano",
          "Ibadan",
          "Enugu",
        ]),
        transport: pick(["FLIGHT", "ROAD"]),
        nights: 1 + Math.floor(rnd() * 4),
      };
    case "SOFTWARE":
      return {
        product: pick(["Microsoft 365", "Figma", "Slack", "Zoom"]),
        licences: 1 + Math.floor(rnd() * 20),
        subscription_months: pick([1, 12]),
      };
    case "EQUIPMENT":
      return {
        item: pick(["Laptop", "Printer", "Office chair", "Monitor"]),
        quantity: 1 + Math.floor(rnd() * 5),
        warranty_months: pick([6, 12, 24]),
      };
    case "FUEL":
      return {
        litres: 10 + Math.floor(rnd() * 90),
        fuel_type: pick(["PETROL", "DIESEL"]),
        vehicle_plate:
          "LND-" +
          (100 + Math.floor(rnd() * 900)) +
          "-" +
          pick(["KJ", "AB", "EP", "LA"]),
      };
    case "UTILITIES":
      return {
        provider: pick([
          "Ikeja Electric",
          "Eko Electric",
          "Lagos Water Corp",
          "Spectranet",
        ]),
        billing_period:
          "2026-" + String(1 + Math.floor(rnd() * 9)).padStart(2, "0"),
      };
    default:
      return {
        note: pick(["Team lunch", "Office cleaning", "Printing", "Courier"]),
      };
  }
}

// Fixed reference lists, so each vendor_id and staff_id always has the same
// name (as they would in the relational tables they are copied from).
// Vendors are owned by a company: 3 per category per company, ids from 101.
const vendors = {}; // vendors[companyId][category] = [{vendor_id, name, bank_name}]
const banks = ["GTBank", "Access Bank", "Zenith Bank", "First Bank", "UBA"];
let nextVendorId = 101;
for (let c = 1; c <= 3; c++) {
  vendors[c] = {};
  for (const cat of categories) {
    vendors[c][cat] = vendorsByCategory[cat].map((name) => ({
      vendor_id: int(nextVendorId++),
      name,
      bank_name: pick(banks),
    }));
  }
}
// Staff: 9 per department, staff_id = deptId * 10 + 1..9
const staffName = {};
for (let d = 1; d <= 12; d++) {
  for (let s = 1; s <= 9; s++) {
    staffName[d * 10 + s] = pick(firstNames) + " " + pick(lastNames);
  }
}

const generated = [];
for (let i = 1; i <= 5000; i++) {
  const companyId = 1 + Math.floor(rnd() * 3);
  const deptIdx = Math.floor(rnd() * 4);
  const deptId = (companyId - 1) * 4 + deptIdx + 1;
  const category = pick(categories);
  const staffId = deptId * 10 + 1 + Math.floor(rnd() * 9);
  const amount = Math.round(5000 + rnd() * 495000);
  const created = new Date(
    Date.UTC(2025, 9, 1) + Math.floor(rnd() * 365) * 86400000,
  );
  const r = rnd();
  const status =
    r < 0.6
      ? "PAID"
      : r < 0.75
        ? "APPROVED"
        : r < 0.85
          ? "REJECTED"
          : "PENDING";

  const approvals = [];
  if (status !== "PENDING") {
    approvals.push(
      approval(
        1,
        deptId * 10,
        "Manager " + deptId,
        status === "REJECTED" ? "REJECTED" : "APPROVED",
        new Date(created.getTime() + 3600000),
      ),
    );
    if (amount > 100000 && (status === "APPROVED" || status === "PAID")) {
      approvals.push(
        approval(
          2,
          companyId * 1000,
          "Finance Officer " + companyId,
          "APPROVED",
          new Date(created.getTime() + 86400000),
        ),
      );
    }
  }

  generated.push({
    company_id: int(companyId),
    department: { department_id: int(deptId), name: deptNames[deptIdx] },
    wallet_id: int(deptId),
    requester: { staff_id: int(staffId), name: staffName[staffId] },
    vendor: pick(vendors[companyId][category]),
    amount: money(amount),
    category,
    description:
      category.charAt(0) + category.slice(1).toLowerCase() + " expense #" + i,
    status,
    details: detailsFor(category),
    approvals,
    receipts:
      status === "PAID"
        ? [
            {
              file_path: "receipts/gen-" + i + ".jpg",
              uploaded_at: new Date(created.getTime() + 7200000),
            },
          ]
        : [],
    created_at: created,
  });
}
db.expenses.insertMany(generated);
print("Inserted " + generated.length + " generated expenses");
print("Total documents: " + db.expenses.countDocuments());

// ---------- Part 3: validation tests (each must be rejected) ----------
const valid = examples[0];
const tests = [
  { label: "Negative amount", doc: { ...valid, amount: money(-500) } },
  { label: "Unknown category", doc: { ...valid, category: "PARTY" } },
  {
    label: "Missing amount",
    doc: (() => {
      const d = { ...valid };
      delete d.amount;
      return d;
    })(),
  },
];
print("\nValidation tests:");
for (const t of tests) {
  try {
    db.expenses.insertOne(t.doc);
    print("  " + t.label + ": ACCEPTED (unexpected)");
  } catch (e) {
    // errInfo explains which schema rule the document broke
    const rules = (e.errInfo?.details?.schemaRulesNotSatisfied || [])
      .map((r) => {
        const props = (r.propertiesNotSatisfied || r.missingProperties || [])
          .map((p) => (typeof p === "string" ? p : p.propertyName))
          .join(", ");
        return r.operatorName + (props ? " (" + props + ")" : "");
      })
      .join("; ");
    print("  " + t.label + ": REJECTED - " + e.message + (rules ? " -> " + rules : ""));
  }
}
