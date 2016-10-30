/*
	About: fastfood service
	Author: ziggi
*/

#if defined _fastfood_included
	#endinput
#endif

#define _fastfood_included

/*
	Defines
*/

#define MAX_FASTFOOD_ACTORS 37

/*
	Enums
*/

enum e_Fastfood_Info {
	e_ffType,
	Float:e_ffPosX,
	Float:e_ffPosY,
	Float:e_ffPosZ,
	e_ffActor_Model,
	Float:e_ffActor_PosX,
	Float:e_ffActor_PosY,
	Float:e_ffActor_PosZ,
	Float:e_ffActor_PosA,
	e_ffCheckpoint,
}

enum e_Food_Info {
	e_fNameVar[MAX_LANG_VAR_STRING],
	e_fCost,
	Float:e_fHealth
}

/*
	Vars
*/

static gFastFoodPlace[][e_Fastfood_Info] = {
	{ENTEREXIT_TYPE_PIZZA,       373.4858, -119.4608, 1001.4922,    155,  373.5132, -117.0893, 1001.4995, 178.9151},
	{ENTEREXIT_TYPE_BURGER,      377.4426, -67.5379,  1001.5078,    205,  377.2474, -65.2258,  1001.5078, 180.7951},
	{ENTEREXIT_TYPE_CHICKEN,     369.3667, -6.3469,   1001.8516,    167,  369.3396, -4.1569,   1001.8516, 178.9150},
	{ENTEREXIT_TYPE_RESTAURANT, -784.5101,  505.0186, 1371.7422,    171, -782.3088,  504.5334, 1371.7422, 85.2274},
	{ENTEREXIT_TYPE_DONUTS,      379.4050, -190.5775, 1000.6328,    209,  380.6582, -188.8537, 1000.6328, 147.8714}
};

static gFoodInfo[][e_Food_Info] = {
	{"FASTFOOD_TYPE_0", 10, 10.0},
	{"FASTFOOD_TYPE_1", 15, 25.0},
	{"FASTFOOD_TYPE_2", 25, 50.0},
	{"FASTFOOD_TYPE_3", 35, 80.0},
	{"FASTFOOD_TYPE_4", 45, 100.0}
};

static
	gActors[MAX_FASTFOOD_ACTORS];

/*
	OnGameModeInit
*/

