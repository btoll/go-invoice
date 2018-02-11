USE invoices;

DROP TABLE IF EXISTS `entry`;

CREATE TABLE `entry` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `comment` text,
  `hours` FLOAT NOT NULL DEFAULT 0.0,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`),
  KEY `invoice_id` (`invoice_id`),
  CONSTRAINT `fkinvoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `invoice` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

