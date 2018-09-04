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

LOCK TABLES `entry` WRITE;
/*!40000 ALTER TABLE `entry` DISABLE KEYS */;
INSERT INTO `entry` VALUES (NULL,1,'Elm work','2018-09-04','github://1','Easy peasy',5.75),(NULL,1,'HTML work','2018-09-06','github://2','Lemon squeezy',8),(NULL,1,'CSS work','2018-09-09','github://3','Yeah!',11.5);
/*!40000 ALTER TABLE `entry` ENABLE KEYS */;
UNLOCK TABLES;

