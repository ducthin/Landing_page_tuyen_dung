-- Migration script to add email column to candidates table
-- Run this on your database to add the email column for existing data

ALTER TABLE candidates ADD COLUMN email VARCHAR(255) NULL;

-- Optional: Add index for better performance when searching by email
CREATE INDEX idx_candidates_email ON candidates(email);

-- Show the updated table structure
DESCRIBE candidates;
