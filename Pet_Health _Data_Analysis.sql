                      /*--- Pet Health Data Analysis --- */

/*1. List the names of all pet owners along with the names of their pets.*/ 

SELECT petowners.Name as pet_Owner, Pets.Name as pets_name
FROM petowners
JOIN Pets ON petowners.OwnerID = Pets.OwnerID;

/*2. List all pets and their owner names, including pets that don't have recorded 
owners. */ 

SELECT 
	pets.name as pets_name,
	CASE 
      WHEN petowners.name IS NOT NULL THEN petowners.name
      ELSE 'No Owner'
	END AS Owner_name
FROM pets
LEFT JOIN petowners ON Pets.OwnerID = petowners.OwnerID;

/*3. Combine the information of pets and their owners, including those pets 
without owners and owners without pets. */ 

SELECT * FROM petowners po
LEFT JOIN pets p ON po.OwnerID = p.OwnerID
UNION
SELECT * FROM petowners po
RIGHT JOIN pets p ON po.OwnerID = p.OwnerID;

/*4. Find the names of pets along with their owners' names and the details of the 
procedures they have undergone. */ 

SELECT petowners.Name as pets_owner, pets.Name as pets_name, procedureshistory.ProcedureType as Procedures
FROM petowners 
JOIN Pets ON petowners.OwnerID = Pets.OwnerID
JOIN procedureshistory ON Pets.PetID = procedureshistory.PetID;

/*5. List all pet owners and the number of dogs they own */

SELECT petowners.Name, COUNT(Pets.PetID) AS Number_Of_Dogs
FROM petowners
LEFT JOIN Pets ON petowners.OwnerID = Pets.OwnerID
WHERE Pets.kind = 'Dog'
GROUP BY petowners.OwnerID, petowners.Name;


/*6. Identify pets that have not had any procedures. */

SELECT Pets.Name as pets_without_procedure
FROM Pets
LEFT JOIN proceduresdetails ON Pets.PetID = proceduresdetails.ProcedureSubCode
WHERE proceduresdetails.ProcedureSubCode IS NULL;


/*7. Find the name of the oldest pet.  */

SELECT Pets.Name
FROM Pets
ORDER BY Age DESC
LIMIT 1;

/*8. List all pets who had procedures that cost more than the average cost of all procedures. */

SELECT pt.petid, pt.name AS pet_name, pcd.price, 
(SELECT round(AVG(price),0) FROM proceduresdetails) as avg_cost
FROM pets pt
LEFT JOIN procedureshistory pch ON pt.PetID = pch.PetID
LEFT JOIN proceduresdetails pcd ON pcd.ProcedureSubCode = pch.ProcedureSubCode
WHERE pcd.price > (SELECT round(AVG(price),0) as avg_cost FROM proceduresdetails);
/*9. Find the details of procedures performed on 'Cuddles'.  */

SELECT pets.Name,pets.OwnerID,procedureshistory.ProcedureType,proceduresdetails.Description,proceduresdetails.Price
FROM pets 
LEFT JOIN procedureshistory ON pets.PetID= procedureshistory.PetID
LEFT JOIN proceduresdetails ON proceduresdetails.ProcedureType = proceduresdetails.ProcedureType
WHERE pets.Name = 'Cuddles';


/*10. Create a list of pet owners along with the total cost they have spent on 
procedures and display only those who have spent above the average 
spending. */

SELECT
    po.name,
    MAX(po.Surname) as Surname,
    SUM(pd.price) as total_cost,
    avg(pd.price) as avg_cost
FROM
    petowners po
JOIN
    pets p ON p.OwnerID = po.OwnerID
JOIN
    procedureshistory ph ON ph.PetID = p.PetID
JOIN
    proceduresdetails pd ON pd.ProcedureType = ph.ProcedureType
GROUP BY
    po.name
HAVING
    total_cost > AVG(pd.price);


/*11. List the pets who have undergone a procedure called 'VACCINATIONS'.  */

SELECT DISTINCT Pets.Name AS pets_procedure
FROM Pets
JOIN procedureshistory ON Pets.PetID = procedureshistory.PetID
WHERE procedureshistory.ProcedureType = 'VACCINATIONS';

/*12. Find the owners of pets who have had a procedure called 'EMERGENCY'.  */


select po.Name, po.Surname, pr.Description
from petowners po
JOIN
    pets p ON p.OwnerID = po.OwnerID
JOIN
    procedureshistory prt ON prt.PetID = p.PetID
JOIN
    proceduresdetails pr ON pr.ProcedureSubCode = prt.ProcedureSubCode
where pr.Description="Emergency";


/*13. Calculate the total cost spent by each pet owner on procedures. */

select distinct(po.ownerid) as owner_id, po.name, po.surname, sum(pcd.price) as total_spent, 
pcd.proceduretype
from petowners po
	join pets pt on pt.OwnerID = po.OwnerID
	join procedureshistory pch on pt.petid =pch.PetID
	join proceduresdetails pcd on pch.ProcedureSubCode = pcd.ProcedureSubCode
