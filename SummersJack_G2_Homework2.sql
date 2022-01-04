use train;
# In all questions below unless otherwise stated label columns with human readable names

/* 1. Display a count of the cars manufactured by the company Talgo listed by car type. 
Order by the highest count of car type to the lowest. */
SELECT carType AS "Car Type", COUNT(carType) AS "Count of Talgo cars by Car Type" 
FROM cargocar
	GROUP BY carType
    ORDER BY COUNT(carType) DESC;
	
/* 2. Display a list of trains by trainID that have at least 31 cars and the number of 
cars those trains have assigned to them.  Order by the longest train to the shortest and by 
trainID increasing numerically. */
SELECT trainID AS "Train ID" , COUNT(carID) AS "Count of Cars" FROM isintrain 
	GROUP BY trainID
	HAVING COUNT(carID)>=31      #citation: I used https://www.codegrepper.com/code-examples/sql/SQL+only+show+where+count+is+great+than+1 to learn about how to use "HAVING".
	ORDER BY COUNT(carID) DESC;

/* 3. Show the cars that are not part of a train.  List the carID, carType, manufacturer 
and year built.  Show results in order by manufacturer then carType. */

SELECT carID AS "Car ID" , carType AS "Car Type", manufacturer AS "Manufacturer", yearbuilt AS "Year Built" 
	FROM isintrain RIGHT JOIN traincar USING (carID) NATURAL JOIN cargocar
		WHERE trainID IS NULL
		ORDER BY manufacturer, carType;

/* 4. Return the crewID, last name and the first name of crew persons supervised by Theresa Allaire that have not yet 
been assigned to a train.  Order the list in alphabetical order by last name and then first name. */
SELECT crewID AS "Crew ID", lastName AS "Last Name", firstName "First Name"
	FROM crewperson LEFT JOIN isassignedto USING (crewID)
		WHERE trainID IS NULL AND supervisor = 112
		ORDER BY lastName, firstName;

/* 5. Show a list of trains that have a departure date in the past 30 days that have not had the engine serviced 
in the past year.  Display trainID, departure date and engine service date.  All field names should be human readable. */

SELECT trainID AS "Train ID", departureDate AS "Departure Date", dateLastEngineService AS "Last Engine Service" 
	FROM train NATURAL JOIN enginecar
		WHERE DATEDIFF(CURRENT_DATE, departureDate) < 30 AND DATEDIFF(CURRENT_DATE, dateLastEngineService) >365;

/* 6. Create a list for DoD customers who wish to transport fuel in fuel cars.  Each fuel car is capable of carrying 
30,000 gallons of fuel. The customer is only interested in trains that can carry a minimum of 60,000 gallons. Display the 
train ID and the calculated fuel capacity of the entire train for every train capable of carrying at least 60,000 gallons. 
Sort by trains with the most fuel carrying capacity to least.*/

SELECT trainID AS "Train ID", (COUNT(carType)*30000) AS "Fuel Carrying Capacity" FROM isintrain NATURAL JOIN cargocar
	WHERE carType = "fuel"
		GROUP BY trainID
			HAVING COUNT(carType) >= 2
				ORDER BY (COUNT(carType)*30000) DESC, trainID DESC;

/* 7. Return the supervisor last name and first name as "Supervisor Last Name" and "Supervisor First Name" and the number 
of people that individual supervises as "Number People Supervised."  Put rows returned in order by the supervisor with the least 
crew members to the most. */

SELECT a.lastname AS "Supervisor Last Name", a.firstname AS "Supervisor First Name", COUNT(b.supervisor) AS "Number People Supervised" 
	FROM crewperson a, crewperson b   #CITATION: I used https://www.w3schools.com/sql/sql_join_self.asp IOT understand what a "self join was".
		WHERE a.crewID = b.supervisor  #This enabled me to refer to the crewperson table twice, and join them together. This was necessary because 
			GROUP BY a.lastname         #the supervisor is also a crewperson, and therefore the crewperson table has a relationship with itself.
			ORDER BY COUNT(b.supervisor);

/* Q8. A crime was committed and the only information the police have is a crewperson on a train that departed
in the vicinity of markers 50 to 100 with the first name Tom may have been a witness.  They need to narrow down
the search.  The crime happened sometime between 1 AUG 2020 and 30 SEP 2020. Display the last name of the possible
witnesses, the train ID and the departure date of the train they were on. Display the departure date in military format
(ie - 30 AUG 2020) */
SELECT lastName AS "Last Name", trainID AS "Train ID", DATE_FORMAT(departureDate, '%e %b %Y') AS "Departure Date" 
	FROM locationmarker NATURAL JOIN train NATURAL JOIN crewperson
		WHERE firstName = "Tom" AND departureMarker >=50 AND departureMarker <= 100 AND departureDate >= '2020/08/01' AND departureDate <= '2020/09/30';
		#GROUP BY LastName
		#ORDER BY trainID;


/* Q9. The cargo car manufacturer "American Railcar" is having a centennial celebration and wants to advertise how 
their cars are used by so many train companies.  They want to know the 5 train ids with the most cars made by their 
company.  Return the trainID, and a count of "American Railcar" cars showing the train with the most to the least. 
Order by the train with the most American Railcar cars to the least, then by the trainID. */
SELECT trainID, COUNT(manufacturer) FROM traincar NATURAL JOIN isintrain
	WHERE manufacturer = "American Railcar"
	GROUP BY trainID
	ORDER BY COUNT(manufacturer) DESC, trainID;

/* Q10. Display a count of trains that arrived at a location that is NE of the coordinate (25.0, 25.0).  A staiton is
NE of (25.0, 25.0) when its xLocation is greater than 25.0 and its yLocation is also greater than 25.0.  Alias the
counter as "Number trains arrived station NE of 25,25". */

SELECT COUNT(trainID) AS "Number trains arrived at station NE of 25,25" 
	FROM train NATURAL JOIN locationmarker
		WHERE xLocation > 25.0 AND yLocation > 25.0 AND arrivalMarker = locationID;
