-- Written by Ammar Hasayen
--http://ammarhasayen.com

-- See other queries here(http://ammarhasayen.com/2015/03/01/config-manager-2012-sccm-most-amazing-hardware-inventory-sql-report/)


SELECT DISTINCT 
sys.Name0 'Machine',
sys.AD_Site_Name0 'ADSite',
CS.UserName0 'User Name',
CASE
    WHEN U.TopConsoleUser0 = '-1' OR U.TopConsoleUser0 IS NULL THEN 'N/A'
    ELSE U.TopConsoleUser0
END as TopUser,
REPLACE (OS.Caption0, 'Microsoft Windows','Win') OS,
REPLACE (OS.CSDVersion0,'Service Pack','SP') 'Service Pack',
CS.Manufacturer0 'Manufacturer',
CS.Model0 Model,
BIOS.SerialNumber0 'Serial Number',
BIOS.ReleaseDate0 as BIOSDate,
BIOS.SMBIOSBIOSVersion0 as BIOSVersion,
(SELECT CONVERT(DATE,sys.Creation_Date0)) 'Managed Date',
SUM(ISNULL(RAM.Capacity0,0)) 'Memory (MB)',
COUNT(RAM.ResourceID) '# Memory Slots',
REPLACE (cs.SystemType0,'-based PC','') 'Type',
SUM(D.Size0) / 1024 AS 'Disk Size GB',
CASE SE.ChassisTypes0
  when '1' then 'Other'
  when '2' then 'Unknown'
  when '3' then 'Desktop'
  when '4' then 'Low Profile Desktop'
  when '5' then 'Pizza Box'
  when '6' then 'Mini Tower'
  when '7' then 'Tower'
  when '8' then 'Portable'
  when '9' then 'Laptop'
  when '10' then 'Notebook'
  when '11' then 'Hand Held'
  when '12' then 'Docking Station'
  when '13' then 'All in One'
  when '14' then 'Sub Notebook'
  when '15' then 'Space-Saving'
  when '16' then 'Lunch Box'
  when '17' then 'Main System Chassis'
  when '18' then 'Expansion Chassis'
  when '19' then 'SubChassis'
  when '20' then 'Bus Expansion Chassis'
  when '21' then 'Peripheral Chassis'
  when '22' then 'Storage Chassis'
  when '23' then 'Rack Mount Chassis'
  when '24' then 'Sealed-Case PC'
  else 'Undefinded'
END AS 'PC Type'
FROM
 v_R_System SYS
INNER JOIN (
     SELECT
      Name0,
      MAX(Creation_Date0) AS Creation_Date
     FROM
     dbo.v_R_System
    GROUP BY
     Name0
) AS CleanSystem
ON SYS.Name0 = CleanSystem.Name0 and sys.Creation_Date0 = CleanSystem.Creation_Date
 LEFT JOIN v_GS_COMPUTER_SYSTEM CS
ON sys.ResourceID=cs.ResourceID
 LEFT JOIN v_GS_PC_BIOS BIOS
ON sys.ResourceID=bios.ResourceID
 LEFT JOIN (
     SELECT
      A.ResourceID,
      MAX(A.[InstallDate0]) AS [InstallDate0]
     FROM
      v_GS_OPERATING_SYSTEM A
     GROUP BY
      A.ResourceID
) AS X
ON sys.ResourceID = X.ResourceID
 INNER JOIN v_GS_OPERATING_SYSTEM OS
ON X.ResourceID=OS.ResourceID and X.InstallDate0 = OS.InstallDate0
 LEFT JOIN v_GS_PHYSICAL_MEMORY RAM
ON sys.ResourceID=ram.ResourceID
 LEFT OUTER join dbo.v_GS_LOGICAL_DISK D
ON sys.ResourceID = D.ResourceID and D.DriveType0 = 3
 LEFT outer join v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP U
ON SYS.ResourceID = U.ResourceID
 LEFT JOIN dbo.v_GS_SYSTEM_ENCLOSURE SE on SYS.ResourceID = SE.ResourceID
 LEFT JOIN dbo.v_GS_ENCRYPTABLE_VOLUME En on SYS.ResourceID = En.ResourceID
 
GROUP BY
  sys.Creation_Date0, sys.Name0,
  sys.AD_Site_Name0 , CS.UserName0 ,REPLACE (OS.Caption0, 'Microsoft Windows','Win') , REPLACE (OS.CSDVersion0,'Service Pack','SP') ,
  CS.Manufacturer0 , CS.Model0 ,BIOS.SerialNumber0 , REPLACE (cs.SystemType0,'-based PC',''),
CASE
  WHEN U.TopConsoleUser0 = '-1' OR U.TopConsoleUser0 IS NULL THEN 'N/A'
  ELSE U.TopConsoleUser0
END,
CASE SE.ChassisTypes0
  when '1' then 'Other'
  when '2' then 'Unknown'
  when '3' then 'Desktop'
  when '4' then 'Low Profile Desktop'
  when '5' then 'Pizza Box'
  when '6' then 'Mini Tower'
  when '7' then 'Tower'
  when '8' then 'Portable'
  when '9' then 'Laptop'
  when '10' then 'Notebook'
  when '11' then 'Hand Held'
  when '12' then 'Docking Station'
  when '13' then 'All in One'
  when '14' then 'Sub Notebook'
  when '15' then 'Space-Saving'
  when '16' then 'Lunch Box'
  when '17' then 'Main System Chassis'
  when '18' then 'Expansion Chassis'
  when '19' then 'SubChassis'
  when '20' then 'Bus Expansion Chassis'
  when '21' then 'Peripheral Chassis'
  when '22' then 'Storage Chassis'
  when '23' then 'Rack Mount Chassis'
  when '24' then 'Sealed-Case PC'
  else 'Undefinded'
END ,
 
BIOS.ReleaseDate0 ,
BIOS.SMBIOSBIOSVersion0
 
ORDER BY sys.Name0