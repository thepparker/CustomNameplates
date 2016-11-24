-- Global: CNPGetTrackedUnitDebuffs, CNPCleanUpExpiredDebuffs

-- Big credit to zetone and EnemyBuffFrames for the basis of this code,
-- https://github.com/zetone/enemyFrames/

-- The following debuffs and their durations are taken directly from (with proper
-- capitalisation of icon names for comparisons):
-- https://github.com/zetone/enemyFrames/blob/master/globals/resources/buffs.lua
local SPELLINFO_TIME_MODIFIER_BUFFS_TO_TRACK = {
    ['Barkskin']                    = {['mod'] = 1.4,   ['list'] = {'all'}},    -- its 1 second flat increase but 1.4 should be close enough
    ['Curse of Tongues']            = {['mod'] = 1.6,   ['list'] = {'all'}},
    
    ['Curse of the Eye']            = {['mod'] = 1.2,   ['list'] = {'all'}},
    
    ['Mind-numbing Poison']         = {['mod'] = 1.6,   ['list'] = {'all'}},    ['Mind-numbing Poison II']      = {['mod'] = 1.6,   ['list'] = {'all'}},    ['Mind-numbing Poison III']         = {['mod'] = 1.6,   ['list'] = {'all'}},
    
    ['Fang of the Crystal Spider']  = {['mod'] = 1.1,   ['list'] = {'all'}},
    
    ['Nature\'s Swiftness']         = {['mod'] = 0.1,   ['list'] = {'Chain Heal', 'Chain Lightning', 'Far Sight', 'Ghost Wolf', 'Healing Wave', 'Lesser Healing Wave', 'Lightning Bolt',   -- shaman
                                                        'Entangling Roots', 'Healing Touch', 'Hibernate', 'Rebirth', 'Regrowth', 'Soothe Animal', 'Wrath'}}, -- druid
                              
    ['Rapid Fire']                  = {['mod'] = .6,    ['list'] = {'Aimed Shot'}},
    ['Shadow Trance']               = {['mod'] = 0,     ['list'] = {'Shadow Bolt'}},
    ['Fel Domination']              = {['mod'] = 0.05,  ['list'] = {'Summon Felhunter', 'Summon Imp', 'Summon Succubus', 'Summon Voidwalker'}},
    
    ['Presence of Mind']            = {['mod'] = 0,     ['list'] = {'Fireball', 'Frostbolt', 'Pyroblast', 'Scorch', 'Polymorph', 'Polymorph: Pig', 'Polymorph: Turtle'}},
    ['Mind Quickening']             = {['mod'] = 0.66,  ['list'] = {'Fireball', 'Frostbolt', 'Pyroblast', 'Scorch', 'Polymorph', 'Polymorph: Pig', 'Polymorph: Turtle'}},       
}

