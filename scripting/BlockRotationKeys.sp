#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <sourcebanspp>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

ConVar g_Method, g_Time;

bool SB;

public Plugin myinfo =
{
    name = "Block Rotation Keys[+left +right]",
	author = "Cruze",
    description = "Kick/Ban the player who uses +left/+right bind.",
    version = "1.0",
	url = "http://steamcommunity.com/profiles/76561198132924835"
};

public void OnPluginStart()
{
	g_Method = CreateConVar("sm_cheat_block_method", "1", "Block method? 0 = ban, 1 = kick.", _, true, 0.0, true, 2.0);
	g_Time = CreateConVar("sm_cheat_block_bantime", "30", "If sm_cheat_block_method is 2, ban time? 0 = permanent.", _, true, 0.0, false);
	
	AutoExecConfig();
	LoadTranslations("BlockRotationKeys.phrases");
	
	SB = LibraryExists("sourcebans");
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(!IsPlayerAlive(client)) return Plugin_Continue;

	if(buttons & IN_LEFT || buttons & IN_RIGHT)
	{
		if(g_Method.BoolValue)
		{
			KickClient(client, "%t", "KickedClient");
		}
		else
		{
			char smsg[64];
			if(g_Time.IntValue > 0)
			{
				if(g_Time.IntValue >= 2)
					Format(smsg, sizeof(smsg), "%t", "BannedClient", g_Time.IntValue);
				else
					Format(smsg, sizeof(smsg), "%t", "BannedClientForMinute", g_Time.IntValue);
			}
			else
			{
				Format(smsg, sizeof(smsg), "%t", "BannedClientPerm");
			}
			if(!SB)
			{
				BanClient(client, g_Time.IntValue, BANFLAG_AUTO, smsg, smsg);
			}
			else
			{
				SBPP_BanPlayer(0, client, g_Time.IntValue, smsg);
			}
		}
	}
	return Plugin_Continue;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "sourcebans"))
	{
		SB = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "sourcebans"))
	{
		SB = false;
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("SBBanPlayer");
	MarkNativeAsOptional("SBPP_BanPlayer");
}

