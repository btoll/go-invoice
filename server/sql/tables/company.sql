USE invoices;

DROP TABLE IF EXISTS `company`;

CREATE TABLE `company` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `contact` varchar(100) DEFAULT NULL,
  `street1` varchar(100) DEFAULT NULL,
  `street2` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(2) DEFAULT NULL,
  `zip` varchar(30) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `comment` text,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

LOCK TABLES `company` WRITE;
/*!40000 ALTER TABLE `company` DISABLE KEYS */;
INSERT INTO `company` VALUES (1,'CoreConnex','Frank Coker','10900 NE 9th Street','Suite 2300','Bellevue','WA','98004','https://www.coreconnex.com', NULL);
/*!40000 ALTER TABLE `company` ENABLE KEYS */;
UNLOCK TABLES;