local SPELLINFO_BUFFS_TO_TRACK = {

    -- MISC & MOBS
    ['First Aid']               = {['icon'] = [[Interface\Icons\Spell_Holy_Heal]],                  ['duration'] = 8,   ['display'] = false,},
    ['Flee']                    = {['icon'] = [[Interface\Icons\Spell_Magic_Polymorphchicken]],     ['duration'] = 10,},
    ['Free Action']             = {['icon'] = [[Interface\Icons\Inv_Potion_04]],                    ['duration'] = 30,  ['type'] = 'magic',     ['prio'] = 4},
    ['Invulnerability']         = {['icon'] = [[Interface\Icons\Spell_Holy_Divineintervention]],    ['duration'] = 6,   ['type'] = 'magic',     ['prio'] = 5},
    ['Living Free Action']      = {['icon'] = [[Interface\Icons\Inv_Potion_07]],                    ['duration'] = 5,   ['type'] = 'magic',     ['prio'] = 4},
    ['Net-o-Matic']             = {['icon'] = [[Interface\Icons\Ability_Ensnare]],                  ['duration'] = 10,  ['type'] = 'physical',  ['prio'] = 2},
    ['Perception']              = {['icon'] = [[Interface\Icons\Spell_Nature_Sleep]],               ['duration'] = 20,},
    ['Recently Bandaged']       = {['icon'] = [[Interface\Icons\Inv_Misc_Bandage_08]],              ['duration'] = 60,  ['display'] = false,},
    ["Reckless Charge"]         = {['icon'] = [[Interface\Icons\Spell_Nature_Astralrecal]],         ['duration'] = 12,  ['type'] = 'magic',     ['prio'] = 3},
    ["Sleep"]                   = {['icon'] = [[Interface\Icons\Spell_Nature_Sleep]],               ['duration'] = 12,  ['type'] = 'magic',     ['prio'] = 3},
    ['Stoneform']               = {['icon'] = [[Interface\Icons\Inv_Gauntlets_03]],                 ['duration'] = 8,},
    ['Tidal Charm']             = {['icon'] = [[Interface\Icons\Spell_Frost_Summonwaterelemental]], ['duration'] = 3,   ['type'] = 'magic',     ['prio'] = 2},
    ['Ward of the Eye']         = {['icon'] = [[Interface\Icons\Spell_Totem_Wardofdraining]],       ['duration'] = 6,                           ['prio'] = 3},
    ['Will of the Forsaken']    = {['icon'] = [[Interface\Icons\Spell_Shadow_Raisedead]],           ['duration'] = 5,                           ['prio'] = 2},
    
        -- ENGINEERING
    ["Flash Bomb"]              = {['icon'] = [[Interface\Icons\Spell_Shadow_Darksummoning]],       ['duration'] = 10,  ['prio'] = 2},
    ['Fire Reflector']          = {['icon'] = [[Interface\Icons\Spell_Fire_Sealoffire]],            ['duration'] = 5},
    ['Frost Reflector']         = {['icon'] = [[Interface\Icons\Spell_Frost_Frostward]],            ['duration'] = 5},     
    ['Shadow Reflector']        = {['icon'] = [[Interface\Icons\Spell_Shadow_Antishadow]],          ['duration'] = 5},
    ['Thorium Grenade']         = {['icon'] = [[Interface\Icons\Spell_Fire_Selfdestruct]],          ['duration'] = 3,   ['type'] = 'physical', ['prio'] = 2},
    ['Iron Grenade']            = {['icon'] = [[Interface\Icons\Spell_Fire_Selfdestruct]],          ['duration'] = 3,   ['type'] = 'physical', ['prio'] = 2},
    
        -- DRUID
    ['Abolish Poison']          = {['icon'] = [[Interface\Icons\Spell_Nature_Nullifypoison_02]],    ['duration'] = 8,   ['type'] = 'magic' },
    ['Barkskin']                = {['icon'] = [[Interface\Icons\Spell_Nature_Stoneclawtotem]],      ['duration'] = 15,  ['type'] = 'magic',     ['prio'] = 2},
    ['Dash']                    = {['icon'] = [[Interface\Icons\Ability_Druid_Dash]],               ['duration'] = 15,  ['type'] = 'physical',},
    ['Demoralizing Roar']       = {['icon'] = [[Interface\Icons\Ability_Druid_Demoralizingroar]],   ['duration'] = 30,  ['display'] = false,},
    ['Entangling Roots']        = {['icon'] = [[Interface\Icons\Spell_Nature_Stranglevines]],       ['duration'] = 12,  ['type'] = 'magic',     ['prio'] = 1,   ['dr'] = 'Controlled Root'},
    ['Enrage']                  = {['icon'] = [[Interface\Icons\Ability_Druid_Enrage]],             ['duration'] = 10,  ['display'] = false,},
    ['Feral Charge Effect']     = {['icon'] = [[Interface\Icons\Ability_Hunter_Pet_Bear]],          ['duration'] = 4,   ['type'] = 'physical',  ['prio'] = 1},
    ['Frenzied Regeneration']   = {['icon'] = [[Interface\Icons\Ability_Bullrush]],                 ['duration'] = 10,  ['display'] = false,},
    ['Growl']                   = {['icon'] = [[Interface\Icons\Ability_Physical_Taunt]],           ['duration'] = 3,   ['display'] = false,},
    ["Hibernate"]               = {['icon'] = [[Interface\Icons\Spell_Nature_Sleep]],               ['duration'] = 20,  ['type'] = 'magic',     ['prio'] = 3},
    ['Innervate']               = {['icon'] = [[Interface\Icons\Spell_Nature_Lightning]],           ['duration'] = 20,  ['type'] = 'magic',     ['prio'] = 2},
    ['Insect Swarm']            = {['icon'] = [[Interface\Icons\Spell_Nature_Insectswarm]],         ['duration'] = 12,  ['display'] = false,},
    ['Moonfire']                = {['icon'] = [[Interface\Icons\Spell_Nature_Starfall]],            ['duration'] = 12,  ['display'] = false,},
    ['Nature\'s Grace']         = {['icon'] = [[Interface\Icons\Spell_Nature_Naturesblessing]],     ['duration'] = 15,  ['display'] = false,},
    ['Nature\'s Grasp']         = {['icon'] = [[Interface\Icons\Spell_Nature_Natureswrath]],        ['type'] = 'magic', ['duration'] = 45},
    ['Pounce']                  = {['icon'] = [[Interface\Icons\Ability_Druid_Supriseattack]],      ['duration'] = 2,   ['display'] = false,},
    ['Rake']                    = {['icon'] = [[Interface\Icons\Ability_Druid_Disembowel]],         ['duration'] = 9,   ['display'] = false,},
    ['Rip']                     = {['icon'] = [[Interface\Icons\Ability_Ghoulfrenzy]],              ['duration'] = 12,  ['display'] = false,},
    ['Tiger\'s Fury']           = {['icon'] = [[Interface\Icons\Ability_Mount_Jungletiger]],        ['duration'] = 6,   ['display'] = false,},
    
    --[[    HUNTER  ]]--
    ['Bestial Wrath']           = {['icon'] = [[Interface\Icons\Ability_Druid_Ferociousbite]],      ['duration'] = 18,                          ['prio'] = 2},
    ['Concussive Shot']         = {['icon'] = [[Interface\Icons\Spell_Frost_Stun]],                 ['duration'] = 4,   ['type'] = 'magic',     ['prio'] = 1},
    ['Counterattack']           = {['icon'] = [[Interface\Icons\Ability_Warrior_Challange]],        ['duration'] = 5,   ['type'] = 'physical',  ['prio'] = 1},
    ['Deterrence']              = {['icon'] = [[Interface\Icons\Ability_Whirlwind]],                ['duration'] = 10,                          ['prio'] = 1},
    ['Immolation Trap Effect']  = {['icon'] = [[Interface\Icons\Spell_Fire_Flameshock]],            ['duration'] = 15,  ['display'] = false,},
    ['Improved Concussive Shot'] = {['icon'] = [[Interface\Icons\Spell_Frost_Stun]],                ['duration'] = 3,   ['type'] = 'magic',     ['prio'] = 2},
    ['Improved Wing Clip']      = {['icon'] = [[Interface\Icons\Ability_Rogue_Trip]],               ['duration'] = 5,   ['type'] = 'physical',},
    ['Intimidation']            = {['icon'] = [[Interface\Icons\Ability_Devour]],                   ['duration'] = 3,   ['type'] = 'physical',  ['prio'] = 1},
    ['Quick Shots']             = {['icon'] = [[Interface\Icons\Ability_Warrior_Innerrage]],        ['duration'] = 12,  ['display'] = false,},
    ['Rapid Fire']              = {['icon'] = [[Interface\Icons\Ability_Hunter_Runningshot]],       ['duration'] = 15,  ['type'] = 'magic',},
    ['Scatter Shot']            = {['icon'] = [[Interface\Icons\Ability_Golemstormbolt]],           ['duration'] = 4,   ['type'] = 'physical',  ['prio'] = 2},
    ["Scare Beast"]             = {['icon'] = [[Interface\Icons\Ability_Druid_Cower]],              ['duration'] = 10,  ['type'] = 'magic',     ['prio'] = 2,   ['dr'] = 'Fear'},
    ['Scorpid Sting']           = {['icon'] = [[Interface\Icons\Ability_Hunter_Criticalshot]],      ['duration'] = 20,  ['display'] = false,},
    ['Serpent Sting']           = {['icon'] = [[Interface\Icons\Ability_Hunter_Quickshot]],         ['duration'] = 15,  ['display'] = false,},
    ["Freezing Trap Effect"]    = {['icon'] = [[Interface\Icons\Spell_Frost_Chainsofice]],          ['duration'] = 20,  ['type'] = 'magic',     ['prio'] = 3},
    ['Viper Sting']             = {['icon'] = [[Interface\Icons\Ability_Hunter_Aimedshot]],         ['duration'] = 8,   ['type'] = 'poison',    ['prio'] = 1},
    ['Wing Clip']               = {['icon'] = [[Interface\Icons\Ability_Rogue_Trip]],               ['duration'] = 10,  ['type'] = 'physical',},
    ['Wyvern Sting']            = {['icon'] = [[Interface\Icons\Inv_Spear_02]],                     ['duration'] = 12,  ['type'] = 'poison',    ['prio'] = 3},
    
        -- MAGE
    ['Arcane Power']            = {['icon'] = [[Interface\Icons\Spell_Nature_Lightning]],           ['duration'] = 15,  ['display'] = false,},
    ['Blast Wave']              = {['icon'] = [[Interface\Icons\Spell_Holy_Excorcism_02]],          ['duration'] = 6,   ['type'] = 'physical',  ['prio'] = 1},
    ['Clearcasting']            = {['icon'] = [[Interface\Icons\Spell_Frost_Manaburn]],             ['duration'] = 15,  ['type'] = 'magic',     },
    ['Counterspell - Silenced'] = {['icon'] = [[Interface\Icons\Spell_Frost_Iceshock]],             ['duration'] = 4,   ['type'] = 'magic',     ['prio'] = 2},
    ["Cone of Cold"]            = {['icon'] = [[Interface\Icons\Spell_Frost_Glacier]],              ['duration'] = 10,  ['type'] = 'magic',     ['display'] = false,},
    ["Chilled"]                 = {['icon'] = [[Interface\Icons\Spell_Frost_Frostarmor02]],         ['duration'] = 7,   ['display'] = false,},
    ['Fireball']                = {['icon'] = [[Interface\Icons\Spell_Fire_Flamebolt]],             ['duration'] = 8,   ['display'] = false,},
    ["Frostbite"]               = {['icon'] = [[Interface\Icons\Spell_Frost_Frostarmor]],           ['duration'] = 5,   ['type'] = 'magic',     ['prio'] = 1},
    ["Frost Nova"]              = {['icon'] = [[Interface\Icons\Spell_Frost_Frostnova]],            ['duration'] = 8,   ['type'] = 'magic',     ['prio'] = 1,   ['dr'] = 'Controlled Root'},
    ['Frost Ward']              = {['icon'] = [[Interface\Icons\Spell_Frost_Frostward]],            ['duration'] = 30,  ['type'] = 'magic'},
    ['Frostbolt']               = {['icon'] = [[Interface\Icons\Spell_Frost_Frostbolt02]],          ['duration'] = 10,  ['type'] = 'magic',     ['display'] = false,},
    ['Fire Ward']               = {['icon'] = [[Interface\Icons\Spell_Fire_Firearmor]],             ['duration'] = 30,  ['type'] = 'magic'},
    --['Ice Barrier']               = {['icon'] = [[Interface\Icons\Spell_Ice_Lament]],                 ['duration'] = 60,  ['type'] = 'magic'},
    ['Ice Block']               = {['icon'] = [[Interface\Icons\Spell_Frost_Frost]],                ['duration'] = 10,  ['prio'] = 5},
    ['Impact']                  = {['icon'] = [[Interface\Icons\Spell_Fire_Meteorstorm]],           ['duration'] = 2,   ['type'] = 'physical',  ['prio'] = 1},
    ['Fire Vulnerability']      = {['icon'] = [[Interface\Icons\Spell_Fire_Soulburn]],              ['duration'] = 30,  ['display'] = false,},
    ["Polymorph"]               = {['icon'] = [[Interface\Icons\Spell_Nature_Polymorph]],           ['duration'] = 12,  ['type'] = 'magic',     ['prio'] = 3,   ['dr'] = 'Polymorph'},
    ['Polymorph: Pig']          = {['icon'] = [[Interface\Icons\Spell_Magic_Polymorphpig]],         ['duration'] = 12,  ['type'] = 'magic',     ['prio'] = 3,   ['dr'] = 'Polymorph'},
    ['Polymorph: Turtle']       = {['icon'] = [[Interface\Icons\Ability_Hunter_Pet_Turtle]],        ['duration'] = 12,  ['type'] = 'magic',     ['prio'] = 3,   ['dr'] = 'Polymorph'},
    ['Pyroblast']               = {['icon'] = [[Interface\Icons\Spell_Fire_Fireball02]],            ['duration'] = 12,  ['display'] = false,},
    ['Slow Fall']               = {['icon'] = [[Interface\Icons\Spell_Magic_Featherfall]],          ['duration'] = 30,  ['display'] = false,},
    ['Winter\'s Chill']         = {['icon'] = [[Interface\Icons\Spell_Frost_Chillingblast]],        ['duration'] = 15,  ['type'] = 'magic',     ['display'] = false,},
    
        -- PALADIN
    ['Blessing of Sacrifice']   = {['icon'] = [[Interface\Icons\Spell_Holy_Sealofsacrifice]],       ['duration'] = 30,  ['display'] = false,},
    ['Blessing of Protection']  = {['icon'] = [[Interface\Icons\Spell_Holy_Sealofprotection]],      ['duration'] = 10,  ['type'] = 'magic',     ['prio'] = 2},
    ['Blessing of Freedom']     = {['icon'] = [[Interface\Icons\Spell_Holy_Sealofvalor]],           ['duration'] = 16,  ['type'] = 'magic'},
    ['Divine Protection']       = {['icon'] = [[Interface\Icons\Spell_Holy_Restoration]],           ['duration'] = 8,   ['prio'] = 4},
    ['Divine Shield']           = {['icon'] = [[Interface\Icons\Spell_Holy_Divineintervention]],    ['duration'] = 12,  ['prio'] = 5},
    ['Forbearance']             = {['icon'] = [[Interface\Icons\Spell_Holy_Removecurse]],           ['duration'] = 60,  ['display'] = false,},
    ["Hammer of Justice"]       = {['icon'] = [[Interface\Icons\Spell_Holy_SealOfMight]],           ['duration'] = 5,   ['type'] = 'magic',     ['prio'] = 1,   ['dr'] = 'Controlled Stun'},
    ['Judgement of the Crusader'] = {['icon'] = [[Interface\Icons\Spell_Holy_Holysmite]],           ['duration'] = 10,  ['type'] = 'magic',                     ['display'] = false,},
    ['Judgement of Justice']    = {['icon'] = [[Interface\Icons\Spell_Holy_Sealofwrath]],           ['duration'] = 10,  ['type'] = 'magic',                     ['display'] = false,},
    ['Judgement of Light']      = {['icon'] = [[Interface\Icons\Spell_Holy_Healingaura]],           ['duration'] = 10,  ['type'] = 'magic',                     ['display'] = false,},
    ['Judgement of Wisdom']     = {['icon'] = [[Interface\Icons\Spell_Holy_Righteousnessaura]],     ['duration'] = 10,  ['type'] = 'magic',                     ['display'] = false,},
    ['Repentance']              = {['icon'] = [[Interface\Icons\Spell_Holy_Prayerofhealing]],       ['duration'] = 6,   ['type'] = 'magic',     ['prio'] = 3},
    ['Seal of Command']         = {['icon'] = [[Interface\Icons\Ability_Warrior_Innerrage]],        ['duration'] = 30,  ['display'] = false,},
    ['Seal of Justice']         = {['icon'] = [[Interface\Icons\Spell_Holy_Sealofwrath]],           ['duration'] = 30,  ['display'] = false,},
    ['Seal of Light']           = {['icon'] = [[Interface\Icons\Spell_Holy_Healingaura]],           ['duration'] = 30,  ['display'] = false,},      
    ['Seal of Righteousness']   = {['icon'] = [[Interface\Icons\Ability_ThunderBolt]],              ['duration'] = 30,  ['display'] = false,},
    ['Seal of the Crusader']    = {['icon'] = [[Interface\Icons\Spell_Holy_Holysmite]],             ['duration'] = 30,  ['display'] = false,},
    ['Seal of Wisdom']          = {['icon'] = [[Interface\Icons\Spell_Holy_Righteousnessaura]],     ['duration'] = 30,  ['display'] = false,},
    ['Stun']                    = {['icon'] = [[Interface\Icons\Spell_Frost_Stun]],                 ['duration'] = 2,   ['type'] = 'physical',                  ['display'] = false,},
    ['Vengeance']               = {['icon'] = [[Interface\Icons\Spell_Holy_Righteousnessaura]],     ['duration'] = 8,   ['display'] = false,},
    ['Vindication']             = {['icon'] = [[Interface\Icons\Spell_Holy_Vindication]],           ['duration'] = 10,  ['display'] = false,},
    
        -- PRIEST
    ['Abolish Disease']         = {['icon'] = [[Interface\Icons\Spell_Nature_NullifyDisease]],      ['duration'] = 8,   ['display'] = false,},
    ['Blackout']                = {['icon'] = [[Interface\Icons\Spell_Shadow_GatherShadows]],       ['duration'] = 3,   ['type'] = 'magic',     ['prio'] = 1},
    ['Devouring Plague']        = {['icon'] = [[Interface\Icons\Spell_Shadow_BlackPlague]],         ['duration'] = 24,  ['display'] = false,},
    ['Lightwell Renew']         = {['icon'] = [[Interface\Icons\Spell_Holy_SummonLightwell]],       ['duration'] = 10,  ['display'] = false,},
    ['Mind Flay']               = {['icon'] = [[Interface\Icons\Spell_Shadow_SiphonMana]],          ['duration'] = 3,   ['type'] = 'magic',     ['display'] = false,},
    ['Power Word: Shield']      = {['icon'] = [[Interface\Icons\Spell_Holy_PowerWordShield]],       ['duration'] = 30,  ['type'] = 'magic'},
    ['Power Infusion']          = {['icon'] = [[Interface\Icons\Spell_Holy_PowerInfusion]],         ['duration'] = 15,  ['type'] = 'magic'},
    ['Psychic Scream']          = {['icon'] = [[Interface\Icons\Spell_Shadow_PsychicScream]],       ['duration'] = 8,   ['type'] = 'magic',     ['prio'] = 1,   ['dr'] = 'Fear'},
    ['Shadow Vulnerability']    = {['icon'] = [[Interface\Icons\Spell_Shadow_BlackPlague]],         ['duration'] = 15,  ['display'] = false},
    ['Shadow Word: Pain']       = {['icon'] = [[Interface\Icons\Spell_Shadow_ShadowWordPain]],      ['duration'] = 24,  ['display'] = false,},
    ['Silence']                 = {['icon'] = [[Interface\Icons\Spell_Shadow_ImpPhaseShift]],       ['duration'] = 5,   ['type'] = 'magic',     ['prio'] = 2},
    ['Renew']                   = {['icon'] = [[Interface\Icons\Spell_Holy_Renew]],                 ['duration'] = 15,  ['display'] = false,},
    ['Weakened Soul']           = {['icon'] = [[Interface\Icons\Spell_Holy_AshesToAshes]],          ['duration'] = 15,  ['display'] = false,},
    
    --[[    ROGUE   ]]--
    ['Adrenaline Rush']         = {['icon'] = [[Interface\Icons\Spell_Shadow_Shadowworddominate]],  ['duration'] = 15,  },
    ['Blade Flurry']            = {['icon'] = [[Interface\Icons\Ability_Warrior_Punishingblow]],    ['duration'] = 15,  ['display'] = false,},
    ['Blind']                   = {['icon'] = [[Interface\Icons\Spell_Shadow_Mindsteal]],           ['duration'] = 10,  ['type'] = 'poison',    ['prio'] = 3},
    ["Cheap Shot"]              = {['icon'] = [[Interface\Icons\Ability_Cheapshot]],                ['duration'] = 4,   ['type'] = 'physical',  ['prio'] = 1},
    ['Crippling Poison']        = {['icon'] = [[Interface\Icons\Ability_Poisonsting]],              ['duration'] = 12,  ['type'] = 'poison',    ['display'] = false,},
    ['Deadly Poison V']         = {['icon'] = [[Interface\Icons\Ability_Rogue_Dualweild]],          ['duration'] = 12,  ['display'] = false,},
    ['Evasion']                 = {['icon'] = [[Interface\Icons\Spell_Shadow_Shadowward]],          ['duration'] = 15,  ['display'] = false,},
    ['Expose Armor']            = {['icon'] = [[Interface\Icons\Ability_Warrior_Riposte]],          ['duration'] = 30,  ['display'] = false,},
    ['Garrote']                 = {['icon'] = [[Interface\Icons\Ability_Rogue_Garrote]],            ['duration'] = 18,  ['display'] = false,},
    ['Ghostly Strike']          = {['icon'] = [[Interface\Icons\Spell_Shadow_Curse]],               ['duration'] = 7,   ['display'] = false,},
    ["Gouge"]                   = {['icon'] = [[Interface\Icons\Ability_Gouge]],                    ['duration'] = 5,   ['type'] = 'physical',  ['prio'] = 2,   ['dr'] = 'Disorient'},
    ['Hemorrhage']              = {['icon'] = [[Interface\Icons\Spell_Shadow_Lifedrain]],           ['duration'] = 15,  ['display'] = false,},
    ['Kick - Silenced']         = {['icon'] = [[Interface\Icons\Ability_Kick]],                     ['duration'] = 2,   ['type'] = 'physical',  ['prio'] = 1},
    ['Mind-numbing Poison III'] = {['icon'] = [[Interface\Icons\Spell_Nature_Nullifydisease]],      ['duration'] = 14,  ['display'] = false,},
    ['Riposte']                 = {['icon'] = [[Interface\Icons\Ability_Warrior_Challange]],        ['duration'] = 6,   ['type'] = 'physical',  ['prio'] = 1},
    ["Sap"]                     = {['icon'] = [[Interface\Icons\Ability_Sap]],                      ['duration'] = 11,  ['type'] = 'physical',  ['prio'] = 3,   ['dr'] = 'Disorient'},
    ['Sprint']                  = {['icon'] = [[Interface\Icons\Ability_Rogue_Sprint]],             ['duration'] = 15,                          ['prio'] = 1},
    ['Kidney Shot']             = {['icon'] = [[Interface\Icons\Ability_Rogue_Kidneyshot]],         ['duration'] = 6,   ['type'] = 'physical',  ['prio'] = 2,   ['dr'] = 'Controlled Stun'},
    ['Wound Poison IV']         = {['icon'] = [[Interface\Icons\Inv_Misc_Herb_16]],                 ['duration'] = 15,  ['type'] = 'poison',    ['display'] = false,},
    
        -- SHAMAN
    ['Earthbind']               = {['icon'] = [[Interface\Icons\Spell_Nature_StrengthOfEarthTotem02]],['duration'] = 5, ['type'] = 'magic',},
    ['Flame Shock']             = {['icon'] = [[Interface\Icons\Spell_Fire_FlameShock]],            ['duration'] = 12,  ['display'] = false,},
    ['Focused Casting']         = {['icon'] = [[Interface\Icons\Spell_Arcane_Blink]],               ['duration'] = 6,   ['display'] = false,},
    ['Frost Shock']             = {['icon'] = [[Interface\Icons\Spell_Frost_FrostShock]],           ['duration'] = 8,   ['type'] = 'magic',     ['prio'] = 1,   ['dr'] = 'Frost Shock'},
    ['Grounding Totem Effect']  = {['icon'] = [[Interface\Icons\Spell_Nature_Groundingtotem]],      ['duration'] = 10,  ['type'] = 'magic',     ['prio'] = 3},
    ['Healing Way']             = {['icon'] = [[Interface\Icons\Spell_Nature_HealingWay]],          ['duration'] = 15,  ['display'] = false,},
    ['Mana Tide Totem']         = {['icon'] = [[Interface\Icons\Spell_Frost_Summonwaterelemental]], ['duration'] = 12,},
    ['Stormstrike']             = {['icon'] = [[Interface\Icons\Spell_Holy_Sealofmight]],           ['duration'] = 12,  ['display'] = false,},
    
         -- WARLOCK
    ['Corruption']              = {['icon'] = [[Interface\Icons\Spell_Shadow_AbominationExplosion]],['duration'] = 18,  ['display'] = false,},
    ['Curse of Agony']          = {['icon'] = [[Interface\Icons\Spell_Shadow_CurseOfSargeras]],     ['duration'] = 24,  ['display'] = false,},
    ['Curse of Exhaustion']     = {['icon'] = [[Interface\Icons\Spell_Shadow_Grimward]],            ['duration'] = 30,  ['type'] = 'curse',},
    ['Curse of Tongues']        = {['icon'] = [[Interface\Icons\Spell_Shadow_CurseOfTounges]],      ['duration'] = 30,  ['type'] = 'curse',},
    ['Death Coil']              = {['icon'] = [[Interface\Icons\Spell_Shadow_Deathcoil]],           ['duration'] = 3,   ['type'] = 'magic',     ['prio'] = 1},
    ['Drain Life']              = {['icon'] = [[Interface\Icons\Spell_Shadow_Lifedrain02]],         ['duration'] = 5,   ['display'] = false,},
    ['Drain Mana']              = {['icon'] = [[Interface\Icons\Spell_Shadow_SiphonMana]],          ['duration'] = 5,   ['display'] = false,},
    ['Drain Soul']              = {['icon'] = [[Interface\Icons\Spell_Shadow_Haunting]],            ['duration'] = 15,                                          ['display'] = false,},
    ["Fear"]                    = {['icon'] = [[Interface\Icons\Spell_Shadow_Possession]],          ['duration'] = 15,  ['type'] = 'magic',     ['prio'] = 2,   ['dr'] = 'Fear'},
    ['Health Funnel']           = {['icon'] = [[Interface\Icons\Spell_Shadow_Lifedrain]],           ['duration'] = 10,  ['display'] = false,},
    ['Immolate']                = {['icon'] = [[Interface\Icons\Spell_Fire_Immolation]],            ['duration'] = 15,  ['type'] = 'magic',                     ['display'] = false,},
    ['Seduction']               = {['icon'] = [[Interface\Icons\Spell_Shadow_Mindsteal]],           ['duration'] = 10,  ['type'] = 'magic',     ['prio'] = 3,   ['dr'] = 'Fear'},
    ['Shadowburn']              = {['icon'] = [[Interface\Icons\Spell_Shadow_Scourgebuild]],        ['duration'] = 5,   ['display'] = false,},
    ['Shadow Trance']           = {['icon'] = [[Interface\Icons\Spell_Shadow_Twilight]],            ['duration'] = 10,  ['type'] = 'magic'},
    ['Shadow Ward']             = {['icon'] = [[Interface\Icons\Spell_Shadow_Antishadow]],          ['duration'] = 30,  ['type'] = 'magic'},
    ['Siphon Life']             = {['icon'] = [[Interface\Icons\Spell_Shadow_Requiem]],             ['duration'] = 30,  ['display'] = false,},
    ['Spell Lock']              = {['icon'] = [[Interface\Icons\Spell_Shadow_Mindrot]],             ['duration'] = 5,  ['display'] = false,},

    --[[    WARRRIOR    ]]--
    ['Berserker Rage']          = {['icon'] = [[Interface\Icons\Spell_Nature_AncestralGuardian]],   ['duration'] = 10,                                      },
    ['Bloodrage']               = {['icon'] = [[Interface\Icons\Ability_Racial_Bloodrage]],         ['duration'] = 10,  ['display'] = false,},
    ['Bloodthirst']             = {['icon'] = [[Interface\Icons\Spell_Nature_Bloodlust]],           ['duration'] = 8,   ['display'] = false,},
    ['Challenging Shout']       = {['icon'] = [[Interface\Icons\Ability_Bullrush]],                 ['duration'] = 6,   ['display'] = false,},
    ['Charge']                  = {['icon'] = [[Interface\Icons\Spell_Frost_Stun]],                 ['duration'] = 1,   ['type'] = 'physical',  ['prio'] = 1,   ['dr'] = 'Controlled Stun'},
    ['Concussion Blow']         = {['icon'] = [[Interface\Icons\Ability_Thunderbolt]],              ['duration'] = 5,   ['type'] = 'physical',  ['prio'] = 1},
    ['Death Wish']              = {['icon'] = [[Interface\Icons\Spell_Shadow_Deathpact]],           ['duration'] = 30,},
    ['Deep Wounds']             = {['icon'] = [[Interface\Icons\Ability_Backstab]],                 ['duration'] = 12,  ['display'] = false,},
    ['Demoralizing Shout']      = {['icon'] = [[Interface\Icons\Ability_Warrior_Warcry]],           ['duration'] = 30,  ['display'] = false,},
    ['Disarm']                  = {['icon'] = [[Interface\Icons\Ability_Warrior_Disarm]],           ['duration'] = 8,   ['type'] = 'physical',  ['prio'] = 1},
    ['Enrage']                  = {['icon'] = [[Interface\Icons\Spell_Shadow_UnholyFrenzy]],        ['duration'] = 12,  ['display'] = false,},
    ['Hamstring']               = {['icon'] = [[Interface\Icons\Ability_Shockwave]],                ['duration'] = 15,  ['type'] = 'physical',  ['prio'] = 1},      
    ['Improved Hamstring']      = {['icon'] = [[Interface\Icons\Ability_Shockwave]],                ['duration'] = 5,   ['type'] = 'physical',  ['prio'] = 2},
    ['Intercept Stun']          = {['icon'] = [[Interface\Icons\Spell_Frost_Stun]],                 ['duration'] = 3,   ['type'] = 'physical',  ['prio'] = 1,   ['dr'] = 'Controlled Stun'},
    ['Intimidating Shout']      = {['icon'] = [[Interface\Icons\Ability_GolemThunderclap]],         ['duration'] = 8,   ['type'] = 'physical',  ['prio'] = 2,   ['dr'] = 'Fear'},
    ['Last Stand']              = {['icon'] = [[Interface\Icons\Spell_Holy_AshesToAshes]],          ['duration'] = 20, },
    ['Mace Stun Effect']        = {['icon'] = [[Interface\Icons\Spell_Frost_Stun]],                 ['duration'] = 3,   ['type'] = 'physical',  ['prio'] = 1,},
    ['Mortal Strike']           = {['icon'] = [[Interface\Icons\Ability_Warrior_SavageBlow]],       ['duration'] = 10,  ['type'] = 'physical'},
    ['Rend']                    = {['icon'] = [[Interface\Icons\Ability_Gouge]],                    ['duration'] = 21,  ['display'] = false,},
    ['Retaliation']             = {['icon'] = [[Interface\Icons\Ability_Warrior_Challange]],        ['duration'] = 15,                          ['prio'] = 2,},
    ['Shield Bash - Silenced']  = {['icon'] = [[Interface\Icons\Ability_Warrior_ShieldBash]],       ['duration'] = 3,   ['type'] = 'magic',     ['prio'] = 2},
    ['Shield Block']            = {['icon'] = [[Interface\Icons\Ability_Defend]],                   ['duration'] = 5,   ['display'] = false,},
    ['Shield Wall']             = {['icon'] = [[Interface\Icons\Ability_Warrior_ShieldWall]],       ['duration'] = 10,                          ['prio'] = 2},
    ['Sweeping Strikes']        = {['icon'] = [[Interface\Icons\Ability_Rogue_SliceDice]],          ['duration'] = 20,  ['display'] = false,},
    ['Thunder Clap']            = {['icon'] = [[Interface\Icons\Spell_Nature_Thunderclap]],         ['duration'] = 30,  ['display'] = false,},
}

