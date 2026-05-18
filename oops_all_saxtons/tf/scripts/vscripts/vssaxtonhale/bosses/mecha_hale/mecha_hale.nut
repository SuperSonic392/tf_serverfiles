//=========================================================================
//Copyright LizardOfOz.
//
//Credits:
//  LizardOfOz - Programming, game design, promotional material and overall development. The original VSH Plugin from 2010.
//  Maxxy - Saxton Hale's model imitating Jungle Inferno SFM; Custom animations and promotional material.
//  Velly - VFX, animations scripting, technical assistance.
//  JPRAS - Saxton model development assistance and feedback.
//  MegapiemanPHD - Saxton Hale and Gray Mann voice acting.
//  James McGuinn - Mercenaries voice acting for custom lines.
//  Yakibomb - give_tf_weapon script bundle (used for Hale's first-person hands model).
//  Phe - game design assistance.
//=========================================================================

::custom_dmg_melee <- SpawnEntityFromTable("info_target", { classname = "hale_punch" });
::custom_dmg_melee_collateral <- SpawnEntityFromTable("info_target", { classname = "hale_punch_collateral" });
::custom_dmg_stomp <- SpawnEntityFromTable("info_target", { classname = "hale_stomp" });
::custom_dmg_hale_taunt <- SpawnEntityFromTable("info_target", { classname = "hale_taunt" });
::custom_dmg_slam <- SpawnEntityFromTable("info_target", { classname = "hale_slam" });
::custom_dmg_slam_collateral <- SpawnEntityFromTable("info_target", { classname = "hale_slam_collateral" });
::custom_dmg_saxton_punch <- SpawnEntityFromTable("info_target", { classname = "hale_megapunch" });
::custom_dmg_saxton_punch_aoe <- SpawnEntityFromTable("info_target", { classname = "hale_megapunch_collateral" });
::custom_dmg_charge <- SpawnEntityFromTable("info_target", { classname = "hale_charge" });

::mecha_model_path <- "models/vsh/mecha/player/mecha_hale.mdl";
::mecha_blue_model_path <- "models/vsh/mecha/player/mecha_hale.mdl";
::mecha_aura_model_path <- "models/vsh/player/items/vsh_effect_body_aura.mdl"
::mecha_viewmodel_path <- "models/vsh/mecha/weapons/c_models/c_mecha_hale_arms.mdl"
::mecha_viewmodel_index <- GetModelIndex("models/vsh/mecha/weapons/c_models/c_mecha_hale_arms.mdl")

PrecacheModel(mecha_model_path);
PrecacheModel(mecha_blue_model_path);
PrecacheModel(mecha_aura_model_path);
PrecacheModel(mecha_viewmodel_path);

class MechaHale extends Boss
{
    name = "mecha_hale";

