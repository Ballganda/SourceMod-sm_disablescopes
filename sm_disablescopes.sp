#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define NAME "[CS:S]sm_disablescopes"
#define AUTHOR "abnerfs, Bara, BallGanda"
#define DESCRIPTION "sm_disablescopes of selected weapons & limit air or ground use"
#define PLUGIN_VERSION "0.0.b2"
#define URL "https://github.com/Ballganda/SourceMod-sm_disablescopes"

public Plugin myinfo = {
	name = NAME,
	author = AUTHOR,
	description = DESCRIPTION,
	version = PLUGIN_VERSION,
	url = URL
}

ConVar g_cvEnablePlugin = null;
ConVar g_cvDisableScopeAwp = null;
ConVar g_cvDisableScopeScout = null;
ConVar g_cvDisableScopeAutoSnipers = null;
ConVar g_cvDisableScopeWeakSnipers = null;
ConVar g_cvDisableInAir = null;
ConVar g_cvDisableOnGround = null;

bool ScopeReset[MAXPLAYERS + 1];

public void OnPluginStart()
{
	CheckGameVersion();

	RegAdminCmd("sm_disablescopes", smAbout, ADMFLAG_BAN, "sm_disablescopes info in console");

	CreateConVar("sm_disablescopes_version", PLUGIN_VERSION, NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	g_cvEnablePlugin = CreateConVar("sm_disablescopes_enable", "1", "sm_disablescopes_enable enables the plugin <1|0>");
	g_cvDisableScopeAwp = CreateConVar("sm_disablescopes_awp", "1", "Disable the AWP scope <1|0>");
	g_cvDisableScopeScout = CreateConVar("sm_disablescopes_scout", "1", "Disable the scout scope <1|0>");
	g_cvDisableScopeAutoSnipers = CreateConVar("sm_disablescopes_autosnipers", "1", "Disable the auto snipers scope <1|0>");
	g_cvDisableScopeWeakSnipers = CreateConVar("sm_disablescopes_weaksnipers", "1", "Disable the weak snipers scope <1|0>");
	g_cvDisableInAir = CreateConVar("sm_disablescopes_inair", "1", "Disable Scope when the player is jumping/off ground <1|0>");
	g_cvDisableOnGround = CreateConVar("sm_disablescopes_onground", "0", "Disable Scope when the player is on ground <1|0>");
	
	AutoExecConfig(true, "sm_disablescopes");

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientValid(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PreThink, OnPreThink);
	ScopeReset[client] = false;
}

public Action OnPreThink(int client)
{
	if(!g_cvEnablePlugin.BoolValue)
	{
		return Plugin_Handled;
	}
	
	int activeWeapon;
	activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(activeWeapon))
	{
		return Plugin_Continue;
	}
	
	if(IsNoScopeWeapon(activeWeapon))
	{
		DisableScope(client, activeWeapon);
	}
	return Plugin_Continue;
}

stock void DisableScope(int client, int entityNumber)
{
	int IsOnGround = (GetEntityFlags(client) & FL_ONGROUND);
	if (ScopeReset && !g_cvDisableOnGround.BoolValue && IsOnGround)
	{
		SetEntPropFloat(entityNumber, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() - 1.0);
		ScopeReset = false;
	}
	
	if (g_cvDisableOnGround.BoolValue && IsOnGround)
	{
		SetEntPropFloat(entityNumber, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 2.0);
		ScopeReset = true;
		int fov;
		GetEntProp(client, Prop_Send, "m_iFOV", fov);
		if (fov < 90)
		{
			SetEntProp(client, Prop_Send, "m_iFOV", 90);
		}
	}
	
	if (ScopeReset && !g_cvDisableInAir.BoolValue && !IsOnGround)
	{
		SetEntPropFloat(entityNumber, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() - 1.0);
		ScopeReset = false;
	}
	
	if (g_cvDisableInAir.BoolValue && !IsOnGround)
	{
		SetEntPropFloat(entityNumber, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 2.0);
		ScopeReset = true;
		int fov;
		GetEntProp(client, Prop_Send, "m_iFOV", fov);
		if (fov < 90)
		{
			SetEntProp(client, Prop_Send, "m_iFOV", 90);
		}
	}
}

bool IsNoScopeWeapon(int entityNumber)
{
	char checkClassname[MAX_NAME_LENGTH];
	GetEdictClassname(entityNumber, checkClassname, sizeof(checkClassname));
	
	if(g_cvDisableScopeAwp.BoolValue)
	{
		if(StrEqual(checkClassname, "weapon_awp"))
		{
			return true;
		}
	}
	
	if(g_cvDisableScopeScout.BoolValue)
	{
		if(StrEqual(checkClassname, "weapon_scout"))
		{
			return true;
		}
	}

	if(g_cvDisableScopeAutoSnipers.BoolValue)
	{
		if(StrEqual(checkClassname, "weapon_g3sg1")
			|| StrEqual(checkClassname, "weapon_sg550"))
		{
			return true;
		}
	}
	
	if(g_cvDisableScopeWeakSnipers.BoolValue)
	{
		if(StrEqual(checkClassname, "weapon_sg552")
			|| StrEqual(checkClassname, "weapon_aug"))
		{
			return true;
		}
	}
	return false;
}

void CheckGameVersion()
{
	if(GetEngineVersion() != Engine_CSS)
	{
		SetFailState("Only CS:S Supported");
	}
}

stock bool IsClientValid(int client)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		return true;
	}
	return false;
}

public Action smAbout(int client, int args)
{
	PrintToConsole(client, "");
	PrintToConsole(client, "Plugin Name.......: %s", NAME);
	PrintToConsole(client, "Plugin Author.....: %s", AUTHOR);
	PrintToConsole(client, "Plugin Description: %s", DESCRIPTION);
	PrintToConsole(client, "Plugin Version....: %s", PLUGIN_VERSION);
	PrintToConsole(client, "Plugin URL........: %s", URL);
	PrintToConsole(client, "List of cvars: ");
	PrintToConsole(client, "sm_disablescopes_version");
	PrintToConsole(client, "sm_disablescopes_enable <1|0>");
	PrintToConsole(client, "sm_disablescopes_awp <1|0>");
	PrintToConsole(client, "sm_disablescopes_scout <1|0>");
	PrintToConsole(client, "sm_disablescopes_autosnipers <1|0>");
	PrintToConsole(client, "sm_disablescopes_weaksnipers <1|0>");
	PrintToConsole(client, "sm_disablescopes_inair <1|0>");
	PrintToConsole(client, "sm_disablescopes_onground <1|0>");
	return Plugin_Continue;
}