local SPELLINFO_UNIQUE_DEBUFFS = {
    ['Kidney Shot'] = {['icon'] = [[Interface\Icons\Ability_Rogue_Kidneyshot]], ['cp'] = {2, 3, 4, 5, 6},       ['type'] = 'physical', ['prio'] = 2,    ['dr'] = 'Controlled Stun'},
    ['Rupture']     = {['icon'] = [[Interface\Icons\Ability_Rogue_Rupture]],    ['cp'] = {8, 10, 12, 14, 16},   ['type'] = 'physical', ['display'] = false,},
}   

local SPELLINFO_DEBUFF_REFRESHING_SPELLS = {
    -- DRUID
    ['Moonfire']        = {'Moonfire'},
    ['Rake']            = {'Rake'},
    -- HUNTER
    ['Wing Clip']       = {'Wing Clip',},
    -- MAGE
    ['Fireball']        = {'Fireball', },       
    ['Blizzard']        = {'Winter\'s Chill',},
    ['Cone of Cold']    = {'Winter\'s Chill',},
    ['Frost Nova']      = {'Winter\'s Chill',},
    ['Frostbolt']       = {'Frostbolt', 'Winter\'s Chill',},
    ['Scorch']          = {'Improved Scorch',},
    -- PALADIN
    ['Judgement of the Crusader'] = {'Judgement of the Crusader',}, ['Judgement of Justice'] = {'Judgement of Justice',}, ['Judgement of Light'] = {'Judgement of Light',},
    ['Judgement of Wisdom'] = {'Judgement of Wisdom',},
    -- PRIEST
    ['Mind Flay']               = {'Shadow Vulnerability',},
    ['Mind Blast']              = {'Shadow Vulnerability',},
    ['Shadow Vulnerability']    = {'Shadow Vulnerability',},
    -- ROGUE
    ['Hemorrhage']          = {'Hemorrhage',},
    ['Wound Poison IV']     = {'Wound Poison IV',},
    ['Deadly Poison V']     = {'Deadly Poison V',},
    -- SHAMAN
    ['Flame Shock']     = {'Flame Shock',},
    ['Frost Shock']     = {'Frost Shock',},
    -- WARLOCK
    ['Immolate']        = {'Immolate',},
    -- WARRRIOR
    ['Hamstring']       = {'Hamstring',},
    ['Mortal Strike']   = {'Mortal Strike',},
}

