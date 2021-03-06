/*

	About: player vehicle system
	Author: ziggi

*/


#if defined _pvehicle_included
	#endinput
#endif

#define _pvehicle_included


#define VEHICLE_COMPONENTS 14

new vehicle_increase_levels[] = {PLAYER_VEHICLE_INCREASE_LEVELS};

#define MAX_PLAYER_VEHICLES    sizeof(vehicle_increase_levels)

enum pvInfo {
	pv_ID,
	pv_Model,
	pv_Color[2],
	Float:pv_Fuel,
	VehicleDoorsAccess:pv_Access,
	pv_Paintjob,
	pv_Component[VEHICLE_COMPONENTS]
}
static PlayerVehicle[MAX_PLAYERS][MAX_PLAYER_VEHICLES][pvInfo];

/*
	For publics
*/

PVehicle_OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	for (new i = 0; i < MAX_PLAYER_VEHICLES; i++) {
		RemovePlayerVehicle(playerid, i);
	}
	return 1;
}

PVehicle_OnVehicleDeath(vehicleid, killerid)
{
	#pragma unused killerid
	foreach (new playerid : Player) {
		new slot = GetPlayerVehicleSlotByID(playerid, vehicleid);
		if (slot != -1) {
			SetTimerEx("DestroyPlayerVehicle", 4000, 0, "d", vehicleid);
			PlayerVehicle[playerid][slot][pv_ID] = 0;
			vehicleid = 0;
			break;
		}
	}
	return 1;
}

PVehicle_OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	new slot = GetPlayerVehicleSlotByID(playerid, vehicleid);
	if (slot == -1) {
		return 0;
	}
	PlayerVehicle[playerid][slot][pv_Paintjob] = paintjobid;
	return 1;
}

PVehicle_OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	new slot = GetPlayerVehicleSlotByID(playerid, vehicleid);
	if (slot == -1) {
		return 0;
	}
	PlayerVehicle[playerid][slot][pv_Color][0] = color1;
	PlayerVehicle[playerid][slot][pv_Color][1] = color2;
	return 1;
}

PVehicle_OnVehicleTuning(playerid, vehicleid, componentid)
{
	new slot = GetPlayerVehicleSlotByID(playerid, vehicleid);
	if (slot == -1) {
		return 0;
	}
	PlayerVehicle[playerid][slot][pv_Component][ GetVehicleComponentType(componentid) ] = componentid;
	return 1;
}

/*
	Functions
*/

stock AddPlayerVehicle(playerid, model, color1, color2, Float:fuel, VehicleDoorsAccess:access = VehicleDoorsAccess_Everyone,
                       paintjob = -1, component[VEHICLE_COMPONENTS] = {0, ...})
{
	new slot = GetPlayerVehicleFreeSlot(playerid);
	PlayerVehicle[playerid][slot][pv_ID] = 0;
	PlayerVehicle[playerid][slot][pv_Model] = model;
	PlayerVehicle[playerid][slot][pv_Color][0] = color1;
	PlayerVehicle[playerid][slot][pv_Color][1] = color2;
	PlayerVehicle[playerid][slot][pv_Fuel] = fuel;
	PlayerVehicle[playerid][slot][pv_Access] = access;
	PlayerVehicle[playerid][slot][pv_Paintjob] = paintjob;
	for (new i = 0; i < VEHICLE_COMPONENTS; i++) {
		PlayerVehicle[playerid][slot][pv_Component][i] = component[i];
	}
	return slot;
}

stock RemovePlayerVehicle(playerid, slot)
{
	if (GetVehicleModel(PlayerVehicle[playerid][slot][pv_ID]) != 0) {
		DestroyVehicle(PlayerVehicle[playerid][slot][pv_ID]);
		PlayerVehicle[playerid][slot][pv_ID] = 0;
	}
	PlayerVehicle[playerid][slot][pv_ID] = 0;
	PlayerVehicle[playerid][slot][pv_Model] = 0;
	PlayerVehicle[playerid][slot][pv_Color][0] = 0;
	PlayerVehicle[playerid][slot][pv_Color][1] = 0;
	PlayerVehicle[playerid][slot][pv_Fuel] = 0;
	PlayerVehicle[playerid][slot][pv_Access] = VehicleDoorsAccess_Invalid;
	PlayerVehicle[playerid][slot][pv_Paintjob] = -1;
	for (new i = 0; i < VEHICLE_COMPONENTS; i++) {
		PlayerVehicle[playerid][slot][pv_Component][i] = 0;
	}
	return 1;
}

