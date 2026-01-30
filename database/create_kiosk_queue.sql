-- Create table for kiosk queue numbers per day
CREATE TABLE IF NOT EXISTS `kiosk_queue` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `bill_id` INT NULL,
  `queue_number` INT NOT NULL,
  `queue_date` DATE NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'waiting',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_queue_per_day` (`queue_date`,`queue_number`),
  KEY `idx_bill_id` (`bill_id`),
  CONSTRAINT `fk_kiosk_queue_bill` FOREIGN KEY (`bill_id`) REFERENCES `final_bill`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;