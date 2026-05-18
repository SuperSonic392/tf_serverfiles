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

::hudAbilityInstances <- {};

class AbilityHudTrait extends BossTrait
{
    game_text_charge = null;
    game_text_punch = null;
    game_text_slam = null;

    //₁₂₃₄₅₆₇₈₉₀
    //¹²³⁴⁵⁶⁷⁸⁹⁰
    big2small = {
        " ": " ", //" "
        "r": "✔",
        "1": "₁",
        "2": "₂",
        "3": "₃",
        "4": "₄",
        "5": "₅",
        "6": "₆",
        "7": "₇",
        "8": "₈",
        "9": "₉",
        "0": "₀",
    };

    function OnApply()
    {
        game_text_charge = SpawnEntityFromTable("game_text",
        {
            color = "255 255 255",
            color2 = "0 0 0",
            channel = 0,
            effect = 0,
            fadein = 0,
            fadeout = 0,
            fxtime = 0,
            holdtime = 250,
            message = "0",
            spawnflags = 0,
            x = 0.67,
            y = 0.939
        });

        game_text_punch = SpawnEntityFromTable("game_text",
        {
            color = "255 255 255",
            color2 = "0 0 0",
            channel = 1,
            effect = 0,
            fadein = 0,
            fadeout = 0,
            fxtime = 0,
            holdtime = 250,
            message = "0",
            spawnflags = 0,
            x = 0.778,
            y = 0.939
        });

        game_text_slam = SpawnEntityFromTable("game_text",
        {
            color = "255 255 255",
            color2 = "0 0 0",
            channel = 2,
            effect = 0,
            fadein = 0,
            fadeout = 0,
            fxtime = 0,
            holdtime = 250,
            message = "0",
            spawnflags = 0,
            x = 0.885,
            y = 0.939
        });
    }

    function OnTickAlive(timeDelta)
    {
        if (!(player in hudAbilityInstances))
            return;

        local progressBarTexts = [];
        local overlay = "";
        foreach(ability in hudAbilityInstances[player])
        {
            local percentage = ability.MeterAsPercentage();
            local progressBarText = BigToSmallNumbers(ability.MeterAsNumber())+" ";
            local i = 13;
            for(; i < clampCeiling(100, percentage); i+=13)
                progressBarText += "▰";
            for(; i <= 100; i+=13)
                progressBarText += "▱";
            progressBarTexts.push(progressBarText);
            if (percentage >= 100)
                overlay += "1";
            else
                overlay += "0";
        }

        // yeah fuck this, lol. I hate this HUD. 
        //if (braveJumpCharges >= 2)
        //    overlay += "0";
        //else
        //    overlay += cos(Time() * 12) < 0 ? "1" : "2";
        
        overlay += "0";

        EntFireByHandle(game_text_charge, "AddOutput", "message "+progressBarTexts[0], 0, boss, boss);
        EntFireByHandle(game_text_charge, "Display", "", 0, boss, boss);

        EntFireByHandle(game_text_punch, "AddOutput", "message "+progressBarTexts[1], 0, boss, boss);
        EntFireByHandle(game_text_punch, "Display", "", 0, boss, boss);

        EntFireByHandle(game_text_slam, "AddOutput", "message "+progressBarTexts[2], 0, boss, boss);
        EntFireByHandle(game_text_slam, "Display", "", 0, boss, boss);

        local prefix = "";

        if(player.GetTeam() == TF_TEAM_BLUE)
        {
            prefix = "blue/"
        }
        else
        {
            prefix = "red/"
        }

        player.SetScriptOverlayMaterial(API_GetString("ability_hud_folder") + "/" + prefix + overlay);
    }

    function OnDiscard()
    {
        // kill HUD entities if they exist
        if (game_text_charge && game_text_charge.IsValid())
            EntFireByHandle(game_text_charge, "Kill", "", 0, null, null);
    
        if (game_text_punch && game_text_punch.IsValid())
            EntFireByHandle(game_text_punch, "Kill", "", 0, null, null);
    
        if (game_text_slam && game_text_slam.IsValid())
            EntFireByHandle(game_text_slam, "Kill", "", 0, null, null);
    
        // clear overlay
        if (player && player.IsValid())
            player.SetScriptOverlayMaterial("");
    
        // clear ability tracking
        if (player in hudAbilityInstances)
            delete hudAbilityInstances[player];
    }

    function OnDeath(attacker, params)
    {
        EntFireByHandle(game_text_charge, "AddOutput", "message ", 0, boss, boss);
        EntFireByHandle(game_text_charge, "Display", "", 0, boss, boss);
        EntFireByHandle(game_text_punch, "AddOutput", "message ", 0, boss, boss);
        EntFireByHandle(game_text_punch, "Display", "", 0, boss, boss);
        EntFireByHandle(game_text_slam, "AddOutput", "message ", 0, boss, boss);
        EntFireByHandle(game_text_slam, "Display", "", 0, boss, boss);

        player.SetScriptOverlayMaterial("");
    }

    function BigToSmallNumbers(input)
    {
        local result = "";
        foreach (char in input)
            result += big2small[char.tochar()];
        return result;
    }
};