// test "boss"
// built upon the foundation of Vs Saxton Hale

::scout_model_path <- "models/player/scout.mdl";
::scout_viewmodel_path <- "models/weapons/c_models/c_scout_arms.mdl";
::scout_viewmodel_index <- GetModelIndex(scout_viewmodel_path);

::sniper_model_path <- "models/player/sniper.mdl";
::sniper_viewmodel_path <- "models/weapons/c_models/c_sniper_arms.mdl";
::sniper_viewmodel_index <- GetModelIndex(sniper_viewmodel_path);

::soldier_model_path <- "models/player/soldier.mdl";
::soldier_viewmodel_path <- "models/weapons/c_models/c_soldier_arms.mdl";
::soldier_viewmodel_index <- GetModelIndex(soldier_viewmodel_path);

::demoman_model_path <- "models/player/demo.mdl";
::demoman_viewmodel_path <- "models/weapons/c_models/c_demo_arms.mdl";
::demoman_viewmodel_index <- GetModelIndex(demoman_viewmodel_path);

::medic_model_path <- "models/player/medic.mdl";
::medic_viewmodel_path <- "models/weapons/c_models/c_medic_arms.mdl";
::medic_viewmodel_index <- GetModelIndex(medic_viewmodel_path);

::heavy_model_path <- "models/player/heavy.mdl";
::heavy_viewmodel_path <- "models/weapons/c_models/c_heavy_arms.mdl";
::heavy_viewmodel_index <- GetModelIndex(heavy_viewmodel_path);

::pyro_model_path <- "models/player/pyro.mdl";
::pyro_viewmodel_path <- "models/weapons/c_models/c_pyro_arms.mdl";
::pyro_viewmodel_index <- GetModelIndex(pyro_viewmodel_path);

::spy_model_path <- "models/player/spy.mdl";
::spy_viewmodel_path <- "models/weapons/c_models/c_spy_arms.mdl";
::spy_viewmodel_index <- GetModelIndex(spy_viewmodel_path);

::engineer_model_path <- "models/player/engineer.mdl";
::engineer_viewmodel_path <- "models/weapons/c_models/c_engineer_arms.mdl";
::engineer_viewmodel_index <- GetModelIndex(engineer_viewmodel_path);

class ThatSpy extends Boss
{
    name = "that_spy";

    function OnApply0Delay()
    {
        bosses[player] <- this;
        ClearPlayerWearables(player);
        BecomeClass(TF_CLASS_SNIPER)
    }


    function OnFrameTickAlive()
    {
        //get the disguise class
        local disguiseClass = NetProps.GetPropInt(player, "m_Shared.m_nDisguiseClass")

        //return early if the spy isn't disguised
        if(disguiseClass == 0)
        {
            return;
        }

        //print for debugging and run the disguise function
        print("Disguised as class ID: " + disguiseClass)
        BecomeClass(disguiseClass)

        //reset everything
        NetProps.SetPropInt(player, "m_Shared.m_nDisguiseClass", 0)
        player.RemoveCond(TF_COND_DISGUISED)
    }
    
    function BecomeClass(m_iClass)
    {
        switch (m_iClass)
        {
            case 1: // Scout
                player.SetCustomModelWithClassAnimations(scout_model_path);
                GivePlayerWeapon(player, "tf_weapon_scattergun", 13, m_iClass, scout_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_pistol", 23, m_iClass, scout_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_bat", 0, m_iClass, scout_viewmodel_path)
                break;
            case 2: // Sniper
                player.SetCustomModelWithClassAnimations(sniper_model_path);
                GivePlayerWeapon(player, "tf_weapon_compound_bow", 56, m_iClass, sniper_viewmodel_path) // huntsman because I hate fighting rifle snipers
                GivePlayerWeapon(player, "tf_weapon_smg", 16, m_iClass,sniper_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_club", 3, m_iClass, sniper_viewmodel_path)
                break;
            case 3: // Soldier
                player.SetCustomModelWithClassAnimations(soldier_model_path);
                GivePlayerWeapon(player, "tf_weapon_rocketlauncher", 18, m_iClass, soldier_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_shotgun_soldier", 10, m_iClass, soldier_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_shovel", 416, m_iClass, soldier_viewmodel_path)
                break;
            case 4: // Demo
                player.SetCustomModelWithClassAnimations(demoman_model_path);
                GivePlayerWeapon(player, "tf_weapon_grenadelauncher", 19, m_iClass, demoman_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_pipebomblauncher", 20, m_iClass,demoman_viewmodel_path)
                GivePlayerWeapon(player, "saxxy", 264, m_iClass,demoman_viewmodel_path) //pan because funny
                break;
            case 5: // Medic
                player.SetCustomModelWithClassAnimations(medic_model_path);
                GivePlayerWeapon(player, "tf_weapon_crossbow", 305, m_iClass, medic_viewmodel_path) //crusader's crossbow
                GivePlayerWeapon(player, "tf_weapon_medigun", 29, m_iClass, medic_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_bonesaw", 8, m_iClass, medic_viewmodel_path)
                break;
            case 6: // Heavy
                player.SetCustomModelWithClassAnimations(heavy_model_path);
                GivePlayerWeapon(player, "tf_weapon_minigun", 15, m_iClass, heavy_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_shotgun_hwg", 11, m_iClass, heavy_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_fists", 5, m_iClass, heavy_viewmodel_path)
                break;
            case 7:
                player.SetCustomModelWithClassAnimations(pyro_model_path);
                GivePlayerWeapon(player, "tf_weapon_flamethrower", 21, m_iClass, pyro_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_shotgun_pyro", 12, m_iClass, pyro_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_fireaxe", 2, m_iClass, pyro_viewmodel_path)
                break;
            case 8: // Spy
                return;
            case 9: // Engineer
                player.SetCustomModelWithClassAnimations(engineer_model_path);
                GivePlayerWeapon(player, "tf_weapon_shotgun_primary", 9, m_iClass, engineer_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_pistol", 22, m_iClass, engineer_viewmodel_path)
                GivePlayerWeapon(player, "tf_weapon_wrench", 7, m_iClass, engineer_viewmodel_path)
                break;
        }

        GivePlayerWeapon(player, "tf_weapon_pda_spy", 27, TF_CLASS_SPY, spy_viewmodel_path) //disguise kit
        GivePlayerWeapon(player, "tf_weapon_invis", 30, TF_CLASS_SPY, spy_viewmodel_path) //stock watch
    }
}

RegisterBoss("that_spy", ThatSpy);

::GivePlayerWeapon <- function(player, classname, item_id, class_animations, viewmodel_path) 
{
    // 1. Create and configure the weapon entity
    local weapon = Entities.CreateByClassname(classname);
    NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", item_id);
    NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true);
    
    weapon.SetTeam(player.GetTeam());
    weapon.DispatchSpawn();

    // 2. Remove existing weapon in that slot
    for (local i = 0; i < 8; i++) 
    {
        local held_weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i);
        if (held_weapon != null && held_weapon.GetSlot() == weapon.GetSlot()) 
        {
            held_weapon.Destroy();
            break;
        }
    }

    if(viewmodel_path != "")
    {
        NetProps.SetPropInt(player, "m_PlayerClass.m_iClass", class_animations); 
        
        weapon.SetCustomViewModel(viewmodel_path);
        
        RunWithDelay2(this, 0.1, function() {
            NetProps.SetPropInt(player, "m_PlayerClass.m_iClass", TF_CLASS_SPY); 
        });
    }

    // 3. Give and equip
    player.Weapon_Equip(weapon);
}

