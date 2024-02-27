



--using the climate change files to determine some climate change differences


---looking at all the average temperatures 
-- replacing all the values in average temperature that is empty with 0
 
UPDATE [Climate Change]..GlobalLandTemperaturesByCity 
SET [AverageTemperature] = 0 
WHERE [AverageTemperature] IS NULL

SELECT dt as date, AverageTemperature, City, Country,
FROM [Climate Change]..GlobalLandTemperaturesByCity

--

-- change the format for the dates to the same 
-- from table major city
SELECT try_parse([dt] as date using 'en-US'),AverageTemperature, City 
FROM [GlobalLandTemperaturesByMajorCity]
ORDER BY dt, City DESC
-- Berlin had the highest temperature in 1743 -11 -1


-- lets see the temperature difference from the earlist day of a majorcity to the most recent
--average temperature is initally as a varchar so need to convert into int
SELECT dt as date, CONVERT (float, AverageTemperature) as AverageTemperature, LEAD(AverageTemperature,1,0) OVER (ORDER BY CONVERT (float, AverageTemperature)) - CONVERT (float, AverageTemperature) AS Difference
FROM [Climate Change]..GlobalLandTemperaturesByMajorCity


-- generate a differnce in global temperatures table to see mom
SELECT dt as date, CONVERT (float, LandAverageTemperature) as LandAverageTemperature, 
LEAD(LandAverageTemperature,1,0) OVER (ORDER BY CONVERT (float, LandAverageTemperature)) - CONVERT (float, LandAverageTemperature) AS Difference
FROM [Climate Change]..GlobalTemperatures


