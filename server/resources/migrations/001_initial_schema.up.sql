DROP TABLE IF EXISTS `people`;
CREATE TABLE `people` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDb DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `clients`;
CREATE TABLE `clients` (
  `people_id` varchar(64),
  `massage_id` char(10),
  `slot` int (11)
) ENGINE=InnoDb DEFAULT CHARSET=utf8;


INSERT INTO people(name) VALUES ("Wayne McCoy"             );
INSERT INTO people(name) VALUES ("Andrew Turner"           );
INSERT INTO people(name) VALUES ("Carol Atkins"            );
INSERT INTO people(name) VALUES ("Susan Barker"            );
INSERT INTO people(name) VALUES ("Victor King"             );
INSERT INTO people(name) VALUES ("Robert Knight"           );
INSERT INTO people(name) VALUES ("Ian Somerville"          );
INSERT INTO people(name) VALUES ("Pete Micklewhite"        );
INSERT INTO people(name) VALUES ("Andrea Hermann"          );
INSERT INTO people(name) VALUES ("Fred Young"              );
INSERT INTO people(name) VALUES ("Barbera C. Cooper"       );
INSERT INTO people(name) VALUES ("Carol Elmsley"           );
INSERT INTO people(name) VALUES ("Dianne Buckingham"       );
INSERT INTO people(name) VALUES ("Elaine Moore"            );
INSERT INTO people(name) VALUES ("Francine Smith"          );
INSERT INTO people(name) VALUES ("Gladys Turlington-Barnes");
INSERT INTO people(name) VALUES ("Hattie Jackson"          );
INSERT INTO people(name) VALUES ("Iris Wallace"            );
INSERT INTO people(name) VALUES ("Jackie Shipman"          );
INSERT INTO people(name) VALUES ("Kate Hardy"              );
INSERT INTO people(name) VALUES ("Leanne Caiazza"          );
INSERT INTO people(name) VALUES ("Michelle Piper"          );
INSERT INTO people(name) VALUES ("Natalie Hammond"         );
INSERT INTO people(name) VALUES ("Orla Monroe"             );
INSERT INTO people(name) VALUES ("Paul Shannon"            );
INSERT INTO people(name) VALUES ("Quincey Hobbs"           );
INSERT INTO people(name) VALUES ("Robert Ellis"            );
INSERT INTO people(name) VALUES ("Simon Dacre"             );
INSERT INTO people(name) VALUES ("Trevor Manning"          );
INSERT INTO people(name) VALUES ("Vic Monkhouse"           );
INSERT INTO people(name) VALUES ("Tim Brooks"              );
INSERT INTO people(name) VALUES ("William Devere"          );
INSERT INTO people(name) VALUES ("Walter Partridge"        );
INSERT INTO people(name) VALUES ("Pam O'Reilly"            );
INSERT INTO people(name) VALUES ("Sharon Higgs"            );
INSERT INTO people(name) VALUES ("Piotr Sczepanek"         );
INSERT INTO people(name) VALUES ("Andrea Tul"              );
INSERT INTO people(name) VALUES ("Aisha Quereshi"          );
INSERT INTO people(name) VALUES ("Marian Boucek"           );
INSERT INTO people(name) VALUES ("Maitrey Patak"           );
INSERT INTO people(name) VALUES ("Bhavnisha Pirbahi"       );
INSERT INTO people(name) VALUES ("Ameena Ahsan Lad"        );
INSERT INTO people(name) VALUES ("Goncalo Garcia"          );
INSERT INTO people(name) VALUES ("Igor Goncales"           );
INSERT INTO people(name) VALUES ("Irina Popovic"           );
INSERT INTO people(name) VALUES ("Phillippe Seron"         );
INSERT INTO people(name) VALUES ("Fred Quincey"            );
INSERT INTO people(name) VALUES ("Bella Trueman"           );
INSERT INTO people(name) VALUES ("Daphne Scales"           );
INSERT INTO people(name) VALUES ("Steve Pringle"           );
INSERT INTO people(name) VALUES ("Maxine Schulmann"        );
INSERT INTO people(name) VALUES ("Clare Simmonds"          );
INSERT INTO people(name) VALUES ("Marlow Jenkins"          );


INSERT INTO clients(people_id,massage_id,slot) VALUES ("Wayne McCoy","2014-11-03",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Andrew Turner","2014-12-08",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Carol Atkins","2015-01-05",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Susan Barker","2015-02-02",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Victor King","2015-03-02",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Robert Knight","2015-03-30",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Ian Somerville","2015-04-27",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Pete Micklewhite","2015-05-25",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Andrea Hermann","2015-06-22",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Fred Young","2015-08-03",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Barbera C. Cooper","2015-08-31",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Carol Elmsley","2015-09-28",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Dianne Buckingham","2015-10-26",1);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Elaine Moore","2014-11-03",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Francine Smith","2014-12-08",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Gladys Turlington-Barnes","2015-01-05",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Hattie Jackson","2015-02-02",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Iris Wallace","2015-03-02",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Jackie Shipman","2015-03-30",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Kate Hardy","2015-04-27",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Leanne Caiazza","2015-05-25",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Michelle Piper","2015-06-22",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Natalie Hammond","2015-08-03",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Orla Monroe","2015-08-31",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Paul Shannon","2015-09-28",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Quincey Hobbs","2015-10-26",2);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Robert Ellis","2014-11-03",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Simon Dacre","2014-12-08",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Trevor Manning","2015-01-05",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Vic Monkhouse","2015-02-02",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Tim Brooks","2015-03-02",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("William Devere","2015-03-30",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Walter Partridge","2015-04-27",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Pam O'Reilly","2015-05-25",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Sharon Higgs","2015-06-22",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Piotr Sczepanek","2015-08-03",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Andrea Tul","2015-08-31",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Aisha Quereshi","2015-09-28",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Marian Boucek","2015-10-26",3);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Maitrey Patak","2014-11-03",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Bhavnisha Pirbahi","2014-12-08",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Ameena Ahsan Lad","2015-01-05",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Goncalo Garcia","2015-02-02",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Igor Goncales","2015-03-02",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Irina Popovic","2015-03-30",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Phillippe Seron","2015-04-27",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Fred Quincey","2015-05-25",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Bella Trueman","2015-06-22",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Daphne Scales","2015-08-03",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Steve Pringle","2015-08-31",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Maxine Schulmann","2015-09-28",4);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Barbera C. Cooper","2015-05-25",5);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Carol Elmsley","2015-08-31",5);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Dianne Buckingham","2015-04-27",5);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Elaine Moore","2014-03-30",5);
INSERT INTO clients(people_id,massage_id,slot) VALUES ("Andrew Turner","2015-08-31",5);