stock CreatePlayerVehicle(playerid, slot, Float:pveh_X, Float:pveh_Y, Float:pveh_Z, Float:pveh_A)
{
	new vehicleid;

	// ���� ��������� ������
	vehicleid = PlayerVehicle[playerid][slot][pv_ID];
	if (vehicleid != 0) {
		foreach (new id : Player) {
			if(GetPlayerVehicleID(id) == vehicleid) {
				RemovePlayerFromVehicle(id);
			}
		}
		SetVehiclePos(vehicleid, pveh_X, pveh_Y, pveh_Z);
		SetVehicleZAngle(vehicleid, pveh_A);
		return vehicleid;
	}

	// ���� �� ������, �� ������
	vehicleid = CreateVehicle(
		PlayerVehicle[playerid][slot][pv_Model],
		pveh_X, pveh_Y, pveh_Z, pveh_A,
		PlayerVehicle[playerid][slot][pv_Color][0], PlayerVehicle[playerid][slot][pv_Color][1],
		GetVehicleRespawnTime()
	);

	PlayerVehicle[playerid][slot][pv_ID] = vehicleid;

	SetVehicleFuel(vehicleid, PlayerVehicle[playerid][slot][pv_Fuel]);
	SetPlayerVehicleDoorsAccess(vehicleid, playerid, PlayerVehicle[playerid][slot][pv_Access], slot);

	if (PlayerVehicle[playerid][slot][pv_Paintjob] != -1) {
		ChangeVehiclePaintjob(vehicleid, PlayerVehicle[playerid][slot][pv_Paintjob]);
	}

	for (new i = 0; i < VEHICLE_COMPONENTS; i++) {
		AddVehicleComponent(vehicleid, PlayerVehicle[playerid][slot][pv_Component][i]);
	}

	return vehicleid;
}

stock CreateVehicleDbString(playerid, slot)
{
	if (PlayerVehicle[playerid][slot][pv_ID] != 0) {
		PlayerVehicle[playerid][slot][pv_Fuel] = GetVehicleFuel(PlayerVehicle[playerid][slot][pv_ID]);
	}
	new vehstr[MAX_STRING];
	format(vehstr, sizeof(vehstr), "%d/%d/%d/%f/%d/%d",
		PlayerVehicle[playerid][slot][pv_Model], PlayerVehicle[playerid][slot][pv_Color][0], PlayerVehicle[playerid][slot][pv_Color][1],
		PlayerVehicle[playerid][slot][pv_Fuel], _:PlayerVehicle[playerid][slot][pv_Access], PlayerVehicle[playerid][slot][pv_Paintjob]
	);
	for (new i = 0; i < VEHICLE_COMPONENTS; i++) {
		format(vehstr, sizeof(vehstr), "%s/%d", vehstr, PlayerVehicle[playerid][slot][pv_Component][i]);
	}
	return vehstr;
}

stock SetVehicleFromDbString(playerid, slot, dbstring[])
{
	if (sscanf(dbstring, "p</>ia<i>[2]fiia<i>[" #VEHICLE_COMPONENTS "]",
		    PlayerVehicle[playerid][slot][pv_Model],
		    PlayerVehicle[playerid][slot][pv_Color],
		    PlayerVehicle[playerid][slot][pv_Fuel],
		    _:PlayerVehicle[playerid][slot][pv_Access],
		    PlayerVehicle[playerid][slot][pv_Paintjob],
		    PlayerVehicle[playerid][slot][pv_Component])
		) {
		return 0;
	}

	return 1;
}

