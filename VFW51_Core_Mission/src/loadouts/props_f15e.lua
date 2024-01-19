-- JHMCS, SOP laser code, LAU3 single ROF
---@diagnostic disable: undefined-global
PropertyData = {
    ["HumanOrchestra"] = false,
    ["InitAirborneTime"] = 0,
    ["InitAlertStatus"] = false,
    ["LCFTLaserCode"] = 500 + (10 * InjectGroupNum) + InjectUnitNum,
    ["MountNVG"] = false,
    ["needsGCAlign"] = false,
    ["NetCrewControlPriority"] = 0,
    ["RCFTLaserCode"] = 500 + (10 * InjectGroupNum) + InjectUnitNum,
    ["SoloFlight"] = false,
    ["Sta2LaserCode"] = 500 + (10 * InjectGroupNum) + InjectUnitNum,
    ["Sta5LaserCode"] = 500 + (10 * InjectGroupNum) + InjectUnitNum,
    ["Sta8LaserCode"] = 500 + (10 * InjectGroupNum) + InjectUnitNum,
} -- end of PropertyData
