# `KBT_Flight_Card`: Flight Information Card

The `KBT_Flight_Card.svg` template supports kneeboards that contain basic flight information
for a flight including details like roster, loadouts, AAR, relevant airbases. This generates
kneeboards that look like this,

![](images/KBT_Flight_Card_Example.png)

The structure of this kneeboard is fixed (that is, there is always a "Hack" field at the top
of the kneeboard, an "Arrivals & Alternates" table at the bottom, etc) but the specific
information on the kneeboard can be changed through the description file.

## Overview

This template is made up of six sections (*Mission Data*, *Ground Procedures*, 
*Takeoff / Departure / Enroute*, *SPINS*, *AAR*, and *Arrival & Alternates*) that each carry
summary information on different phases of a mission (departure, enroute, etc.) or important
frequencies and details. Each section holds multiple fields that may be set by the description
file. All content on this kneeboard is optional and any field may be empty as desired.

> While a given field may not be filled in, you cannot remove unused fields from the kneeboard
> and replace them with other content.

## Descriptions

The sample description file for this kneeboard is
[here](sdefs/Description_Flight_Card.xlsx).

> For correct operation, do **not** change field names in Column B.

The *Mission Data* section supplies overview information on the mission and has the following
fields,

|Field|Description|
|:---:|-----------|
|Hack                | Hack time for mission
|Mission&nbsp;Type   | Mission type; for example, "SEAD", "BARCAP", "Strike".
|ALR                 | Acceptable level of risk for mission; for example, "Extreme", "Low"
|Fuel&nbsp;JOKER     | JOKER fuel level
|Fuel&nbsp;BINGO     | BINGO fuel level
|Fuel&nbsp;EMER      | Emergency fuel level
|Threats             | Threat information. Two lines are available, line breaks in the field value specify where lines are broken when building the output
|FL                  | Flight abbreviation, typically first and lest letter of name plus the flight number. For example, PYTHON2 would use "PN2" for this field
|Pilot&nbsp;*N*      | Pilot callsign for position *N* in the flight
|T&nbsp;*N*          | Five-digit tag for position *N* in the flight; for example, a TNDL value in the VIPER
|Loadout&nbsp;*N*    | Loadout information for position *N* in the flight

Here, *N* is the position number within the flight and is either "1", "2", "3", or "4".

The *Ground Procedures* section supplies information on ground operations pre- and post-flight.
This section has the following fields,

|Field|Description|
|:---:|-----------|
|Step&nbsp;Time      | Step time
|COMM&nbsp;ATIS      | ATIS frequency at departure airport
|COMM&nbsp;TWR       | Tower frequency at departure airport
|Startup             | Startup instructions. Two lines are available, line breaks in the field value specify where lines are broken when building the output
|COMM&nbsp;Flight    | Inter-flight communications frequency
|TACAN&nbsp;Flight   | TACAN to use for flight yardstick
|Ground&nbsp;Taxi    | Ground taxi instructions from parking to departure runway

The *Takeoff / Departure / Enroute* section supplies information on getting to and from the
AO. This section has the following fields,

|Field|Description|
|:---:|-----------|
|Enroute&nbsp;Takeoff  | Take off instructions, runway, etc.
|Enroute&nbsp;Rejoin   | Rejoin instructions for forming up post departure
|Enroute&nbsp;Climb    | Climb instructions for enroute portion of mission
|Enroute&nbsp;Routing  | Routing instructions from departure point to AO
|Enroute&nbsp;Checks   | System check reminders for the enroute portion of the flight
|Enroute&nbsp;Check&nbsp;In | Frequencies and agencies for check-in following departure during enroute

The *SPINS* section summarizes information on special instructions for the mission. This
section has the following fields,

|Field|Description|
|:---:|-----------|
|SPINS&nbsp;IFF      | Summary of IFF requriements
|SPINS&nbsp;ROE      | Summary of rules of engagement
|SPINS&nbsp;Notes    | General notes. Two lines are available, line breaks in the field value specify where lines are broken when building the output

The *AAR* section supplies information on tankers available for air-to-air refueling. The
kneeboard has space for up to two AAR flights. This section has the following fields,

|Field|Description|
|:---:|-----------|
|AAR *N* Flight    | Callsign for AAR flight *N*
|AAR *N* FRQ TACAN | Frequency and TACAN information for AAR flight *N*
|AAR *N* Notes     | Notes on AAR flight *N* including altitude, track, etc.

Here, *N* is the AAR number and is either "1" or "2".

The *Arrival & Alternatives* section supplies information on arrival and alternate airbases
for the mission. The kneeboard has space for a primary and two alternate airbases. This section
has the following fields,

|Field|Description|
|:---:|-----------|
|*X* I        | Airbase ICAO code for airbase *X*
|*X* R        | Active runway for airbase *X*
|*X* A        | ATIS frequency for airbase *X*
|*X* T        | Tower frequency for airbase *X*
|*X* NAVAIDS  | NAVAIDS (VORTAC, TACAN, ILS, etc.) for airbase *X*

Here, *X* specifies the base the data applies to and is either "P" (primary), "1" (alternate
#1), or "2" (alternate #2).