stock GetPlayerVehicleSlotByID(playerid, vehicleid)
{
	for (new i = 0; i < MAX_PLAYER_VEHICLES; i++) {
		if (PlayerVehicle[playerid][i][pv_ID] == vehicleid) {
			return i;
		}
	}
	return -1;
}

stock GetPlayerVehicleFreeSlot(playerid)
{
	for (new i = 0; i < MAX_PLAYER_VEHICLES; i++) {
		if (PlayerVehicle[playerid][i][pv_Model] == 0) {
			return i;
		}
	}
	return -1;
}

stock GetPlayerVehicleCount(playerid)
{
	new count = 0;
	for (new i = 0; i < MAX_PLAYER_VEHICLES; i++) {
		if (PlayerVehicle[playerid][i][pv_Model] != 0) {
			count++;
		}
	}
	return count;
}

stock GetPlayerVehicleMaximumCount(playerid)
{
	return GetVehicleMaximumCountByLevel( GetPlayerLevel(playerid) );
}

stock GetVehicleMaximumCountByLevel(level)
{
	new count = 0;

	for (new i = 0; i < MAX_PLAYER_VEHICLES; i++) {
		if (level >= vehicle_increase_levels[i]) {
			count++;
		}
	}

	return count;
}

stock IsValidPlayerVehicleSlot(playerid, slot)
{
	if (PlayerVehicle[playerid][slot][pv_Model] == 0) {
		return 0;
	}
	return 1;
}

stock ChangePlayerVehicleColor(playerid, vehicleid, color1, color2)
{
	OnVehicleRespray(playerid, vehicleid, color1, color2);
	return ChangeVehicleColor(vehicleid, color1, color2);
}

stock GetPlayerVehicleCostBySlot(playerid, slot)
{
	return GetVehicleModelCost( PlayerVehicle[playerid][slot][pv_Model] );
}

stock GetPlayerVehicleSellCostBySlot(playerid, slot)
{
	return GetVehicleModelSellCost( PlayerVehicle[playerid][slot][pv_Model] );
}

stock GetPlayerVehicleModelBySlot(playerid, slot)
{
	return PlayerVehicle[playerid][slot][pv_Model];
}

stock SetPlayerVehicleDoorsAccess(vehicleid, playerid, VehicleDoorsAccess:status, slot = -1)
{
	if (slot == -1) {
		slot = GetPlayerVehicleSlotByID(playerid, vehicleid);
		if (slot == -1) {
			return 0;
		}
	}

	PlayerVehicle[playerid][slot][pv_Access] = status;
	SetVehicleDoorsAccess(vehicleid, playerid, status);
	return 1;
}

stock ChangePlayerVehicleDoorsAccess(vehicleid, playerid, slot = -1)
{
	if (slot == -1) {
		slot = GetPlayerVehicleSlotByID(playerid, vehicleid);
		if (slot == -1) {
			return 0;
		}
	}

	ChangeVehicleDoorsAccess(vehicleid, playerid);
	PlayerVehicle[playerid][slot][pv_Access] = GetVehicleDoorsAccess(vehicleid);
	return 1;
}

stock RemovePlayerVehicleComponents(playerid, slot)
{
	for (new i = 0; i < VEHICLE_COMPONENTS; i++) {
		if (PlayerVehicle[playerid][slot][pv_ID] != 0) {
			RemoveVehicleComponent(PlayerVehicle[playerid][slot][pv_ID], PlayerVehicle[playerid][slot][pv_Component][i]);
		}
		PlayerVehicle[playerid][slot][pv_Component][i] = 0;
	}
}

forward DestroyPlayerVehicle(vehicleid);
public DestroyPlayerVehicle(vehicleid)
{
	return DestroyVehicle(vehicleid);
}

stock GetPlayerVehicleNearestLevel(playerid)
{
	new level = GetPlayerLevel(playerid);
	for (new i = 0; i < sizeof(vehicle_increase_levels); i++) {
		if (vehicle_increase_levels[i] > level) {
			return vehicle_increase_levels[i];
		}
	}
	return -1;
}
