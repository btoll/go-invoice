USE invoices;

DROP TABLE IF EXISTS `invoice`;

CREATE TABLE `invoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `dateFrom` date NOT NULL,
  `dateTo` date NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `comment` text,
  `rate` FLOAT DEFAULT 0.00,
  `totalHours` FLOAT DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

