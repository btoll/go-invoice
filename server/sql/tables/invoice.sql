USE invoices;

DROP TABLE IF EXISTS `invoice` ;

CREATE TABLE IF NOT EXISTS `invoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `dateFrom` date NOT NULL,
  `dateTo` date NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `totalHours` decimal(3,2) DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ;

