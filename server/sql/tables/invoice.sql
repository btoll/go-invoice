USE invoices;

DROP TABLE IF EXISTS `invoice`;

CREATE TABLE `invoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `title` varchar(255),
  `dateFrom` date NOT NULL,
  `dateTo` date NOT NULL,
  `url` varchar(255),
  `comment` text,
  `rate` FLOAT DEFAULT 0.0,
  `totalHours` FLOAT DEFAULT 0.0,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`),
  CONSTRAINT `fkcompany_id` FOREIGN KEY (`company_id`) REFERENCES `company` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

LOCK TABLES `invoice` WRITE;
/*!40000 ALTER TABLE `invoice` DISABLE KEYS */;
INSERT INTO `invoice` VALUES (1,1,'Ramp Up and First Task','2018-08-20','2018-08-31','','',75,17);
/*!40000 ALTER TABLE `invoice` ENABLE KEYS */;
UNLOCK TABLES;

