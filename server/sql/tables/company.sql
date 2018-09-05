USE invoices;

DROP TABLE IF EXISTS `company`;

CREATE TABLE `company` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `contact` varchar(100),
  `street1` varchar(100) NOT NULL,
  `street2` varchar(100),
  `city` varchar(100) NOT NULL,
  `state` varchar(2) NOT NULL,
  `zip` varchar(30) NOT NULL,
  `url` varchar(255),
  `comment` text,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

LOCK TABLES `company` WRITE;
/*!40000 ALTER TABLE `company` DISABLE KEYS */;
INSERT INTO `company` VALUES (1,'CoreConnex','Frank Coker','10900 NE 9th Street','Suite 2300','Bellevue','WA','98004','https://www.coreconnex.com','');
/*!40000 ALTER TABLE `company` ENABLE KEYS */;
UNLOCK TABLES;

