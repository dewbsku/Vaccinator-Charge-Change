#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <tf2condhooks>
#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
	name = "Anti Vaccinator",
	author = "Dooby Skoo",
	description = "Changes the vaccinator",
	version = "0.2.0",
	url = "https://github.com//dewbsku"
};

public Action TF2_OnAddCond(int client, TFCond &condition, float &time, int &provider){
	//get rid of passives
	if(condition == TFCond_SmallBulletResist) return Plugin_Handled;
	if(condition == TFCond_SmallBlastResist) return Plugin_Handled;
	if(condition == TFCond_SmallFireResist) return Plugin_Handled;
	//get heal target
	int healed = GetHealingTarget(client);
	//bullet
	if(condition == TFCond_UberBulletResist){
		condition = TFCond_Ubercharged;
		return Plugin_Changed;
	}
	//explosive
	if(condition == TFCond_UberBlastResist){
		condition = TFCond_Kritzkrieged;
		return Plugin_Changed;
	}
	//fire
	if(condition == TFCond_UberFireResist){
		condition = TFCond_RunePrecision;
		return Plugin_Changed;
	}
}

int GetHealingTarget(int client, bool checkgun = false)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	char weapon_classname[64];
	GetEntityClassname( medigun, weapon_classname, sizeof weapon_classname );
	if(!StrEqual(weapon_classname, "tf_weapon_medigun")) return -1;
	if(!checkgun)
    {
        if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
        {
            return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
        }
        return -1;
    }

	if(IsValidEdict(medigun))
    {
        char classname[64];
        GetEdictClassname(medigun, classname, sizeof(classname));
        if(!strcmp(classname, "tf_weapon_medigun", false))
        {
            if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
            {
                return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
            }
        }
    }
	return -1;
}  

bool IsValidClient(int client) {
	return ( client > 0 && client <= MaxClients && IsClientInGame(client) );
}