    function OnApply0Delay()
    {
        player.SetPlayerClass(TF_CLASS_HEAVY);
        player.Regenerate(true);
        SetPropInt(player, "m_bForcedSkin", 1);
        SetPropInt(player, "m_nForcedSkin", 0);

        base.OnApply0Delay();

        // This is bullshit, don't do this unless you REALLY have to. 
        if(player.GetTeam() == TF_TEAM_BLUE)
        {
            player.SetCustomModelWithClassAnimations(mecha_blue_model_path);
        }
        else
        {
            player.SetCustomModelWithClassAnimations(mecha_model_path);
        }

        vsh_vscript.Hale_SetRedArm(player, false);
        vsh_vscript.Hale_SetBlueArm(player, false);
        RunWithDelay2(this, 0.1, function() {
            vsh_vscript.Hale_SetRedArm(player, false);
            vsh_vscript.Hale_SetBlueArm(player, false);
            player.CreateCustomWearable(null, mecha_aura_model_path);
            player.GiveWeapon("Hale's Own Fists of Steel");
        });

        player.SetModelScale(API_GetFloat("boss_scale"), 0);
        player.GiveWeapon("Hale's Own Fists of Steel");

        player.AddCustomAttribute("move speed bonus", 1.8, -1);
        player.AddCustomAttribute("cancel falling damage", 1, -1);
        player.AddCustomAttribute("voice pitch scale", 0, -1);
        player.AddCustomAttribute("melee range multiplier", 1.2, -1);
        player.AddCustomAttribute("damage bonus", 3, -1);
        player.AddCustomAttribute("melee bounds multiplier", 1.1, -1);
        player.AddCustomAttribute("crit mod disabled hidden", 0, -1);
        player.AddCustomAttribute("increase player capture value", 2, -1);
        //player.AddCustomAttribute("cannot pick up intelligence", 1, -1);
        //player.AddCustomAttribute("patient overheal penalty", 1, -1);
        //player.AddCustomAttribute("health from packs decreased", 0, -1);
        //player.AddCustomAttribute("damage force reduction", 0.75, -1);
        //player.AddCustomAttribute("dmg taken from crit reduced", 0.75, -1);
        //player.AddCustomAttribute("dmg taken from blast increased", 1.5, -1);
        //player.AddCustomAttribute("dmg taken from fire increased", 1.25, -1);

        player.AddCond(TF_COND_CANNOT_SWITCH_FROM_MELEE);
    }
}
RegisterBoss("mecha_hale", MechaHale);

Include("/bosses/saxton_hale/abilities/sweeping_charge.nut");
Include("/bosses/saxton_hale/abilities/mighty_slam.nut");
Include("/bosses/saxton_hale/abilities/saxton_punch.nut");
Include("/bosses/saxton_hale/misc/colored_arms.nut");
Include("/bosses/saxton_hale/misc/visible_weapon_fix.nut");

AddBossTrait("mecha_hale", AbilityHudTrait);
AddBossTrait("mecha_hale", SweepingChargeTrait);
AddBossTrait("mecha_hale", SaxtonPunchTrait);
AddBossTrait("mecha_hale", MightySlamTrait);

AddBossTrait("mecha_hale", BraveJumpTrait);
AddBossTrait("mecha_hale", DeathCleanupTrait);
AddBossTrait("mecha_hale", MovespeedTrait);
AddBossTrait("mecha_hale", ScreenShakeTrait);
AddBossTrait("mecha_hale", SetupStatRefreshTrait);
AddBossTrait("mecha_hale", TauntHandlerTrait);
AddBossTrait("mecha_hale", AoEPunchTrait);
AddBossTrait("mecha_hale", DebuffResistanceTrait);
AddBossTrait("mecha_hale", HeadStompTrait);
AddBossTrait("mecha_hale", ReceivedDamageScalingTrait);
AddBossTrait("mecha_hale", StunBreakoutTrait);
AddBossTrait("mecha_hale", BuildingDamageRescaleTrait);
AddBossTrait("mecha_hale", SpawnProtectionTrait);
AddBossTrait("mecha_hale", NoGibFixTrait);

AddBossTrait("mecha_hale", JaratedVoiceLine);
AddBossTrait("mecha_hale", LastMannHidingVoiceLine);
AddBossTrait("mecha_hale", KillVoiceLine);

RegisterCustomWeapon(
    "Hale's Own Fists of Steel",
    "Fists",
    null,
    Defaults,
    function (table, player) {
        table.worldModel = "models/empty.mdl";
        table.viewModel = mecha_viewmodel_path;
        table.classArms = mecha_viewmodel_path;
    },
    function (weapon, player)
    {
        if (player.ValidateScriptScope())
            player.GetScriptScope()["hide_base_arms"] <- true;

        weapon.AddAttribute("kill eater", casti2f(9001), -1);

        local isModelFlipped = false;
        try { isModelFlipped = Convars.GetClientConvarValue("cl_flipviewmodels", player.entindex()).tointeger() > 0; }
        catch(ignored) { }
        SetPropInt(weapon, "m_bFlipViewModel", isModelFlipped ? 1 : 0);
    }
);