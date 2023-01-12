#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define m_flNextSecondaryAttack FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack")

#define NAME "[CS:S]sm_disablescope"
#define AUTHOR "abnerfs,Bara, Neuro Toxin, BallGanda"
#define DESCRIPTION "sm_disablescope of selected weapons & limit air or ground use"
#define PLUGIN_VERSION "0.0.b1"
#define URL "https://github.com/Ballganda/SourceMod-sm_give"

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

public void OnPluginStart()
{
	CheckGameVersion();

	//RegAdminCmd("sm_disablescope", About, ADMFLAG_BAN, "sm_disablescope info in console");

	CreateConVar("sm_disablescope_version", PLUGIN_VERSION, "Disable Scopes", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	g_cvEnablePlugin = CreateConVar("sm_disablescope_enable", "1", "sm_disablescope_enable enables the plugin <1|0>");
	g_cvDisableScopeAwp = CreateConVar("sm_disablescope_awp", "1", "Disable the AWP scope <1|0>");
	g_cvDisableScopeScout = CreateConVar("sm_disablescope_scout", "0", "Disable the scout scope <1|0>");
	g_cvDisableScopeAutoSnipers = CreateConVar("sm_disablescope_autosnipers", "1", "Disable the auto snipers scope <1|0>");
	g_cvDisableScopeWeakSnipers = CreateConVar("sm_disablescope_weaksnipers", "1", "Disable the weak snipers scope <1|0>");
	g_cvDisableInAir = CreateConVar("sm_disablescope_inair", "0", "Disable Scope when the player is jumping/off ground <1|0>");
	g_cvDisableOnGround = CreateConVar("sm_disablescope_onground", "1", "Disable Scope when the player is on ground <1|0>");
	
	//will create a file named cfg/sourcemod/<sm_pluginname>.cfg
	AutoExecConfig(true, "sm_disablescope");

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
	
	int iWeapon;
	iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if(IsNoScopeWeapon(iWeapon))
	{
		DisableScope(client, iWeapon);
	}
	return Plugin_Continue;
}

stock void DisableScope(int client, int entitynumber)
{
	if (g_cvDisableInAir.BoolValue && !(GetEntityFlags(client) & FL_ONGROUND))
	{
		if (GetEntProp(client, Prop_Send, "m_bIsScoped"))
		{
			SetEntProp(entitynumber, Prop_Send, "m_zoomLevel", 0);
			SetEntProp(client, Prop_Send, "m_iFOV", 90);
			SetEntProp(client, Prop_Send, "m_bIsScoped", 0);
			SetEntProp(client, Prop_Send, "m_bResumeZoom", 0);
		}
		
		SetEntDataFloat(entitynumber, m_flNextSecondaryAttack, 0.0);
	}
	else if (g_cvDisableOnGround.BoolValue && (GetEntityFlags(client) & FL_ONGROUND))
	{
		if (GetEntProp(client, Prop_Send, "m_bIsScoped"))
		{
			SetEntProp(entitynumber, Prop_Send, "m_zoomLevel", 0);
			SetEntProp(client, Prop_Send, "m_iFOV", 90);
			SetEntProp(client, Prop_Send, "m_bIsScoped", 0);
			SetEntProp(client, Prop_Send, "m_bResumeZoom", 0);
		}
		
		SetEntDataFloat(entitynumber, m_flNextSecondaryAttack, 0.0);
	}
	else
	{
		SetEntDataFloat(entitynumber, m_flNextSecondaryAttack, 0.0);
	}
}

bool IsNoScopeWeapon(int entitynumber)
{
	char sCheckClassname[MAX_NAME_LENGTH];
	if(!GetEdictClassname(entitynumber, sCheckClassname, sizeof(sCheckClassname)))
	{
		return false;
	}
	
	if(g_cvDisableScopeAwp.BoolValue)
	{
		if(StrEqual(sCheckClassname, "weapon_awp"))
		{
			return true;
		}
	}
	
	if(g_cvDisableScopeScout.BoolValue)
	{
		if(StrEqual(sCheckClassname, "weapon_scout"))
		{
			return true;
		}
	}

	if(g_cvDisableScopeAutoSnipers.BoolValue)
	{
		if(StrEqual(sCheckClassname, "weapon_g3sg1")
			|| StrEqual(sCheckClassname, "weapon_sg550"))
		{
			return true;
		}
	}
	
	if(g_cvDisableScopeWeakSnipers.BoolValue)
	{
		if(StrEqual(sCheckClassname, "weapon_sg552")
			|| StrEqual(sCheckClassname, "weapon_aug"))
		{
			return true;
		}
	}
	return false;
}

public void CheckGameVersion()
{
	if(GetEngineVersion() != Engine_CSS)
	{
		SetFailState("Only CS:S Supported");
	}
}

stock bool IsClientValid(int client)
{
	if(client > 0 
		&& client <= MaxClients
		&& IsClientInGame(client))
	{
		return true;
	}
	return false;
}

public void About(int client)
{
	PrintToConsole(client, "");
	PrintToConsole(client, "Plugin Name.......: %s", NAME);
	PrintToConsole(client, "Plugin Author.....: %s", AUTHOR);
	PrintToConsole(client, "Plugin Description: %s", DESCRIPTION);
	PrintToConsole(client, "Plugin Version....: %s", PLUGIN_VERSION);
	PrintToConsole(client, "Plugin URL........: %s", URL);
}
