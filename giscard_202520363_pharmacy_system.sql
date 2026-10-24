-- =============================================================================
-- ASSIGNMENT III: SQL TABLE MANIPULATION 
-- Student Name: BAHATI KAWAYA GISCARD 
-- Student ID: 202520363
-- Project Name: Pharmacy Management System
-- Database Name: giscard_202520363_pharmacy_system
-- Kigali Independent University (ULK)
-- =============================================================================

-- =============================================================================
-- SECTION 1: DATABASE CREATION
-- =============================================================================

CREATE DATABASE giscard_202520363_pharmacy_system;

-- =============================================================================
-- SECTION 2: TABLE CREATION AND CONSTRAINTS
-- =============================================================================

-- 1. Parent Table: suppliers
CREATE TABLE suppliers (
    supplier_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    address TEXT NOT NULL
);

-- 2. Parent Table & Child of suppliers: medicines
CREATE TABLE medicines (
    medicine_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_id INT NOT NULL,
    medicine_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    expiry_date DATE NOT NULL,
    CONSTRAINT fk_medicines_suppliers FOREIGN KEY (supplier_id) 
        REFERENCES suppliers(supplier_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3. Child Table: sales
CREATE TABLE sales (
    sale_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medicine_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    quantity_sold INT NOT NULL CHECK (quantity_sold > 0),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sales_medicines FOREIGN KEY (medicine_id) 
        REFERENCES medicines(medicine_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =============================================================================
-- SECTION 3: INITIAL DATA INSERTION (Minimum 5 records per table)
-- =============================================================================

-- Populate suppliers (Parent Table)
INSERT INTO suppliers (supplier_name, contact_person, phone, email, address) VALUES
('PharmaCorp Rwanda', 'Jean Paul Ndayishimiye', '+250788111222', 'contact@pharmacorp.rw', 'Kigali Special Economic Zone'),
('MediHealth Ltd', 'Aline Uwamahoro', '+250788333444', 'sales@medihealth.rw', 'KN 5 Rd, Remera, Kigali'),
('Global BioMed', 'David Smith', '+250788555666', 'dsmith@globalbiomed.com', 'Free Zone, Masaka'),
('East Africa Pharma', 'Claire Akamanzi', '+250788777888', 'info@eapharma.co.rw', 'Gikondo Industrial Zone'),
('Apex Healthcare Supply', 'Eric Mugisha', '+250788999000', 'orders@apexhealth.rw', 'KG 7 Ave, Kacyiru');

-- Populate medicines (Child of suppliers)
INSERT INTO medicines (supplier_id, medicine_name, category, unit_price, stock_quantity, expiry_date) VALUES
(1, 'Paracetamol 500mg', 'Analgesic', 500.00, 150, '2027-12-31'),
(1, 'Amoxicillin 250mg', 'Antibiotic', 1200.00, 80, '2027-06-30'),
(2, 'Ibuprofen 400mg', 'Anti-inflammatory', 800.00, 200, '2028-01-15'),
(3, 'Metformin 500mg', 'Antidiabetic', 1500.00, 45, '2026-11-20'),
(4, 'Omeprazole 20mg', 'Gastrointestinal', 2000.00, 120, '2027-09-15');

-- Populate sales (Child of medicines)
INSERT INTO sales (medicine_id, customer_name, quantity_sold, total_amount, sale_date) VALUES
(1, 'Alice Umutoni', 2, 1000.00, '2026-10-24 09:30:00+02'),
(2, 'Bernard Bizimana', 1, 1200.00, '2026-10-24 10:15:00+02'),
(1, 'Chantal Mukamana', 5, 2500.00, '2026-10-24 11:45:00+02'),
(3, 'Daniel Hakizimana', 3, 2400.00, '2026-10-24 14:20:00+02'),
(5, 'Emmanuel Nshimiyimana', 2, 4000.00, '2026-10-24 16:00:00+02');


-- =============================================================================
-- SECTION 4: PRACTICAL TASKS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 4.1 SELECT TASKS (Data Retrieval)
-- -----------------------------------------------------------------------------

-- Q1.1: Basic Data Retrieval
-- Objective: Retrieve specific columns from the medicines table to display product details.
SELECT medicine_name, category, unit_price, stock_quantity 
FROM medicines;

-- Q1.2: Conditional Data Retrieval
-- Objective: Retrieve medicines that have a low stock level (less than 100 units).
SELECT medicine_name, category, stock_quantity 
FROM medicines 
WHERE stock_quantity < 100;

-- Q1.3: Sorted Data Retrieval
-- Objective: Retrieve all medicines sorted by unit price in descending order.
SELECT medicine_name, category, unit_price 
FROM medicines 
ORDER BY unit_price DESC;


-- -----------------------------------------------------------------------------
-- 4.2 JOIN TASKS (Retrieving Related Data)
-- -----------------------------------------------------------------------------

-- Q2.1: INNER JOIN
-- Objective: Join medicines and suppliers to show which supplier provides each medicine.
SELECT 
    m.medicine_name, 
    m.category, 
    m.unit_price, 
    s.supplier_name, 
    s.phone 
FROM medicines m
INNER JOIN suppliers s ON m.supplier_id = s.supplier_id;

-- Q2.2: LEFT JOIN
-- Objective: Retrieve all suppliers and any medicines they supply, including suppliers with no assigned products.
SELECT 
    s.supplier_name, 
    s.contact_person, 
    m.medicine_name, 
    m.unit_price 
FROM suppliers s
LEFT JOIN medicines m ON s.supplier_id = m.supplier_id;

-- Q2.3: Multi-Table JOIN
-- Objective: Combine sales, medicines, and suppliers tables into a single transaction report.
SELECT 
    sa.sale_id,
    sa.sale_date,
    sa.customer_name,
    m.medicine_name,
    sa.quantity_sold,
    sa.total_amount,
    s.supplier_name
FROM sales sa
INNER JOIN medicines m ON sa.medicine_id = m.medicine_id
INNER JOIN suppliers s ON m.supplier_id = s.supplier_id
ORDER BY sa.sale_date DESC;


-- -----------------------------------------------------------------------------
-- 4.3 UPDATE TASKS (Modifying Existing Data)
-- -----------------------------------------------------------------------------

-- Q3.1: Update One Record
-- Objective: Update the unit price of 'Metformin 500mg' (medicine_id = 4).
-- Verification Before:
SELECT medicine_id, medicine_name, unit_price FROM medicines WHERE medicine_id = 4;

UPDATE medicines 
SET unit_price = 1750.00 
WHERE medicine_id = 4;

-- Verification After:
SELECT medicine_id, medicine_name, unit_price FROM medicines WHERE medicine_id = 4;


-- Q3.2: Update Multiple Records
-- Objective: Apply a 10% price increase to all medicines supplied by 'PharmaCorp Rwanda' (supplier_id = 1).
-- Verification Before:
SELECT medicine_id, medicine_name, supplier_id, unit_price FROM medicines WHERE supplier_id = 1;

UPDATE medicines 
SET unit_price = unit_price * 1.10 
WHERE supplier_id = 1;

-- Verification After:
SELECT medicine_id, medicine_name, supplier_id, unit_price FROM medicines WHERE supplier_id = 1;


-- Q3.3: Conditional Update
-- Objective: Restock items by adding 50 units to stock for any medicine with less than 100 units.
-- Verification Before:
SELECT medicine_id, medicine_name, stock_quantity FROM medicines WHERE stock_quantity < 100;

UPDATE medicines 
SET stock_quantity = stock_quantity + 50 
WHERE stock_quantity < 100;

-- Verification After:
SELECT medicine_id, medicine_name, stock_quantity FROM medicines WHERE medicine_id IN (2, 4);


-- -----------------------------------------------------------------------------
-- 4.4 ALTER TABLE TASKS (Modifying Table Structure)
-- -----------------------------------------------------------------------------

-- Q4.1: Rename a Column
-- Objective: Rename 'contact_person' to 'primary_contact' in the suppliers table.
ALTER TABLE suppliers 
RENAME COLUMN contact_person TO primary_contact;

-- Verification:
SELECT supplier_id, supplier_name, primary_contact FROM suppliers LIMIT 3;


-- Q4.2: Change a Column's Data Type
-- Objective: Change the data type of 'address' in suppliers from TEXT to VARCHAR(255).
ALTER TABLE suppliers 
ALTER COLUMN address TYPE VARCHAR(255);

-- Verification:
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'suppliers' AND column_name = 'address';


-- Q4.3: Add or Remove a Column
-- Objective: Add a new column 'prescription_required' (BOOLEAN) to the medicines table.
ALTER TABLE medicines 
ADD COLUMN prescription_required BOOLEAN DEFAULT FALSE;

-- Verification:
SELECT medicine_id, medicine_name, prescription_required FROM medicines LIMIT 3;


-- -----------------------------------------------------------------------------
-- 4.5 INSERT TASKS (Adding New Records)
-- -----------------------------------------------------------------------------

-- Q5.1: Insert a Single Record
-- Objective: Add a new supplier to the suppliers table.
INSERT INTO suppliers (supplier_name, primary_contact, phone, email, address) 
VALUES ('Kigali Med Supplies', 'Grace Umulisa', '+250788222333', 'grace@kigalimed.rw', 'KN 3 Rd, Nyarugenge, Kigali');

-- Verification:
SELECT * FROM suppliers WHERE supplier_name = 'Kigali Med Supplies';


-- Q5.2: Insert Multiple Records
-- Objective: Insert multiple new medicines in a single statement.
INSERT INTO medicines (supplier_id, medicine_name, category, unit_price, stock_quantity, expiry_date, prescription_required) VALUES
(2, 'Ciprofloxacin 500mg', 'Antibiotic', 2200.00, 60, '2027-10-15', TRUE),
(3, 'Losartan 50mg', 'Antihypertensive', 1800.00, 90, '2028-03-31', TRUE);

-- Verification:
SELECT medicine_id, medicine_name, category, unit_price FROM medicines WHERE medicine_id IN (6, 7);


-- Q5.3: Insert a Related Record
-- Objective: Insert a new sale referencing an existing medicine (medicine_id = 6) and supplier relationship.
INSERT INTO sales (medicine_id, customer_name, quantity_sold, total_amount, sale_date) 
VALUES (6, 'Fabrice Ishimwe', 2, 4400.00, CURRENT_TIMESTAMP);

-- Verification:
SELECT sa.sale_id, sa.customer_name, m.medicine_name, sa.quantity_sold, sa.total_amount 
FROM sales sa 
JOIN medicines m ON sa.medicine_id = m.medicine_id 
WHERE sa.customer_name = 'Fabrice Ishimwe';