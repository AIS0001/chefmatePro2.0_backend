ALTER TABLE support_tickets
  ADD COLUMN IF NOT EXISTS progress_stage VARCHAR(120) NULL AFTER status,
  ADD COLUMN IF NOT EXISTS stage_updated_at TIMESTAMP NULL DEFAULT NULL AFTER progress_stage,
  ADD COLUMN IF NOT EXISTS resolved_by INT NULL AFTER resolved_at,
  ADD COLUMN IF NOT EXISTS closed_at TIMESTAMP NULL DEFAULT NULL AFTER resolved_by,
  ADD COLUMN IF NOT EXISTS closed_by INT NULL AFTER closed_at;

CREATE INDEX IF NOT EXISTS idx_support_tickets_progress_stage
  ON support_tickets (progress_stage);

CREATE INDEX IF NOT EXISTS idx_support_tickets_closed_at
  ON support_tickets (closed_at);