local SPELLINFO_ROOTS_SNARES = {
    -- MISC
    ['Net-o-Matic'] = true, 
    -- DRUID
    ['Entangling Roots'] = true, ['Feral Charge Effect'] = true, 
    -- HUNTER
    ['Concussive Shot'] = true, ['Wing Clip'] = true, ['Improved Wing Clip'] = true, 
    -- MAGE
    ['Blast Wave'] = true, ["Cone of Cold"] = true, ["Frostbite"] = true, ["Frost Nova"] = true, ['Frostbolt'] = true, 
    -- PALADIN      
    -- PRIEST   
    ['Mind Flay'] = true,
    -- ROGUE 
    -- SHAMAN
    ['Frost Shock']  = true,    
    -- WARRRIOR 
    ['Hamstring'] = true, ['Improved Hamstring'] = true,
}
--

-- The following is custom spell information

local CNPDebuff = CreateFrame("Frame", "CNPDebuff", UIParent)

local debuffList = {}

CNPDebuff:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
CNPDebuff:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
CNPDebuff:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
CNPDebuff:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")

local Print = function(msg)
  local out = "|cff008800CustomPlates: |r"..tostring(msg)
  if not DEFAULT_CHAT_FRAME:IsVisible() then
    FCF_SelectDockFrame(DEFAULT_CHAT_FRAME)
  end
  DEFAULT_CHAT_FRAME:AddMessage(out)