public OnGameModeInit()
{
	for (new id = 0; id < sizeof(gFastFoodPlace); id++) {
		gFastFoodPlace[id][e_ffCheckpoint] = CreateDynamicCP(gFastFoodPlace[id][e_ffPosX], gFastFoodPlace[id][e_ffPosY], gFastFoodPlace[id][e_ffPosZ], 1.5, .streamdistance = 20.0);
	}
	Log_Init("services", "Fastfood module init.");
	#if defined Fastfood_OnGameModeInit
		return Fastfood_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit Fastfood_OnGameModeInit
#if defined Fastfood_OnGameModeInit
	forward Fastfood_OnGameModeInit();
#endif

/*
	OnInteriorCreated
*/

public OnInteriorCreated(id, type, world)
{
	new slot;

	for (new i = 0; i < sizeof(gFastFoodPlace); i++) {
		if (type == gFastFoodPlace[i][e_ffType]) {
			slot = GetActorFreeSlot();
			if (slot == -1) {
				Log(systemlog, DEBUG, "fastfood.inc: Free slot not found. Increase MAX_FASTFOOD_ACTORS value.");
				break;
			}

			gActors[slot] = CreateActor(gFastFoodPlace[i][e_ffActor_Model],
				gFastFoodPlace[i][e_ffActor_PosX], gFastFoodPlace[i][e_ffActor_PosY], gFastFoodPlace[i][e_ffActor_PosZ],
				gFastFoodPlace[i][e_ffActor_PosA]
			);
			SetActorVirtualWorld(gActors[slot], world);
		}
	}
	#if defined Fastfood_OnInteriorCreated
		return Fastfood_OnInteriorCreated(id, type, world);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnInteriorCreated
	#undef OnInteriorCreated
#else
	#define _ALS_OnInteriorCreated
#endif

#define OnInteriorCreated Fastfood_OnInteriorCreated
#if defined Fastfood_OnInteriorCreated
	forward Fastfood_OnInteriorCreated(id, type, world);
#endif

/*
	OnActorStreamIn
*/

public OnActorStreamIn(actorid, forplayerid)
{
	for (new id = 0; id < sizeof(gActors); id++) {
		if (actorid == gActors[id]) {
			SetPVarInt(forplayerid, "fastfood_actor_id", actorid);
			ClearActorAnimations(actorid);
			return 1;
		}
	}
	#if defined Fastfood_OnActorStreamIn
		return Fastfood_OnActorStreamIn(actorid, forplayerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnActorStreamIn
	#undef OnActorStreamIn
#else
	#define _ALS_OnActorStreamIn
#endif

#define OnActorStreamIn Fastfood_OnActorStreamIn
#if defined Fastfood_OnActorStreamIn
	forward Fastfood_OnActorStreamIn(actorid, forplayerid);
#endif

/*
	OnPlayerEnterDynamicCP
*/

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	for (new id = 0; id < sizeof(gFastFoodPlace); id++) {
		if (checkpointid == gFastFoodPlace[id][e_ffCheckpoint]) {
			Dialog_Show(playerid, Dialog:ServiceFastfood);
			ApplyActorAnimation(GetPVarInt(playerid, "fastfood_actor_id"), "MISC", "Idle_Chat_02", 4.1, 0, 1, 1, 1, 1);
			return 1;
		}
	}
	#if defined Fastfood_OnPlayerEnterDynamicCP
		return Fastfood_OnPlayerEnterDynamicCP(playerid, checkpointid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicCP
	#undef OnPlayerEnterDynamicCP
#else
	#define _ALS_OnPlayerEnterDynamicCP
#endif

#define OnPlayerEnterDynamicCP Fastfood_OnPlayerEnterDynamicCP
#if defined Fastfood_OnPlayerEnterDynamicCP
	forward Fastfood_OnPlayerEnterDynamicCP(playerid, checkpointid);
#endif

/*
	Dialogs
*/

DialogCreate:ServiceFastfood(playerid)
{
	static
		name[MAX_LANG_VALUE_STRING],
		string[MAX_LANG_VALUE_STRING * (sizeof(gFoodInfo) + 1)];

	Lang_GetPlayerText(playerid, "FASTFOOD_DIALOG_LIST_HEADER", string);

	for (new i = 0; i < sizeof(gFoodInfo); i++) {
		Lang_GetPlayerText(playerid, gFoodInfo[i][e_fNameVar], name);
		Lang_GetPlayerText(playerid, "FASTFOOD_DIALOG_LIST_ITEM", string, _,
		                   string,
		                   name,
		                   gFoodInfo[i][e_fCost],
		                   gFoodInfo[i][e_fHealth]);
	}

	Dialog_Open(playerid, Dialog:ServiceFastfood, DIALOG_STYLE_TABLIST_HEADERS,
	            "FASTFOOD_DIALOG_HEADER",
	            string,
	            "FASTFOOD_DIALOG_BUTTON_0", "FASTFOOD_DIALOG_BUTTON_1",
	            MDIALOG_NOTVAR_INFO);
}

DialogResponse:ServiceFastfood(playerid, response, listitem, inputtext[])
{
	if (!response) {
		return 1;
	}

	new id = listitem;

	if (GetPlayerMoney(playerid) < gFoodInfo[id][e_fCost]) {
		Dialog_Message(playerid, "FASTFOOD_DIALOG_BUY_HEADER", "FASTFOOD_NOT_ENOUGH_MONEY", "FASTFOOD_DIALOG_BUTTON_OK");
		return 1;
	}

	new
		name[MAX_LANG_VALUE_STRING],
		Float:max_health,
		Float:health;

	Lang_GetPlayerText(playerid, gFoodInfo[id][e_fNameVar], name);
	GetMaxHealth(playerid, max_health);
	GetPlayerHealth(playerid, health);

	if (gFoodInfo[id][e_fHealth] + health > max_health) {
		SetPlayerHealth(playerid, max_health);
	} else {
		SetPlayerHealth(playerid, health + gFoodInfo[id][e_fHealth]);
	}

	GivePlayerMoney(playerid, -gFoodInfo[id][e_fCost]);
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 1, 1, 1, 1, 1);

	Dialog_Message(playerid,
	               "FASTFOOD_DIALOG_BUY_HEADER",
	               "FASTFOOD_DIALOG_INFORMATION_TEXT",
	               "FASTFOOD_DIALOG_BUTTON_OK",
	               MDIALOG_NOTVAR_NONE,
	               name,
	               gFoodInfo[id][e_fCost],
	               gFoodInfo[id][e_fHealth]);
	return 1;
}

stock IsPlayerAtFastgFoodInfo(playerid)
{
	for (new ff_id = 0; ff_id < sizeof(gFastFoodPlace); ff_id++) {
		if (IsPlayerInRangeOfPoint(playerid, 2, gFastFoodPlace[ff_id][e_ffPosX], gFastFoodPlace[ff_id][e_ffPosY], gFastFoodPlace[ff_id][e_ffPosZ])) {
			return 1;
		}
	}
	return 0;
}

/*
	Private functions
*/

static stock GetActorFreeSlot()
{
	static slot;

	if (slot >= sizeof(gActors)) {
		return -1;
	}

	return slot++;
}
