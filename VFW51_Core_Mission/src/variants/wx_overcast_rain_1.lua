-- ************************************************************************************************************
--
-- weather description file for overcast/rain 1 mission editor preset
--
-- contains a single table WxData that has a table with the value of the ["weather"] key for the .miz mission
-- file. the contents for this file can be extracted from an existing .miz with the extract.cmd script.
--
-- ************************************************************************************************************

WxData = {
    ["atmosphere_type"] = 0,
    ["clouds"] = {
        ["base"] = 2900,
        ["density"] = 0,
        ["iprecptns"] = 0,
        ["preset"] = "RainyPreset1",
        ["thickness"] = 200,
    }, -- end of ["clouds"]
    ["cyclones"] = {
    }, -- end of ["cyclones"]
    ["dust_density"] = 0,
    ["enable_dust"] = false,
    ["enable_fog"] = false,
    ["fog"] = {
        ["thickness"] = 0,
        ["visibility"] = 0,
    }, -- end of ["fog"]
    ["groundTurbulence"] = 0,
    ["halo"] = {
        ["preset"] = "auto",
    }, -- end of ["halo"]
    ["modifiedTime"] = false,
    ["name"] = "Winter, clean sky",
    ["qnh"] = 760,
    ["season"] = {
        ["temperature"] = 20,
    }, -- end of ["season"]
    ["type_weather"] = 0,
    ["visibility"] = {
        ["distance"] = 80000,
    }, -- end of ["visibility"]
    ["wind"] = {
        ["at2000"] = {
            ["dir"] = 0,
            ["speed"] = 0,
        }, -- end of ["at2000"]
        ["at8000"] = {
            ["dir"] = 0,
            ["speed"] = 0,
        }, -- end of ["at8000"]
        ["atGround"] = {
            ["dir"] = 0,
            ["speed"] = 0,
        }, -- end of ["atGround"]
    }, -- end of ["wind"]
} -- end of WxData
