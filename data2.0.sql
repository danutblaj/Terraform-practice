-- MySQL dump 10.13  Distrib 8.0.30, for Linux (x86_64)
--
-- Host: localhost    Database: DevOps
-- ------------------------------------------------------
-- Server version       8.0.30


DROP DATABASE IF EXISTS DevOps;
CREATE DATABASE DevOps;

USE DevOps;

--
-- Table structure for table `Files`
--

DROP TABLE IF EXISTS `Files`;

CREATE TABLE `Files` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `filename` varchar(30) NOT NULL,
  `keyword` varchar(30) NOT NULL,
  `substitute` varchar(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 ;


--
-- Dumping data for table `Files`
--

LOCK TABLES `Files` WRITE;
INSERT INTO `Files` VALUES (1,'test1.txt','test1','replaced1'),(2,'test2.txt','test2','replaced2'),(3,'test3.txt','test3','replaced3'),(4,'test4.txt','test4','replaced4'),(5,'test5.txt','test5','replaced5'),(6,'test6.txt','test6','replaced6'),(7,'test7.txt','test7','replaced7');
UNLOCK TABLES;