group by owner_id, po.name, po.surname, pcd.proceduretype;


/*14. Count the number of pets of each kind. */
SELECT Kind, COUNT(*) AS Pet_Count
FROM Pets
GROUP BY Kind;

/*15. Group pets by their kind and gender and count the number of pets in each group.  */

SELECT Kind, Gender, COUNT(*) AS Pet_Count
FROM Pets
GROUP BY Kind, Gender;

/*16. Show the average age of pets for each kind, but only for kinds that have more than 5 pets.  */

SELECT Kind, AVG(Age) AS Average_Age
FROM Pets
GROUP BY Kind
HAVING COUNT(*) > 5;

/*17. Find the types of procedures that have an average cost greater than $50.*/

SELECT Price as avg_price
FROM proceduresdetails
GROUP BY Price
HAVING AVG(Price) > 50;

/*18. Classify pets as 'Young', 'Adult', or 'Senior' based on their age. Age less then 3 Young, Age between 3and 8 Adult, else Senior.  */
SELECT
    Name,
    CASE
        WHEN Age < 3 THEN 'Young'
        WHEN Age BETWEEN 3 AND 8 THEN 'Adult'
        ELSE 'Senior'
    END AS Age_Group
FROM Pets;


/*19. .Calculate the total spending of each pet owner on procedures, labeling them as 'Low Spender' for spending under $100, 'Moderate Spender' for spending 
between $100 and $500, and 'High Spender' for spending over $500.  */

SELECT
    petowners.Name,
    SUM(proceduresdetails.Price) AS Total_Spending,
    CASE
        WHEN SUM(proceduresdetails.Price) < 100 THEN 'Low Spender'
        WHEN SUM(proceduresdetails.Price) BETWEEN 100 AND 500 THEN 'Moderate Spender'
        ELSE 'High Spender'
    END AS Spending_Category
FROM petowners
JOIN Pets ON petowners.OwnerID = Pets.OwnerID
JOIN procedureshistory ON Pets.PetID = procedureshistory.PetID
JOIN proceduresdetails ON procedureshistory.ProcedureSubCode = proceduresdetails.ProcedureSubCode
GROUP BY petowners.OwnerID, petowners.Name;


/*20. Show the gender of pets with a custom label ('Boy' for male, 'Girl' for female). */

SELECT
    Name,
    CASE
        WHEN Gender = 'Male' THEN 'Boy'
        WHEN Gender = 'Female' THEN 'Girl'
        ELSE 'Unknown'
    END AS Pet_Gender
FROM Pets;



/*21. For each pet, display the pet's name, the number of procedures they've had, 
and a status label: 'Regular' for pets with 1 to 3 procedures, 'Frequent' for 4 to 
7 procedures, and 'Super User' for more than 7 procedures. 
*/

SELECT
    Name,
    COUNT(procedureshistory.PetID) AS Procedure_Count,
    CASE
        WHEN COUNT(procedureshistory.PetID) <= 3 THEN 'Regular'
        WHEN COUNT(procedureshistory.PetID) BETWEEN 4 AND 7 THEN 'Frequent'
        ELSE 'Super User'
    END AS Status_Label
FROM Pets
LEFT JOIN procedureshistory ON Pets.PetID = procedureshistory.PetID
GROUP BY Pets.PetID, Name;


/*22. .Rank pets by age within each kind..*/

SELECT
    Name,
    Age,
    Kind,
    RANK() OVER (PARTITION BY Kind ORDER BY Age) AS Age_Rank
FROM Pets;

/*23. .Assign a dense rank to pets based on their age, regardless of kind. */

SELECT
    Name,
    Age,
    DENSE_RANK() OVER (ORDER BY Age) AS Age_Dense_Rank
FROM Pets;


/*24. For each pet, show the name of the next and previous pet in alphabetical order.*/

WITH RankedPets AS (
    SELECT
        Name,
        ROW_NUMBER() OVER (ORDER BY Name) AS Pet_Rank
    FROM Pets
)
SELECT
    p.Name,
    prev.Name AS Previous_Pet,
    next.Name AS Next_Pet
FROM RankedPets p
LEFT JOIN RankedPets prev ON p.Pet_Rank = prev.Pet_Rank + 1
LEFT JOIN RankedPets next ON p.Pet_Rank = next.Pet_Rank - 1;


/*25. Show the average age of pets, partitioned by their kind.  .*/

SELECT
    Kind,
    AVG(Age) AS Averag_eAge
FROM Pets
GROUP BY Kind;

/*26. Create a CTE that lists all pets, then select pets older than 5 years from the CTE. */

WITH AllPets AS (
    SELECT *
    FROM Pets
)
SELECT *
FROM AllPets
WHERE Age > 5;

