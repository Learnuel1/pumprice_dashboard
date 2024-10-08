 
--  PROCEDURES 
 use marketwatch_db;
   DELIMITER //
 CREATE PROCEDURE sp_update_price(IN productId varchar(30),IN price decimal(7,2),IN status varchar(20), IN userid INT(11))
BEGIN
 INSERT INTO price(Proid,Cost) VALUES(productId,price);
 UPDATE currentprice SET Cost = price, Date = CURRENT_TIMESTAMP() WHERE CuId =(SELECT CuId FROM currentprice WHERE Proid = productId);
 UPDATE products SET Status = status WHERE Proid = productId AND Regid = userid;
 END //
DELIMITER ;
 


DELIMITER //
CREATE PROCEDURE sp_get_user_products(IN userid int(11))
BEGIN
SELECT DISTINCT Name FROM view_product_price
WHERE Regid=userid;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_current_price(IN userid int(11))
BEGIN
SELECT Regid,Proid,Name,Symbol,Cost,Status,Created,Date,Time
FROM view_current_price 
WHERE Regid=userid;
END //
DELIMITER ;


DELIMITER //
CREATE  PROCEDURE `sp_add_product`(IN userid int(11), IN name varchar(50), IN symbol varchar(10),IN pstatus varchar(20),IN price DECIMAL(7,2))
BEGIN
    INSERT INTO products(Regid,Name,Symbol,Status) VALUES(userid,name,symbol,pstatus);
     SET @lastProductId = LAST_INSERT_ID();
   INSERT INTO price(Proid,Cost) VALUES(@lastProductId ,price);
   INSERT INTO currentprice(Proid,Cost,Date) VALUES(@lastProductId ,price,
          (SELECT Date FROM price WHERE Proid=@lastProductId
 ORDER BY priceid DESC LIMIT 1));
 END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_register_business(IN name varchar(60), IN CAC varchar(30), IN contact varchar(15), IN email varchar(255),IN state varchar(30), IN city varchar(30),
                                      IN address varchar(60), IN password VARCHAR(255),IN website varchar(80))
    BEGIN
   INSERT INTO business (BusinessName,CAC,Email,State,City,Contact,Address,Website) 
   VALUES(name,cac,email,state,city, contact,address,website);
   INSERT INTO users(Regid,Password,Email) VALUES((SELECT max(Regid) FROM business),password,email);
   END //
   DELIMITER ;

  DELIMITER //
CREATE  PROCEDURE `sp_update_product`(IN oldname varchar(50),IN newname varchar(50),IN userid int(11),  IN symbol varchar(10),IN pstatus varchar(20))
BEGIN
    UPDATE products SET Name = newname, Symbol =symbol , Status = pstatus WHERE Name = oldname AND Regid = userid;
 END //
DELIMITER ;

CREATE VIEW view_current_price
AS
SELECT b.Regid AS Userid,b.BusinessName,CAC,b.Address,b.Contact,State,City,b.Website, p.Proid,p.Regid,Name,Symbol,Status,Cost, CONVERT(p.DateAdded,Date)AS Created ,CONVERT(c.Date,Date)AS Date,CONVERT(c.Date,Time)AS Time
FROM products p INNER JOIN currentprice c ON p.Proid=c.Proid INNER JOIN business b ON p.Regid=b.Regid;


CREATE VIEW `view_price_history` 
AS select `b`.`Regid` AS `Userid`,`b`.`BusinessName` AS `BusinessName`,`b`.`CAC` AS `CAC`,`b`.`Address` AS `Address`,`b`.`Contact` AS `Contact`,`b`.`State` AS `State`,`b`.`City` AS `City`,`b`.`Website` AS `Website`,`p`.`Proid` AS `Proid`,`p`.`Regid` AS `Regid`,`p`.`Name` AS `Name`,`p`.`Symbol` AS `Symbol`,`p`.`Status` AS `Status`,`c`.`Cost` AS `Cost`,cast(`p`.`DateAdded` as date) AS `Created`,cast(`c`.`Date` as date) AS `Date`,cast(`c`.`Date` as time) AS `Time` from ((`products` `p` join `price` `c` on(`p`.`Proid` = `c`.`Proid`)) join `business` `b` on(`p`.`Regid` = `b`.`Regid`));
