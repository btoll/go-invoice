USE invoices;

DROP TABLE IF EXISTS `invoice` ;

CREATE TABLE IF NOT EXISTS `invoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `title` varchar(255) NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `hours` decimal(2,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ;

