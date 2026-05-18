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

function OnPostSpawn()
{
    RecachePlayers();
    if (IsValidRoundPreStart())
        FireListeners("setup_start");
}

function Tick()
{
    try { TF_TEAM_MERCS; } catch(e) { return; }

    if (IsValidRound())
        FireListeners("tick_only_valid", 0.1);
    FireListeners("tick_always", 0.1);

    return 0.1;
}

function OnScriptHook_OnTakeDamage(params)
{
    if (params.const_entity == worldspawn) //wall climb off of the static world
    {
        if (params.damage_type & 128)  // DMG_CLUB - constants are slower than plain numbers
            MeleeWallClimb_Hit(params);
        return;
    }
    if (params.damage_type & 128) // Wall climb off of the rest of the world. worldspawn handled separately for performance reasons
    {
        if (MeleeWallClimb_Check(params))
        {
            MeleeWallClimb_Hit(params);
            return;
        }
    }
    if (IsNotValidRound() || !IsValidPlayerOrBuilding(params.const_entity))
        return;
    FireListeners("damage_hook", params.attacker, params.const_entity, params);
}

function OnGameEvent_player_hurt(params)
{
    if (IsNotValidRound())
        return;
    local victim = GetPlayerFromParams(params);
    if (!IsValidPlayer(victim))
        return;
    local attacker = GetPlayerFromParams(params, "attacker");
    if (!IsValidPlayer(attacker))
        return;
    FireListeners("player_hurt", attacker, victim, params);
}

function OnGameEvent_player_team(params)
{
    if (IsNotValidRound())
        return;
    local player = GetPlayerFromUserID(params["userid"]);
    if (player == null || !player.IsValid() || !player.IsPlayer())
        return;
    FireListeners("team_change", player, params);
}

function OnGameEvent_player_changeclass(params)
{
    if (IsNotValidRound())
        return;
    local player = GetPlayerFromParams(params);
    if (!IsValidPlayer(player))
        return;
    FireListeners("class_change", player, params);
}

function OnGameEvent_player_spawn(params)
{
    if (IsInWaitingForPlayers() || IsNotValidRound())
        return;
    local player = GetPlayerFromParams(params);
    if (!IsValidPlayer(player))
        return;
    FireListeners("spawn", player, params);
}

function OnGameEvent_player_death(params)
{
    if (params.death_flags & TF_DEATHFLAG.DEAD_RINGER || IsNotValidRound())
        return;
    local player = GetPlayerFromParams(params);
    if (!IsValidPlayer(player))
        return;
    local attacker = GetPlayerFromParams(params, "attacker");
    FireListeners("death", attacker, player, params);
}

function OnGameEvent_object_destroyed(params)
{
    if (IsNotValidRound())
        return;
    local attacker = GetPlayerFromParams(params, "attacker");
    if (!IsValidPlayer(attacker))
        return;
    FireListeners("builing_destroyed", attacker, params);
}

function OnGameEvent_rps_taunt_event(params)
{
    local winner = PlayerInstanceFromIndex(params.winner);
    local loser = PlayerInstanceFromIndex(params.loser);
    if (!IsValidBoss(winner) && !IsValidBoss(loser))
        return;
    FireListeners("rps_with_boss", winner, loser, params);
}

function OnGameEvent_player_say(params)
{
    local userid = params.userid;
    local text = params.text;
    local player = GetPlayerFromUserID(userid);
    local mySubstrings = split(text, " ");
    local firstChar = text.slice(0, 1);
    if(firstChar != "/")
        return;

    // todo: case switch
    if(mySubstrings[0] == "/bossify")
    {   
        if(mySubstrings[1] == "none" || mySubstrings[1] == "merc")
        {
            bosses[player] = null;
            DiscardTraits(player);
            player.ForceRegenerateAndRespawn();

            ClientPrint(player, 3, "Congratulations!");
            if(mySubstrings[1] == "none")
            {
                ClientPrint(player, 3, "You are a nobody again!");
            }
            else
            {
                ClientPrint(player, 3, "You are now a mercenary!");
            }
            return;
        }
        AssignBoss(mySubstrings[1], player);
        DiscardTraits(player);
        player.ForceRegenerateAndRespawn();
        bosses[player].TryApply(player);

        ClientPrint(player, 3, "Congratulations!");
        ClientPrint(player, 3, "You are now " + mySubstrings[1] + "!");
    }
    else if(mySubstrings[0] == "/bossify_all")
    {
        foreach(target in GetAlivePlayers())
        {
            if(mySubstrings[1] == "none" || mySubstrings[1] == "merc")
            {
                bosses[target] = null;
                DiscardTraits(target);
                target.ForceRegenerateAndRespawn();

                ClientPrint(target, 3, "Congratulations!");
                if(mySubstrings[1] == "none")
                {
                    ClientPrint(target, 3, "You are a nobody... Just like the rest of us...");
                }
                else
                {
                    ClientPrint(target, 3, "You are now a mercenary!");
                }
                continue;
            }
            AssignBoss(mySubstrings[1], target);
            DiscardTraits(target);
            target.ForceRegenerateAndRespawn();
            bosses[target].TryApply(target);
            ClientPrint(target, 3, "Congratulations!");
            ClientPrint(target, 3, "You are now " + mySubstrings[1] + "!");
        }
    }
    else
    {
        ClientPrint(player, 3, "the current set of commands are:");
        ClientPrint(player, 3, "/bossify (boss string) - turns you into a certain boss, e.g saxton_hale");
        ClientPrint(player, 3, "/bossify_all (boss string) - turns everyone into a certain boss, e.g mecha_hale");
        ClientPrint(player, 3, "(you can use 'none' or 'merc' in place of the boss string to return to being a mercenary)");
    }
}

function FinishSetup()
{
    //todo Hale-specific check to fix Class-Restricted Duels bug.
    //local boss = GetRandomBossPlayer();
    //if (boss != null && boss.GetPlayerClass() != TF_CLASS_HEAVY && !IsRoundOver())
    //{
    //    boss.RemoveCond(TF_COND_STUNNED);
    //    boss.RemoveCond(TF_COND_TAUNTING);
    //    DiscardTraits(boss);
    //    characterTraits[boss] <- [];
    //    hudAbilityInstances[boss] <- [];
    //    boss.ForceRespawn();
    //    RefreshBossSetup(boss);
    //    bosses[boss].TryApply(boss);
    //}
    FireListeners("setup_end");
    isRoundSetup = false;
}

function OnGameEvent_post_inventory_application(params)
{
    local player = GetPlayerFromParams(params);
    if (!IsValidClient(player))
        return;
    player.GTFW_Cleanup();
    FireListeners("post_inventory", player, params);
}

function OnGameEvent_player_disconnect(params)
{
    local player = GetPlayerFromParams(params);
    if (!IsValidClient(player))
        return;
    FireListeners("disconnect", player, params);
}