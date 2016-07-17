/*

	About: player kick system
	Author:	ziggi

*/

#if defined _player_kick_included
	#endinput
#endif

#define _player_kick_included

#if !defined MAX_KICK_REASON_LENGTH
	#define MAX_KICK_REASON_LENGTH 64
#endif

stock KickPlayer(playerid, reason[] = "", showreason = 1)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	if (strlen(reason) == 0) {
		__(playerid, ADMIN_COMMAND_KICK_NOREASON, reason, MAX_KICK_REASON_LENGTH);
	}

	new
		string[MAX_STRING],
		playername[MAX_PLAYER_NAME + 1];

	GetPlayerName(playerid, playername, sizeof(playername));

	if (IsPlayerHavePrivilege(playerid, PlayerPrivilegeRcon)) {
		format(string, sizeof(string), _(playerid, ADMIN_COMMAND_KICK_IS_ADMIN), reason);
		SendClientMessage(playerid, COLOR_YELLOW, string);
		return 0;
	}

	if (showreason) {
		format(string, sizeof(string), _(playerid, ADMIN_COMMAND_KICK_KICKED_SELF), reason);
		SendClientMessage(playerid, COLOR_RED, string);

		format(string, sizeof(string), _(playerid, ADMIN_COMMAND_KICK_KICKED), playername, reason);
		SendClientMessageToAll(COLOR_MISC, string);
	}

	GameTextForPlayer(playerid, "~r~Connection Lost.", 1000, 5);
	TogglePlayerControllable(playerid, 0);

	SetTimerEx("PlayerKickFix", 100, 0, "d", playerid);
	Log_Game("player: %s(%d): has been kicked. Reason: %s", playername, playerid, reason);
	return 1;
}

forward PlayerKickFix(playerid);
public PlayerKickFix(playerid)
{
	Kick(playerid);
}