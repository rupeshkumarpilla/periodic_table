-- Periodic Table Database Setup Script
ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;
ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;
ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

-- Add constraints
ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;
ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;
ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;
ALTER TABLE elements ALTER COLUMN name SET NOT NULL;
ALTER TABLE elements ADD UNIQUE(symbol);
ALTER TABLE elements ADD UNIQUE(name);

-- Create types table
CREATE TABLE types(type_id SERIAL PRIMARY KEY, type VARCHAR(20) NOT NULL UNIQUE);
INSERT INTO types(type) VALUES('metal'), ('nonmetal'), ('metalloid');

-- Add type_id column and update references
ALTER TABLE properties ADD COLUMN type_id INT;
UPDATE properties SET type_id = (SELECT type_id FROM types WHERE types.type = properties.type);
ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;
ALTER TABLE properties ADD FOREIGN KEY(type_id) REFERENCES types(type_id);

-- Clean up data
UPDATE elements SET symbol = UPPER(LEFT(symbol, 1)) || LOWER(SUBSTRING(symbol, 2));
ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;

-- Add missing elements
INSERT INTO elements(atomic_number, symbol, name) VALUES(9, 'F', 'Fluorine');
INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) 
VALUES(9, 18.998, -220, -188.1, (SELECT type_id FROM types WHERE type = 'nonmetal'));

INSERT INTO elements(atomic_number, symbol, name) VALUES(10, 'Ne', 'Neon');
INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) 
VALUES(10, 20.18, -248.6, -246.1, (SELECT type_id FROM types WHERE type = 'nonmetal'));

-- Cleanup
DELETE FROM properties WHERE atomic_number = 1000;
DELETE FROM elements WHERE atomic_number = 1000;
ALTER TABLE properties DROP COLUMN type;
-- comment
-- another
