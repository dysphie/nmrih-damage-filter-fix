

#include <sdkhooks>

public Plugin myinfo = {
    name        = "[NMRiH] Damage Filter Fix",
    author      = "Dysphie",
    description = "Fixes damage filters not working",
    version     = "1.0.0",
    url         = ""
};

int offs_m_hDamageFilter;
int offs_m_iDamageType;
int offs_m_bNegated;

public void OnPluginStart()
{
	char version[32];
	FindConVar("nmrih_version").GetString(version, sizeof(version));

	if (!StrEqual(version, "1.12.1"))
		SetFailState("This plugin is no longer required");

	GameData gamedata = new GameData("filterfix.games");
	if (!gamedata)
		SetFailState("Failed to open gamedata file filterfix.games");
	
	offs_m_hDamageFilter = GetOffsetOrFail(gamedata, "CBaseEntity::m_hDamageFilter");
	offs_m_bNegated = GetOffsetOrFail(gamedata, "CBaseFilter::m_bNegated");
	offs_m_iDamageType = GetOffsetOrFail(gamedata, "FilterDamageType::m_iDamageType");
}

int GetOffsetOrFail(GameData gamedata, const char[] key)
{
	int offs = gamedata.GetOffset(key);
	if (offs == -1)
		SetFailState("Failed to get offset %s", key);
	return offs;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	SDKHookEx(entity, SDKHook_OnTakeDamage, OnEntityDamage);
}

Action OnEntityDamage(int entity, int& attacker, int& inflictor, float& damage, 
	int& damagetype, int& weapon, float damageForce[3], float damagePosition[3])
{
	if (attacker != -1)
	{
		int filter = GetEntDataEnt2(entity, offs_m_hDamageFilter);
		if (filter != -1)
		{
			bool shouldDmg = GetEntData(filter, offs_m_iDamageType) == damagetype;

			if (GetEntData(filter, offs_m_bNegated))
				shouldDmg = !shouldDmg;

			if (!shouldDmg)
				return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}