end

function CNPGetTrackedUnitDebuffs(unitName)
    if (debuffList[unitName] == nil) then
        return {}
    end

    return debuffList[unitName]
end

local function getExistingBuff(unitName, spellName)
    local debuffs = CNPGetTrackedUnitDebuffs(unitName)

    for k, v in ipairs(debuffs) do
        if v.name == spellName then
            return k, v
        end
    end

    return nil
end

local function getNewDebuffDRModifier(debuff)
    local modifier = 1
    if (SPELLINFO_BUFFS_TO_TRACK[debuff.name]['dr'] == nil) then
        return modifier
    else
        if debuff.drmodifier > 0.25 then
            modifier = debuff.drmodifier/2
        else
            modifier = 0
        end
    end

    return modifier
end

local function getDebuffDuration(spellName)
    if (SPELLINFO_BUFFS_TO_TRACK[spellName] == nil) then
        return 0
    end

    local duration = SPELLINFO_BUFFS_TO_TRACK[spellName]['duration']

    if (SPELLINFO_TIME_MODIFIER_BUFFS_TO_TRACK[spellName] == nil) then
        return duration
    else
        return duration * SPELLINFO_TIME_MODIFIER_BUFFS_TO_TRACK[spellName]['mod']
    end
end

local function addTrackedDebuff(unitName, spellName)
    if (SPELLINFO_BUFFS_TO_TRACK[spellName] == nil) then
        Print(spellName .. " is not trackable")
        return
    end

    local index, existing = getExistingBuff(unitName, spellName)
    Print(index)
    local drmod = 1
    if (existing ~= nil) then
        drmod = getNewDebuffDRModifier(existing)
    end

    local ctime = GetTime()

    local debuff = {}

    debuff.name = spellName
    debuff.starttime = ctime
    
    debuff.drmodifier = drmod
    debuff.duration = getDebuffDuration(spellName) * drmod
    debuff.endtime = debuff.starttime + debuff.duration
    debuff.target = unitName

    debuff.texture = SPELLINFO_BUFFS_TO_TRACK[spellName]['icon']

    if (debuffList[unitName] == nil) then
        debuffList[unitName] = {}
    end

    table.remove(debuffList[unitName], index)

    table.insert(debuffList[unitName], debuff)
end

local function parseDebuffEvent()
    local otherAfflictedRegex = "(.+) is afflicted by (.+)."
    local otherAfflicted = string.find(arg1, otherAfflictedRegex)

    Print(otherAfflicted)

    if (otherAfflicted and otherAfflictedRegex) then
        local afflictedUnitName = string.gsub(arg1, otherAfflictedRegex, '%1')
        local afflictedSpellName = string.gsub(arg1, otherAfflictedRegex, '%2')

        Print(afflictedUnitName)
        Print(afflictedSpellName)

        addTrackedDebuff(afflictedUnitName, afflictedSpellName)
    end
end


CNPDebuff:SetScript("OnEvent", function() 
        parseDebuffEvent()
    end
)

function CNPCleanUpExpiredDebuffs()
    local ctime = GetTime()

    for k, v in pairs(debuffList) do
        local i = 1
        for j, d in ipairs(v) do
            if (ctime > d.endtime) then
                table.remove(d, i)
            end
            i = i+1
        end

        -- No debuffs removed from this unit's debuff list. Therefore, 
        -- we can safely uncache the unit.
        if (i == 1) then
            debuffList[k] = nil
        end
    end
end
