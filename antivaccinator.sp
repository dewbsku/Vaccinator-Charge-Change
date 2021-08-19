#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <tf2condhooks>
#pragma newdecls required
#pragma semicolon 1
#pragma tabsize 0

#define FIRST_CHARGE TFCond_StealthedUserBuffFade
#define SECOND_CHARGE TFCond_KingAura
#define THIRD_CHARGE TFCond_SwimmingNoEffects

public Plugin myinfo =
{
	name = "Anti Vaccinator",
	author = "Dooby Skoo",
	description = "Changes the vaccinator",
	version = "0.1.0",
	url = "https://github.com//dewbsku"
};

public Action TF2_OnAddCond(int client, TFCond &condition, float &time, int &provider){
	//get rid of passives
	if(condition == TFCond_SmallBulletResist) return Plugin_Handled;
	if(condition == TFCond_SmallBlastResist) return Plugin_Handled;
	if(condition == TFCond_SmallFireResist) return Plugin_Handled;
	//bullet
	if(condition == TFCond_UberBulletResist){
		condition = FIRST_CHARGE;
		return Plugin_Changed;
	}
	//explosive
	if(condition == TFCond_UberBlastResist){
		condition = SECOND_CHARGE;
		return Plugin_Changed;
	}
	//fire
	if(condition == TFCond_UberFireResist){
		condition = THIRD_CHARGE;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]){
	if(buttons & IN_ATTACK2 && TF2_GetPlayerClass(client) == TFClass_Medic){
		int healed = GetHealingTarget(client);
		int chargeType = GetChargeType(client);

		if(healed==-1) healed = client; 
		if(TF2_IsPlayerInCondition(client, FIRST_CHARGE) && TF2_IsPlayerInCondition(healed, FIRST_CHARGE) && chargeType == 1){
			buttons -= IN_ATTACK2;
			return Plugin_Continue;
		}

		if(TF2_IsPlayerInCondition(client, SECOND_CHARGE) && TF2_IsPlayerInCondition(healed, SECOND_CHARGE) && chargeType == 2){
			buttons -= IN_ATTACK2;
			return Plugin_Continue;
		}

		if(TF2_IsPlayerInCondition(client, THIRD_CHARGE) && TF2_IsPlayerInCondition(healed, THIRD_CHARGE) && chargeType == 3){
			buttons -= IN_ATTACK2;
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}


int GetHealingTarget(int client, bool checkgun=true)
{
    int medigun=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
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

int GetChargeType(int client){
	int charge = -1;
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	char classname[64];
	GetEdictClassname(medigun, classname, sizeof(classname));
	if(StrEqual("tf_weapon_medigun", classname)) charge = GetEntProp(medigun, Prop_Send, "m_nChargeResistType");
	return charge+1;
}
