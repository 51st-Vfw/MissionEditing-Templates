-- ************************************************************************************************************
-- 
-- VFW51WorkflowGetMission: Extract the mission name from a mission directory path
--
-- ************************************************************************************************************

print(string.match(arg[1], ".-([^:\\]+)$"))
