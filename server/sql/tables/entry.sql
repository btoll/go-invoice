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
INSERT INTO `entry` VALUES (1,1,'React research','2018-08-21','','',2),
	(2,1,'React research','2018-08-22','','',2),
	(3,1,'React research and phone call','2018-08-23','','Spoke with Robert about the project for approximately 20 minutes.',3),
	(4,1,'React research and project phone call','2018-08-27','','Did a quick sync-up with Frank, and let him know that I was waiting on information from Robert.',4),
	(5,1,'Phone call with Robert','2018-08-28','','Productive call with Robert that allowed me to move forward.',.5),
	(6,1,'Express framework for routing, phone calls and simplifying codebase','2018-08-30','','Brought in the Express web framework (Node.js) to mock the REST calls.  Spoke with Frank about the project for an hour and then Steve for about 15 minutes.\n\nGreatly simplified the existing app, it\'s already too overly-engineered.',4),
	(7,1,'Finished mocking REST calls','2018-08-31','','With the new json blob from Steve, finished the GET and POST calls and tested that the percentage drop-down and input box were working.',1.5);
/*!40000 ALTER TABLE `entry` ENABLE KEYS */;
UNLOCK TABLES;

