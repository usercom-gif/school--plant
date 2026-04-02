-- Drop the incorrect unique constraint that prevents multiple REJECTED/APPROVED applications
-- The constraint unique_user_active_adoption(user_id, status) is too restrictive.
-- Business logic for limiting active adoptions is handled in the service layer.

ALTER TABLE `adoption_applications` DROP INDEX `unique_user_active_adoption`;

-- Optionally, add non-unique indexes if they don't exist (they do in schema.sql but good to ensure)
-- CREATE INDEX `idx_user_status` ON `adoption_applications` (`user_id`, `status`);
