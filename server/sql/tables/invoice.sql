USE invoices;

DROP TABLE IF EXISTS `invoice`;

CREATE TABLE `invoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `dateFrom` date NOT NULL,
  `dateTo` date NOT NULL,
  `url` varchar(255),
  `notes` text,
  `rate` FLOAT DEFAULT 0.0,
  `paid` TINYINT(4) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`),
  CONSTRAINT `fkcompany_id` FOREIGN KEY (`company_id`) REFERENCES `company` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

