#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define NAME "[CS:S]sm_disablescope"
#define AUTHOR "abnerfs, Bara, BallGanda"
#define DESCRIPTION "sm_disablescope of selected weapons & limit air or ground use"
#define PLUGIN_VERSION "0.0.b1"
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

// '\0' is null 
int m_flNextSecondaryAttack = '\0';

bool ScopeReset = false;

public void OnPluginStart()
{
	CheckGameVersion();

	RegAdminCmd("sm_disablescope", smAbout, ADMFLAG_BAN, "sm_disablescope info in console");

	CreateConVar("sm_disablescope_version", PLUGIN_VERSION, NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	g_cvEnablePlugin = CreateConVar("sm_disablescope_enable", "1", "sm_disablescope_enable enables the plugin <1|0>");
	g_cvDisableScopeAwp = CreateConVar("sm_disablescope_awp", "1", "Disable the AWP scope <1|0>");
	g_cvDisableScopeScout = CreateConVar("sm_disablescope_scout", "1", "Disable the scout scope <1|0>");
	g_cvDisableScopeAutoSnipers = CreateConVar("sm_disablescope_autosnipers", "1", "Disable the auto snipers scope <1|0>");
	g_cvDisableScopeWeakSnipers = CreateConVar("sm_disablescope_weaksnipers", "1", "Disable the weak snipers scope <1|0>");
	g_cvDisableInAir = CreateConVar("sm_disablescope_inair", "1", "Disable Scope when the player is jumping/off ground <1|0>");
	g_cvDisableOnGround = CreateConVar("sm_disablescope_onground", "0", "Disable Scope when the player is on ground <1|0>");
	
	AutoExecConfig(true, "sm_disablescope");
	
	//Get the offset for m_flNextSecondaryAttack
	m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");

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
}

public Action OnPreThink(int client)
{
	if(!g_cvEnablePlugin.BoolValue)
	{
		return Plugin_Handled;
	}
	
	int activeWeapon;
	activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if(IsNoScopeWeapon(activeWeapon))
	{
		DisableScope(client, activeWeapon);
	}
	return Plugin_Continue;
}

stock void DisableScope(int client, int entityNumber)
{
	if (ScopeReset && !g_cvDisableOnGround.BoolValue && (GetEntityFlags(client) & FL_ONGROUND))
	{
		SetEntDataFloat(entityNumber, m_flNextSecondaryAttack, GetGameTime() - 1.0);
		ScopeReset = false;
	}
	
	if (g_cvDisableOnGround.BoolValue && (GetEntityFlags(client) & FL_ONGROUND))
	{
		SetEntDataFloat(entityNumber, m_flNextSecondaryAttack, GetGameTime() + 2.0);
		ScopeReset = true;
		int fov;
		GetEntProp(client, Prop_Send, "m_iFOV", fov);
		if (fov < 90)
		{
			SetEntProp(client, Prop_Send, "m_iFOV", 90);
		}
	}
	
	if (ScopeReset && !g_cvDisableInAir.BoolValue && !(GetEntityFlags(client) & FL_ONGROUND))
	{
		SetEntDataFloat(entityNumber, m_flNextSecondaryAttack, GetGameTime() - 1.0);
		ScopeReset = false;
	}
	
	if (g_cvDisableInAir.BoolValue && !(GetEntityFlags(client) & FL_ONGROUND))
	{
		SetEntDataFloat(entityNumber, m_flNextSecondaryAttack, GetGameTime() + 2.0);
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
	PrintToConsole(client, "sm_disablescope_enable");
	PrintToConsole(client, "sm_disablescope_awp");
	PrintToConsole(client, "sm_disablescope_scout");
	PrintToConsole(client, "sm_disablescope_autosnipers");
	PrintToConsole(client, "sm_disablescope_weaksnipers");
	PrintToConsole(client, "sm_disablescope_inair");
	PrintToConsole(client, "sm_disablescope_onground");
	return Plugin_Continue;
}
