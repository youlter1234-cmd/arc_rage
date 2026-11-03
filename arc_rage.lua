--[[
  arc_rage.lua - Arc Warden combo for Umbrella: Heroes -> Arc Warden -> Arc Rage (Scripts -> Utility if not there).
  Kir's bot's combo step for step (src/spells/aw_combo.h planAwUnit, items.h, combat_policy.h, combo_select.cpp).
  Hold the key (Space by default) with the cursor on an enemy hero: each tick the hero and the Tempest Double each
  take their next step, the next cast the moment the last one is done (max rage: by our clock, see Orders below).
  v36: per-body Spark switches, adjustable movement prediction, defensive-only main Manta by default,
  on-screen auto-farm state, and shared queued-cast reservations for silence and Linken breakers.
  v37: native-style target ring, chevron and lines; the Double's overhead task, target and remaining life.
  The visual distinguishes a queued cast from a cast phase and observed attacks; it never sends orders.
  v38: preserve active attacks, recover dropped/wrong-target orders, and reserve the Double throughout combo casts.
    0. saves: BKB first in an emergency; when silenced / rooted / a spell comes / 20% HP lost in 2 s: BKB, Manta,
       Satanic; Disperser / Heavy Blade cleanse; Crozier / Ghost / Ethereal on itself when hit by attacks; Glimmer;
       Wand / Stick / Locket / Mekansm / Greaves / Arcane Boots
    1. Tempest Double (the hero, within 1200): right at the target (v14, 100 short of it, menu switch), else the
       bot's point - beside the target, out of its team's attack and tower ranges, behind it when possible
    2. Linken's: popped by Flux, else by the cheapest item; while a pop flies the units wait; nothing to pop it:
       no holds / silences / targeted items, the rest goes on
    3. Blink in (450 short, where it will be) / Harpoon; hold chain shared by both units (Hex 2.8, Atos / Gleipnir
       2.0, Abyssal 1.6 through BKB), landing as the current one ends; silence: Bloodthorn, then Orchid;
       the double's Blink also chases a target running from it out of its reach (into BKB too; menu switch)
    4. Flux, each unit its own
    5. Magnetic Field a step towards the target: when hit, or in attack range; the hero hit -> both fields at once,
       250 either side of the hero; never into a field of ours
    6. items: debuffs, amps, nukes, own buffs by the bot's rules (BKB only in real danger, Mjollnir / Blade Mail
       when attacked, Manta to dispel or in the fight ...), Satanic / Essence Ring / Faerie Fire under half HP
    7. Spark Wraith where the target will be as it arms, only when it still lands there
    8. Midas on the biggest lane creep in 570 (one a creep a second)
    9. attack: once, again after each cast, again when it stood idle; never re-sent while swinging
  Illusions and our other units near the target or the hero attack it (6 orders each 0.1 s, again while they hit
  something else; selected illusions are yours).
  The target (cursor only): the enemy hero nearest the cursor (radius; an illusion stands for its hero); another
  hero there 0.15 s takes over (menu "Target": or locked until it dies, at the cursor / nearest / lowest HP); a press within 1 s goes on with the same
  hero; the hero dead -> the double alone. The double's own key (unbound by default): only the double fights.
  v19: Hex / Atos / Gleipnir / Abyssal / Bloodthorn / Orchid wait for the game before the next order (the next one
  cut them online); the rest waits 0.07 s, not 0.03; a debug log switch. v17: the hold time left read right (the next Hex lands as the last one ends). v16: the double's distance from the target is a slider (0..400, 100). v15: Silver Edge / Shadow Blade first, then the hit from invisibility, then the rest; an item with charges (Midas)
  counts a charge gone as the cast done. v13 (a tester, 2026-11-01): a hold in reach goes first (before the summon and the Blink), and until one is sent
  nothing else touches an unheld target (at most 1 s); Blink and Manta switch per unit (Manta off: kept for the
  dodger).
  After the key is up the double goes on with the target a few seconds (slider). Into Lotus Orb: no targeted casts;
  into BKB: no Flux / Spark / Blink / non-piercing items; attack-immune: no attacks. Refused: 0.6 s, 2 s, 4 s.
  With the key up (Auto group, the bot's awAutoField / exit support / autoMidas): the double's field on the hero
  when an enemy hero attacks it (both fields when low or 2+ attack); the double's dying gift (Mjollnir, then
  Linken's, on the hero with < 2 s of life or caught under 25% HP); Midas by the double (by the hero: off).
  v26 (Codex review FIX_BATCH_01): the combo's defensive field goes off the attackers (single / lens by them); the Duel
  field before the combo and farm, key held or not; the push chain owns both units, re-checks Duel / Chrono / Black
  Hole each step, counts only the item it sent, ends on your click; fields last by their rank; the farm walks only to a
  wave its life and safety allow, a solo tower only when it fits, attacks again right after a Manta, tells a cut TP
  from a landing, a camp is "empty" only when looked at, farm images are only the double's own Manta images.
  v25 (Darer, roblox): "double next to the target" is off by default (not recommended); the double no longer
  walks with our creep wave (a switch, off) - it goes for the next enemy wave; no tower under backdoor protection.
  v25: in its last 7 s with nothing it may finish the double attack-moves to the nearest enemy creep / tower in reach.
  v25: an Earth Spirit within 1200 rolling anywhere but at us is stopped by the double appearing on his line ahead of the boulder.
  v25: Manta images (the hero's and the double's) body-block the target in the combo: in front of it when it runs (one
  in the centre, two at the sides), beside its path when they can't get ahead yet; while it stands they hit it.
  v25: smart Magnetic Field (lab 2026-11-01: an attacker outside a field misses the hero in it, also in each of two
  overlapping ones): the field goes off the hero's centre away from those swinging at him; from both sides the second
  field makes a lens 200 wide with the first; none against an MKB on all; the hero keeps 25% mana. Push key (aw_force
  + Pika's script): turn to the cursor, the double's Pike / Force on the hero, then his own; no double -> summon first.
  Hook save (hook_defense.cpp): an enemy Pudge's hook on the hero's line - a free double walks onto the line in front
  of him if it gets there in time, else Tempest Double at the last safe moment, the double there 0.05 s before the tip.
  Boulder save (boulder_defense.cpp): the same against Earth Spirit's Rolling Boulder, the double 200 in front of him.
  Camps (aw_jungle.h, Farm switch): with no creeps around it the double farms a neutral camp within 1800 between waves,
  weakest neutral first, confirmed dead camp members cached until the next minute; unknown visibility is retried. Midas in camps: on the neutral with the most HP.
  v24: in its field at a tower it stays inside (creeps it kills from there, else the tower); its Manta images follow
  it; with our creeps it walks 300 ahead of the front one, not behind our ranged creep (Darer).
  v23: the double's lane farm is the bot's own, rule for rule (aw_farm*.cpp, lanes only): TP by its scroll with Boots
  of Travel onto our creeps (also to push a lane with no wave), Blink / Force Staff on the way, never on foot back
  toward our base, out of an enemy tower's fire, back from an enemy hero it does not fight, Static Charge on our front
  creep, Stick / Wand / Locket, Spark on a lone ranged creep, an attack-move with our creeps; an enemy TP to the tower
  it pushes alone: Spark at the landing for vision and that tower is left (Darer).
  v22: Manta on creeps (3+) and towers; with no creeps of ours the double hits the nearest unguarded tower alone
  under its own field; an on/off key for the auto farm (unbound by default); plain labels for auto farm and the fight after release; the farm casts no Flux; Field and Spark Wraith on creeps, Field at the tower it pushes (Darer).
  v21: illusions and units are sent again when they hit something else or stand idle (they went for creeps from
  full range); 6 orders a 0.1 s, units near the hero join too.
  v20 (Farm group): with the keys up the double farms the lanes the bot's way (no camps) - see "lane farm"
  below: the wave worth most per second of its life, a TP to it when walking is long, last hits by a forecast
  of every creep's coming hits, Field / Spark on creeps, Field at towers, a push with our creeps, an enemy hero near it
  fought with the combo. Log lines "farm: ...". A click of yours on the double pauses it (slider).
  Orders: Player.PrepareUnitOrders straight to the unit (issuer PASSED_UNIT_ONLY, as the bot sends them: no selection
  switch, no camera), execute_fast; Umbrella's Ability.Cast* only when that call is missing (menu switch).
  Max rage (v12, Kir 2026-11-01 «самые минимальные задержки»): a unit's next order goes when its cast is done on the
  server by our own clock - turn + cast point + a tick or two (both orders take the same way there) - not when the
  game's answer comes back a ping later; a walk into range keeps the old wait; IMMEDIATE items (BKB, Satanic, Shiva's,
  Veil, Blade Mail: game files) free the unit at once. The same spell is never sent twice while one is in flight.
  Numbers (7.41 game files): Flux CP 0.3, range 625/700/775/850 (+200 talent); Field CP 0.3, radius 300;
  Spark CP 0.3, arms 1.5 s, range 2000, search 375; Tempest Double CP 0.15, range 700.
  Log lines start with [arc_rage]: every order with its time since the key went down, refusals, start / release.
  Menu text is Russian when Umbrella's language is Russian (the widget names, i.e. the saved settings, stay English).
]]

local Script = {}

local function Try(fn, ...)
  local ok, res = pcall(fn, ...)
  if ok then return res end
  return nil
end

local function Note(fmt, ...)
  if Log and Log.Write then Log.Write("[arc_rage] " .. string.format(fmt, ...)) end
end

local atan2 = math.atan2 or math.atan
local ARC          = "npc_dota_hero_arc_warden"
local BUILD_ID     = "v38-20261102-combo-recovery"
local DOUBLE_MOD   = "modifier_arc_warden_tempest_double"
local FIELD        = "arc_warden_magnetic_field"
local LATENCY      = 0.09
local SPARK_ARM    = 1.5
local SPARK_SEARCH = 375
local SPARK_RANGE  = 2000
local FIELD_RADIUS = 300
local FIELD_LASTS  = 4.0
local TEMPEST_NEAR = 1200
-- max rage slack after a cast's own time: a server tick (1/30 s) for a zero cast point, two for a cast point
-- 0.03 lost orders online (a tester's log, 2026-11-01: Hex / Bloodthorn sent, the next order 0.03-0.04 s after
-- them, each refused 0.45 s later - both reached the server in one tick and the second replaced the first)
local SLACK_ZERO   = 0.07
local SLACK_CAST   = 0.06
local IMMEDIATE    = 2048  -- DOTA_ABILITY_BEHAVIOR_IMMEDIATE
-- hook_defense.cpp castEcho: our hero's cast order -> its phase seen (the way there and back + the turn), last 8;
-- the hook / boulder save times its Tempest Double by the best of them
local ECHO = { n = 0 }

-- the bot's item catalogue (spells/items_catalog.h): holds (seconds held, range, through BKB)
local HOLDS = {
  { name = "item_sheepstick",    hold = 2.8, range = 800 },
  { name = "item_rod_of_atos",   hold = 2.0, range = 1100 },
  { name = "item_gungir",        hold = 2.0, range = 1100, point = true },
  { name = "item_abyssal_blade", hold = 1.6, range = 150, pierces = true },
}
-- may pop Linken's, cheapest to waste first
local LINKEN_POP = { "item_medallion_of_courage", "item_crippling_crossbow", "item_diffusal_blade", "item_disperser",
                     "item_heavens_halberd", "item_rod_of_atos", "item_harpoon", "item_orchid", "item_nullifier",
                     "item_dagon_upgraded", "item_dagon_5", "item_dagon_4", "item_dagon_3", "item_dagon_2", "item_dagon",
                     "item_ethereal_blade", "item_bloodthorn", "item_abyssal_blade", "item_sheepstick" }
local DEBUFFS = {
  { "item_nullifier", 900 }, { "item_diffusal_blade", 600 }, { "item_disperser", 600 },
  { "item_heavens_halberd", 750 }, { "item_medallion_of_courage", 1000 }, { "item_crippling_crossbow", 650 },
  { "item_essence_distiller", 1000 }, { "item_spirit_vessel", 750, soul = true }, { "item_urn_of_shadows", 750, soul = true },
}
local AMPS   = { { "item_veil_of_discord", 850 }, { "item_jidi_pollen_bag", 850 } }
local NUKES  = { { "item_dagon_upgraded", 790, true }, { "item_dagon_5", 820, true }, { "item_dagon_4", 790, true },
                 { "item_dagon_3", 760, true }, { "item_dagon_2", 730, true }, { "item_dagon", 700, true },
                 { "item_shivas_guard", 700 }, { "item_blood_grenade", 900 } }
local BLINKS = { { "item_blink", 1200 }, { "item_overwhelming_blink", 1200 }, { "item_swift_blink", 1200 },
                 { "item_arcane_blink", 1400 } }

-- own buffs in catalogue order with the bot's wanted() rule (items.h planItemsBurst); self: cast on itself
local BUFFS = {
  { "item_black_king_bar", "bkb" }, { "item_minotaur_horn", "bkb" }, { "item_manta", "manta" },
  { "item_blade_mail", "blademail" }, { "item_ancient_janggo", "hitting" }, { "item_boots_of_bearing", "hitting" },
  { "item_bloodstone", "hitting" }, { "item_dagger_of_ristul", "hitting" }, { "item_flayers_bota", "hitting" },
  { "item_idol_of_screeauk", "danger" }, { "item_metamorphic_mandible", "danger" },
  { "item_riftshadow_prism", "hitting" }, { "item_phase_boots", "chase" },
  { "item_mjollnir", "focused", self = true }, { "item_solar_crest", "focused", self = true },
  { "item_pavise", "focused", self = true }, { "item_lotus_orb", "dispel", self = true },
  { "item_pipe", "pipe" }, { "item_crimson_guard", "crimson" },
  { "item_polliwog_charm", "polliwog", self = true }, { "item_seeds_of_serenity", "seeds", here = true },
  { "item_ash_legion_shield", "ash" }, { "item_kobold_cup", "kobold" }, { "item_spider_legs", "spider" },
  { "item_demonicon", "demonicon" },
}

-- --------------------------------------------------------------------- menu --
local ui = {}
local configReport

-- Russian text when Umbrella's language is Russian (SettingsHidden -> Main -> Language: 1, as the community scripts
-- read it). Widget names stay English: they are the config keys, so a language switch keeps every setting.
local RU = {
  ["Double intercepts Sharpshooter for allies"] = "Двойник перехватывает Sharpshooter для союзников",
  ["Interrupt Dismember on allies with a free body"] = "Свободное тело прерывает Dismember на союзнике",
  ["Combo"] = "Комбо", ["Auto"] = "Авто", ["Enabled"] = "Включено", ["Combo key"] = "Кнопка комбо",
  ["Target radius around cursor"] = "Радиус поиска цели вокруг курсора",
  ["None at the cursor: nearest to the hero (850)"] = "Никого у курсора: ближайший к герою (850)",
  ["Target"] = "Цель",
  ["Tempest Double first"] = "Сначала Tempest Double",
  ["Tempest Double away from the hero (off: on the hero, as v4)"] = "Клон в стороне от героя (выкл: на герое)",
  ["Double keeps fighting after combo key release (s)"] = "Клон дерётся ещё N с после отпускания комбо",
  ["Tempest Double next to the target (not recommended)"] = "Клон вплотную к цели (не рекомендую)",
  ["Double's distance from the target"] = "Расстояние клона до цели",
  ["Use items"] = "Предметы", ["Blink in"] = "Блинк на вход (герой)", ["Double: Blink in"] = "Блинк на вход (клон)",
  ["Double chases with Blink"] = "Клон догоняет блинком",
  ["Hero: Manta in combo"] = "Манта в комбо (герой)",
  ["Hero: offensive Manta (off: defensive use only)"] = "Герой: манта для атаки (выкл: только для защиты)",
  ["Hero: Spark Wraith in combo"] = "Герой: спарки в комбо",
  ["Double: Spark Wraith in combo"] = "Клон: спарки в комбо",
  ["Spark prediction (%)"] = "Упреждение спарка (%)",
  ["Manta illusions body-block the target"] = "Иллюзии Манты блокируют цель телом",
  ["Hero stays in the fields' overlap (no walk out after the target)"] = "Герой стоит в перекрытии полей, не бежит за целью", ["Double: Manta in combo"] = "Манта в комбо (клон)",
  ["Double combo key"] = "Кнопка комбо клона",
  ["Silver Edge / Shadow Blade: the hit from invisibility first"] = "Silver Edge / Shadow Blade: сначала удар из инвиза",
  ["Illusions and units join"] = "Иллюзии и юниты бьют цель",
  ["No targeted casts into Lotus Orb"] = "Не кастовать в Lotus Orb",
  ["Fast orders (no Umbrella delays)"] = "Быстрые приказы (без задержек Umbrella)",
  ["Max rage: next cast without waiting for the game's answer"] = "Макс. рейдж: следующий каст не ждёт ответа игры",
  ["Direct orders (no selection switch)"] = "Прямые приказы (без переключения выделения)",
  ["Umbrella order-spam guard"] = "Страховка Umbrella от спама приказов",
  ["Recommended execution"] = "Рекомендуемый режим приказов",
  ["Log execution setup"] = "Записать режим и API в лог",
  ["Magnetic Field when an enemy hero attacks the hero"] = "Поле, когда героя бьёт вражеский герой",
  ["Double's last gift (Mjollnir / Linken's)"] = "Клон перед смертью отдаёт Mjollnir / Linken",
  ["Midas by the double"] = "Мидас клоном", ["Midas by the hero"] = "Мидас героем",
  ["Double waits after your click on it (s)"] = "Клон ждёт после клика по нему (с)",
  ["Debug log (holds, 5 a second)"] = "Отладочный лог (хексы, 5 раз в секунду)",
  ["Farm"] = "Фарм", ["Auto farm: double farms lanes while combo key is not held"] = "Автофарм: клон фармит линии, пока комбо не зажато",
  ["Auto farm on/off key"] = "Кнопка вкл/выкл автофарма",
  ["Show auto farm status on screen"] = "Показывать статус автофарма на экране",
  ["Auto farm: OFF"] = "Автофарм: ВЫКЛ",
  ["Auto farm: ON"] = "Автофарм: ВКЛ",
  ["script off"] = "скрипт выключен", ["no double"] = "клон не призван",
  ["combo"] = "комбо", ["manual control"] = "ручное управление",
  ["saving"] = "сейв", ["push"] = "толчок", ["farming"] = "фармит",
  ["waiting"] = "ожидание", ["teleporting"] = "телепорт", ["paused"] = "пауза",
  ["orders blocked"] = "Umbrella блокирует приказы", ["controlled"] = "под контролем",
  ["waiting for cast"] = "ожидает каст", ["no safe task"] = "нет доступной цели",
  ["no attack target"] = "ждёт цель", ["farm error"] = "ошибка фарма: см. лог",
  ["Visuals"] = "Визуалы", ["Highlight combo target"] = "Выделять цель комбо",
  ["Line to combo target"] = "Линия к цели комбо",
  ["Show predicted target position"] = "Показывать прогноз позиции цели",
  ["Double status above its health bar"] = "Статус клона над полоской здоровья",
  ["Double status text size"] = "Размер текста над клоном",
  ["Only target lines"] = "Только линия к цели",
  ["Combo troubleshooting preset"] = "Профиль для проверки комбо",
  ["Push key: double's Pike / Force on you, then yours"] = "Толчок: пика / форс клона в тебя, потом твоя",
  ["Push key with no double: summon it next to you first"] = "Толчок без клона: сначала призвать его рядом",
  ["Double: Manta on creeps and towers"] = "Клон: манта по крипам и башне",
  ["Double pushes towers (with our creeps, else alone under its field)"] = "Клон пушит башни (с крипами, иначе один под полем)",
  ["Double walks with our creep wave (off: straight to the next enemy wave)"] = "Клон ходит с нашей волной (выкл: сразу к следующей вражеской)",
  ["Double: TP to far waves"] = "Клон: ТП к дальним волнам",
  ["Double: Field / Spark on creeps, Field on towers"] = "Клон: поле / спарк по крипам, поле у башни",
  ["Double pushes towers with our creeps"] = "Клон пушит башни вместе с нашими крипами",
  ["Double fights an enemy hero near it (1200)"] = "Клон бьёт вражеского героя рядом (1200)",
  ["Double: Spark Wraith where an enemy TPs in to the tower it pushes alone"] = "Клон: спарк на место ТП врага к башне, которую пушит один",
  ["Double: neutral camps between waves"] = "Клон: лесные кемпы между волнами",
  ["Double saves from Pudge's hook"] = "Клон спасает от хука Пуджа",
  ["Double saves from Rolling Boulder"] = "Клон спасает от Rolling Boulder",
  ["Loaded"] = "Загружен", ["Waiting for Arc Warden"] = "Ждёт Arc Warden", ["No enemy at the cursor"] = "Нет врага у курсора",
  ["Combo on "] = "Комбо на ", ["Double on "] = "Клон на ", ["Ready"] = "Готов",
}
local EN = { ["Tempest Double away from the hero (off: on the hero, as v4)"] = "Tempest Double away from the hero" }
-- "Target" modes (a tester asked to choose); 0 follows the cursor, the rest keep the first pick until it dies
local TARGET_EN = { "Nearest to cursor (switches)", "Nearest to cursor, locked", "Nearest to the hero, locked",
                    "Lowest HP near the hero, locked" }
local TARGET_RU = { "У курсора (переключается)", "У курсора, фиксированная", "Ближайший к герою, фиксированная",
                    "Меньше всего HP рядом, фиксированная" }
local named = {}  -- { widget, its name }: the text shown in the menu follows the language
local langWidget, langRu = nil, nil
local function russian()
  langWidget = langWidget or Try(Menu.Find, "SettingsHidden", "", "", "", "Main", "Language")
  return langWidget ~= nil and Try(function() return langWidget:Get() end) == 1
end
local function tr(text) return langRu and RU[text] or text end
local function name(w, n) if w then named[#named + 1] = { w, n } end return w end

-- a group in our tab; Scripts -> Utility -> Arc Rage when the hero tab is not there
local function group(tab, n)
  local g = tab and Try(function() return tab:Create(n) end)
  if g == nil then g = Try(Menu.Create, "Scripts", "Utility", "Arc Rage", "Main", n) end
  return name(g, n)
end
local function sw(g, n, v) return g and name(Try(function() return g:Switch(n, v) end), n) end
local function sl(g, n, a, b, v) return g and name(Try(function() return g:Slider(n, a, b, v) end), n) end

local function buildMenu()
  -- its own tab next to Umbrella's in Heroes -> Arc Warden (where 1x6 puts its combos)
  local tab = Try(Menu.Create, "Heroes", "Hero List", "Arc Warden", "Arc Rage")
  local grp = group(tab, "Combo")
  if grp == nil then return false end
  if tab then Try(function() tab:Image("panorama/images/heroes/icons/npc_dota_hero_arc_warden_png.vtex_c") end) end
  ui.status  = Try(function() return grp:Label("Loaded") end)  -- shows the script is in, then what it does
  ui.enabled = sw(grp, "Enabled", true)
  ui.key     = name(Try(function() return grp:Bind("Combo key", Enum.ButtonCode.KEY_SPACE) end), "Combo key")
  ui.radius  = sl(grp, "Target radius around cursor", 200, 1500, 600)
  ui.near    = sw(grp, "None at the cursor: nearest to the hero (850)", false)
  ui.target  = name(Try(function() return grp:Combo("Target", TARGET_EN, 0) end), "Target")
  ui.double  = sw(grp, "Tempest Double first", true)
  ui.tdAway  = sw(grp, "Tempest Double away from the hero (off: on the hero, as v4)", true)
  -- a tester, 2026-11-01: Umbrella's own combo puts the double right at the enemy hero; this wins over the switch above.
  -- Off by default (another tester: worse); a new widget name so a saved "on" does not carry over
  ui.tdAtTarget = sw(grp, "Tempest Double next to the target (not recommended)", false)
  ui.tdGap   = sl(grp, "Double's distance from the target", 0, 400, 100)
  ui.after   = sl(grp, "Double keeps fighting after combo key release (s)", 0, 8, 3)
  ui.keyD    = name(Try(function() return grp:Bind("Double combo key", Enum.ButtonCode.KEY_NONE) end), "Double combo key")
  ui.items   = sw(grp, "Use items", true)
  ui.sneak   = sw(grp, "Silver Edge / Shadow Blade: the hit from invisibility first", true)
  -- "Blink in" (the old name, its saved value kept) is the hero's now; a tester, 2026-11-01: off on the hero turned
  -- the double's off too
  ui.blink   = sw(grp, "Blink in", true)
  ui.blinkD  = sw(grp, "Double: Blink in", true)
  ui.chase   = sw(grp, "Double chases with Blink", true)
  -- off: that unit's Manta stays for Umbrella's dodger (the combo neither saves nor fights with it)
  ui.mantaH  = sw(grp, "Hero: Manta in combo", true)
  ui.mantaD  = sw(grp, "Double: Manta in combo", true)
  ui.mantaAttackH = sw(grp, "Hero: offensive Manta (off: defensive use only)", false)
  ui.sparkH  = sw(grp, "Hero: Spark Wraith in combo", true)
  ui.sparkD  = sw(grp, "Double: Spark Wraith in combo", true)
  ui.sparkLead = sl(grp, "Spark prediction (%)", 0, 150, 100)
  ui.lens    = sw(grp, "Hero stays in the fields' overlap (no walk out after the target)", true)
  ui.units   = sw(grp, "Illusions and units join", true)
  ui.block   = sw(grp, "Manta illusions body-block the target", true)
  ui.lotus   = sw(grp, "No targeted casts into Lotus Orb", true)
  ui.fast    = sw(grp, "Fast orders (no Umbrella delays)", true)
  ui.rage    = sw(grp, "Max rage: next cast without waiting for the game's answer", false)
  ui.direct  = sw(grp, "Direct orders (no selection switch)", true)
  ui.guard   = sw(grp, "Umbrella order-spam guard", true)
  local ag = group(tab, "Auto") or grp
  ui.channelSave = sw(ag, "Interrupt Dismember on allies with a free body", true)
  ui.aField  = sw(ag, "Magnetic Field when an enemy hero attacks the hero", true)
  ui.gift    = sw(ag, "Double's last gift (Mjollnir / Linken's)", true)
  ui.aMidasD = sw(ag, "Midas by the double", true)
  ui.aMidasH = sw(ag, "Midas by the hero", false)
  ui.dPause  = sl(ag, "Double waits after your click on it (s)", 0, 5, 2)
  ui.debug   = sw(ag, "Debug log (holds, 5 a second)", false)
  ui.push      = name(Try(function() return ag:Bind("Push key: double's Pike / Force on you, then yours", Enum.ButtonCode.KEY_NONE) end), "Push key: double's Pike / Force on you, then yours")
  ui.pushSpawn = sw(ag, "Push key with no double: summon it next to you first", true)
  ui.sharpSave = sw(ag, "Double intercepts Sharpshooter for allies", true)
  ui.hookSave    = sw(ag, "Double saves from Pudge's hook", true)
  ui.boulderSave = sw(ag, "Double saves from Rolling Boulder", true)
  local fg = group(tab, "Farm") or ag
  ui.farm      = sw(fg, "Auto farm: double farms lanes while combo key is not held", true)
  ui.farmKey   = name(Try(function() return fg:Bind("Auto farm on/off key", Enum.ButtonCode.KEY_NONE) end), "Auto farm on/off key")
  ui.farmHud   = sw(fg, "Show auto farm status on screen", true)
  ui.farmTp    = sw(fg, "Double: TP to far waves", true)
  ui.farmSpell = sw(fg, "Double: Field / Spark on creeps, Field on towers", true)
  ui.farmManta = sw(fg, "Double: Manta on creeps and towers", true)
  ui.farmPush  = sw(fg, "Double pushes towers (with our creeps, else alone under its field)", true)
  ui.farmFollow = sw(fg, "Double walks with our creep wave (off: straight to the next enemy wave)", false)
  ui.farmFight = sw(fg, "Double fights an enemy hero near it (1200)", true)
  ui.farmTpSpark = sw(fg, "Double: Spark Wraith where an enemy TPs in to the tower it pushes alone", true)
  ui.farmCamps = sw(fg, "Double: neutral camps between waves", true)
  local vg = group(tab, "Visuals") or grp
  ui.linesOnly = sw(vg, "Only target lines", true)
  ui.targetVisual = sw(vg, "Highlight combo target", true)
  ui.targetLine = sw(vg, "Line to combo target", true)
  ui.targetPredict = sw(vg, "Show predicted target position", false)
  ui.cloneStatus = sw(vg, "Double status above its health bar", true)
  ui.cloneTextSize = sl(vg, "Double status text size", 16, 30, 22)
  name(Try(function() return grp:Button("Recommended execution", function()
    for key, value in pairs({ fast = true, direct = true, guard = true, rage = false }) do
      Try(function() ui[key]:Set(value) end)
    end
    if configReport then configReport("recommended button") end
  end) end), "Recommended execution")
  name(Try(function() return grp:Button("Combo troubleshooting preset", function()
    -- A single-fight setup to separate combo execution from farming and the invisibility opener.
    for key, value in pairs({ fast = true, direct = true, guard = true, rage = false,
      enabled = true, double = true, items = true, blinkD = true, chase = true,
      sneak = false, farm = false, target = 1, after = 2, dPause = 0,
      tdAtTarget = false, sparkH = true, sparkD = true, linesOnly = true, targetLine = true }) do
      Try(function() ui[key]:Set(value) end)
    end
    if configReport then configReport("combo troubleshooting preset") end
  end) end), "Combo troubleshooting preset")
  name(Try(function() return grp:Button("Log execution setup", function()
    if configReport then configReport("button") end
  end) end), "Log execution setup")
  return ui.key ~= nil
end

local shown = "Loaded"
local function status(text)
  if text == shown or ui.status == nil then return end
  shown = text
  Try(function() ui.status:Name(text) end)
end

local function on(w) return w ~= nil and Try(function() return w:Get() end) == true end
configReport = function(reason)
  local src = Try(function() return debug.getinfo(1, "S").source end) or "unknown"
  local values = {}
  for _, key in ipairs({ "fast", "rage", "direct", "guard", "key", "keyD", "target", "blink", "blinkD",
                         "tdAtTarget", "tdAway", "tdGap", "farm", "farmFollow", "mantaH", "mantaD",
                         "mantaAttackH", "sparkH", "sparkD", "sparkLead", "farmHud",
                         "targetVisual", "targetLine", "targetPredict", "cloneStatus", "cloneTextSize", "linesOnly", "sneak", "dPause" }) do
    values[#values + 1] = key .. "=" .. tostring(Try(function() return ui[key]:Get() end))
  end
  Note("release %s; %s; source=%s; reason=%s; %s", BUILD_ID, tostring(_VERSION), src, reason, table.concat(values, " "))
  Note("API PrepareUnitOrders=%s CastTarget=%s CastPosition=%s CastNoTarget=%s Guard=%s Budget=%s Queue=%s; guard result=%s",
    type(Player and Player.PrepareUnitOrders), type(Ability and Ability.CastTarget), type(Ability and Ability.CastPosition),
    type(Ability and Ability.CastNoTarget), type(Humanizer and Humanizer.IsSafeToCastOrder),
    type(Humanizer and Humanizer.OrdersCanBeCastedThisTick), type(Humanizer and Humanizer.GetOrderQueue),
    tostring(Try(function() return Humanizer.IsSafeToCastOrder() end)))
end
local function num(w, d)
  local v = w and Try(function() return w:Get() end)
  if type(v) == "number" then return v end
  return d
end

-- the menu's text in the current language, again whenever it changes
local function applyLanguage()
  local ru = russian()
  if ru == langRu then return end
  langRu = ru
  for _, e in ipairs(named) do
    local w, n = e[1], e[2]
    Try(function() w:ForceLocalization(ru and RU[n] or EN[n] or n) end)
  end
  local pick = math.tointeger(num(ui.target, 0)) or 0
  Try(function() ui.target:Update(ru and TARGET_RU or TARGET_EN, pick) end)
  local was = shown
  shown = nil
  if was == "Loaded" or was == RU["Loaded"] then status(tr("Loaded")) end  -- the lobby shows it until a game
end

-- ------------------------------------------------------------------ helpers --
local function pos(u) return u and Try(Entity.GetAbsOrigin, u) end
local function idx(u) return u and Try(Entity.GetIndex, u) or 0 end
local function dist(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return math.sqrt(dx * dx + dy * dy)
end
local function toward(from, to, step)
  local d = dist(from, to)
  if d < 1 then return from end
  return Vector(from.x + (to.x - from.x) / d * step, from.y + (to.y - from.y) / d * step, from.z)
end
local function alive(u) return u ~= nil and Try(Entity.IsAlive, u) == true end
local function visible(u) return Try(Entity.IsDormant, u) ~= true and Try(NPC.IsVisible, u) ~= false end
local function has(u, m) return Try(NPC.HasModifier, u, m) == true end
local function counterspell(u)
  return has(u, "modifier_antimage_counterspell") or has(u, "modifier_antimage_counterspell_ally")
end
local function hasState(u, s) return Try(NPC.HasState, u, s) == true end
local function MS() return Enum.ModifierState end
local function debuffImmune(u)
  return hasState(u, MS().MODIFIER_STATE_MAGIC_IMMUNE)
    or (MS().MODIFIER_STATE_DEBUFF_IMMUNE ~= nil and hasState(u, MS().MODIFIER_STATE_DEBUFF_IMMUNE))
    or has(u, "modifier_black_king_bar_immune")
end
local function teamOf(u) return Try(Entity.GetTeamNum, u) end
local function hpFrac(u) return (Try(Entity.GetHealth, u) or 0) / math.max(1, Try(Entity.GetMaxHealth, u) or 1) end

local function stateLeft(u, list)
  local want = {}
  for i = 1, #list do want[list[i]] = true end
  -- true: the time left (without it the full duration came back, so a hold looked fresh to its end and the next
  -- Hex waited for it: a tester, 2026-11-01 «hex takes too long to cast hex again»; the community scripts pass it)
  local d = Try(NPC.GetStatesDuration, u, want, true) or {}
  local best = 0
  for _, v in pairs(d) do if type(v) == "number" and v > best then best = v end end
  return best
end
-- the target can neither move nor act (stun, hex, nightmare) or move (root) this much longer
-- our holds by their own modifiers: their die time is the exact end, whatever the states read says
local HOLD_MODS = { "modifier_sheepstick_debuff", "modifier_rod_of_atos_debuff", "modifier_gungnir_debuff", "modifier_bashed" }
local function holdModsLeft(u, now)
  local ours = nil
  for _, n in ipairs(HOLD_MODS) do
    local m = Try(NPC.GetModifier, u, n)
    local die = m and Try(Modifier.GetDieTime, m)
    if type(die) == "number" and die > now then ours = math.max(ours or 0, die - now) end
  end
  return ours
end
local function heldLeft(u)
  local left = stateLeft(u, { MS().MODIFIER_STATE_STUNNED, MS().MODIFIER_STATE_HEXED, MS().MODIFIER_STATE_ROOTED,
                              MS().MODIFIER_STATE_NIGHTMARED })
  local now = Try(GameRules.GetGameTime)
  if type(now) ~= "number" then return left end
  local ours = holdModsLeft(u, now)
  -- one of ours on it and nothing longer seen by its state: trust the modifier
  if ours and (left <= 0 or left > ours + 0.05) then return ours end
  return left
end
local function modLeft(u, name, now)
  local m = Try(NPC.GetModifier, u, name)
  local die = m and Try(Modifier.GetDieTime, m)
  if type(die) ~= "number" then return 0 end
  return math.max(0, die - now)
end

-- radians between where u faces and the direction to p (9: unknown)
local function facingOff(u, p)
  local up, f = pos(u), Try(Entity.GetForwardPosition, u, 100)
  if up == nil or f == nil then return 9 end
  local a = atan2(f.y - up.y, f.x - up.x) - atan2(p.y - up.y, p.x - up.x)
  return math.abs((a + math.pi) % (2 * math.pi) - math.pi)
end

local function item(u, name)
  if not on(ui.items) or Try(NPC.HasState, u, Enum.ModifierState.MODIFIER_STATE_MUTED) == true then return nil end
  return Try(NPC.GetItem, u, name, true)
end
local function castable(u, ab) return ab ~= nil and Try(Ability.IsCastable, ab, Try(NPC.GetMana, u) or 0) == true end
local function attackRange(u)
  return (Try(NPC.GetAttackRange, u) or 625) + (Try(NPC.GetAttackRangeBonus, u) or 0)
end
local function castBonus(u) return Try(NPC.GetCastRangeBonus, u) or 0 end
-- the game measures attack range edge to edge: a hero hitting from its full range stands this much farther, centre
-- to centre (Kir's friend: «без клона купол под себя 50 на 50» — he hit from range and never got within +30)
local function hulls(u, h) return (Try(NPC.GetHullRadius, u) or 24) + (Try(NPC.GetHullRadius, h) or 24) end

-- ------------------------------------------------------------------- state --
-- G: the fight, shared by the hero and the double; U[index]: one unit's own casts; D: outside the combo; F: the farm
local G, U, D, F = {}, {}, {}, {}
local function reset()
  G = {
    target = nil, wasHeld = false, startAt = 0, afterUntil = -100, releasedAt = -100,
    cand = nil, candSince = 0,  -- another hero at the cursor while the key is held, since when
    fights = {}, lastFieldAt = -100, -- control and Linken coordination belong to the target
    fields = {},                -- { pos, at }: our Magnetic Fields, no second one over either
    pair = nil,                 -- both fields at once: { hero, double centres, at, heroDone, doubleDone }
    track = {},                 -- target velocity
    double = nil, doubleAt = -100,
    atkAt = {},                 -- enemy hero -> last seen in its attack animation
    midasAt = {},               -- creep -> its last Midas by either unit (one a creep a second)
    unitAttack = {}, unitsAt = -100,  -- illusions / units sent at the target
    held = false, heroFocused = false, heroLoss = 0, heroAttackers = 0, lastNow = 0,
  }
  U = {}
  D = {
    ownAt = -100, pauseUntil = -100, playerAt = -100,  -- our last order; your click on the double / the hero
    fieldAt = -100, midasAt = -100, hookLease = -100,  -- hookLease: the double walks onto a hook line until then
    bornAt = nil, lasts = 18, life = nil, had = false,  -- the double's life, for the gift and the log
  }
  F = {
    live = false, dbl = 0,      -- the farm runs (the attack callbacks record only then); the double's index
    hits = {},                  -- creep index -> attacks on their way to it { src, land, release, dmg, projectile }
    cycles = {},                -- attacker index -> its next swing at the same creep { src, target, next, cp, spa, ranged, dmg }
    scanAt = -100, waves = {}, ours = {}, enemies = {}, towers = {}, heroes = {},
    task = nil, claimUntil = 0, why = nil, fight = nil, tp = false, logAt = -100,
  }
end
reset()

local function unitState(u)
  local i = idx(u)
  local s = U[i]
  if s == nil then
    s = {
      pending = nil,           -- { ab, key, sentAt, cp, cd0, freeAt }: the last cast sent
      inflight = {},           -- every cast the game has not answered yet (max rage: more than one)
      backoff = {},            -- ability name -> game time it may be tried again (the game refused it)
      refused = {},            -- ability name -> refusals in a row (0.6 s, 2 s, then 4 s)
      nextOrder = 0,
      castAt = {},             -- item name -> last cast (once a 0.8 s)
      lastFluxAt = -100, lastSparkAt = -100,
      attackSentAt = nil, lastCastAt = -100, lastAttackAt = -100,
      attackTarget = nil, attackCastAt = -100, attackProgressAt = -100,
      hp = {},                 -- HP samples for the last 2 s
    }
    U[i] = s
  end
  return s
end

local function hpLoss2s(u, s, now)
  local hp, maxHp = Try(Entity.GetHealth, u) or 0, Try(Entity.GetMaxHealth, u) or 1
  local h = s.hp
  h[#h + 1] = { t = now, hp = hp }
  while #h > 1 and now - h[1].t > 2.0 do table.remove(h, 1) end
  local top = hp
  for i = 1, #h do if h[i].hp > top then top = h[i].hp end end
  return (top - hp) / math.max(1, maxHp)
end

-- an enemy ability in its cast point (the bot keys on its dodger's disables; the API has no such table: any)
local function castingAt(e)
  for i = 0, 9 do
    local ab = Try(NPC.GetAbilityByIndex, e, i)
    if ab and Try(Ability.IsInAbilityPhase, ab) == true then return true end
  end
  return false
end

-- combo_caster.cpp: focused = an enemy hero facing us (0.45 rad) in its range + 200 attacked within 1.2 s;
-- incoming = one facing us (0.25 rad) within 1100 in a cast point; near = enemy heroes in 900;
-- attackers (attack_notice.cpp) = ones swinging at us right now (20 degrees, range + 200, 0.45 s)
local function danger(u, now)
  local z = { focused = false, incoming = false, near = 0, attackers = 0, spots = {} }
  local up = pos(u)
  if up == nil then return z end
  for _, e in ipairs(Try(Heroes.InRadius, up, 1400, teamOf(u), Enum.TeamType.TEAM_ENEMY, false, true) or {}) do
    local ep = pos(e)
    if ep and alive(e) then
      local i = idx(e)
      if Try(NPC.IsAttacking, e) == true then G.atkAt[i] = now end
      local dd, off = dist(up, ep), facingOff(e, up)
      local swung = now - (G.atkAt[i] or -100)
      if dd < 900 then z.near = z.near + 1 end
      if off < 0.45 and dd < attackRange(e) + 200 and swung < 1.2 then z.focused = true end
      if off < 0.35 and dd <= attackRange(e) + 200 and swung < 0.45 then
        z.attackers = z.attackers + 1
        z.spots[#z.spots + 1] = { p = ep, r = attackRange(e), mkb = Try(NPC.GetItem, e, "item_monkey_king_bar", true) ~= nil }
      end
      if off < 0.25 and dd < 1100 and castingAt(e) then z.incoming = true end
    end
  end
  return z
end

-- Per-target EMA: main and a remote Double may fight different heroes in the same frame.
-- Keep at most16 live samples for2s; jumps faster than900/s reset that target's velocity.
local function velocity(h, now)
  local p = pos(h)
  local id = idx(h)
  if p == nil or not alive(h) then G.track[id] = nil return 0, 0 end
  local count, oldest, oldestAt = 0, nil, math.huge
  for key, sample in pairs(G.track) do
    if now < sample.t or now - sample.t > 2 or not alive(sample.unit) then G.track[key] = nil
    else
      count = count + 1
      if key ~= id and sample.t < oldestAt then oldest, oldestAt = key, sample.t end
    end
  end
  local s = G.track[id]
  if s == nil or s.unit ~= h or now - s.t > 0.5 then
    if s == nil and count >= 16 and oldest then G.track[oldest] = nil end
    G.track[id] = { unit = h, x = p.x, y = p.y, t = now, vx = 0, vy = 0 }
    return 0, 0
  end
  local dt = now - s.t
  if dt > 0.02 then
    local vx, vy = (p.x - s.x) / dt, (p.y - s.y) / dt
    if vx * vx + vy * vy > 900 * 900 then
      s.vx, s.vy = 0, 0
    else
      s.vx = s.vx * 0.65 + vx * 0.35
      s.vy = s.vy * 0.65 + vy * 0.35
    end
    s.x, s.y, s.t = p.x, p.y, now
  end
  return s.vx, s.vy
end
local function predict(h, now, ahead)
  local p = pos(h)
  local vx, vy = velocity(h, now)
  return Vector(p.x + vx * ahead, p.y + vy * ahead, p.z)
end

-- ----------------------------------------------------------------- targets --
-- the seen enemy hero (no illusion) nearest a point within r
local function nearestHero(me, center, r)
  local best, bestD = nil, r
  for _, h in ipairs(Try(Heroes.InRadius, center, r, teamOf(me), Enum.TeamType.TEAM_ENEMY, true, true) or {}) do
    local p = pos(h)
    if p and alive(h) and visible(h) and Try(NPC.IsIllusion, h) ~= true then
      local d = dist(p, center)
      if d < bestD then best, bestD = h, d end
    end
  end
  return best
end

-- an illusion stands for its hero (the same name and team, alive; one in sight first)
local function genuine(h)
  if h == nil or Try(NPC.IsIllusion, h) ~= true then return h end
  local name, team, best = Try(NPC.GetUnitName, h), teamOf(h), nil
  for _, u in ipairs(Try(Heroes.GetAll) or {}) do
    if alive(u) and Try(NPC.IsIllusion, u) ~= true and Try(NPC.GetUnitName, u) == name and teamOf(u) == team then
      if visible(u) then return u end
      best = best or u
    end
  end
  return best
end

-- the hero at the cursor: the nearest one in the radius, illusions included (each mapped to its hero)
local function cursorHero(me)
  local cursor = Try(Input.GetWorldCursorPos)
  if cursor == nil then return nil end
  local best, bestD = nil, num(ui.radius, 600)
  for _, h in ipairs(Try(Heroes.InRadius, cursor, bestD, teamOf(me), Enum.TeamType.TEAM_ENEMY, false, true) or {}) do
    local p = pos(h)
    if p and alive(h) and visible(h) then
      local d = dist(p, cursor)
      if d < bestD then best, bestD = h, d end
    end
  end
  return genuine(best)
end

local function targetMode() return math.tointeger(num(ui.target, 0)) or 0 end

-- the enemy hero in sight with the least HP within r of the hero, illusions skipped
local function weakestHero(me, center, r)
  local best, bestHp = nil, math.huge
  for _, h in ipairs(Try(Heroes.InRadius, center, r, teamOf(me), Enum.TeamType.TEAM_ENEMY, true, true) or {}) do
    local hp = Try(Entity.GetHealth, h)
    if hp and alive(h) and visible(h) and Try(NPC.IsIllusion, h) ~= true and hp < bestHp then best, bestHp = h, hp end
  end
  return best
end

local function pickTarget(me)
  local mode, mp = targetMode(), pos(me)
  if mode == 2 then return mp and nearestHero(me, mp, 1200) or nil end
  if mode == 3 then return mp and weakestHero(me, mp, 1200) or nil end
  local h = cursorHero(me)
  if h == nil and on(ui.near) then h = mp and nearestHero(me, mp, 850) end
  return h or nil
end

-- our Tempest Double (ours: the local player controls it; an allied Arc Warden's is not)
-- Umbrella's own link every tick (a new double is seen at once); the hero scan only every 0.25 s
local function findDouble(me, now)
  if G.double and alive(G.double) and now - G.doubleAt < 0.25 then return G.double end
  local td = Try(NPC.GetAbility, me, "arc_warden_tempest_double")
  local cd = td and Try(function() return CustomEntities.GetTempestDouble(td) end)
  if cd and alive(cd) then
    G.double, G.doubleAt = cd, now
    return cd
  end
  if now - G.doubleAt < 0.25 then return nil end
  G.doubleAt, G.double = now, nil
  local player = Try(Players.GetLocal)
  local pid = player and Try(Player.GetPlayerID, player)
  for _, u in ipairs(Try(Heroes.GetAll) or {}) do
    if idx(u) ~= idx(me) and alive(u) and Try(NPC.GetUnitName, u) == ARC and has(u, DOUBLE_MOD)
      and (pid == nil or Try(NPC.IsControllableByPlayer, u, pid) ~= false) then
      G.double = u
      break
    end
  end
  return G.double
end

-- ------------------------------------------------------------------ orders --
-- Player.PrepareUnitOrders straight to the unit, as the bot's order_queue.h does: issuer PASSED_UNIT_ONLY, no click
-- effect, no OnPrepareUnitOrders call for our own orders. The argument order is the community scripts' (player, order,
-- target, position, ability, issuer, unit, queue, show effects, callback, execute fast, identifier).
local ORDER = { move = 1, attack = 4, castPos = 5, castTarget = 6, castNo = 8, hold = 10 }  -- DOTA_UNIT_ORDER_*
-- Unknown guard capability is not permission to bypass an enabled guard.
local function guardOk(now)
  if not on(ui.guard) then return true end
  local result = Try(function() return Humanizer.IsSafeToCastOrder() end)
  local ok = result == true
  if type(result) ~= "boolean" and not G.guardUnavailable then
    Note("order guard unavailable; automated orders wait (disable the visible guard only if intended)")
    G.guardUnavailable = true
  elseif type(result) == "boolean" then G.guardUnavailable = nil end
  if not ok and G.guardSince == nil then G.guardSince = now
  elseif ok and G.guardSince ~= nil then
    if now - G.guardSince >= 0.02 then Note("umbrella guard held orders %.2f s  t=%.2f", now - G.guardSince, now - G.startAt) end
    G.guardSince = nil
  end
  return ok
end
-- a unit may dispatch only inside the same budget as the other automated bodies
local function orderCall(fn, ...)
  if type(fn) ~= "function" then return false end
  local now = Try(GameRules.GetGameTime) or 0
  if not guardOk(now) then return false end
  if on(ui.guard) then
    if G.orderTick ~= now then
      local budget = Try(function() return Humanizer.OrdersCanBeCastedThisTick() end)
      G.orderTick, G.orderUsed = now, 0
      G.orderBudget = type(budget) == "number" and math.max(0, math.floor(budget)) or 1
    end
    if G.orderUsed >= G.orderBudget then return false end
  end
  local ok, result = pcall(fn, ...)
  if ok and result ~= false then
    if on(ui.guard) then G.orderUsed = G.orderUsed + 1 end
    return true  -- documented nil means the API call completed, not that its effect happened
  end
  if not ok and now - (G.dispatchErrorAt or -100) >= 2 then
    G.dispatchErrorAt = now
    Note("order API call failed: %s", tostring(result))
  end
  return false
end

local function direct(u, kind, target, p, ab)
  if not on(ui.direct) or type(Player) ~= "table" or type(Player.PrepareUnitOrders) ~= "function" then return false end
  local player = Try(Players.GetLocal)
  if player == nil then return false end
  local I = Enum.PlayerOrderIssuer
  local issuer = (I and I.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY) or 3
  return orderCall(Player.PrepareUnitOrders, player, kind, target, p or Vector(0, 0, 0), ab, issuer, u,
                   false, false, false, on(ui.fast), "arc_rage")
end

local function attackOrder(player, u, h)
  return direct(u, ORDER.attack, h, pos(h), nil)
    or orderCall(Player.AttackTarget, player, u, h, false, false, on(ui.fast), "arc_rage")
end

local function dispatchCast(u, ab, h, where, aimed, point)
  -- Recheck at dispatch too: a shield can appear after the combo planned its next cast.
  if aimed and h ~= nil and teamOf(h) ~= teamOf(u) and counterspell(h) then return false end
  if aimed then
    return direct(u, ORDER.castTarget, h, nil, ab)
      or orderCall(Ability.CastTarget, ab, h, false, false, on(ui.fast), "arc_rage")
  elseif point then
    return direct(u, ORDER.castPos, nil, where, ab)
      or orderCall(Ability.CastPosition, ab, where, false, false, on(ui.fast), "arc_rage")
  end
  return direct(u, ORDER.castNo, nil, nil, ab)
    or orderCall(Ability.CastNoTarget, ab, false, false, on(ui.fast), "arc_rage")
end

local function castMode(ab, h)
  local B = Enum.AbilityBehavior
  local b = math.tointeger(Try(Ability.GetBehavior, ab) or 0) or 0
  local aimed = h ~= nil and (b & B.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0
  local point = not aimed and (b & B.DOTA_ABILITY_BEHAVIOR_POINT) ~= 0
  return aimed, point, (b & IMMEDIATE) ~= 0
end

local function send(u, s, ab, label, h, p, now)
  local cd0, ch0 = Try(Ability.GetCooldown, ab) or 0, Try(Item.GetCurrentCharges, ab)
  local ach0 = Try(Ability.GetCurrentCharges, ab)
  local aimed, point, immediate = castMode(ab, h)
  local where = point and (p or pos(h or u)) or nil
  if not dispatchCast(u, ab, h, where, aimed, point) then return false end
  local key = Try(Ability.GetName, ab) or label
  -- its deadline includes the current walk speed and turn (aw_combo.h castT / castPos)
  local up, at = pos(u), (h and pos(h)) or p
  local walk, turn, reach = 0, 0, true
  if up and at then
    local range = (Try(Ability.GetCastRange, ab) or 0) + castBonus(u)
    if range > 0 then
      walk = math.max(0, dist(up, at) - range) / math.max(100, Try(NPC.GetMoveSpeed, u) or 300)
      reach = dist(up, at) <= range - ((aimed and h ~= u) and 80 or 0)  -- a target may step out while the order flies
    end
    turn = Try(NPC.GetTimeToFacePosition, u, at) or 0
  end
  local cp = math.max(0, Try(Ability.GetCastPoint, ab) or 0)
  s.pending = { ab = ab, actor = u, target = h, where = where,
                orderType = aimed and ORDER.castTarget or point and ORDER.castPos or ORDER.castNo,
                key = key, sentAt = now, cp = cp + walk + turn, cd0 = cd0,
                ch0 = ch0, ach0 = ach0,
                aimed = aimed, echo = not has(u, DOUBLE_MOD), turn = turn }
  -- a Blink, Harpoon or Manta moves or hides the unit: the next step needs where it is now, so it waits for the game
  -- a TP too: an order before its channel shows would cut it (the farm's TP)
  local moves = key:find("blink", 1, true) ~= nil or key == "item_harpoon" or key == "item_manta"
    or key == "item_tpscroll" or key:find("travel_boots", 1, true) ~= nil
  -- a hold or a silence is the fight: the next order waits for the game to show it went (a ping), never cuts it
  local sure = key == "item_sheepstick" or key == "item_rod_of_atos" or key == "item_gungir"
    or key == "item_abyssal_blade" or key == "item_bloodthorn" or key == "item_orchid"
  if on(ui.rage) then
    if immediate then
      s.pending.freeAt = now
    elseif reach and walk == 0 and not moves and not sure then
      s.pending.freeAt = now + (turn > 0.02 and turn + 0.03 or 0) + cp + (cp > 0 and SLACK_CAST or SLACK_ZERO)
    end
  end
  s.inflight[#s.inflight + 1] = s.pending
  s.nextOrder = on(ui.rage) and now or now + 0.05
  s.lastCastAt = now
  s.castAt[key] = now
  D.ownAt = now
  local free = s.pending.freeAt
  Note("%s -> %s  t=%.2f%s", has(u, DOUBLE_MOD) and "double" or "hero", label, now - G.startAt,
       free and string.format("  next +%.2f", free - now) or "  waits for the game")
  return true
end

-- the cast in flight: done once the game shows it (cast point running, then the cooldown); refused after its time
-- a Magnetic Field that never went off is no field: off the list, its pair half open again
local function forgetField(p)
  local f = p.field
  if f == nil then return end
  for i = #G.fields, 1, -1 do
    if G.fields[i] == f then table.remove(G.fields, i) end
  end
  if G.lastFieldAt == p.sentAt then G.lastFieldAt = -100 end
  if p.half and G.pair == p.pair then
    if p.half == "hero" then G.pair.heroDone = false else G.pair.doubleDone = false end
  end
end

-- Completion needs a cooldown/charge change. A vanished phase alone does not prove cancellation;
-- timeout follows the observed round trip and matching queue, with a bounded queue wait.
local function castReplyWindow(p, now)
  local delay = LATENCY
  if type(NetChannel) == "table" and Enum.Flow then
    local outgoing = Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_OUTGOING)
    local incoming = Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_INCOMING)
    if type(outgoing) == "number" and outgoing >= 0 then delay = math.max(delay, outgoing + (type(incoming) == "number" and math.max(0, incoming) or outgoing)) end
  end
  for i = 1, 8 do
    local sample = ECHO[i]
    if sample and now >= sample.at and now - sample.at < 10 then delay = math.max(delay, sample.v) end
  end
  local queue = Try(function() return Humanizer.GetOrderQueue() end)
  if type(queue) == "table" and p.actor then
    local waiting = false
    for _, q in ipairs(queue) do
      local targetFits = not p.aimed or q.targetIndex == idx(p.target)
      local pointFits = p.where == nil or (q.position and type(q.position.x) == "number"
        and type(q.position.y) == "number" and dist(q.position, p.where) <= 16)
      if q.unit == p.actor and q.abilityIndex == idx(p.ab) and q.orderType == p.orderType and targetFits and pointFits then
        waiting = true break
      end
    end
    if waiting then
      p.queueSeen = true
      -- Bounded observation of our exact queued order; an old host queue row must not own the actor forever.
      if now - p.sentAt <= math.max(3, delay * 4) + p.cp then return nil end
      p.queueExpired = true
    end
    if p.queueSeen and not waiting and p.queueGoneAt == nil then p.queueGoneAt = now end
  end
  return (p.queueGoneAt or p.sentAt) + delay + p.cp + 0.35
end
local function open(s, p, now)
  local function confirmed()
    if not p.confirmed then
      p.confirmed, p.confirmedAt = true, now
      if p.field then
        p.field.confirmed = true
        p.field.at = math.max(p.field.at, p.sentAt + p.cp)
      end
      if p.onConfirm then p.onConfirm(now) end
    end
    s.refused[p.key] = 0
    return false
  end
  p.inPhase = Try(Ability.IsInAbilityPhase, p.ab) == true
  if p.inPhase then
    if p.echo and not p.phaseSeen and now - p.sentAt <= 1 then
      -- the order's trip and the game's answer, without the turn it took (a save adds its own turn: INT-05)
      ECHO.n = ECHO.n + 1
      ECHO[(ECHO.n - 1) % 8 + 1] = { v = math.max(0, now - p.sentAt - (p.turn or 0)), at = now }
    end
    p.phaseSeen, p.gone = true, 0
    return true
  end
  local cd = Try(Ability.GetCooldown, p.ab) or 0
  -- an item with charges left shows no cooldown: a charge gone is the cast done (a tester, 2026-11-01: the second
  -- Midas charge never went, the first one read as refused and Midas waited 8 s)
  local ch = p.ch0 and Try(Item.GetCurrentCharges, p.ab)
  local ach = p.ach0 and Try(Ability.GetCurrentCharges, p.ab)
  if type(ach) == "number" and type(p.ach0) == "number" and ach < p.ach0 then return confirmed() end
  if type(ch) == "number" and type(p.ch0) == "number" and ch < p.ch0 then
    return confirmed()
  end
  if cd > p.cd0 + 0.01 or (cd > 0 and p.cd0 <= 0) then
    return confirmed()
  end
  if p.phaseSeen and p.goneAt ~= now then p.gone, p.goneAt = (p.gone or 0) + 1, now end  -- one read a tick
  local deadline = castReplyWindow(p, now)
  -- A vanished phase without a CD/charge update is still unconfirmed, not proof of cancellation.
  if deadline ~= nil and now > deadline then
    if p.phaseSeen then
      s.backoff[p.key] = now + 0.15
      Note("cut %s  t=%.2f", p.key, now - G.startAt)
    else
      local n = (s.refused[p.key] or 0) + 1
      s.refused[p.key] = n
      s.backoff[p.key] = now + (p.key == "item_hand_of_midas" and 8 or n == 1 and 0.6 or n == 2 and 2 or 4)
      Note("%s %s (%d)  t=%.2f", p.queueExpired and "queued without cast ACK" or "refused", p.key, n, now - G.startAt)
    end
    forgetField(p)
    if p.onRefuse then p.onRefuse(now) end
    return false
  end
  return true
end

-- the unit waits while a cast of its own is unanswered; with max rage only until that cast's own end (freeAt)
local function pendingBusy(s, now)
  local busy = false
  for i = #s.inflight, 1, -1 do
    local p = s.inflight[i]
    if not open(s, p, now) then
      table.remove(s.inflight, i)
      if s.pending == p then s.pending = nil end
    elseif p.inPhase or p.freeAt == nil or now < p.freeAt then
      busy = true
    end
  end
  return busy
end

local function inFlight(s, key)
  for _, p in ipairs(s.inflight) do
    if p.key == key then return true end
  end
  return false
end

local function usable(u, s, ab, now)
  local key = ab and Try(Ability.GetName, ab) or ""
  return ab ~= nil and castable(u, ab) and now >= (s.backoff[key] or 0) and not inFlight(s, key)
end
local function useItem(u, s, name, now, every)
  if name == "item_manta" and not on(has(u, DOUBLE_MOD) and ui.mantaD or ui.mantaH) then return nil end
  local it = item(u, name)
  if it and usable(u, s, it, now) and now - (s.castAt[name] or -100) > (every or 0.8) then return it end
  return nil
end

local function fluxReach(u, flux)
  local lvl = Try(Ability.GetLevel, flux) or 1
  local r = lvl <= 1 and 625 or lvl == 2 and 700 or lvl == 3 and 775 or 850
  local talent = Try(NPC.GetAbility, u, "special_bonus_unique_arc_warden_5")
  if talent and (Try(Ability.GetLevel, talent) or 0) > 0 then r = r + 200 end
  return math.max(r, Try(Ability.GetCastRange, flux) or 0) + castBonus(u) + 50
end

-- where the target will be when the spark arms; the aim clamped to the cast range (aw_combo.h sparkAim)
local function sparkAim(u, h, now)
  local p = pos(h)
  local spark = Try(NPC.GetAbility, u, "arc_warden_spark_wraith")
  local range = tonumber(Try(Ability.GetCastRange, spark)) or 0
  range = (range > 0 and range or SPARK_RANGE) + castBonus(u)
  local activation = tonumber(Try(Ability.GetLevelSpecialValueFor, spark, "activation_delay")) or 0
  if activation <= 0 or activation > 5 then activation = SPARK_ARM end
  local cp = tonumber(Try(Ability.GetCastPoint, spark)) or 0.3
  local turn = Try(NPC.GetTimeToFacePosition, u, p) or 0
  local delay = LATENCY
  if NetChannel and Enum.Flow then
    local out = Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_OUTGOING)
    local incoming = Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_INCOMING)
    if type(out) == "number" and type(incoming) == "number" then delay = math.max(delay, out + incoming) end
  end
  for i = 1, 8 do
    local sample = ECHO[i]
    if sample and now >= sample.at and now - sample.at < 10 then delay = math.max(delay, sample.v) end
  end
  local arm = math.min(delay, 1) + turn + cp + activation
  local held = heldLeft(h)
  if held >= arm then return p, p, range end
  local vx, vy = velocity(h, now)
  local speed = math.sqrt(vx * vx + vy * vy)
  local running = Try(NPC.IsRunning, h)
  if running == false or (speed < 20 and running ~= true) then return p, p, range end
  local moveSpeed = tonumber(Try(NPC.GetMoveSpeed, h)) or speed
  if speed < 20 then
    -- A fresh target has no displacement sample yet; use its facing only while it is running.
    local front = Try(Entity.GetForwardPosition, h, 1)
    if not front or dist(front, p) < 0.001 then return p, p, range end
    vx, vy = front.x - p.x, front.y - p.y
    speed = math.sqrt(vx * vx + vy * vy)
  end
  local actual = math.min(550, moveSpeed > 0 and moveSpeed or speed)
  vx, vy = vx * actual / speed, vy * actual / speed
  local ahead = math.min(3.5, math.max(0, arm - held)) * math.max(0, math.min(150, num(ui.sparkLead, 100))) / 100
  local pred = Vector(p.x + vx * ahead, p.y + vy * ahead, p.z)
  local up, aim = pos(u), pred
  if dist(up, aim) > range - 10 then aim = toward(up, aim, math.max(0, range - 10)) end
  return aim, pred, range
end

-- standing in a field of ours: its modifier, or one cast here moments ago (the aura shows ~0.5 s late)
local function fieldOn(u)
  return has(u, "modifier_arc_warden_magnetic_field_evasion") or has(u, "modifier_arc_warden_magnetic_field_attack_speed")
end
local function inField(u, up, now)
  if fieldOn(u) then return true end
  for _, f in ipairs(G.fields) do
    if f.confirmed and now >= f.at and now - f.at < f.lasts and dist(up, f.pos) < FIELD_RADIUS - 50 then return true end
  end
  return false
end
-- a field lasts by its rank (game files: the "duration" special value), from the cast point on; 3.5 when unreadable
local function addField(p, now, mf)
  local lasts = mf and tonumber(Try(Ability.GetLevelSpecialValueFor, mf, "duration")) or 0
  local f = { pos = p, at = now + 0.3, lasts = lasts > 0 and lasts or FIELD_LASTS }
  G.fields[#G.fields + 1] = f
  if #G.fields > 4 then table.remove(G.fields, 1) end
  return f
end

-- combo_target.cpp midasCreep: an enemy lane creep in sight within 570, the most max HP, then HP; not one Midas'd
-- by either unit in the last second
local function midasCreep(u, now)
  local best, bestHp, bestCur = nil, 0, 0
  for _, c in ipairs(Try(NPCs.InRadius, pos(u), 570, teamOf(u), Enum.TeamType.TEAM_ENEMY, true, true) or {}) do
    if Try(NPC.IsLaneCreep, c) == true and alive(c) and visible(c) and now - (G.midasAt[idx(c)] or -100) > 1 then
      local mh, cur = Try(Entity.GetMaxHealth, c) or 0, Try(Entity.GetHealth, c) or 0
      if mh > bestHp or (mh == bestHp and cur > bestCur) then best, bestHp, bestCur = c, mh, cur end
    end
  end
  return best
end
local function midas(u, s, now)
  local m = useItem(u, s, "item_hand_of_midas", now)
  local c = m and midasCreep(u, now)
  if c == nil then return false end
  if not send(u, s, m, "item_hand_of_midas", c, nil, now) then return false end
  G.midasAt[idx(c)] = now
  return true
end

-- attack: once, again after each cast, again when idle; never re-sent while swinging
local function attack(u, s, h, now, d, ar)
  if hasState(h, MS().MODIFIER_STATE_ATTACK_IMMUNE) or hasState(u, MS().MODIFIER_STATE_DISARMED) then return end
  local actual = Try(NPC.GetAttackTarget, u)
  local same = actual == h or (actual == nil and s.attackTarget == h)
  local up = pos(u)
  if same and Try(NPC.IsAttacking, u) == true then
    s.lastAttackAt, s.attackTarget, s.attackCastAt = now, h, s.lastCastAt
    s.attackSentAt = s.attackSentAt or now
    s.attackPos, s.attackProgressAt = up, now
    return
  end
  local first = s.attackSentAt == nil or s.attackTarget ~= h
  local elapsed = now - (s.attackSentAt or -100)
  local grace = 0.4
  if NetChannel and Enum.Flow then
    local out = Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_OUTGOING)
    local incoming = Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_INCOMING)
    if type(out) == "number" and out >= 0 then
      grace = math.min(1.5, math.max(grace, out + (type(incoming) == "number" and math.max(0, incoming) or out) + 0.15))
    end
  end
  local resume = (s.lastCastAt or -100) > (s.attackCastAt or -100)
  if not first and not resume then
    if elapsed < grace then return end
    if same and Try(NPC.IsRunning, u) == true then
      if up and (s.attackPos == nil or dist(up, s.attackPos) >= 12) then s.attackPos, s.attackProgressAt = up, now end
      if now - (s.attackProgressAt or now) < 0.8 then return end
    end
    local cycle = math.max(0.1, Try(NPC.GetSecondsPerAttack, u, false) or 1)
    if (actual == nil or actual == h) and now - (s.lastAttackAt or -100) < cycle + 0.15 then return end
  end
  if not first then
    local queue = Try(function() return Humanizer.GetOrderQueue() end)
    for _, q in ipairs(type(queue) == "table" and queue or {}) do
      if q.unit == u and q.orderType == ORDER.attack and q.targetIndex == idx(h)
        and elapsed <= math.max(3, grace * 4) then return end
    end
  end
  local player = Try(Players.GetLocal)
  if player == nil or not attackOrder(player, u, h) then return end
  s.attackSentAt, s.attackTarget, s.attackCastAt = now, h, s.lastCastAt
  s.attackPos, s.attackProgressAt = up, now
  s.nextOrder = on(ui.rage) and now or now + 0.05
  D.ownAt = now
end

-- combo_kite.cpp comboTurnPairPoint (Kir: «стоял в куполе, а не бежал за героем»): the hero in the overlap of two
-- fields of ours, the target out of his reach -> the nearest point of the overlap he hits it from (aw_field_pair.h
-- attackPoint: eleven candidates), none -> hold position; he still hits whoever comes into reach
local function lensPair(up, now)
  local a, b
  for _, f in ipairs(G.fields) do
    if f.confirmed and now >= f.at and now - f.at < f.lasts and dist(up, f.pos) <= FIELD_RADIUS then
      if a == nil then a = f.pos elseif dist(a, f.pos) > 60 then b = f.pos end
    end
  end
  return a, b
end
local function lensPoint(up, tp, reach, c1, c2)
  local pts = { up, tp }
  local cs, rs = { c1, c2, tp }, { FIELD_RADIUS, FIELD_RADIUS, reach }
  for i = 1, 3 do
    local d = dist(up, cs[i])
    if d > 0 then pts[#pts + 1] = Vector(cs[i].x + (up.x - cs[i].x) * rs[i] / d, cs[i].y + (up.y - cs[i].y) * rs[i] / d, up.z) end
  end
  for i = 1, 2 do
    for j = i + 1, 3 do
      local d = dist(cs[i], cs[j])
      if d > 0 and d <= rs[i] + rs[j] and d >= math.abs(rs[i] - rs[j]) then
        local x = (rs[i] ^ 2 - rs[j] ^ 2 + d * d) / (2 * d)
        local y = math.sqrt(math.max(0, rs[i] ^ 2 - x * x))
        local dx, dy = (cs[j].x - cs[i].x) / d, (cs[j].y - cs[i].y) / d
        for _, sg in ipairs({ -1, 1 }) do
          pts[#pts + 1] = Vector(cs[i].x + x * dx - sg * y * dy, cs[i].y + x * dy + sg * y * dx, up.z)
        end
      end
    end
  end
  local best, bestD
  for _, q in ipairs(pts) do
    if dist(q, c1) <= FIELD_RADIUS and dist(q, c2) <= FIELD_RADIUS and dist(q, tp) <= reach
      and (bestD == nil or dist(up, q) < bestD) then best, bestD = q, dist(up, q) end
  end
  return best
end
local function lensStay(u, s, h, now, up, tp, d, reach)
  if not on(ui.lens) or d <= reach or hasState(u, MS().MODIFIER_STATE_ROOTED) then return false end
  local c1, c2 = lensPair(up, now)
  if c2 == nil or dist(up, c1) > FIELD_RADIUS or dist(up, c2) > FIELD_RADIUS then return false end
  local goal = lensPoint(up, tp, reach, c1, c2)
  local kind = goal and ORDER.move or ORDER.hold
  goal = goal or up
  if s.lensKind == kind and now - (s.lensAt or -100) <= 0.5 and dist(goal, s.lensGoal) <= 60 then return true end
  local player = Try(Players.GetLocal)
  if player == nil then return false end
  local sent = direct(u, kind, nil, goal, nil)
  if not sent then
    if kind == ORDER.hold then sent = orderCall(Player.HoldPosition, player, u, false, false, false, "arc_rage")
    else sent = orderCall(NPC.MoveTo, u, goal, false, false) end
  end
  if not sent then return false end
  s.lensKind, s.lensAt, s.lensGoal = kind, now, goal
  s.attackSentAt = nil  -- the next step in reach sends the attack again
  s.nextOrder = on(ui.rage) and now or now + 0.05
  D.ownAt = now
  Note("%s %s  t=%.2f", kind == ORDER.hold and "hold" or "move", "stays in the field lens", now - G.startAt)
  return true
end

local function canAct(u)
  return not hasState(u, MS().MODIFIER_STATE_STUNNED) and not hasState(u, MS().MODIFIER_STATE_HEXED)
    and not hasState(u, MS().MODIFIER_STATE_NIGHTMARED) and not hasState(u, MS().MODIFIER_STATE_OUT_OF_GAME)
    and not hasState(u, MS().MODIFIER_STATE_COMMAND_RESTRICTED) and Try(NPC.IsChannellingAbility, u) ~= true
    and not has(u, "modifier_teleporting")
end

local function targetable(h)
  return alive(h) and not hasState(h, MS().MODIFIER_STATE_INVULNERABLE) and not hasState(h, MS().MODIFIER_STATE_OUT_OF_GAME)
end

-- a unit may get its next order: its cast in flight is done (max rage: by our clock), Umbrella's spam check
local function ready(u, s, now)
  return now >= s.nextOrder and not pendingBusy(s, now) and canAct(u) and guardOk(now)
end

-- ------------------------------------------------------------ tempest point --
-- aw_combo.h smartTempestPoint: the old point (200 towards the target, short of attack range) or one of: 675 towards
-- the target, 8 around it at gap = 0.75 x attack range (200..450), behind it and to its sides. Fewest enemy towers,
-- then enemy heroes (the target's team, illusions too) with the point in their attack range, then the closest to
-- the gap, the farthest from us, the most behind it, the first.
-- The old point is ON the hero when the target stands in attack range (the friend, 2026-10-31: «теперь во мне»):
-- it wins only when every point away from us stands under more enemy towers. Returns the point and why, for the log.
local function tempestPoint(u, h, d, ar)
  local c, t = pos(u), pos(h)
  local k = d > 1 and math.min(200, math.max(0, d - ar)) / d or 0
  local legacy = Vector(c.x + (t.x - c.x) * k, c.y + (t.y - c.y) * k, c.z)
  if on(ui.tdAtTarget) and d > 0 then
    -- the slider short of the target on our side (100 by default), within the cast range (700 + bonuses)
    local td = Try(NPC.GetAbility, u, "arc_warden_tempest_double")
    local range = math.max(700, (td and Try(Ability.GetCastRange, td)) or 0) + castBonus(u) - 10
    local go = math.min(range, math.max(0, d - num(ui.tdGap, 100)))
    return Vector(c.x + (t.x - c.x) * go / d, c.y + (t.y - c.y) * go / d, c.z),
           string.format("at the target, %d from it", math.floor(d - go))
  end
  if not on(ui.tdAway) then return legacy, "old point, switch off" end
  if not visible(h) or ar <= 0 or d <= 0 then return legacy, "old point, target unseen" end
  local R, gap = 675, math.max(200, math.min(450, 0.75 * ar))
  local fx, fy
  local f = Try(Entity.GetForwardPosition, h, 100)
  if f then
    local l = dist(f, t)
    if l > 1 then fx, fy = (f.x - t.x) / l, (f.y - t.y) / l end
  end
  local dx, dy = (t.x - c.x) / d, (t.y - c.y) / d
  local cands = { { p = legacy, legacy = true, name = "old point" },
                  { p = Vector(c.x + R * dx, c.y + R * dy, c.z), name = "675 toward" } }
  for i = 0, 7 do
    local a = i * math.pi / 4
    local ca, sa = math.cos(a), math.sin(a)
    cands[#cands + 1] = { p = Vector(t.x + gap * (dx * ca - dy * sa), t.y + gap * (dy * ca + dx * sa), c.z),
                          name = "ring " .. (i * 45) }
  end
  if fx then
    cands[#cands + 1] = { p = Vector(t.x - gap * fx, t.y - gap * fy, c.z), name = "behind it" }
    cands[#cands + 1] = { p = Vector(t.x - gap * fy, t.y + gap * fx, c.z), name = "its left" }
    cands[#cands + 1] = { p = Vector(t.x + gap * fy, t.y - gap * fx, c.z), name = "its right" }
  end
  local team, threats = teamOf(h), {}
  for _, e in ipairs(Try(Heroes.GetAll) or {}) do
    local ep = pos(e)
    if ep and idx(e) ~= idx(h) and alive(e) and visible(e) and teamOf(e) == team then
      threats[#threats + 1] = { p = ep, r = attackRange(e), tower = false }
    end
  end
  for _, tw in ipairs(Try(function() return Towers.GetAll() end) or {}) do
    local tp = pos(tw)
    if tp and alive(tw) and teamOf(tw) == team then
      threats[#threats + 1] = { p = tp, r = Try(NPC.GetAttackRange, tw) or 700, tower = true }
    end
  end
  local function less(a, b)
    for _, key in ipairs({ "towers", "enemies", "error", "spread", "facing", "index" }) do
      if a[key] ~= b[key] then return a[key] < b[key] end
    end
    return false
  end
  local best, old
  for i, cd in ipairs(cands) do
    local spread, reach = dist(c, cd.p), dist(t, cd.p)
    if cd.legacy or (spread >= 200 and spread <= R) then
      cd.towers, cd.enemies, cd.index = 0, 0, i
      for _, th in ipairs(threats) do
        if dist(cd.p, th.p) <= th.r then
          if th.tower then cd.towers = cd.towers + 1 else cd.enemies = cd.enemies + 1 end
        end
      end
      cd.error, cd.spread = math.abs(reach - gap), -spread
      cd.facing = (fx and reach > 0) and ((cd.p.x - t.x) * fx + (cd.p.y - t.y) * fy) / reach or 0
      if cd.legacy then old = cd elseif best == nil or less(cd, best) then best = cd end
    end
  end
  local pick = best
  if best == nil or (less(old, best) and (dist(c, old.p) >= 200 or old.towers < best.towers)) then pick = old end
  return pick.p, string.format("%s, %d from us, %d from it, %d enemies / %d towers reach it",
    pick.name, math.floor(dist(c, pick.p)), math.floor(dist(t, pick.p)), pick.enemies, pick.towers)
end

-- --------------------------------------------------------------- field pair --
local function fieldReady(u, s, now)
  local mf = Try(NPC.GetAbility, u, FIELD)
  if mf and not hasState(u, MS().MODIFIER_STATE_SILENCED) and usable(u, s, mf, now) then return mf end
  return nil
end

-- aw_field_pair.h (lab 2026-11-01: an attacker outside a field misses the hero inside it, also in each of two
-- overlapping fields; from inside it hits): where an attacker swings from, a melee one at its reach
local LENS_GAP = 200  -- centres this far either side of the hero: a lens 200 wide around it
local function swingSpot(hp, a)
  local d, r = dist(hp, a.p), math.max(a.r, 100) + 30
  if d > r and d > 1 then return Vector(hp.x + (a.p.x - hp.x) / d * r, hp.y + (a.p.y - hp.y) / d * r, a.p.z) end
  return a.p
end
local function inCircle(p, c) return c ~= nil and dist(p, c) <= FIELD_RADIUS + 40 end
-- one field off the hero's centre away from the attackers (the hero 60 inside its edge); with `other` (a field of ours
-- over the hero already) the lens with it: only an attacker inside both hits. Returns the centre and attackers it misses
local function singleField(hp, spots, other)
  local best, bestHits, bestD = hp, math.huge, 0
  for _, d in ipairs({ 0, 80, 160, 200, 240 }) do
    for k = 0, (d > 0 and 23 or 0) do
      local a = k * math.pi / 12
      local c = Vector(hp.x + math.cos(a) * d, hp.y + math.sin(a) * d, hp.z)
      if other == nil or dist(c, other) >= 120 then
        local hits = 0
        for _, sp in ipairs(spots) do
          local at = swingSpot(hp, sp)
          if inCircle(at, c) and (other == nil or inCircle(at, other)) then hits = hits + 1 end
        end
        if hits < bestHits or (hits == bestHits and d < bestD) then best, bestHits, bestD = c, hits, d end
      end
    end
  end
  return best, (#spots == 0) and 0 or bestHits
end
-- the lens axis turned so the fewest attackers stand in both fields: a point that way from the hero, and how many do
local function lensToward(hp, spots, toward)
  local want = atan2(toward.y - hp.y, toward.x - hp.x)
  local best, bestScore, bestHits = want, math.huge, 0
  for k = 0, 23 do
    local a = want + k * math.pi / 24
    local ux, uy = math.cos(a), math.sin(a)
    local c1 = Vector(hp.x + ux * LENS_GAP, hp.y + uy * LENS_GAP, hp.z)
    local c2 = Vector(hp.x - ux * LENS_GAP, hp.y - uy * LENS_GAP, hp.z)
    local hits = 0
    for _, sp in ipairs(spots) do
      local at = swingSpot(hp, sp)
      if inCircle(at, c1) and inCircle(at, c2) then hits = hits + 1 end
    end
    local off = math.abs((a - want + math.pi / 2) % math.pi - math.pi / 2)
    if hits * 10 + off < bestScore then best, bestScore, bestHits = a, hits * 10 + off, hits end
  end
  return Vector(hp.x + math.cos(best) * 100, hp.y + math.sin(best) * 100, hp.z), bestHits
end

-- aw_field.cpp awPairCurrent: the hero hit -> both fields at once, LENS_GAP either side of the hero towards `dir`; the
-- double takes the centre nearer it, each within 875 of its unit; 0.45 s after your last order to the hero
local function preparePair(me, dbl, dir, now)
  if G.pair or dbl == nil or dir == nil or now - D.playerAt < 0.45 then return end
  local hp, dp = pos(me), pos(dbl)
  if hp == nil or dp == nil then return end
  local hs, ds = unitState(me), unitState(dbl)
  if fieldOn(me)
    or pendingBusy(hs, now) or pendingBusy(ds, now) or not canAct(me) or not canAct(dbl)
    or not fieldReady(me, hs, now) or not fieldReady(dbl, ds, now) then
    return
  end
  local l = dist(hp, dir)
  if l <= 0 then return end
  local ox, oy = LENS_GAP * (dir.x - hp.x) / l, LENS_GAP * (dir.y - hp.y) / l
  local a, b = Vector(hp.x + ox, hp.y + oy, hp.z), Vector(hp.x - ox, hp.y - oy, hp.z)
  if dist(dp, b) < dist(dp, a) then a, b = b, a end
  if dist(dp, a) > 875 or dist(hp, b) > 875 then return end
  G.pair = { hero = b, double = a, at = now, heroDone = false, doubleDone = false }
  Note("field pair  t=%.2f", now - G.startAt)
end

-- the pair ends when both are down, after 8 s, when nobody cast in 0.5 s, or once the hero left either circle
local function pairCheck(me, dbl, now)
  local p = G.pair
  if p == nil then return end
  local hp = pos(me)
  if dbl == nil or hp == nil or (p.heroDone and p.doubleDone) or now - p.at > 8
    or (not p.heroDone and not p.doubleDone and now - p.at > 0.5)
    or dist(hp, p.hero) > FIELD_RADIUS or dist(hp, p.double) > FIELD_RADIUS then
    G.pair = nil
  end
end

local function pairHalf(isHero)
  local p = G.pair
  if p == nil then return nil end
  if isHero then return (not p.heroDone) and p.hero or nil end
  return (not p.doubleDone) and p.double or nil
end

local function castHalf(u, s, isHero, now)
  local c = pairHalf(isHero)
  local mf = c and fieldReady(u, s, now)
  if not mf then return false end
  if not send(u, s, mf, "magnetic field (pair)", nil, c, now) then return false end
  if isHero then G.pair.heroDone = true else G.pair.doubleDone = true end
  G.lastFieldAt = now
  local f = addField(c, now, mf)
  s.pending.field, s.pending.half, s.pending.pair = f, isHero and "hero" or "double", G.pair
  return true
end

local function castField(u, s, p, label, now)
  local mf = fieldReady(u, s, now)
  if not mf then return false end
  if not send(u, s, mf, label, nil, p, now) then return false end
  G.lastFieldAt = now
  local f = addField(p, now, mf)
  s.pending.field = f
  return true
end

-- -------------------------------------------------------------------- saves --
-- a learned spell that is ready but short of mana by at most `gain`
local function needsMana(u, gain)
  if hasState(u, MS().MODIFIER_STATE_SILENCED) then return false end
  local mana = Try(NPC.GetMana, u) or 0
  for _, n in ipairs({ "arc_warden_flux", FIELD, "arc_warden_spark_wraith", "arc_warden_tempest_double" }) do
    local ab = Try(NPC.GetAbility, u, n)
    local cost = ab and Try(Ability.GetManaCost, ab) or 0
    if ab and (Try(Ability.GetLevel, ab) or 0) > 0 and (Try(Ability.GetCooldown, ab) or 1) <= 0
      and cost > mana and cost - mana <= gain then
      return true
    end
  end
  return false
end

-- items.h planItemsRecovery: Mekansm / Greaves, Arcane Boots, then Stick / Wand / Locket by their charges
local function recovery(u, s, now, loss, z, silenced, rooted)
  local hp, maxHp = Try(Entity.GetHealth, u) or 0, Try(Entity.GetMaxHealth, u) or 1
  local hurtNow = z.focused or z.incoming or loss > 0.06
  for _, n in ipairs({ "item_mekansm", "item_guardian_greaves" }) do
    local it = useItem(u, s, n, now, 3)
    local greaves = n == "item_guardian_greaves"
    if it then
      local hurt = not has(u, "modifier_item_mekansm_noheal")
        and (maxHp - hp >= (greaves and 325 or 250) or (hp < 0.35 * maxHp and hurtNow))
      if hurt or (greaves and (silenced or rooted or needsMana(u, 200))) then return send(u, s, it, n, nil, nil, now) end
    end
  end
  local boots = useItem(u, s, "item_arcane_boots", now, 3)
  if boots and needsMana(u, 150) then return send(u, s, boots, "item_arcane_boots", nil, nil, now) end
  for _, w in ipairs({ { "item_magic_stick", 10, 15 }, { "item_magic_wand", 20, 15 }, { "item_holy_locket", 25, 17 } }) do
    local it = useItem(u, s, w[1], now, 3)
    local ch = it and Try(Item.GetCurrentCharges, it) or 0
    if it and ch > 0 and ch <= w[2] then
      local heal = ch * w[3]
      if (maxHp - hp >= math.max(60, heal * 0.8) and (hurtNow or hp < 0.7 * maxHp)) or (hurtNow and hp < 0.35 * maxHp)
        or needsMana(u, ch * 15) then
        return send(u, s, it, w[1], u, nil, now)
      end
    end
  end
  return false
end

-- items.h planItemsUrgentSave, with combat_policy.h's emergency BKB first
local function saves(u, s, now, loss, z)
  local silenced = hasState(u, MS().MODIFIER_STATE_SILENCED)
  local rooted = hasState(u, MS().MODIFIER_STATE_ROOTED)
  local frac = hpFrac(u)
  local bkbOn = has(u, "modifier_black_king_bar_immune")
  local emergency = (frac <= 0.28 and (z.focused or loss >= 0.12)) or (loss >= 0.12 and frac <= math.min(0.65, 0.28 + loss))
  if emergency and not bkbOn and not has(u, "modifier_life_stealer_rage") then
    local bkb = useItem(u, s, "item_black_king_bar", now)
    if bkb then return send(u, s, bkb, "item_black_king_bar (emergency)", nil, nil, now) end
  end
  if silenced or rooted or z.incoming or loss > 0.2 then
    for _, n in ipairs({ "item_black_king_bar", "item_manta", "item_satanic" }) do
      local it = useItem(u, s, n, now)
      if it and not (n == "item_black_king_bar" and bkbOn) and (n ~= "item_satanic" or frac < 0.5) then
        return send(u, s, it, n .. " (save)", nil, nil, now)
      end
    end
  end
  if silenced or rooted then
    local disp = useItem(u, s, "item_disperser", now)
    if disp then return send(u, s, disp, "item_disperser (cleanse self)", u, nil, now) end
    local blade = useItem(u, s, "item_heavy_blade", now)
    if blade then return send(u, s, blade, "item_heavy_blade (cleanse self)", u, pos(u), now) end
  end
  -- Ghost amplifies magic: only against attacks
  if z.focused and not z.incoming and (loss > 0.06 or frac < 0.65) and not bkbOn and not has(u, "modifier_ghost_state")
    and not has(u, "modifier_item_crellas_crozier_active") then
    for _, n in ipairs({ "item_crellas_crozier", "item_ghost" }) do
      local it = useItem(u, s, n, now)
      if it then return send(u, s, it, n, nil, nil, now) end
    end
    local eb = not has(u, "modifier_item_ethereal_blade_ethereal") and useItem(u, s, "item_ethereal_blade", now)
    if eb then return send(u, s, eb, "item_ethereal_blade (self)", u, nil, now) end
  end
  if (z.incoming or loss > 0.2) and not has(u, "modifier_item_glimmer_cape_fade") then
    local gl = useItem(u, s, "item_glimmer_cape", now)
    if gl then return send(u, s, gl, "item_glimmer_cape (self)", u, nil, now) end
  end
  return recovery(u, s, now, loss, z, silenced, rooted)
end

-- -------------------------------------------------------------------- burst --
-- items.h planItemsBurst: debuffs, amps, nukes, own buffs (each by its rule), then low-HP items
local function burst(u, s, h, now, d, ar, loss, z, f)
  local up, tp = pos(u), pos(h)
  local silenced = hasState(u, MS().MODIFIER_STATE_SILENCED)
  local rooted = hasState(u, MS().MODIFIER_STATE_ROOTED)
  local hp, maxHp = Try(Entity.GetHealth, u) or 0, Try(Entity.GetMaxHealth, u) or 1
  local bonus = castBonus(u)
  if f.aimed then
    for _, it_ in ipairs(DEBUFFS) do
      local it = useItem(u, s, it_[1], now)
      if it and (not f.linken or it_.soul) and d < it_[2] + bonus + 100
        and not (it_.soul and (has(h, "modifier_item_spirit_vessel_damage") or has(h, "modifier_item_urn_damage")
                               or (Try(Item.GetCurrentCharges, it) or 0) <= 0))
        and not (it_[1] == "item_heavens_halberd" and has(h, "modifier_axe_berserkers_call")) then
        return send(u, s, it, it_[1], h, nil, now)
      end
    end
  end
  if f.spellOk then
    for _, it_ in ipairs(AMPS) do
      local it = useItem(u, s, it_[1], now)
      if it and d <= it_[2] then return send(u, s, it, it_[1], nil, tp, now) end
    end
  end
  if f.spellOk and not f.linken then
    for _, it_ in ipairs(NUKES) do
      local targeted = it_[3] == true
      local it = useItem(u, s, it_[1], now, it_[1] == "item_blood_grenade" and 3 or 0.8)
      if it and (not targeted or f.aimed) then
        local range = targeted and math.max(it_[2], Try(Ability.GetCastRange, it) or 0) + bonus + 300 or it_[2]
        if d < range then return send(u, s, it, it_[1], targeted and h or nil, tp, now) end
      end
    end
  end
  local hitting = d < ar + 150
  local danger_ = silenced or rooted or z.incoming or loss > 0.2 or (z.focused and (loss > 0.06 or z.near >= 2))
  local missing = maxHp - hp
  local chase = f.seen and d > f.reach + 25 and d < f.reach + 450
  local chaseFar = not rooted and f.seen and d > f.reach + 25 and d < f.reach + 600
  local rule = {
    bkb = not has(u, "modifier_black_king_bar_immune")
          and (z.incoming or silenced or rooted or loss > 0.2 or (z.focused and z.near >= 2)),
    manta = silenced or rooted or z.incoming or (hitting and (has(u, DOUBLE_MOD) or on(ui.mantaAttackH))),
    blademail = has(h, "modifier_axe_berserkers_call") or z.focused,
    hitting = hitting, danger = danger_, chase = chase, focused = z.focused, dispel = silenced or rooted,
    pipe = z.incoming and not has(u, "modifier_item_pipe_barrier") and not has(u, "modifier_item_pipe_debuff"),
    crimson = z.focused and not has(u, "modifier_item_crimson_guard_extra") and not has(u, "modifier_item_crimson_guard_nostack"),
    polliwog = missing >= 112 and not has(u, "modifier_item_polliwog_charm_buff"),
    seeds = hitting and missing >= 100 and not has(u, "modifier_item_seeds_of_serenity_active"),
    ash = z.focused and (hitting or rooted) and not has(u, "modifier_item_ash_legion_shield"),
    kobold = chaseFar and not has(u, "modifier_item_kobold_cup"),
    spider = chaseFar and not has(u, "modifier_item_spider_legs_active"),
    demonicon = d < ar + 300 and now - (s.castAt["item_demonicon"] or -100) >= 65,
  }
  for _, b in ipairs(BUFFS) do
    if rule[b[2]] then
      local it = useItem(u, s, b[1], now)
      if it then return send(u, s, it, b[1], b.self and u or nil, b.here and up or nil, now) end
    end
  end
  if hp < 0.5 * maxHp and (hitting or danger_) then
    for _, n in ipairs({ "item_satanic", "item_essence_ring", "item_faerie_fire" }) do
      local it = useItem(u, s, n, now)
      if it then return send(u, s, it, n, nil, nil, now) end
    end
  end
  return false
end

-- -------------------------------------------------------------- silver edge --
-- items_silver_edge.h: Silver Edge (or Shadow Blade), then the hit from invisibility, then everything else - any cast
-- ends the invisibility and with it the +300 and the Break (a tester, 2026-11-01: with Silver Edge the combo spawned
-- the double instead of hitting first). Game files: no cast point, fade 0.3 s, 17 s, Break 5 s.
local SNEAK_MODS = { "modifier_item_silver_edge_windwalk", "modifier_item_invisibility_edge_windwalk" }
local function sneakMod(u)
  for _, m in ipairs(SNEAK_MODS) do
    if has(u, m) then return m end
  end
  return nil
end
local function sneak(u, s, h, now, d, ar, reach, loss)
  if not on(ui.sneak) or loss > 0.2 or hasState(h, MS().MODIFIER_STATE_ATTACK_IMMUNE) or not visible(h) then
    return false
  end
  local m = sneakMod(u)
  if m then
    if d > ar + 1000 then return false end
    local mod = Try(NPC.GetModifier, u, m)
    local age = mod and now - (Try(Modifier.GetCreationTime, mod) or now) or 1
    if not hasState(u, MS().MODIFIER_STATE_INVISIBLE) and age < 0.4 and d <= reach + 50 then return true end  -- fading
    if s.sneakHitAt == nil or now - s.sneakHitAt > 1.5 then  -- once; again if a click of yours took the unit
      local player = Try(Players.GetLocal)
      if not player or not attackOrder(player, u, h) then return true end
      s.sneakHitAt = now
      Note("%s -> hit from invisibility  t=%.2f", has(u, DOUBLE_MOD) and "double" or "hero", now - G.startAt)
    end
    return true
  end
  s.sneakHitAt = nil
  -- sent a moment ago, its walk not on us yet: nothing in between either
  for _, n in ipairs({ "item_silver_edge", "item_invis_sword" }) do
    if now - (s.castAt[n] or -100) < 0.5 and Try(Ability.GetCooldown, item(u, n)) ~= nil then return true end
  end
  if d > ar + 1000 or has(h, "modifier_silver_edge_debuff")
    or (hasState(u, MS().MODIFIER_STATE_ROOTED) and d > reach + 50) then return false end
  for _, n in ipairs({ "item_silver_edge", "item_invis_sword" }) do
    local it = useItem(u, s, n, now)
    if it then return send(u, s, it, n, nil, nil, now) end
  end
  return false
end

-- -------------------------------------------------------------------- holds --
-- whether this hold may go on the target as it stands (a point hold: not into BKB; a targeted one: seen, no Lotus,
-- through BKB only if it pierces)
local function holdFits(hs, immune, lotus, seen)
  if hs.point then return not immune end
  return seen and not lotus and (not immune or hs.pierces)
end

local function fightState(h, now)
  G.fights = G.fights or {}
  for id, q in pairs(G.fights) do
    if now < q.at or now - q.at > 15 or not alive(q.target) then G.fights[id] = nil end
  end
  local id = idx(h)
  local q = G.fights[id]
  if q == nil or q.target ~= h then
    q = { target = h, lastHoldAt = -100, lastSilenceAt = -100, linkenPopUntil = -100 }
    G.fights[id] = q
  end
  q.at = now
  return q
end

local function openerPending(h, now, slot)
  local q = fightState(h, now)
  slot = slot or "opener"
  local p = q[slot]
  if p == nil then return false end
  if p.context ~= G or p.target ~= h or not alive(h) or not alive(p.actor)
    or (p.doubleBirth ~= nil and p.doubleBirth ~= D.bornAt) then q[slot] = nil return false end
  pendingBusy(p.state, now)
  if p.cast.confirmed or not inFlight(p.state, p.cast.key) then q[slot] = nil return false end
  return true
end

-- Keep one target reservation through the host queue; the timestamp begins at confirmed execution.
local function fightCast(u, s, h, now, slot, timestamp, settle)
  local q, p = fightState(h, now), s.pending
  local claim = { context = G, target = h, actor = u, state = s, cast = p,
                  doubleBirth = has(u, DOUBLE_MOD) and D.bornAt or nil }
  q[slot] = claim
  p.onConfirm = function(at)
    if claim.context == G and G.fights[idx(h)] == q and q[slot] == claim
      and (claim.doubleBirth == nil or claim.doubleBirth == D.bornAt) then q[timestamp] = at + (settle or 0) end
  end
end

-- the hold chain, both units: the longest hold in reach, landing as the current one ends
local function holdChain(u, s, h, now, d, ar, immune, lotus, seen)
  local q = fightState(h, now)
  if openerPending(h, now) or heldLeft(h) >= 0.3 + LATENCY or now - q.lastHoldAt <= 0.45 then return false end
  local best, bestIt
  for _, hs in ipairs(HOLDS) do
    local it = useItem(u, s, hs.name, now)
    local range = it and Try(Ability.GetCastRange, it)
    if type(range) ~= "number" or range <= 0 then range = hs.range end
    if it and holdFits(hs, immune, lotus, seen) and d <= range + castBonus(u)
      and (best == nil or hs.hold > best.hold) then
      best, bestIt = hs, it
    end
  end
  if best == nil then return false end
  if not send(u, s, bestIt, best.name, not best.point and h or nil, pos(h), now) then return false end
  fightCast(u, s, h, now, "opener", "lastHoldAt")
  return true
end

-- a hold of this unit's is ready and it reaches the target now, or with its Blink first
local function holdComing(x, isHero, h, immune, lotus, seen)
  if x == nil or not alive(x) or not canAct(x) then return false end
  local xp, tp = pos(x), pos(h)
  if xp == nil or tp == nil then return false end
  local d, bonus, state = dist(xp, tp), castBonus(x), unitState(x)
  if pendingBusy(state, Try(GameRules.GetGameTime) or 0) then return false end
  local blink = 0
  if on(isHero and ui.blink or ui.blinkD) and not immune and not hasState(x, MS().MODIFIER_STATE_ROOTED) then
    for _, b in ipairs(BLINKS) do
      if usable(x, state, item(x, b[1]), Try(GameRules.GetGameTime) or 0) then blink = math.max(blink, b[2]) end
    end
  end
  for _, hs in ipairs(HOLDS) do
    local it = item(x, hs.name)
    local range = it and Try(Ability.GetCastRange, it)
    if type(range) ~= "number" or range <= 0 then range = hs.range end
    if usable(x, state, it, Try(GameRules.GetGameTime) or 0) and holdFits(hs, immune, lotus, seen)
      and d <= range + bonus + blink then
      return true
    end
  end
  return false
end

-- The opening (a tester, 2026-11-01: after the Blink the combo pressed Spark and Flux before the Hex, a window for
-- the target's BKB; Umbrella's own combo hexes right after the Blink): the target not held yet and a hold of ours on
-- its way -> nothing else touches it until that hold is sent. At most 1 s, so a refused hold cannot stall the fight.
local function opening(me, dbl, h, now, linken, immune, lotus, seen)
  if openerPending(h, now) then return true end
  local q = fightState(h, now)
  local open = not linken and heldLeft(h) < 0.05 and now - q.lastHoldAt > 0.6
    and ((G.heroIn and holdComing(me, true, h, immune, lotus, seen)) or holdComing(dbl, false, h, immune, lotus, seen))
  if not open then q.openFrom = nil return false end
  q.openFrom = q.openFrom or now
  return now - q.openFrom < 1.0
end

-- --------------------------------------------------------------------- step --
-- aw_combo.h planAwUnit: one unit's next order
local function step(u, s, isHero, partner, h, now, loss, z)
  local up, tp = pos(u), pos(h)
  if up == nil or tp == nil then return end
  local q = fightState(h, now)
  local d = dist(up, tp)
  local ar = attackRange(u)
  local silenced = hasState(u, MS().MODIFIER_STATE_SILENCED)
  local rooted = hasState(u, MS().MODIFIER_STATE_ROOTED)
  local immune = hasState(h, MS().MODIFIER_STATE_MAGIC_IMMUNE)
  local debuff = debuffImmune(h)
  local linken = Try(NPC.IsLinkensProtected, h) == true
  local lotus = counterspell(h) or (on(ui.lotus) and has(h, "modifier_item_lotus_orb_active"))
  local seen = visible(h)
  local spellOk = not immune and seen
  local aimed = spellOk and not lotus and not debuff  -- non-piercing unit-target effects
  local reach = ar + hulls(u, h)  -- where it hits from, centre to centre
  local f = { linken = linken, spellOk = spellOk, aimed = aimed, seen = seen, reach = reach }
  local flux = Try(NPC.GetAbility, u, "arc_warden_flux")
  local turn = Try(NPC.GetTimeToFacePosition, u, tp) or 0

  -- 0. saves: a disable must not wait behind the summon
  if saves(u, s, now, loss, z) then return end
  if sneak(u, s, h, now, d, ar, reach, loss) then return end

  -- the hold opens the fight: in reach, it goes before the summon and the Blink; until it is sent (by either unit)
  -- nothing else of ours touches the target
  if not linken and holdChain(u, s, h, now, d, ar, debuff, lotus, seen) then return end
  local holdFirst = opening(isHero and u or partner, isHero and partner or u, h, now, linken, debuff, lotus, seen)

  -- 1. Tempest Double: the hero summons it once the fight is near (a ready one means the last double is gone)
  if isHero and partner == nil and now >= (D.saveUntil or -100) and on(ui.double) and not silenced and d < TEMPEST_NEAR then
    local td = Try(NPC.GetAbility, u, "arc_warden_tempest_double")
    if usable(u, s, td, now) then
      local p, why = tempestPoint(u, h, d, ar)
      return send(u, s, td, "tempest double (" .. why .. ")", nil, p, now)
    end
  end

  -- 2. Linken's: popped by Flux, never by a disable; one of us does it, the other waits while it flies
  local popping = linken and (openerPending(h, now, "linken") or now <= q.linkenPopUntil)
  if linken and aimed and not silenced and not popping and usable(u, s, flux, now)
    and d <= fluxReach(u, flux) then
    if send(u, s, flux, "flux (Linken)", h, nil, now) then
      fightCast(u, s, h, now, "linken", "linkenPopUntil", 0.25)
      return true
    end
  end

  -- 3. setup: gap close, Linken's by the cheapest item (nothing pops it: no holds or silences), holds, silence
  -- the double chases (a tester, 2026-11-01): out of its reach with the target running from it at 150/s+, its Blink
  -- goes after it from closer than the blink-in distance and into BKB too (a point blink; the double is spent anyway)
  local chase = false
  if not isHero and on(ui.chase) and d > reach + 50 then
    local vx, vy = velocity(h, now)
    chase = vx * (tp.x - up.x) + vy * (tp.y - up.y) > 150 * d
  end
  if d > ar + 150 or chase then
    if ((on(isHero and ui.blink or ui.blinkD) and not immune) or chase) and not rooted then
      local standoff = math.min(450, ar - 100)
      for _, b in ipairs(BLINKS) do
        local it = useItem(u, s, b[1], now)
        if it and d <= b[2] + standoff then
          local p = predict(h, now, LATENCY + turn)
          local go = math.min(b[2] - 10, math.max(0, dist(up, p) - standoff))
          if not chase or go >= 200 then
            return send(u, s, it, b[1] .. (chase and " (chase)" or ""), nil, toward(up, p, go), now)
          end
        end
      end
    end
    local harpoon = useItem(u, s, "item_harpoon", now)
    if harpoon and aimed and not linken and d < 700 then return send(u, s, harpoon, "item_harpoon", h, nil, now) end
  end
  if linken and aimed and not popping then
    for _, n in ipairs(LINKEN_POP) do
      local it = useItem(u, s, n, now)
      local r = it and ((Try(Ability.GetCastRange, it) or 0) + castBonus(u)) or 0
      if it and d < r + ((ar > 250 and r < ar - 100) and 30 or 100) then
        if send(u, s, it, n .. " (Linken)", h, nil, now) then
          fightCast(u, s, h, now, "linken", "linkenPopUntil", 0.35)
          return true
        end
      end
    end
  elseif not linken then
    if holdChain(u, s, h, now, d, ar, debuff, lotus, seen) then return end
    if holdFirst then return end  -- the opening: no silence, Flux, items, Spark or swing before the hold
    -- silence: Bloodthorn, then Orchid, as the last one ends (they go on a hexed target too)
    local rend = math.max(modLeft(h, "modifier_bloodthorn_debuff", now), modLeft(h, "modifier_orchid_malevolence_debuff", now))
    if aimed and not debuff and rend < 0.5 and not openerPending(h, now, "silence") and now - q.lastSilenceAt > 0.45 then
      for _, n in ipairs({ "item_bloodthorn", "item_orchid" }) do
        local it = useItem(u, s, n, now)
        if it and d < 1000 then
          if send(u, s, it, n, h, nil, now) then
            fightCast(u, s, h, now, "silence", "lastSilenceAt")
            return true
          end
        end
      end
    end
  end

  -- 4. Flux from each of us, from where we stand
  if aimed and not linken and not silenced and now - s.lastFluxAt > 0.45 and usable(u, s, flux, now)
    and d <= fluxReach(u, flux) then
    if send(u, s, flux, "flux", h, nil, now) then s.lastFluxAt = now return true end
  end

  -- 5. Magnetic Field: when hit, or in attack range; the hero hit -> both fields at once (the pair)
  local mf = fieldReady(u, s, now)
  local half = pairHalf(isHero)
  if mf and (half or z.focused or loss > 0.08 or (d <= reach + 30 and now - G.lastFieldAt > 0.45)) then
    if half == nil and G.pair == nil and partner
      and (G.heroFocused or G.heroLoss > 0.08 or (isHero and G.heroAttackers > 0)) then
      -- the lens axis turned so the fewest of those swinging at the hero stand in both fields (Codex FP-01)
      local hero = isHero and u or partner
      local hp, hs = pos(hero), G.heroSpots or {}
      preparePair(hero, isHero and partner or u, (hp and #hs > 0) and (lensToward(hp, hs, tp)) or tp, now)
      half = pairHalf(isHero)
    end
    if half then return castHalf(u, s, isHero, now) end
    if not inField(u, up, now) then
      -- hit: off its centre away from those swinging at it (singleField, as the auto field does), none when every one
      -- carries an MKB; not hit: a step towards the target for the attack speed
      local sp = z.spots or {}
      if (z.focused or loss > 0.08) and #sp > 0 then
        local mkb = 0
        for _, a in ipairs(sp) do if a.mkb then mkb = mkb + 1 end end
        if mkb < #sp then return castField(u, s, (singleField(up, sp)), "magnetic field (off the attackers)", now) end
      else
        return castField(u, s, toward(up, tp, 50), "magnetic field", now)
      end
    end
  end

  -- 6. items
  if burst(u, s, h, now, d, ar, loss, z, f) then return end

  -- 7. Spark Wraith where the target will be when it arms, only when the clamped aim still lands there
  local spark = Try(NPC.GetAbility, u, "arc_warden_spark_wraith")
  if on(isHero and ui.sparkH or ui.sparkD) and not silenced and not immune
    and now - s.lastSparkAt > 0.5 and usable(u, s, spark, now) then
    local aim, pred, range = sparkAim(u, h, now)
    if dist(up, aim) <= range and dist(aim, pred) <= SPARK_SEARCH then
      if send(u, s, spark, "spark wraith", nil, aim, now) then s.lastSparkAt = now return true end
    end
  end

  -- 8. Midas, 9. attack
  if midas(u, s, now) then return end
  if isHero and lensStay(u, s, h, now, up, tp, d, reach) then return end
  attack(u, s, h, now, d, ar)
end

-- combo_units.cpp: illusions and our other units near the target or near the hero attack it (6 orders each 0.1 s);
-- an illusion you have selected is yours. A tester (2026-11-01): from full range the orders came late and the
-- illusions went for the nearest units. A fresh illusion can drop its first order and then auto-attacks a creep,
-- and nothing sent it back: now the order is repeated while a unit hits something else, or stands idle 0.5 s.
-- ------------------------------------------------------------- body block --
-- spells/body_block.h (Kir: «иллюзии манты должны забегать вперёд врага и стопать его»): Manta images, the hero's and
-- the double's, get in front of a target running from us - the earliest one in the centre, the next two at its sides
-- so it can't slip round; nobody in front within 3 s -> they run beside its path and cut in. While it stands they all
-- attack it (unitsJoin), as do the ones not blocking.
local bodyBlock = (function()
local T_HULL, I_HULL, SLACK, SIDE_SLACK, RUNNING = 27, 27, 4, 6, 120
local MAX_TAU, STEP, REACTION, HOLD_WALL, KEEP_SLOT, KEEP_FLANK = 3.0, 0.05, 0.1, 0.6, 0.15, 60
local FLANK_ASIDE, FLANK_AHEAD, FLANK_LEAD, REORDER_EVERY, REORDER_SHIFT = 1.5, 80, 0.2, 0.12, 30
local mem, wall, roles = {}, { at = -1e9, ux = 0, uy = 0 }, {}

-- the real move speed: the base (no boots, haste) as the floor, the ground it covers while it runs on top
local function realSpeed(m, p, now, base, current)
  local sn = m.seen
  if sn == nil or now - sn.at > 0.6 then
    m.seen = { p = p, at = now, fast = sn and sn.fast or 0 }
  elseif now - sn.at >= 0.2 then
    local v = dist(p, sn.p) / (now - sn.at)
    if v > 0.6 * base and v < 700 then sn.fast = sn.fast > 0 and sn.fast + 0.3 * (v - sn.fast) or v end
    sn.p, sn.at = p, now
  end
  if type(current) == "number" and current > 0 then
    m.seen.fast = math.min(m.seen.fast, current)
    return current
  end
  return math.min(550, math.max(base, m.seen.fast))
end
local function spot(tg, ahead, side)
  return Vector(tg.p.x + tg.ux * ahead - tg.uy * side, tg.p.y + tg.uy * ahead + tg.ux * side, tg.p.z)
end
local function intercept(b, tg, side)
  local gap, speed = T_HULL + I_HULL + SLACK, math.max(b.speed, 50)
  for i = 1, math.floor(MAX_TAU / STEP + 1e-6) do
    local tau = i * STEP
    local goal = spot(tg, tg.speed * tau + gap, side)
    if dist(goal, b.p) / speed + tg.react + (b.turn or 0) <= tau + 1e-6 then return tau, goal end
  end
  return -1, nil
end
local function alongAcross(b, tg)
  local dx, dy = b.p.x - tg.p.x, b.p.y - tg.p.y
  return dx * tg.ux + dy * tg.uy, -dx * tg.uy + dy * tg.ux
end
local function pathDistance(b, tg)
  local along, across = alongAcross(b, tg)
  return along > 0 and math.abs(across) or math.sqrt(along * along + across * across)
end
local function clamp01(x) return math.max(0, math.min(1, x)) end
local function flank(b, tg)
  local along, across = alongAcross(b, tg)
  local side = (math.abs(across) < 20 and b.lastSide ~= 0) and b.lastSide or (across >= 0 and 1 or -1)
  local sum = T_HULL + I_HULL
  return { role = "flank", side = side, goal = spot(tg, tg.speed * FLANK_LEAD + FLANK_AHEAD, side * FLANK_ASIDE * sum * clamp01(-along / sum)) }
end

local function plan(units, tg, hero, now)
  local out = {}
  for i = 1, #units do out[i] = { role = "attack" } end
  local running = tg.free and tg.speed > RUNNING and tg.ux * (tg.p.x - hero.x) + tg.uy * (tg.p.y - hero.y) > 0
  if wall.id ~= tg.id then wall = { at = -1e9, ux = 0, uy = 0, id = tg.id } end  -- a new target: not the old one's run
  if running then wall = { at = now, ux = tg.ux, uy = tg.uy, id = tg.id } end
  local held = not running and tg.free and now - wall.at < HOLD_WALL
  -- it stands: they hit it at once (a tester: waiting on its far side first cost the hits); they block once it runs
  if not running and not held then return out, false end
  if held then tg.ux, tg.uy = wall.ux, wall.uy end
  local function pick(side, centreHull)
    local p = { rank = 1e9 }
    for i, b in ipairs(units) do
      if out[i].role == "attack" then
        local off = side ~= 0 and side * (centreHull + I_HULL + SIDE_SLACK) or 0
        local tau, goal = intercept(b, tg, off)
        if tau >= 0 then
          local rank = tau - ((b.lastRole == "block" and b.lastSide == side) and KEEP_SLOT or 0)
          if rank < p.rank then p = { unit = i, tau = tau, rank = rank, goal = goal } end
        end
      end
    end
    return p
  end
  local centre = pick(0, 0)
  if centre.unit then
    out[centre.unit] = { role = "block", goal = centre.goal, side = 0 }
    local left, right = pick(1, I_HULL), pick(-1, I_HULL)
    local first = (left.unit and (right.unit == nil or left.rank <= right.rank)) and 1 or -1
    local a = first == 1 and left or right
    if a.unit then
      out[a.unit] = { role = "block", goal = a.goal, side = first }
      local b = pick(-first, I_HULL)
      if b.unit then out[b.unit] = { role = "block", goal = b.goal, side = -first } end
    end
    return out, false
  end
  -- nobody gets in front yet: all flank, nearest the path first; the second takes the other side
  local order = {}
  for i = 1, #units do order[i] = i end
  local function near(i) return pathDistance(units[i], tg) - (units[i].lastRole == "flank" and KEEP_FLANK or 0) end
  table.sort(order, function(a, b) local na, nb = near(a), near(b) if na ~= nb then return na < nb end return a < b end)
  for k, i in ipairs(order) do
    local a = flank(units[i], tg)
    if k == 2 and a.side == out[order[1]].side then
      local along = alongAcross(units[i], tg)
      local sum = T_HULL + I_HULL
      a.side = -a.side
      a.goal = spot(tg, tg.speed * FLANK_LEAD + FLANK_AHEAD, a.side * FLANK_ASIDE * sum * math.max(clamp01(-along / sum), 0.5))
    end
    out[i] = a
  end
  return out, false
end

-- the adapter: our hero's images (not the double, not one you selected), the target's run, the orders
return function(me, dbl, h, now)
  roles = {}
  local tp, mp = pos(h), pos(me)
  local player = Try(Players.GetLocal)
  local pid = player and Try(Player.GetPlayerID, player)
  if not on(ui.block) or tp == nil or mp == nil or pid == nil or not alive(h) then return roles end
  local selected = {}
  for _, u in ipairs(Try(Player.GetSelectedUnits, player) or {}) do selected[idx(u)] = true end
  local di = dbl and idx(dbl)
  local list, units = {}, {}
  for _, u in ipairs(Try(NPCs.InRadius, mp, 2000, teamOf(me), Enum.TeamType.TEAM_FRIEND, false, true) or {}) do
    local i = idx(u)
    -- one that cannot walk (rooted, stunned, hexed, restricted) takes no block slot: it hits from where it is (INT-01)
    if i ~= idx(me) and i ~= di and alive(u) and Try(NPC.IsIllusion, u) == true and Try(NPC.GetUnitName, u) == ARC
      and not selected[i] and now >= ((G.imageManual or {})[i] or 0) and Try(NPC.IsControllableByPlayer, u, pid) == true
      and not hasState(u, MS().MODIFIER_STATE_OUT_OF_GAME) and not hasState(u, MS().MODIFIER_STATE_ROOTED)
      and not hasState(u, MS().MODIFIER_STATE_STUNNED) and not hasState(u, MS().MODIFIER_STATE_HEXED)
      and not hasState(u, MS().MODIFIER_STATE_COMMAND_RESTRICTED) and dist(pos(u), tp) < 1600 then
      local m = mem[i] or { at = -1e9, role = "attack", side = 0 }
      mem[i] = m
      -- Umbrella gives the real move speed (boots, haste, slows) at once: the floor, the measured run on top
      local current = Try(NPC.GetMoveSpeed, u)
      local base = current or Try(NPC.GetBaseSpeed, u) or 300
      list[#list + 1] = u
      -- its turn towards the target first (about 0.05 s a radian, the hero turn rate)
      units[#units + 1] = { p = pos(u), speed = realSpeed(m, pos(u), now, base, current), lastRole = m.role, lastSide = m.side,
                            turn = 0.05 * math.min(math.pi, facingOff(u, tp)) }
    end
  end
  if #units == 0 then return roles end
  -- where it runs: the way it faces (a tester: the smoothed motion came a step late and the images stood; the PL /
  -- Naga scripts aim by facing too), its real move speed once it is moving; the order's delay = 0.1 + the ping
  local vx, vy = velocity(h, now)
  local v = math.sqrt(vx * vx + vy * vy)
  local ux, uy = v > 1 and vx / v or 0, v > 1 and vy / v or 0
  local f = Try(function() return Entity.GetRotation(h):GetForward() end)
  local fl = f and math.sqrt(f.x * f.x + f.y * f.y) or 0
  if fl > 0.1 and (v <= 1 or (f.x * ux + f.y * uy) / fl > -0.2) then ux, uy = f.x / fl, f.y / fl end
  local moving = v > 60 or Try(NPC.IsRunning, h) == true
  local ping = Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_OUTGOING) or 0
  local tg = { id = idx(h), p = tp, speed = moving and math.max(v, Try(NPC.GetMoveSpeed, h) or v) or v, ux = ux, uy = uy,
               react = REACTION + math.min(0.3, math.max(0, ping)),
               free = heldLeft(h) <= 0.3 and not hasState(h, MS().MODIFIER_STATE_ROOTED) }
  local out = plan(units, tg, mp, now)
  for k, u in ipairs(list) do
    local i, a, m = idx(u), out[k], mem[idx(u)]
    if a.role ~= "attack" then
      roles[i] = a.role
      local due = now - m.at >= REORDER_EVERY and (m.role ~= a.role or m.goal == nil or dist(a.goal, m.goal) > REORDER_SHIFT)
      if due then
        if direct(u, ORDER.move, nil, a.goal, nil) or orderCall(NPC.MoveTo, u, a.goal, false, false) then
          m.at, m.goal = now, a.goal
          G.unitAttack[i] = nil  -- back to attacking: unitsJoin sends it again
        end
      end
    end
    m.role, m.side = a.role, a.side or 0
  end
  return roles
end
end)()

local function unitsJoin(me, dbl, h, now)
  local blocking = bodyBlock(me, dbl, h, now)
  if now - G.unitsAt < 0.1 then return end
  G.unitsAt = now
  local tp, mp = pos(h), pos(me)
  local player = Try(Players.GetLocal)
  local pid = player and Try(Player.GetPlayerID, player)
  if tp == nil or pid == nil or hasState(h, MS().MODIFIER_STATE_ATTACK_IMMUNE) then return end
  local selected = {}
  for _, u in ipairs(Try(Player.GetSelectedUnits, player) or {}) do selected[idx(u)] = true end
  local hi, mi, di = idx(h), idx(me), idx(dbl)
  local seen, units = {}, {}
  for _, c in ipairs({ tp, mp }) do
    for _, u in ipairs(c and Try(NPCs.InRadius, c, 1600, teamOf(me), Enum.TeamType.TEAM_FRIEND, false, true) or {}) do
      local i = idx(u)
      if not seen[i] then seen[i] = true; units[#units + 1] = u end
    end
  end
  local sent = 0
  for _, u in ipairs(units) do
    if sent >= 6 then break end
    local i = idx(u)
    local illusion = Try(NPC.IsIllusion, u) == true
    if i ~= mi and i ~= di and not blocking[i] and alive(u) and Try(NPC.IsControllableByPlayer, u, pid) == true
      and Try(NPC.IsCourier, u) ~= true and Try(NPC.IsStructure, u) ~= true and Try(NPC.IsWard, u) ~= true
      and not (illusion and (selected[i] or now < ((G.imageManual or {})[i] or 0))) and (Try(NPC.GetTrueMaximumDamage, u) or 1) > 0
      and Try(NPC.IsChannellingAbility, u) ~= true then
      local a = G.unitAttack[i]
      local hits = Try(NPC.GetAttackTarget, u)
      local elsewhere = hits ~= nil and idx(hits) ~= hi and a ~= nil and now - a.at > 0.2
      local idle = a ~= nil and now - a.at > 0.5 and Try(NPC.IsAttacking, u) ~= true
      if a == nil or a.target ~= hi or elsewhere or idle then
        if attackOrder(player, u, h) then
          G.unitAttack[i] = { target = hi, at = now }
          sent = sent + 1
        end
      end
    end
  end
end

-- -------------------------------------------------------- with the key up --
-- its modifier's end, else the spell's duration since it came
local function lifeLeft(u, now)
  local l = math.max(modLeft(u, DOUBLE_MOD, now), modLeft(u, "modifier_kill", now))
  if l <= 0 and D.bornAt then l = D.bornAt + D.lasts - now end
  if l <= 0 then return nil end
  return l
end

local function enemyTowerNear(u, p, r)
  for _, t in ipairs(Try(function() return Towers.GetAll() end) or {}) do
    local tp = pos(t)
    if tp and alive(t) and teamOf(t) ~= teamOf(u) and dist(tp, p) < r then return true end
  end
  return false
end

-- aw_clone_exit_support.h, the dying gift: Mjollnir, then Linken's, on the hero (an ally hero; an ally creep for
-- Mjollnir) with < 2 s of its life left or caught under 25% HP
local function gift(u, s, me, now, loss)
  local life, up = lifeLeft(u, now), pos(u)
  if up == nil then return false end
  local dying = life ~= nil and life > 0.15 and life < 2.0
  local caught = hpFrac(u) <= 0.25 and loss > 0.02 and (nearestHero(u, up, 900) ~= nil or enemyTowerNear(u, up, 900))
  if not (dying or caught) then return false end
  local function ally(r, creeps, skip)
    local mp = pos(me)
    if mp and alive(me) and dist(up, mp) < r and not has(me, skip) then return me end
    for _, a in ipairs(Try(Heroes.InRadius, up, r, teamOf(u), Enum.TeamType.TEAM_FRIEND, true, true) or {}) do
      if alive(a) and idx(a) ~= idx(u) and not has(a, DOUBLE_MOD) and not has(a, skip) then return a end
    end
    if creeps then
      for _, c in ipairs(Try(NPCs.InRadius, up, r, teamOf(u), Enum.TeamType.TEAM_FRIEND, true, true) or {}) do
        if alive(c) and Try(NPC.IsCreep, c) == true and (Try(Entity.GetHealth, c) or 0) >= 50 and hpFrac(c) >= 0.2
          and not has(c, skip) then
          return c
        end
      end
    end
    return nil
  end
  local mj = useItem(u, s, "item_mjollnir", now, 0.6)
  local to = mj and ally(768, true, "modifier_item_mjollnir_static")
  if to then return send(u, s, mj, "item_mjollnir (gift)", to, nil, now) end
  local sp = useItem(u, s, "item_sphere", now, 0.6)
  to = sp and ally(668, false, "modifier_item_sphere_target")
  if to then return send(u, s, sp, "item_sphere (gift)", to, nil, now) end
  return false
end

-- ------------------------------------------------------------------- push --
-- aw_force.cpp (Kir 2026-11-01 «2 пики на мейн по кнопке»), and the Pika script's «Spawn clone and save»: the hero turns
-- to the cursor, the double's Hurricane Pike / Force Staff pushes him (600 the way he faces), and as that push ends his
-- own pushes him again. No double: Tempest Double next to him first, then its push. Not inside Duel / Chronosphere /
-- Black Hole (Valve: both items wasted there). items.txt: push 0.5 s; on an ally Force reaches 550, Pike 650.
local PUSH_HELD = { "modifier_legion_commander_duel", "modifier_faceless_void_chronosphere_freeze", "modifier_enigma_black_hole_pull" }
local function pushHeld(me)
  for _, m in ipairs(PUSH_HELD) do if has(me, m) then return m end end
  return nil
end
-- a caster that can use an item now (the bot's canUseItems): not stunned / hexed / muted / out of the game / restricted
local function pushItem(u)
  if u == nil or not alive(u) or hasState(u, MS().MODIFIER_STATE_STUNNED) or hasState(u, MS().MODIFIER_STATE_HEXED)
    or hasState(u, MS().MODIFIER_STATE_MUTED) or hasState(u, MS().MODIFIER_STATE_OUT_OF_GAME)
    or hasState(u, MS().MODIFIER_STATE_COMMAND_RESTRICTED) then return nil end
  local mana = Try(NPC.GetMana, u) or 0
  for _, it in ipairs({ { "item_hurricane_pike", 650 }, { "item_force_staff", 550 } }) do
    local item = Try(NPC.GetItem, u, it[1], true)
    if item and Try(Ability.IsCastable, item, mana) == true then
      local r = Try(Ability.GetCastRange, item)
      return item, (type(r) == "number" and r > 0 and r or it[2]) + castBonus(u)
    end
  end
  return nil
end
local function pushCast(u, it, target, now, point)
  local state = unitState(u)
  if not ready(u, state, now) or castingAt(u) then return nil end
  if not send(u, state, it, "push: " .. (Try(Ability.GetName, it) or "ability"), target, point, now) then return nil end
  local p = state.pending
  p.freeAt = nil
  p.onRefuse = function() p.failed = true end
  local duration = Try(Ability.GetLevelSpecialValueFor, it, "push_duration")
  p.pushDuration = type(duration) == "number" and duration > 0 and duration <= 2 and duration or 0.5
  return p
end

-- Both bodies stay reserved while their exact cast waits for the normal ACK/queue
-- logic. Budget the push duration from the cast ACK; it is not proof of displacement.
local function pushTick(me, down, now)
  local P = G.push
  if now < math.max(D.hookLease or -100, D.saveUntil or -100) then G.push = nil return false end
  if down and not G.pushWas and P == nil then
    if not alive(me) or pushHeld(me) then G.pushWas = down return false end
    local mp, cur = pos(me), Try(Input.GetWorldCursorPos)
    P = { stage = "double", at = now, start = now, hero = me }
    if mp and cur and dist(mp, cur) > 100 then
      P.goal, P.stage = toward(mp, cur, 150), "turn"
    end
    G.push = P
  end
  G.pushWas = down
  if P == nil then return false end
  local function stop(why) G.push = nil Note("push: stopped, %s", why) return false end
  if (G.pushCancelAt or -100) > P.start then return stop("external order") end
  if not alive(me) or (P.hero and P.hero ~= me) then return stop("hero changed or dead") end
  if pushHeld(me) then return stop("hero is held") end
  if now - P.start > 8 then return stop("chain timed out") end
  local hs = unitState(me)
  local dbl = findDouble(me, now)
  local ds = dbl and unitState(dbl)
  pendingBusy(hs, now)
  if ds then pendingBusy(ds, now) end
  if P.stage == "turn" then
    if not ready(me, hs, now) or castingAt(me) then return true end
    if not P.turnSent then
      if not (direct(me, ORDER.move, nil, P.goal, nil)
        or orderCall(NPC.MoveTo, me, P.goal, false, false, false, on(ui.fast), "arc_rage")) then return true end
      P.turnSent, D.ownAt = now, now
    end
    if facingOff(me, P.goal) > 0.26 then return true end
    -- Cancel the short turn's walk so it cannot turn us back after the first push.
    if not (direct(me, ORDER.hold, nil, pos(me), nil)
      or orderCall(Player.HoldPosition, Try(Players.GetLocal), me, false, false, on(ui.fast), "arc_rage")) then return true end
    P.stage = "double"
  end
  if P.stage == "double" and dbl == nil and not P.triedSpawn and on(ui.pushSpawn) then
    local td = Try(NPC.GetAbility, me, "arc_warden_tempest_double")
    if td and Try(Ability.IsCastable, td, Try(NPC.GetMana, me) or 0) == true then
      local p = pushCast(me, td, nil, now, pos(me))
      if not p then return true end
      P.cast, P.stage, P.bornBefore, P.triedSpawn = p, "spawn", D.bornAt, true
      return true
    end
  end
  if P.stage == "spawn" then
    if P.cast.failed then return stop("summon refused") end
    if dbl == nil or D.bornAt == P.bornBefore or now - D.bornAt < 0.2 then return true end
    P.cast, P.stage = nil, "double"
  end
  if P.stage == "double" then
    local it, range = pushItem(dbl)
    local mp, dp = pos(me), dbl and pos(dbl)
    if it and mp and dp and dist(mp, dp) <= range then
      local p = pushCast(dbl, it, me, now)
      if not p then return true end
      P.actor, P.birth, P.cast, P.stage = dbl, D.bornAt, p, "pushed"
      return true
    end
    P.stage = "self-ready"
  end
  if P.stage == "pushed" then
    if dbl ~= P.actor or D.bornAt ~= P.birth then return stop("double changed") end
    if P.cast.failed then return stop("double item refused") end
    if not P.cast.confirmed or now - P.cast.confirmedAt < P.cast.pushDuration then return true end
    P.stage = "self-ready"
  end
  if P.stage == "self-ready" then
    local it = pushItem(me)
    if not it then return stop("hero has no ready Pike / Force") end
    local p = pushCast(me, it, me, now)
    if not p then return true end
    P.cast, P.stage = p, "self-pushed"
    return true
  elseif P.stage == "self-pushed" then
    if P.cast.failed then return stop("self item refused") end
    if P.cast.confirmed and now - P.cast.confirmedAt >= P.cast.pushDuration then return stop("finished") end
  end
  return true
end

-- aw_field.cpp awAutoField, every 0.1 s: enemy heroes swinging at the hero -> the double's field, off the hero's centre
-- away from them so they swing from outside (Kir 2026-11-01 «дабл купол, но максимально по умному»); attackers from
-- both sides -> the second field makes the lens with the first; under 60% HP or 2+ attackers and one field can't leave
-- them out -> both at once as a lens. None against an MKB on every attacker; the hero keeps a quarter of its mana.
-- Duel (aw_field.cpp, Kir 2026-11-01): the hero held, Legion at his side -> the double's field off-centre, the hero
-- 60 inside its edge and she 60 past it, so her hits miss: centre P - d*(L-P)/|L-P|; she too far behind -> none
local function duelCentre(me, mp)
  local mod = Try(NPC.GetModifier, me, "modifier_legion_commander_duel")
  local enemy = mod and Try(Modifier.GetCaster, mod)
  local lp = enemy and pos(enemy)
  if not enemy or not lp or not alive(enemy) or teamOf(enemy) == teamOf(me)
    or Try(NPC.GetUnitName, enemy) ~= "npc_dota_hero_legion_commander" then return nil end
  local gap = dist(mp, lp)
  if gap < 1 then return nil end
  local d = math.min(FIELD_RADIUS - 60, math.max(0, FIELD_RADIUS + 60 - gap))
  if gap + d < FIELD_RADIUS + 30 then return nil end
  return Vector(mp.x - (lp.x - mp.x) / gap * d, mp.y - (lp.y - mp.y) / gap * d, mp.z), enemy
end

-- the Duel save runs before the combo and the farm, key held or not (Codex FP-02: with the key held the auto field never
-- ran and the double's combo field went round the double, not the hero). Only the free double casts (the hero in a Duel
-- takes no orders); none while a field of ours already holds that spot. No promise against MKB / true strike.
local function duelSave(me, dbl, ds, now)
  if not on(ui.aField) or dbl == nil or not alive(me) or not ready(dbl, ds, now) then return false end
  local mp = pos(me)
  local c, legion = nil, nil
  if mp then c, legion = duelCentre(me, mp) end
  local dp = pos(dbl)
  if c == nil or dp == nil or dist(dp, c) > 850 then return false end
  for _, f in ipairs(G.fields) do
    if f.confirmed and now >= f.at and now - f.at < f.lasts and dist(mp, f.pos) <= FIELD_RADIUS - 30
      and legion and pos(legion) and dist(pos(legion), f.pos) >= FIELD_RADIUS + 30 then return false end
  end
  if castField(dbl, ds, c, "magnetic field (Duel: hero inside, Legion outside)", now) then
    D.fieldAt = now + 0.6
    return true
  end
  return false
end

local function autoField(me, dbl, hs, ds, now)
  if not on(ui.aField) or now < D.fieldAt or not alive(me) then return end
  D.fieldAt = now + 0.1
  local mp = pos(me)
  local n = G.heroAttackers
  if mp == nil or n == 0 then return end
  if duelCentre(me, mp) then return end  -- duelSave has it, key held or not
  local spots, pierce = G.heroSpots or {}, 0
  for _, sp in ipairs(spots) do if sp.mkb then pierce = pierce + 1 end end
  if #spots > 0 and pierce == #spots then return end
  local low, several = hpFrac(me) < 0.6, n >= 2
  local mana, maxMana = Try(NPC.GetMana, me) or 0, Try(NPC.GetMaxMana, me) or 0
  local own = Try(NPC.GetAbility, me, FIELD)
  local spare = own ~= nil and maxMana > 0 and mana - (Try(Ability.GetManaCost, own) or 0) >= 0.25 * maxMana
  local single, singleHits = singleField(mp, spots)
  local foe = nearestHero(me, mp, 2000)
  local lens, lensHits = lensToward(mp, spots, foe and pos(foe) or mp)
  if (low or several) and spare and lensHits < singleHits and dbl and now >= D.pauseUntil then
    preparePair(me, dbl, lens, now)
  end
  if G.pair then
    if dbl and ready(dbl, ds, now) and castHalf(dbl, ds, false, now) then D.fieldAt = now + 0.6 return end
    if ready(me, hs, now) and now - D.playerAt >= 0.45 and castHalf(me, hs, true, now) then D.fieldAt = now + 0.6 end
    return
  end
  local at, label = (#spots > 0) and single or mp, "magnetic field (off the attackers)"
  if inField(me, mp, now) then
    -- a field over the hero already, attackers swinging from inside it: the second one closes them out as a lens
    local last
    for _, f in ipairs(G.fields) do
      if now - f.at < f.lasts - 0.3 and dist(mp, f.pos) <= FIELD_RADIUS then last = f end
    end
    if last == nil or #spots == 0 then return end
    local inside = 0
    for _, sp in ipairs(spots) do if inCircle(swingSpot(mp, sp), last.pos) then inside = inside + 1 end end
    local hits
    at, hits = singleField(mp, spots, last.pos)
    if hits >= inside then return end
    label = "magnetic field (lens with ours)"
  end
  local dp = dbl and pos(dbl)
  if dp and now >= D.pauseUntil and ready(dbl, ds, now) then
    -- nobody swinging from close (a caster): one field over both of us when we stand together
    if #spots == 0 and dist(dp, mp) <= 300 then at = Vector((dp.x + mp.x) / 2, (dp.y + mp.y) / 2, mp.z) end
    if dist(dp, at) <= 875 and castField(dbl, ds, at, label, now) then
      D.fieldAt = now + 0.6
      return
    end
  end
  if (low or several) and ready(me, hs, now) and now - D.playerAt >= 0.45
    and castField(me, hs, at, label, now) then
    D.fieldAt = now + 0.6
  end
end

-- autoMidas, every 0.25 s: the double (and the hero if asked, standing, 0.2 s after your last order to it)
local function autoMidas(me, dbl, hs, ds, now)
  if now < D.midasAt then return end
  D.midasAt = now + 0.25
  local function try(u, s, want)
    if not want or u == nil or not alive(u) or not ready(u, s, now) or hasState(u, MS().MODIFIER_STATE_INVISIBLE) then
      return false
    end
    return midas(u, s, now)
  end
  if try(me, hs, on(ui.aMidasH) and now - D.playerAt >= 0.2 and Try(NPC.IsRunning, me) ~= true) then return end
  try(dbl, ds, on(ui.aMidasD) and now >= D.pauseUntil)
end

local function trackDouble(me, dbl, now)
  if dbl then
    local m = Try(NPC.GetModifier, dbl, DOUBLE_MOD)
    local born = m and Try(Modifier.GetCreationTime, m)
    local valid = type(born) == "number" and born <= now and born >= 0
    if not D.had or D.actor ~= dbl or (valid and born ~= D.bornAt) then
      local td = Try(NPC.GetAbility, me, "arc_warden_tempest_double")
      if D.actor then U[idx(D.actor)] = nil end
      D.actor = dbl
      D.bornAt = valid and born or now
      U[idx(dbl)] = nil
      D.pauseUntil = -100
      D.hookLease = -100
      D.lasts = (td and Try(Ability.GetLevelSpecialValueFor, td, "duration")) or 18
      if type(D.lasts) ~= "number" or D.lasts <= 0 then D.lasts = 18 end
    end
    D.life, D.had = lifeLeft(dbl, now), true
    return
  end
  if D.had then
    if D.life and D.life > 1 then Note("double killed with %.1f s of its life left", D.life) end
    if D.actor then U[idx(D.actor)] = nil end
    D.actor = nil
    D.had, D.bornAt = false, nil
  end
end

-- Reset selection/attack planning while each target retains its pending control chain.
local function freshFight()
  G.lastFieldAt = -100
  G.pair, G.cand, G.unitAttack = nil, nil, {}
  for _, state in pairs(U) do
    -- Already dispatched casts belong to their actor/life, not the current combo target.
    state.attackSentAt, state.lastFluxAt, state.lastSparkAt = nil, -100, -100
  end
end

-- The lane farm and the creep-hit forecast in a function of their own: Lua allows a chunk 200 locals at once, and
-- with them at the top the file stopped loading (v24, «too many local variables»). Only these come out of it.
local farm, addHit, flightTime, hitOn, swingPoint, attackTargetOf = (function()
-- ---------------------------------------------------------------- lane farm --
-- v23: the bot's own lane farm for the Tempest Double, rule for rule, lanes only - no wisdom runes (camps: v25, below)
-- (aw_farm.cpp awFarmTick, aw_farm_world.cpp, aw_farm_actor.cpp, aw_farm_cast.cpp, aw_farm_wave.cpp, aw_farm_idle.cpp,
-- aw_farm_items.cpp, spells/aw_smart_clone.h, spells/aw_push.h, spells/aw_clone_items.h). With the keys up, every tick:
--   waves: enemy lane creeps in sight grouped within 700; one with an enemy hero within 800, or under an enemy tower
--     (range + 100) that fewer than 2 of our creeps tank, is not the double's;
--   first its own fight: an enemy hero within 1200 (kept to 1600) with the combo; under 30% HP only one under 35%;
--     under his tower (range + 150) only one under 35% it already fights. Then: an enemy tower shooting it -> out of
--     its reach (range + 220); an enemy hero within 900 it does not fight -> 700 back from him; its swing in flight is
--     never cut;
--   the wave worth most: n / (way + 2 + HP / 900), one by the hero worth 0.4, the last pick kept 3 s or until another
--     is 1.25x better, none on foot behind it (400 toward our base). The way: a TP when walking is 4 s longer and it
--     lands with 6.5 s of life (a walk: 5 s; an unknown life: only within 900) - Boots of Travel onto our creep there
--     (half HP or more, the fewest enemies on it, a ranged one first), else the scroll onto our tower by the wave;
--     never with an enemy hero within 1200 or 4 s after a fight. On foot: a Blink onto our creep by the wave, a Force
--     Staff / Pike ahead, else our side of the wave;
--   at the wave: Static Charge / Manta / Stick, Midas, Field on 3+ creeps in reach, Spark on a lone ranged creep, Spark
--     on its target, then the last hit by the forecast below, else the creep it kills in the fewest hits (no Flux: v22);
--   no wave: 2+ of our creeps within 1500 -> their enemy tower (2 of ours tank it, it does not shoot the double), else
--     an attack-move among them; else the nearest wave (a TP onto our creep there over 2500), our creep within 1800,
--     the nearest tower alone under its own field (v22), a TP onto our group furthest down a lane, out of the base,
--     our most pushed group anywhere (v22), else it holds.
--   An enemy TP to the tower it pushes alone (v23): Spark Wraith on the landing for vision, and that tower is left.
-- The forecast (lh_forecast.h, the way LASThitv6 reads the game): each creep's coming hits - a melee swing lands at
-- its attack point, a ranged one when its projectile does - plus each attacker's next swing at it. The double shoots
-- when the creep's HP after the hits sure to land first is within its own hit.

-- lh_model.h damageMult: ranged creeps +50% to creeps, -50% to siege and buildings; siege takes 50% of a hero's hit,
-- 70% of the others'
local function kindOf(u)
  if Try(NPC.IsHero, u) == true then return "hero" end
  if Try(NPC.IsTower, u) == true then return "tower" end
  if (Try(NPC.GetUnitName, u) or ""):find("siege", 1, true) then return "siege" end
  if Try(NPC.IsRanged, u) == true then return "ranged" end
  return "melee"
end
local function kindMult(a, b)
  local m = 1
  if a == "ranged" then m = (b == "siege" or b == "tower") and 0.5 or 1.5 end
  if b == "siege" or b == "tower" then m = m * (a == "hero" and 0.5 or 0.7) end
  return m
end
local function hitOn(src, dst)
  return (Try(NPC.GetTrueDamage, src) or 0) * (Try(NPC.GetArmorDamageMultiplier, dst) or 1) * kindMult(kindOf(src), kindOf(dst))
end
local function flightTime(src, dst)
  local a, b = pos(src), pos(dst)
  if a == nil or b == nil then return 0 end
  return dist(a, b) / math.max(300, Try(NPC.GetAttackProjectileSpeed, src) or 900)
end
local function swingPoint(u)
  return (Try(NPC.GetAttackAnimPoint, u) or 0.5) / math.max(0.2, Try(NPC.GetAttackSpeed, u) or 1)
end

-- what a unit hits: the game's own read, a tower's target, else the enemy it faces in reach (LASThitv6)
local function attackTargetOf(u)
  local t = Try(NPC.GetAttackTarget, u) or Try(Entity.GetAttackTarget, u)
  if t == nil and Try(NPC.IsTower, u) == true and type(Tower) == "table" then t = Try(Tower.GetAttackTarget, u) end
  if t == nil then
    local ranged = Try(NPC.IsRanged, u) == true
    t = Try(NPC.FindFacingNPC, u, nil, Enum.TeamType.TEAM_ENEMY, ranged and 35 or 25, attackRange(u) + (ranged and 350 or 120))
  end
  return t
end
-- backdoor protection up (no enemy creeps by it): hits on it do next to nothing and it heals (Darer 2026-11-01)
local function backdoor(t) return has(t, "modifier_backdoor_protection_active") end
-- whom a tower shoots: the game's own reads only (a guess by facing is no proof for a building)
local function towerTarget(t)
  local x = Try(NPC.GetAttackTarget, t)
  if x == nil and type(Tower) == "table" then x = Try(Tower.GetAttackTarget, t) end
  return x
end

local function addHit(src, dst, land, release, projectile)
  local di = idx(dst)
  local list = F.hits[di]
  if list == nil then list = {} F.hits[di] = list end
  list[#list + 1] = { src = idx(src), land = land, release = release, dmg = hitOn(src, dst), projectile = projectile }
end

-- the HP a creep surely / possibly lost by `at` to the others' hits (and the double's own swing on its way)
local function forecast(c, at, now)
  local sure, possible = 0, 0
  for _, e in ipairs(F.hits[idx(c)] or {}) do
    if e.land > now - 0.05 then  -- an older one is in its HP already
      local edge = e.projectile and 0.08 or 0.03
      if e.land <= at - edge then sure = sure + e.dmg end
      if e.land <= at + edge then possible = possible + e.dmg end
    end
  end
  local ci = idx(c)
  for _, cy in pairs(F.cycles) do
    if cy.target == ci and alive(cy.src) and Try(NPC.IsAttacking, cy.src) == true then
      local start = cy.next
      for _ = 1, 3 do
        local land = start + cy.cp + (cy.ranged and flightTime(cy.src, c) or 0)
        if land > at + 0.05 then break end
        if land > now then possible = possible + cy.dmg end
        start = start + cy.spa
      end
    end
  end
  return sure, possible
end

-- the double's shot at c ordered now: when it releases and lands (the walk, the turn, its attack cooldown count)
local function shot(u, s, c, now)
  local up, cp = pos(u), pos(c)
  local gap = math.max(0, dist(up, cp) - hulls(u, c) - attackRange(u))
  local walk = gap / math.max(100, Try(NPC.GetMoveSpeed, u) or 300)
  local turn = Try(NPC.GetTimeToFacePosition, u, cp) or 0
  local start = math.max(now + LATENCY + turn + walk, s.fReady or 0)
  local release = start + swingPoint(u)
  return release, release + flightTime(u, c)
end

-- spells/aw_smart_clone.h farmTarget: the creep it kills now (the first to release), else the one it kills in the
-- fewest hits that nobody else kills first
local function farmTarget(u, s, eligible, now)
  local kill, killAt, clear, clearHits = nil, math.huge, nil, math.huge
  local base = Try(NPC.GetTrueDamage, u) or 0
  for _, c in ipairs(eligible) do
    local hp = Try(Entity.GetHealth, c) or 0
    local release, land = shot(u, s, c, now)
    local sure, possible = forecast(c, land, now)
    local mine = base * (Try(NPC.GetArmorDamageMultiplier, c) or 1) * kindMult("hero", kindOf(c))
    local left = hp - sure
    if left > 0 and left <= mine then
      if release < killAt then kill, killAt = c, release end
    elseif left > 0 and mine > 0 then
      local hits = math.max(1, (hp - possible) / mine)
      if hits < clearHits then clear, clearHits = c, hits end
    end
  end
  return kill, clear
end

-- aw_farm_actor.cpp x.home: back toward it by more than 400 is "back", where the double never walks (a TP may take it:
-- Kir 2026-10-18 «всё равно назад бежит» - after the push it walked 1800 back to our next wave)
local HOME = { [2] = { x = -7100, y = -6600 }, [3] = { x = 7000, y = 6400 } }
local function behind(up, p, home) return home ~= nil and dist(p, home) < dist(up, home) - 400 end

-- our lane creeps by a point (the towers' tanks)
local function tanks(p, r)
  local n = 0
  for _, o in ipairs(F.ours) do if dist(o.p, p) < (r or 750) then n = n + 1 end end
  return n
end
-- an enemy tower in reach of p (its range + margin)
local function towerOver(p, team, margin)
  for _, t in ipairs(F.towers) do
    local tp = pos(t)
    if tp and teamOf(t) ~= team and dist(tp, p) < attackRange(t) + margin then return t, tp end
  end
  return nil
end
-- an enemy tower covers p (range + margin) with fewer than 2 of our creeps there to tank it
local function exposed(p, team, margin)
  for _, t in ipairs(F.towers) do
    local tp = pos(t)
    if tp and teamOf(t) ~= team and dist(tp, p) < attackRange(t) + margin and tanks(tp) < 2 then return true end
  end
  return false
end
-- a creep is fair game unless an enemy tower covers it with fewer than 2 of our creeps there to tank
local function towerSafe(p, team) return not exposed(p, team, 100) end
-- the nearest seen enemy hero (no illusion) within r of p
local function heroNear(p, r)
  local best, bp, bd = nil, nil, r
  for _, h in ipairs(F.heroes) do
    local hp = pos(h)
    if hp and dist(hp, p) < bd then best, bp, bd = h, hp, dist(hp, p) end
  end
  return best, bp
end
local function heroName(h) return ((Try(NPC.GetUnitName, h) or "?"):gsub("^npc_dota_hero_", "")) end
-- our tower nearest a point within 2200 (a TP without Boots lands there)
local function ourTower(c, team)
  local best, bd = nil, 2200
  for _, t in ipairs(F.towers) do
    local tp = pos(t)
    if tp and teamOf(t) == team and dist(tp, c) < bd then best, bd = t, dist(tp, c) end
  end
  return best, bd
end

-- aw_farm_world.cpp awFarmWaves, every 0.1 s: lane creeps (ours as { u, p, i, hp, max, ranged }), enemy creeps in
-- sight and their waves, towers, enemy heroes in sight (no illusions)
local function farmScan(me, now)
  if now - F.scanAt < 0.1 then return end
  F.scanAt = now
  local team = teamOf(me)
  local ours, enemies, towers, heroes = {}, {}, {}, {}
  for _, u in ipairs(Try(NPCs.GetAll) or {}) do
    if Try(NPC.IsLaneCreep, u) == true and alive(u) and Try(Entity.IsDormant, u) ~= true
      and Try(NPC.IsWaitingToSpawn, u) ~= true then
      local p = pos(u)
      if p and teamOf(u) == team then
        ours[#ours + 1] = { u = u, p = p, i = idx(u), hp = Try(Entity.GetHealth, u) or 0,
                            max = math.max(1, Try(Entity.GetMaxHealth, u) or 1), ranged = Try(NPC.IsRanged, u) == true }
      elseif p and visible(u) then
        enemies[#enemies + 1] = u
      end
    end
  end
  for _, t in ipairs(Try(function() return Towers.GetAll() end) or {}) do
    if alive(t) and pos(t) then towers[#towers + 1] = t end
  end
  for _, h in ipairs(Try(Heroes.GetAll) or {}) do
    if alive(h) and teamOf(h) ~= team and visible(h) and Try(NPC.IsIllusion, h) ~= true and pos(h) then
      heroes[#heroes + 1] = h
    end
  end
  F.ours, F.enemies, F.towers, F.heroes, F.aimed = ours, enemies, towers, heroes, nil
  local waves = {}
  for _, c in ipairs(enemies) do
    local p = pos(c)
    local w = nil
    for _, x in ipairs(waves) do if dist(x.c, p) < 700 then w = x end end
    if w == nil then w = { c = p, n = 0, hp = 0 } waves[#waves + 1] = w end
    w.c = Vector((w.c.x * w.n + p.x) / (w.n + 1), (w.c.y * w.n + p.y) / (w.n + 1), p.z)
    w.n, w.hp = w.n + 1, w.hp + (Try(Entity.GetHealth, c) or 0)
  end
  for _, w in ipairs(waves) do
    if heroNear(w.c, 800) then w.unsafe = "enemy hero" end
    if exposed(w.c, team, 100) then w.unsafe = "enemy tower" end
    -- our creep nearest it within 1200 (the side of the wave it walks to), our tower nearest within 2200
    local best = 1200
    for _, o in ipairs(ours) do
      if dist(o.p, w.c) < best then w.anchor, best = o, dist(o.p, w.c) end
    end
    w.tower, w.towerD = ourTower(w.c, team)
  end
  F.waves = waves
end

-- how many enemies hit each of our creeps this scan (counted once, when a TP asks)
local function aimedAt()
  if F.aimed then return F.aimed end
  local n = {}
  local function count(t) if t then local i = idx(t) n[i] = (n[i] or 0) + 1 end end
  for _, e in ipairs(F.enemies) do count(attackTargetOf(e)) end
  for _, h in ipairs(F.heroes) do count(attackTargetOf(h)) end
  for _, t in ipairs(F.towers) do count(towerTarget(t)) end
  F.aimed = n
  return n
end
-- aw_push.h tpCreep: our lane creep within 1200 of c at half HP or more, the one the fewest enemies hit, a ranged one
-- first (it stands behind the fight), then the most HP; `fits` may filter more
local function tpCreep(c, fits)
  local aimed = aimedAt()
  local best, bestHits = nil, 0
  for _, o in ipairs(F.ours) do
    if dist(o.p, c) <= 1200 and o.hp * 2 >= o.max and (fits == nil or fits(o)) then
      local hits = aimed[o.i] or 0
      local better = best == nil or hits < bestHits
      if not better and hits == bestHits then
        if o.ranged ~= best.ranged then better = o.ranged else better = o.hp > best.hp end
      end
      if better then best, bestHits = o, hits end
    end
  end
  return best
end

-- aw_farm_actor.cpp awFarmGuard: the double's TP is its scroll (slot 15; Boots of Travel upgrade it: onto units, 2 s
-- with level 2). Ready: off cooldown, its mana, a charge or Boots, neither muted nor rooted, no refusal pending
local function tpState(u, s, now)
  local tp = { boots2 = Try(NPC.GetItem, u, "item_travel_boots_2", true) ~= nil }
  tp.bot = tp.boots2 or Try(NPC.GetItem, u, "item_travel_boots", true) ~= nil
  local it = Try(NPC.GetItemByIndex, u, 15)
  if it == nil or Try(Ability.GetName, it) ~= "item_tpscroll" then it = Try(NPC.GetItem, u, "item_tpscroll", true) end
  tp.it = it
  local cd = it and Try(Ability.GetCooldown, it) or 0
  local charges = it and Try(Item.GetCurrentCharges, it)
  if it == nil then tp.why = "no TP scroll"
  elseif cd > 0.001 then tp.why = string.format("TP cooldown %.0f s", cd)
  elseif (Try(NPC.GetMana, u) or 0) < (Try(Ability.GetManaCost, it) or 0) then tp.why = "no mana for TP"
  elseif not tp.bot and type(charges) == "number" and charges <= 0 then tp.why = "no TP scroll charge"
  elseif hasState(u, MS().MODIFIER_STATE_MUTED) or hasState(u, MS().MODIFIER_STATE_ROOTED) then tp.why = "muted or rooted"
  elseif not usable(u, s, it, now) then tp.why = "TP refused a moment ago or not castable"
  else tp.ready = true end
  return tp
end

-- spells/aw_smart_clone.h travel: on foot when it fits its life (+5 s to work there), a TP (over 2500) when walking is
-- 4 s longer than channel + 1.5 s (+ the creep's walk to the wave beyond 900 / the walk from our tower) and it lands
-- with 6.5 s left; an unknown life goes only within 900
local function travel(d, w, life, ms, enemyNear, tp)
  local plan = { dur = d / ms, how = "walk" }
  if life == nil then return d <= 900 and plan or nil end
  if d <= 900 then plan.dur = 0 return life >= 2 and plan or nil end
  local budget = (tp.boots2 and 2 or 3) + 1.5
  if d > 2500 and plan.dur > budget + 4 then
    if not on(ui.farmTp) then F.noTp = "TP switch off"
    elseif not tp.ready then F.noTp = tp.why
    elseif enemyNear then F.noTp = "an enemy hero within 1200 or a fight 4 s ago"
    else
      local creep = tp.bot and tpCreep(w.c)
      if creep then
        local dur = budget + math.max(0, dist(creep.p, w.c) - 900) / ms
        if plan.dur > dur + 4 then plan = { dur = dur, how = "creep", to = creep, at = creep.p } end
      end
      if plan.how == "walk" and w.tower then
        local dur = budget + w.towerD / ms
        if plan.dur > dur + 4 then plan = { dur = dur, how = "tower", at = pos(w.tower) } end
      end
      if plan.how == "walk" then
        F.noTp = (not tp.bot and not w.tower) and "no Boots of Travel and no tower of ours by the wave"
          or "walking is not 4 s longer than the TP"
      end
    end
  end
  if plan.dur + (plan.how == "walk" and 5 or 6.5) > life then return nil end
  return plan
end

-- aw_farm_cast.cpp awFarmPickWave + aw_smart_clone.h selectTask
local function pickWave(me, u, now, life, enemyNear, tp, home)
  local up, mp = pos(u), pos(me)
  local ms = math.max(150, Try(NPC.GetMoveSpeed, u) or 300)
  local best, bestScore, cur, curScore = nil, 0, nil, 0
  local task = F.task
  for _, w in ipairs(F.waves) do
    w.plan = nil
    if not w.unsafe then
      local plan = travel(dist(up, w.c), w, life, ms, enemyNear, tp)
      if plan and not (plan.how == "walk" and behind(up, w.c, home)) then
        w.plan = plan
        local score = w.n / (plan.dur + 2 + w.hp / 900)
        if mp and alive(me) and #F.waves > 1 and dist(w.c, mp) < 1500 then score = score * 0.4 end
        if score > bestScore then best, bestScore = w, score end
        if task and ((w.anchor and w.anchor.i == task.anchor) or dist(w.c, task.c) <= 700) and score > curScore then
          cur, curScore = w, score
        end
      end
    end
  end
  if cur and (now < F.claimUntil or bestScore <= curScore * 1.25) then best = cur end
  if best == nil then F.task = nil return nil end
  if F.task == nil or best ~= cur then F.claimUntil = now + 3 end
  F.task = { c = best.c, anchor = best.anchor and best.anchor.i }
  return best
end

-- orders: straight to the double (no selection switch), the way the combo sends them
local function unitOrder(n, v) return Try(function() return Enum.UnitOrder[n] end) or v end
local MOVE, AMOVE, HOLD = "DOTA_UNIT_ORDER_MOVE_TO_POSITION", "DOTA_UNIT_ORDER_ATTACK_MOVE", "DOTA_UNIT_ORDER_HOLD_POSITION"
local ORDER_N = { [MOVE] = 1, [AMOVE] = 3, [HOLD] = 10 }
local function farmAttack(u, s, c, now, why, release)
  F.taskName = why
  local ci = idx(c)
  if s.fTarget == ci and now - (s.fAt or -100) <= 2.5 then
    local actual = Try(NPC.GetAttackTarget, u)
    local protected = (s.fRelease and now < s.fRelease)
      or (s.fReady and now < s.fReady)
      or (s.fLease and now < s.fLease.by and alive(s.fLease.u))
    -- The engine may retain an old target after the attack stopped. Retry that idle body, not a real swing.
    local active = idx(actual) == ci and (Try(NPC.IsAttacking, u) ~= false or Try(NPC.IsRunning, u) ~= false)
    if active or protected or now - (s.fAt or -100) < 0.35 then return end
  end
  local player = Try(Players.GetLocal)
  if player == nil then return end
  if not attackOrder(player, u, c) then return end
  s.fTarget, s.fAt, s.fGoal, s.fOrder, s.fMove = ci, now, pos(c), ORDER.attack, nil
  -- aw_smart_clone.h AttackLease: the swing it begins is kept until its release (+0.12, 0.12..2 s), never extended
  s.fLease = release and { u = c, at = now, by = math.min(now + 2, math.max(now + 0.12, release + 0.12)) } or nil
  s.nextOrder = now + 0.05
  D.ownAt = now
  if why ~= "clear" or F.why ~= "clear" then
    Note("farm: double %s %s hp %d", why, kindOf(c), math.floor(Try(Entity.GetHealth, c) or 0))
  end
  F.why = why
end
-- a move / attack-move / hold: again after `every` s, or at once for a goal 300 away (strict: only by time)
local function farmMove(u, s, p, now, why, every, kind, strict)
  F.taskName = why
  every, kind = every or 1, kind or MOVE
  local up = pos(u)
  if up == nil or p == nil then return false end
  local elapsed = now - (s.fAt or -100)
  if s.fOrder == kind and elapsed <= every and (strict or (s.fGoal and dist(s.fGoal, p) <= 300)) then
    if kind == HOLD then return false end
    local m = s.fMove
    if m and dist(up, m.p) >= 12 then m.p, m.at = up, now end
    local hitting = kind == AMOVE and Try(NPC.IsAttacking, u) == true
    local stopped = Try(NPC.IsRunning, u) == false
    local stuck = m ~= nil and now - m.at >= 0.6
    if elapsed < 0.35 or dist(up, p) <= 150 or hitting or not (stopped or stuck) then return false end
  end
  if kind ~= HOLD and hasState(u, MS().MODIFIER_STATE_ROOTED) then return end
  local player = Try(Players.GetLocal)
  if player == nil then return end
  local I = Enum.PlayerOrderIssuer
  local ok = orderCall(Player.PrepareUnitOrders, player, unitOrder(kind, ORDER_N[kind]), nil, p, nil,
                   (I and I.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY) or 3, u, false, false, false, on(ui.fast), "arc_rage")
  if not ok then
    if kind == HOLD then ok = orderCall(Player.HoldPosition, player, u, false, false, false, "arc_rage")
    elseif kind == MOVE then ok = orderCall(NPC.MoveTo, u, p, false, false, false, on(ui.fast), "arc_rage") end
  end
  if not ok then return false end
  if F.why ~= why then Note("farm: double %s (%d away)", why, math.floor(dist(pos(u), p))) end
  s.fGoal, s.fAt, s.fTarget, s.fLease, F.why = p, now, nil, nil, why
  s.fOrder, s.fMove = kind, kind ~= HOLD and { p = up, at = now } or nil
  s.nextOrder = now + 0.05
  D.ownAt = now
  return true
end
-- A previously valid tower can become protected while an ATTACK order is still active.
local function retireFarmTower(u, s, now)
  local actual = Try(NPC.GetAttackTarget, u)
  for _, t in ipairs(F.towers) do
    if (actual == t or (actual == nil and s.fTarget == idx(t)))
      and (backdoor(t) or hasState(t, MS().MODIFIER_STATE_INVULNERABLE) or not alive(t)) then
      s.fTarget, s.fLease, s.fGoal, s.fAt = nil, nil, nil, nil
      F.task, F.towerAt, F.solo = nil, nil, nil
      return farmMove(u, s, pos(u), now, "stops hitting a protected tower", 0, HOLD, true)
    end
  end
  return false
end
-- the TP: onto our creep (a targeted order, as the bot sends it with Boots of Travel) or onto a point (our tower).
-- It waits for the game (no next order before its channel shows); a refusal backs off as any cast does.
local function farmTp(u, s, tp, creep, at, label, now)
  local fast = on(ui.fast)
  local cd0, ch0 = Try(Ability.GetCooldown, tp.it) or 0, Try(Item.GetCurrentCharges, tp.it)
  F.tpGo = { at = at, from = pos(u), creep = creep and creep.u, sentAt = now, unit = u, birth = D.bornAt }
  if not dispatchCast(u, tp.it, creep and creep.u, at, creep ~= nil, creep == nil) then F.tpGo = nil return false end
  s.pending = { ab = tp.it, actor = u, target = creep and creep.u, where = not creep and at or nil,
                orderType = creep and ORDER.castTarget or ORDER.castPos,
                key = "item_tpscroll", sentAt = now, cp = 0, cd0 = cd0,
                ch0 = ch0, aimed = creep ~= nil }
  s.inflight[#s.inflight + 1] = s.pending
  s.nextOrder, s.lastCastAt, s.castAt.item_tpscroll, D.ownAt = now + 0.05, now, now, now
  s.fGoal, s.fTarget, s.fLease, s.fOrder, s.fMove, F.task = nil, nil, nil, nil, nil, nil
  F.taskName, F.why = "TP " .. label, "tp"
  Note("farm: double TP %s (%d away, life %.1f)", label, math.floor(dist(pos(u), at)), lifeLeft(u, now) or -1)
  return true
end

-- its swing in flight (aw_smart_clone.h AttackLease): until the release it was ordered for, the launch seen
-- (OnUnitAnimation: its swing's start + attack point), or the creep gone
local function leaseHolds(s, now)
  local l = s.fLease
  if l == nil then return false end
  local launched = s.fRelease ~= nil and s.fRelease > l.at and now >= s.fRelease
  if now >= l.by or launched or not alive(l.u) then s.fLease = nil return false end
  return true
end
-- its own wind-up as the game shows it: an attack animation whose shot has not left yet
local function swinging(s, now) return s.fRelease ~= nil and now < s.fRelease end

-- ------------------------------------------------------------ farm items --
-- items.h planItemsRecovery, the part the farm keeps (aw_farm_items.cpp): Stick / Wand / Locket by their charges
local function farmRecovery(u, s, now)
  local hp, maxHp = Try(Entity.GetHealth, u) or 0, Try(Entity.GetMaxHealth, u) or 1
  local z, loss = F.z or {}, F.loss or 0
  local hurtNow = z.focused or z.incoming or loss > 0.06
  for _, w in ipairs({ { "item_magic_stick", 10, 15 }, { "item_magic_wand", 20, 15 }, { "item_holy_locket", 25, 17 } }) do
    local it = useItem(u, s, w[1], now, 3)
    local ch = it and Try(Item.GetCurrentCharges, it) or 0
    if it and ch > 0 and ch <= w[2] then
      local heal = ch * w[3]
      if (maxHp - hp >= math.max(60, heal * 0.8) and (hurtNow or hp < 0.7 * maxHp)) or (hurtNow and hp < 0.35 * maxHp)
        or needsMana(u, ch * 15) then
        return send(u, s, it, w[1] .. " (farm)", u, nil, now)
      end
    end
  end
  return false
end

-- aw_clone_items.h frontCreep: our creep for Static Charge - within 768 (Mjollnir 800), 50+ HP and 20%+, no charge on
-- it; at half HP or more first, then the one nearest an enemy creep or tower (within 1500); none in front: the nearest
local function frontCreep(up, team)
  local best, bestFront, bestHealthy, fit, fitScore = nil, math.huge, false, nil, -math.huge
  for _, o in ipairs(F.ours) do
    local d, frac = dist(o.p, up), o.hp / o.max
    if d <= 768 and o.hp >= 50 and frac >= 0.2 and not has(o.u, "modifier_item_mjollnir_static")
      and not hasState(o.u, MS().MODIFIER_STATE_INVULNERABLE) then
      local score = 100 - d / 1000 + frac / 10
      if score > fitScore then fit, fitScore = o, score end
      local front = math.huge
      for _, e in ipairs(F.enemies) do local ep = pos(e) if ep then front = math.min(front, dist(ep, o.p)) end end
      for _, t in ipairs(F.towers) do
        local tp = pos(t)
        if tp and teamOf(t) ~= team then front = math.min(front, dist(tp, o.p)) end
      end
      if front <= 1500 then
        local healthy = frac >= 0.5
        if best == nil or (healthy and not bestHealthy) or (healthy == bestHealthy and front < bestFront) then
          best, bestFront, bestHealthy = o, front, healthy
        end
      end
    end
  end
  return best or fit
end

-- Manta while it farms (v22, a tester: none on creeps or towers); its illusions go on the tower it hits
local function mantaFarm(u, s, now, why)
  if not on(ui.farmManta) then return false end
  local it = item(u, "item_manta")
  if it == nil or not usable(u, s, it, now) then return false end
  local before, birth = {}, D.bornAt
  for _, x in ipairs(Try(NPCs.InRadius, pos(u), 800, teamOf(u), Enum.TeamType.TEAM_FRIEND, false, true) or {}) do before[idx(x)] = x end
  if not send(u, s, it, "manta (" .. why .. ")", nil, nil, now) then return false end
  s.pending.freeAt = nil
  s.pending.onConfirm = function(at)
    if D.bornAt ~= birth then return end
    s.fTarget, s.fAt, s.fLease = nil, nil, nil
    F.mantaAt, F.mantaSent, F.mantaBefore, F.mantaOwner = at, now, before, u
  end
  return true
end
-- Membership requires a new image and its modifier's caster, not just nearby owner/index.
local function farmImages(u, now, r)
  local player = Try(Players.GetLocal)
  local pid = player and Try(Player.GetPlayerID, player)
  local up, me = pos(u), Try(Heroes.GetLocal)
  if pid == nil or up == nil then return {}, player end
  F.images = F.images or {}
  local selected, out = {}, {}
  for _, x in ipairs(Try(Player.GetSelectedUnits, player) or {}) do selected[idx(x)] = true end
  for _, x in ipairs(Try(NPCs.InRadius, up, r, teamOf(u), Enum.TeamType.TEAM_FRIEND, false, true) or {}) do
    local i, xp = idx(x), pos(x)
    if xp and alive(x) and i ~= idx(u) and i ~= idx(me) and not has(x, DOUBLE_MOD) and Try(NPC.IsIllusion, x) == true
      and Try(NPC.IsControllableByPlayer, x, pid) == true and Try(NPC.GetUnitName, x) == ARC then
      local m = Try(NPC.GetModifier, x, "modifier_illusion")
      local caster = m and Try(Modifier.GetCaster, m)
      local born = m and Try(Modifier.GetCreationTime, m)
      if F.mantaOwner == u and F.mantaBefore and F.mantaBefore[i] ~= x and now - (F.mantaAt or -100) < 1
        and caster == u and type(born) == "number" and born >= F.mantaSent then F.images[i] = x end
      if F.images[i] == x and not selected[i] and now >= ((G.imageManual or {})[i] or 0) then out[#out + 1] = x end
    end
  end
  return out, player
end
local function illusionsOn(u, t, now)
  if now - (F.illAt or -100) < 0.5 then return end
  F.illAt = now
  local ti = idx(t)
  local list, player = farmImages(u, now, 1200)
  for _, x in ipairs(list) do
    if idx(Try(NPC.GetAttackTarget, x)) ~= ti then attackOrder(player, x, t) end
  end
end
local function illusionsFollow(me, u, s, now)
  if now - (F.followAt or -100) < 0.5 then return end
  local up = pos(u)
  if up == nil then return end
  local goal = s.fGoal or up
  local I = Enum.PlayerOrderIssuer
  local list, player = farmImages(u, now, 3000)
  for _, x in ipairs(list) do
    local xp = pos(x)
    if (dist(xp, up) > 700 or Try(NPC.IsAttacking, x) ~= true) and dist(xp, goal) > 250 then
      if orderCall(Player.PrepareUnitOrders, player, unitOrder(AMOVE, ORDER_N[AMOVE]), nil, goal, nil,
          (I and I.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY) or 3, x, false, false, false, on(ui.fast), "arc_rage") then
        F.followAt = now
      end
    end
  end
end

-- aw_farm_items.cpp awFarmLaneItems / aw_clone_items.h decide, in every lane task, never on a trip and never in its
-- wind-up: Stick / Wand / Locket; Static Charge on our front creep while it pushes with 2+ of our creeps within 900
-- (at their tower, by an enemy tower within 1500, or with 2+ enemy creeps in reach), 7 s of life left or less, twice a
-- life at most; else Manta with 3+ enemy creeps within attack range + 150 and no enemy hero within 900 (v22: and at the
-- tower it hits). `task`: "clear", "tower", "follow", "with creeps".
local function laneItems(u, s, now, life, task, towerHit)
  if has(u, "modifier_teleporting") or swinging(s, now) or (life ~= nil and life < 0.15) then return false end
  if not hasState(u, MS().MODIFIER_STATE_INVISIBLE) and farmRecovery(u, s, now) then return true end
  local up, team = pos(u), teamOf(u)
  local reach, inReach, towerNear = attackRange(u) + 150, 0, false
  for _, e in ipairs(F.enemies) do
    local ep = pos(e)
    if ep and dist(ep, up) <= reach then inReach = inReach + 1 end
  end
  for _, t in ipairs(F.towers) do
    local tp = pos(t)
    if tp and teamOf(t) ~= team and dist(tp, up) < 1500 then towerNear = true end
  end
  local L = F.lifeState
  local mj = item(u, "item_mjollnir")
  if mj and life ~= nil and life <= 7 and L.static < 2 and now >= L.staticAt and tanks(up, 900) >= 2
    and (task == "tower" or towerNear or inReach >= 2) and usable(u, s, mj, now) then
    local to = frontCreep(up, team)
    if to then
      if not send(u, s, mj, "item_mjollnir (static, " .. task .. ")", to.u, nil, now) then return false end
      s.pending.onConfirm = function(at)
        if F.lifeState == L then L.static, L.staticAt = L.static + 1, at + 0.6 end
      end
      return true
    end
  end
  if heroNear(up, 900) then return false end
  if inReach >= 3 then return mantaFarm(u, s, now, "creeps") end
  if towerHit then return mantaFarm(u, s, now, "tower") end
  return false
end

-- ------------------------------------------------------------ farm casts --
-- aw_farm_cast.cpp awFarmField / awFarmCast: under itself, 80 mana kept, not in a field of ours, 3.5 s of life left
local function fieldOk(u, s, now, life)
  local mf = fieldReady(u, s, now)
  if mf == nil or life == nil or life <= 3.5 or inField(u, pos(u), now)
    or (Try(NPC.GetMana, u) or 0) < (Try(Ability.GetManaCost, mf) or 0) + 80 then return nil end
  return mf
end
local function farmField(u, s, now, life, label)
  return fieldOk(u, s, now, life) ~= nil and castField(u, s, pos(u), label, now)
end
-- Spark Wraith ready, 2 s after its last one
local function sparkReady(u, s, now)
  if hasState(u, MS().MODIFIER_STATE_SILENCED) then return nil end
  local sp = Try(NPC.GetAbility, u, "arc_warden_spark_wraith")
  if sp and (Try(Ability.GetLevel, sp) or 0) > 0 and usable(u, s, sp, now) and now - (s.fSparkAt or -100) > 2 then return sp end
  return nil
end
local function farmSpark(u, s, sp, p, label, now)
  if not send(u, s, sp, label, nil, p, now) then return false end
  s.fSparkAt = now
  F.taskName = label
  return true
end
-- aw_smart_clone.h rangedSpellTarget (Spark): a ranged creep within 1200 hitting something, over two of its hits, no
-- other unit of its side within 32 (Spark takes the nearest in its search); the one with the fewest hits
local function rangedSpark(u, up, eligible, base)
  local best, bestHits = nil, math.huge
  for _, c in ipairs(eligible) do
    local p = pos(c)
    if p and kindOf(c) == "ranged" and dist(p, up) <= 1200 then
      local dmg = base * (Try(NPC.GetArmorDamageMultiplier, c) or 1) * kindMult("hero", "ranged")
      local hp = Try(Entity.GetHealth, c) or 0
      if dmg > 0 and hp > dmg * 2 and hp / dmg < bestHits and attackTargetOf(c) ~= nil then
        local crowd = false
        for _, x in ipairs(Try(NPCs.InRadius, p, 32, teamOf(u), Enum.TeamType.TEAM_ENEMY, true, true) or {}) do
          if alive(x) and idx(x) ~= idx(c) then crowd = true end
        end
        if not crowd then best, bestHits = c, hp / dmg end
      end
    end
  end
  return best
end

-- aw_farm_wave.cpp awFarmAtWave
local function atWave(u, s, w, now, life)
  if laneItems(u, s, now, life, "clear") then return end
  local team, up = teamOf(u), pos(u)
  local eligible = {}
  for _, c in ipairs(F.enemies) do
    local p = pos(c)
    if p and alive(c) and dist(p, w.c) <= 750 and towerSafe(p, team) then eligible[#eligible + 1] = c end
  end
  local kill, clear = farmTarget(u, s, eligible, now)
  -- a tester 2026-11-01: an enemy catapult shooting a building of ours is the one to hit (a last hit due now still first)
  local cart
  for _, x in ipairs(F.enemies) do
    local xp = pos(x)
    if xp and alive(x) and kindOf(x) == "siege" and dist(xp, w.c) <= 1000 and dist(xp, up) <= 1500 then
      local tgt = attackTargetOf(x)
      if tgt and teamOf(tgt) == team and (Try(NPC.IsStructure, tgt) == true or Try(NPC.IsTower, tgt) == true) then cart = x break end
    end
  end
  if cart and (kill == nil or idx(kill) == idx(cart)) then kill, clear = nil, cart end
  local c = kill or clear
  if c == nil then
    F.taskName, F.idle = "at a wave, nothing to hit", "each creep there dies to other hits first or stands under a tower"
    return
  end
  local base = Try(NPC.GetTrueDamage, u) or 0
  -- Midas on the biggest creep in 570 (not the one it last-hits), 2.85 s of life left (the switch: Midas by the double)
  if not kill and on(ui.aMidasD) and (life == nil or life >= 2.85) then
    local m = useItem(u, s, "item_hand_of_midas", now)
    local best, bestMax, bestHp = nil, 0, 0
    for _, x in ipairs(m and eligible or {}) do
      local p = pos(x)
      if p and dist(p, up) <= 570 and now - (G.midasAt[idx(x)] or -100) > 1 then
        local mh, cur = Try(Entity.GetMaxHealth, x) or 0, Try(Entity.GetHealth, x) or 0
        if mh > bestMax or (mh == bestMax and cur > bestHp) then best, bestMax, bestHp = x, mh, cur end
      end
    end
    if best then
      if not send(u, s, m, "item_hand_of_midas (farm)", best, nil, now) then return false end
      G.midasAt[idx(best)] = now
      F.taskName = "midas"
      return true
    end
  end
  local sp = not kill and on(ui.farmSpell) and sparkReady(u, s, now)
  if not kill and on(ui.farmSpell) and not hasState(u, MS().MODIFIER_STATE_SILENCED) then
    -- Field on 3+ creeps within its attack range (no Flux in the farm: v22)
    local n = 0
    for _, x in ipairs(eligible) do if dist(pos(x), up) <= attackRange(u) then n = n + 1 end end
    if n >= 3 and farmField(u, s, now, life, "magnetic field (farm)") then return end
    local r = sp and life ~= nil and life > 3.5 and rangedSpark(u, up, eligible, base)
    if r then return farmSpark(u, s, sp, pos(r), "spark wraith (farm, ranged creep)", now) end
  end
  -- Spark on its target: a creep hitting something, over two of the double's hits, within 1200, 3.5 s of life left
  local cp = pos(c)
  if sp and life ~= nil and life > 3.5 and attackTargetOf(c) ~= nil and dist(cp, up) <= 1200
    and (Try(Entity.GetHealth, c) or 0) > base * (Try(NPC.GetArmorDamageMultiplier, c) or 1) * kindMult("hero", kindOf(c)) * 2 then
    return farmSpark(u, s, sp, cp, "spark wraith (farm)", now)
  end
  if hasState(u, MS().MODIFIER_STATE_DISARMED) then F.taskName = "disarmed" return end
  -- its hit must release with 2 s of its life to spare
  local release = shot(u, s, c, now)
  if release < now or (life ~= nil and release - now + 2 > life) then
    F.taskName, F.idle = "at a wave", "its next hit comes after its life"
    return
  end
  farmAttack(u, s, c, now, kill and "last hit" or (c == cart and "the catapult hitting our tower") or "clear", release)
end

-- aw_farm_wave.cpp awFarmTravel on foot: a Blink onto our creep by the wave (400..range on the way, 300 nearer the
-- wave), none an enemy hero in sight within 1200 or a tower (range + 100) covers; else a Force Staff / Pike 600 ahead
-- when that is 300 nearer the wave, not back, and as safe
local function landingSafe(p, team) return heroNear(p, 1200) == nil and towerOver(p, team, 100) == nil end
local function blinkTo(u, s, w, now, up)
  local team, d = teamOf(u), dist(up, w.c)
  for _, b in ipairs(BLINKS) do
    local it = item(u, b[1])
    if it and usable(u, s, it, now) then
      local land, near = nil, math.huge
      for _, o in ipairs(F.ours) do
        local go = dist(up, o.p)
        if dist(o.p, w.c) <= 900 and go >= 400 and go <= b[2] - 10 and go < near and d - dist(o.p, w.c) >= 300
          and landingSafe(o.p, team) then
          land, near = o, go
        end
      end
      if land then
        F.taskName = "blinks to a wave"
        return send(u, s, it, b[1] .. " (farm, to a wave)", nil, land.p, now)
      end
    end
  end
  return false
end
local function forceTo(u, s, w, now, up, home)
  local ahead = Try(Entity.GetForwardPosition, u, 600)
  if ahead == nil or behind(up, ahead, home) or dist(up, w.c) - dist(ahead, w.c) < 300
    or not landingSafe(ahead, teamOf(u)) then
    return false
  end
  for _, n in ipairs({ "item_force_staff", "item_hurricane_pike" }) do
    local it = item(u, n)
    if it and usable(u, s, it, now) then
      F.taskName = "pushes itself to a wave"
      return send(u, s, it, n .. " (farm, to a wave)", u, nil, now)
    end
  end
  return false
end
local function travelTo(u, s, w, now, life, enemyNear, tp, home)
  local plan, up = w.plan, pos(u)
  if plan.how ~= "walk" then
    return farmTp(u, s, tp, plan.to, plan.at, plan.how == "creep" and "onto our creep by a wave of " .. w.n
      or "onto our tower by a wave of " .. w.n, now)
  end
  local free = not hasState(u, MS().MODIFIER_STATE_MUTED) and not hasState(u, MS().MODIFIER_STATE_ROOTED)
    and not enemyNear and life ~= nil and life > 3.5
  if free and (blinkTo(u, s, w, now, up) or forceTo(u, s, w, now, up, home)) then return end
  -- our side of the wave: halfway to our creep at it
  local a = w.anchor
  farmMove(u, s, a and Vector((w.c.x + a.p.x) / 2, (w.c.y + a.p.y) / 2, w.c.z) or w.c, now, "walks to a wave")
end

-- ------------------------------------------------------------ enemy TP in --
-- v23 (a tester): an enemy hero TPs in to defend the tower the double pushes alone - Spark Wraith on the landing (the
-- tower area when it is not known) gives vision of him in fog or trees, and the double does not walk in blind: that
-- tower is left for 6 s. Seen: an enemy hero in sight channelling a TP (modifier_teleporting), or the teleport_end
-- particle of an enemy hero (OnParticleCreate / OnParticleUpdate below give where it lands).
local function tpWatch(u, s, now)
  local tps = F.tps or {}
  F.tps = tps
  for k, x in pairs(tps) do
    if now - x.at > 6 or not alive(x.hero) then tps[k] = nil end
  end
  for _, h in ipairs(F.heroes) do
    if has(h, "modifier_teleporting") and tps[idx(h)] == nil then tps[idx(h)] = { hero = h, at = now, seen = true } end
  end
  local tw = F.towerAt
  local up = pos(u)
  -- only a lone push: with our creeps around the double the push rules see to an enemy who comes
  if tw == nil or now - tw.at > 2 or up == nil or tanks(up, 1500) > 0 then return false end
  for _, x in pairs(tps) do
    local hp = pos(x.hero)
    -- the landing unknown: the tower area, when he stands far from it (not one leaving it)
    local land = x.p
    if land == nil and x.seen and hp and dist(hp, tw.p) > 2000 then land = tw.p end
    if land and dist(land, tw.p) < 1500 then
      x.tower = idx(tw.t)
      if not x.logged then
        x.logged = true
        Note("farm: enemy %s TPs in by the tower the double pushes (landing %s, %d from the tower): it stays out",
             heroName(x.hero), x.p and "seen" or "unknown", math.floor(dist(land, tw.p)))
      end
      local sp = not x.sparked and on(ui.farmTpSpark) and sparkReady(u, s, now)
      local aim = (dist(up, land) <= SPARK_RANGE - 10 and land) or (dist(up, tw.p) <= SPARK_RANGE - 10 and tw.p) or nil
      if sp and aim then
        if not farmSpark(u, s, sp, aim, "spark wraith (vision on an enemy TP)", now) then return false end
        s.pending.onConfirm = function() x.sparked = true end
        return true
      end
    end
  end
  return false
end
-- an enemy TP lands by this tower (within 1200), or was seen coming to it
local function tpGuarded(t, tp)
  for _, x in pairs(F.tps or {}) do
    if x.tower == idx(t) or (x.p and dist(x.p, tp) < 1200) then return true end
  end
  return false
end

-- ------------------------------------------------------------- no wave --
-- v22 (a tester, 2026-11-01: «it just stops there»): no creeps of ours by it - the nearest enemy tower no enemy hero
-- guards (and no enemy TP comes to), hit alone from inside the double's own Magnetic Field (the tower shoots from
-- outside it: evaded); with no field to stand in it keeps away under half HP
local function soloTower(u, s, now, life)
  if not on(ui.farmPush) or (life ~= nil and life < 5) or hasState(u, MS().MODIFIER_STATE_DISARMED) then return false end
  local up, team = pos(u), teamOf(u)
  local best, bestD = nil, 3000
  for _, t in ipairs(F.towers) do
    local tp = pos(t)
    if tp and teamOf(t) ~= team and not hasState(t, MS().MODIFIER_STATE_INVULNERABLE) and dist(tp, up) < bestD
      and not backdoor(t) and heroNear(tp, 1200) == nil and not tpGuarded(t, tp) then
      best, bestD = t, dist(tp, up)
    end
  end
  if best == nil then return false end
  local tp, reach = pos(best), attackRange(u)
  -- the walk in and 3 s of hits must fit its life (FARM-001)
  local eta = math.max(0, bestD - reach) / math.max(150, Try(NPC.GetMoveSpeed, u) or 300)
  if life ~= nil and eta + 3 > life then return false end
  F.solo, F.towerAt = { i = idx(best), at = now }, { t = best, p = tp, at = now }
  local shielded = inField(u, up, now)
  local canField = on(ui.farmSpell) and not hasState(u, MS().MODIFIER_STATE_SILENCED) and fieldOk(u, s, now, life) ~= nil
  if not shielded and not canField and hpFrac(u) < 0.5 then
    F.solo = nil
    if bestD >= 950 then return false end
    local k = 1000 / math.max(1, bestD)  -- out of the tower's reach (700) on its own side
    farmMove(u, s, Vector(tp.x + (up.x - tp.x) * k, tp.y + (up.y - tp.y) * k, up.z), now, "backs off the tower, no field")
    return true
  end
  if bestD > reach + 200 then
    local k = (reach - 50) / bestD  -- its attack range short of the tower, on its own side
    farmMove(u, s, Vector(tp.x + (up.x - tp.x) * k, tp.y + (up.y - tp.y) * k, up.z), now, "walks to a tower alone")
    return true
  end
  if not shielded and canField and farmField(u, s, now, life, "magnetic field (tower alone)") then return true end
  if laneItems(u, s, now, life, "tower", true) then return true end
  farmAttack(u, s, best, now, "hits a tower alone")
  illusionsOn(u, best, now)
  return true
end

-- aw_push.h step: 2+ of our creeps within 1500 -> the enemy tower within 1600 that 2 of ours tank (750) and that does
-- not shoot the double; else an attack-move to their centre (a walk by an enemy tower: range + 300). True: a step.
local function pushStep(u, s, now, life, home)
  local up, team = pos(u), teamOf(u)
  local n, sx, sy = 0, 0, 0
  for _, o in ipairs(F.ours) do
    if dist(o.p, up) < 1500 then n, sx, sy = n + 1, sx + o.p.x, sy + o.p.y end
  end
  if n < 2 then return false end
  if on(ui.farmPush) then
    for _, t in ipairs(F.towers) do
      local tp = pos(t)
      if tp and teamOf(t) ~= team and dist(tp, up) <= 1600 and not hasState(t, MS().MODIFIER_STATE_INVULNERABLE)
        and not backdoor(t) and tanks(tp) >= 2 and idx(towerTarget(t)) ~= idx(u) then
        F.towerAt = { t = t, p = tp, at = now }
        -- the field under the double as it gets to the tower: faster hits on it (v22, Darer: field on towers)
        local close = dist(tp, up) <= attackRange(u) + 200
        if laneItems(u, s, now, life, "tower", close) then return true end
        if close and on(ui.farmSpell) and farmField(u, s, now, life, "magnetic field (tower)") then return true end
        if hasState(u, MS().MODIFIER_STATE_DISARMED) then F.taskName = "disarmed at a tower" return true end
        farmAttack(u, s, t, now, "pushes the tower")
        illusionsOn(u, t, now)
        return true
      end
    end
  end
  -- Darer 2026-11-01: walking with our wave wastes the double's life; off -> it goes for the next enemy wave instead
  if not on(ui.farmFollow) then return false end
  local c = Vector(sx / n, sy / n, up.z)
  if behind(up, c, home) then return false end
  if laneItems(u, s, now, life, "follow") then return true end
  -- ahead of our front creep, 300 on down the lane, to the next wave / tower (v24, a tester: after a wave it walked
  -- behind our ranged creep); by an enemy tower that point would be under it: their centre, as before
  local front, fd = nil, -1
  for _, o in ipairs(F.ours) do
    if home and dist(o.p, up) < 1500 and dist(o.p, home) > fd then front, fd = o, dist(o.p, home) end
  end
  if front then
    local dx, dy = front.p.x - c.x, front.p.y - c.y
    local l = math.sqrt(dx * dx + dy * dy)
    if l < 50 then dx, dy, l = front.p.x - home.x, front.p.y - home.y, math.max(1, fd) end
    local ahead = Vector(front.p.x + dx / l * 300, front.p.y + dy / l * 300, up.z)
    if towerOver(ahead, team, 300) == nil then c = ahead end
  end
  -- an attack-move hits what it meets down the lane (barracks, buildings); by an enemy tower its creeps cannot tank: a
  -- walk. Never a new order in its wind-up.
  local byTower = towerOver(c, team, 300) ~= nil
  if swinging(s, now) then F.taskName = "pushes with our creeps" return true end
  if not byTower or dist(up, c) > 250 then
    farmMove(u, s, c, now, byTower and "walks with our creeps by a tower" or "attack-moves with our creeps",
             byTower and 1 or 1.5, byTower and MOVE or AMOVE)
  end
  return true
end

-- aw_push.h pushGroup: our creeps (2+ within 700) furthest from our base - ahead of the double (its distance from our
-- base - 400) unless `anywhere`, `minD` from it at least - with no enemy hero in sight within 1200 and no enemy tower
-- (range + 150) over them that 2 of ours do not tank, and the creep of them to land on
local function groupSafe(p, team) return heroNear(p, 1200) == nil and not exposed(p, team, 150) end
local function pushGroup(up, home, team, minD, anywhere)
  if home == nil then return nil end
  local best, bestAhead = nil, anywhere and -1 or dist(up, home) - 400
  for _, seed in ipairs(F.ours) do
    local m, gx, gy = 0, 0, 0
    for _, o in ipairs(F.ours) do
      if dist(o.p, seed.p) < 700 then m, gx, gy = m + 1, gx + o.p.x, gy + o.p.y end
    end
    if m >= 2 then
      local c = Vector(gx / m, gy / m, seed.p.z)
      local ahead = dist(c, home)
      if ahead > bestAhead and dist(c, up) >= minD and groupSafe(c, team) then
        local creep = tpCreep(c, function(o) return dist(o.p, seed.p) < 700 and groupSafe(o.p, team) end)
        if creep then best, bestAhead = { c = c, creep = creep, n = m }, ahead end
      end
    end
  end
  return best
end

-- ------------------------------------------------------------ neutral camps --
-- v25 (Kir: everything the bot has): spells/aw_jungle.h step in its lane form (the smart clone between waves,
-- aw_farm_actor.cpp / aw_farm_idle.cpp awFarmJungle): a camp on either side within 1800 of the double (+500 for the one
-- it already walks to), none within 950 of their tower or 1500 of their hero in sight, the walk + 6 s of hitting inside
-- its life; at a camp the neutral with the least HP first; a camp it cleared, or stood in and saw nothing of, holds
-- nothing until the next minute mark (the game refills at :00), none before 1:00. Only with no creeps around it, or to
-- finish the camp it is clearing (Kir 2026-10-31 «если есть [крипы], то не фармит»).
-- camps.h kCamps (the community stacker's boxes): id, centre x / y, spawn box min x / y, max x / y, wait point x / y
local CAMPS = {
  { 1, -766.0, 4912.0, -1216.0, 4520.0, -316.0, 5304.0, -816.1, 4432.8 },
  { 2, 3392.0, -1216.0, 3008.0, -1536.0, 3776.0, -896.0, 3177.8, -1020.6 },
  { 3, 4045.2, -5043.0, 3647.4, -5437.9, 4442.9, -4648.1, 4412.4, -5091.8 },
  { 4, 7937.1, -56.8, 7617.1, -408.8, 8257.1, 295.2, 8326.5, -21.9 },
  { 5, -4853.6, 3991.1, -5211.7, 3584.1, -4495.6, 4398.0, -4842.5, 4373.3 },
  { 6, 4750.5, -3904.0, 4379.1, -4312.6, 5121.9, -3495.4, 4315.8, -4163.4 },
  { 7, -1512.0, -3457.6, -2036.0, -3881.0, -988.0, -3034.2, -1179.5, -3720.0 },
  { 8, 192.7, -5153.8, -250.6, -5531.5, 636.0, -4776.0, 255.1, -4779.4 },
  { 9, -4796.8, -103.5, -5348.7, -592.0, -4245.0, 385.0, -4769.6, -547.4 },
  { 10, 4099.0, 63.0, 3528.0, -402.0, 4670.0, 528.0, 3978.5, -217.4 },
  { 11, -1961.5, -4740.5, -2304.0, -5088.0, -1619.0, -4393.0, -1632.7, -4750.1 },
  { 12, 2079.9, 7896.0, 1629.2, 7524.4, 2530.6, 8267.6, 2115.9, 7461.8 },
  { 13, 1152.0, 4096.0, 783.2, 3772.0, 1520.8, 4420.0, 951.4, 4351.4 },
  { 14, -4032.0, 895.4, -4368.0, 535.4, -3696.0, 1255.4, -3755.6, 675.2 },
  { 15, -768.8, -7684.8, -1068.5, -8019.4, -469.1, -7350.1, -454.4, -8097.9 },
  { 16, -2479.5, -8399.5, -2855.5, -8767.5, -2103.5, -8031.5, -2381.8, -8063.7 },
  { 17, 307.4, 7710.3, -39.7, 7358.3, 654.5, 8062.3, 48.1, 7503.6 },
  { 18, -4240.0, 8256.0, -4594.8, 7904.0, -3885.2, 8608.0, -3945.6, 8074.0 },
  { 19, 1088.0, 2536.5, 637.0, 2142.0, 1539.0, 2931.0, 1284.8, 2886.6 },
  { 20, 8448.0, 1216.0, 8192.0, 896.0, 8704.0, 1536.0, 7999.4, 1098.8 },
  { 21, -8261.0, -431.2, -8645.0, -815.2, -7877.0, -47.2, -7976.3, -414.2 },
  { 22, -2963.9, 7412.0, -3318.7, 7060.0, -2609.0, 7764.0, -2687.9, 7678.5 },
  { 23, -2568.1, 3856.8, -2923.0, 3543.0, -2213.3, 4170.7, -2596.6, 4298.6 },
  { 24, 2671.2, -8370.4, 2343.8, -8714.1, 2998.6, -8026.8, 2770.8, -7976.7 },
  { 25, 1832.0, -4033.2, 1458.0, -4448.5, 2206.0, -3617.9, 1566.2, -4048.5 },
  { 26, -3940.0, 4945.5, -4260.0, 4550.3, -3620.0, 5340.7, -4287.1, 4940.7 },
  { 27, -7982.5, -1782.5, -8357.0, -2173.0, -7608.0, -1392.0, -7728.8, -1505.0 },
  { 28, 4399.2, -8290.4, 4071.8, -8634.1, 4726.6, -7946.8, 4218.1, -8065.3 },
}
local CAMP_REACH, CAMP_SLACK, CAMP_TOWER, CAMP_HERO = 1800, 500, 950, 1500
-- J: the camp it walks to or clears (0: none), whether it hit something of it, the clock of the last step (a smaller
-- one is another game), by camp id the clock until which it holds nothing
local J = { camp = 0, fought = false, clock = 0, emptyUntil = {} }

local function campDist(c, p) local dx, dy = c[2] - p.x, c[3] - p.y return math.sqrt(dx * dx + dy * dy) end
-- camps.h campAt: the camp whose box (+100) holds p, or whose wait point / centre is nearest within reach
local function campAt(p, reach)
  local best, bd = nil, reach
  for _, c in ipairs(CAMPS) do
    local d
    if p.x >= c[4] - 100 and p.x <= c[6] + 100 and p.y >= c[5] - 100 and p.y <= c[7] + 100 then d = 0
    else d = math.min(campDist(c, p), math.sqrt((c[8] - p.x) ^ 2 + (c[9] - p.y) ^ 2)) end
    if d < bd then best, bd = c, d end
  end
  return best
end
-- aw_farm_internal.h neutralsInSight, near the double (900 covers every use): camp creeps (team 4) in sight, none that
-- cannot be hit (units of the same class hover in the boxes)
local function neutralsNear(u, up, now)
  if F.neutralsAt == now and F.neutrals then return F.neutrals end
  local out = {}
  for _, c in ipairs(Try(NPCs.InRadius, up, 900, teamOf(u), Enum.TeamType.TEAM_BOTH, true, true) or {}) do
    local p = pos(c)
    if p and teamOf(c) == 4 and alive(c) and visible(c) and (Try(NPC.GetUnitName, c) or ""):find("^npc_dota_neutral_")
      and not hasState(c, MS().MODIFIER_STATE_ATTACK_IMMUNE) and not hasState(c, MS().MODIFIER_STATE_INVULNERABLE)
      and not hasState(c, MS().MODIFIER_STATE_OUT_OF_GAME) and not hasState(c, MS().MODIFIER_STATE_UNTARGETABLE)
      and not hasState(c, MS().MODIFIER_STATE_UNSELECTABLE) then
      out[#out + 1] = { u = c, p = p, hp = Try(Entity.GetHealth, c) or 0, max = Try(Entity.GetMaxHealth, c) or 0,
                        ancient = Try(NPC.IsAncient, c) == true }
    end
  end
  F.neutrals, F.neutralsAt = out, now
  return out
end
-- aw_farm_idle.cpp awFarmCreepsAround: a wave not under their tower within 2500, or our creep ahead within 1500
local function creepsAround(up, home)
  for _, w in ipairs(F.waves) do if w.unsafe ~= "enemy tower" and dist(w.c, up) <= 2500 then return true end end
  for _, o in ipairs(F.ours) do if dist(o.p, up) < 1500 and not behind(up, o.p, home) then return true end end
  return false
end
-- aw_farm_internal.h clearingCamp: a camp step, its last order an attack, camp creeps within 600
local function clearingCamp(u, s, up, now)
  if J.camp == 0 or s.fTarget == nil then return false end
  for _, n in ipairs(neutralsNear(u, up, now)) do if dist(n.p, up) < 600 then return true end end
  return false
end

-- aw_farm_items.cpp awFarmJungleMidas (Kir 2026-10-30 «мидасы хорошо фармило»): the neutral with the most max HP in
-- 570, no ancient (Midas cannot take one); once a second; 0.85 s for the cast with 2 s of life to spare
local function campMidas(u, s, now, life, neutrals, up)
  if not on(ui.aMidasD) or life == nil or life < 2.85 then return false end
  local m = useItem(u, s, "item_hand_of_midas", now, 1)
  if m == nil then return false end
  local best = nil
  for _, n in ipairs(neutrals) do
    if not n.ancient and dist(n.p, up) <= 570
      and (best == nil or n.max > best.max or (n.max == best.max and n.hp > best.hp)) then best = n end
  end
  if best == nil then return false end
  if not send(u, s, m, "item_hand_of_midas (camp, max hp " .. math.floor(best.max) .. ")", best.u, nil, now) then return false end
  G.midasAt[idx(best.u)] = now
  F.taskName, F.lockUntil = "midas in a camp", now + 0.85
  return true
end

-- aw_jungle.h step + awFarmJungle (lane): true when it has a step at a camp
local function jungle(u, s, now, life, up)
  local clock = Try(GameRules.GetDOTATime, false, false)
  if type(clock) ~= "number" then return false end
  if clock < J.clock - 5 then J = { camp = 0, fought = false, clock = 0, emptyUntil = {} } end
  J.clock = clock
  -- a new double starts with no camp of its own: the old one's camp / fight say nothing here (Codex FARM-004)
  if J.life ~= D.bornAt or now - (J.lastAt or -100) > 0.35 then
    J.life, J.camp, J.fought, J.members = D.bornAt, 0, false, {}
  end
  J.lastAt = now
  if clock < 60 then return false end
  local neutrals = neutralsNear(u, up, now)
  local weakest = nil
  for _, n in ipairs(neutrals) do if weakest == nil or n.hp < weakest.hp then weakest = n end end
  if weakest then
    local at = campAt(weakest.p, 900)
    if at and J.camp ~= at[1] then J.camp, J.members = at[1], {} end
    J.members = J.members or {}
    for _, n in ipairs(neutrals) do J.members[idx(n.u)] = n.u end
    J.fought = true
    if campMidas(u, s, now, life, neutrals, up) then return true end
    if on(ui.farmSpell) and not hasState(u, MS().MODIFIER_STATE_SILENCED) then
      local around = 0
      for _, n in ipairs(neutrals) do if dist(n.p, up) < 500 then around = around + 1 end end
      if around >= 3 and farmField(u, s, now, life, "magnetic field (camp)") then return true end
      local sp = (life == nil or life > 3.5) and sparkReady(u, s, now)
      if sp then
        if farmSpark(u, s, sp, weakest.p, "spark wraith (camp " .. J.camp .. ")", now) then
          F.lockUntil = now + 0.85
          return true
        end
        return false
      end
    end
    if not hasState(u, MS().MODIFIER_STATE_DISARMED) then farmAttack(u, s, weakest.u, now, "camp " .. J.camp) end
    return true
  end
  local current = nil
  for _, c in ipairs(CAMPS) do if c[1] == J.camp then current = c end end
  if current and campDist(current, up) < (J.fought and 600 or 250) then
    local resolved, count = true, 0
    for _, x in pairs(J.members or {}) do
      count = count + 1
      if Try(Entity.IsAlive, x) ~= false then resolved = false end
    end
    -- Missing visibility/invalid handles get only a short retry, never a minute-long empty claim.
    J.emptyUntil[current[1]] = count > 0 and resolved and (math.floor(clock / 60) + 1) * 60 or clock + 1
    current, J.members = nil, {}
  end
  local team, ms = teamOf(u), Try(NPC.GetMoveSpeed, u) or 300
  if ms <= 100 then ms = 300 end
  local function usableCamp(c, slack)
    local d = campDist(c, up)
    if clock < (J.emptyUntil[c[1]] or 0) or d > CAMP_REACH + slack then return false end
    for _, h in ipairs(F.heroes) do
      local hp = pos(h)
      if hp and campDist(c, hp) < CAMP_HERO then return false end
    end
    for _, t in ipairs(F.towers) do
      local tp = pos(t)
      if tp and teamOf(t) ~= team and campDist(c, tp) < CAMP_TOWER then return false end
    end
    return life == nil or d / ms + 6 <= life
  end
  if current and not usableCamp(current, CAMP_SLACK) then current = nil end
  if current == nil then
    local nd = math.huge
    for _, c in ipairs(CAMPS) do
      local d = campDist(c, up)
      if d < nd and usableCamp(c, 0) then current, nd = c, d end
    end
  end
  J.camp, J.fought = current and current[1] or 0, false
  if current == nil then return false end
  -- walking, nothing to hit: a combo takes it from as far as it walks (awFarmIdle)
  F.idleAt, F.idleReach = now, life and math.min(3000, math.max(1600, ms * (life - 4))) or 1600
  farmMove(u, s, Vector(current[2], current[3], up.z), now, "walks to camp " .. current[1])
  return true
end
-- the camp exception of the smart clone: switch on, no creeps around it or the camp it is clearing, a step there
local function campBetween(u, s, now, life, up, home)
  if not on(ui.farmCamps) then return false end
  if creepsAround(up, home) and not clearingCamp(u, s, up, now) then return false end
  return jungle(u, s, now, life, up)
end

-- aw_farm_idle.cpp awFarmNoWave (smart clone)
local function noWave(u, s, now, life, enemyNear, tp, home)
  if pushStep(u, s, now, life, home) then return end
  local up, team = pos(u), teamOf(u)
  if campBetween(u, s, now, life, up, home) then return end
  -- the nearest wave pickWave would take too: safe (no enemy tower or hero by it), and walking there leaves the life
  -- travel() asks (Codex FARM-001: a wave pickWave dropped for its life or a hero came back here as a long walk)
  local ms = math.max(150, Try(NPC.GetMoveSpeed, u) or 300)
  local nearest, nd = nil, math.huge
  for _, w in ipairs(F.waves) do
    if w.unsafe == nil and dist(w.c, up) < nd then nearest, nd = w, dist(w.c, up) end
  end
  local walkOk = nearest ~= nil and ((life == nil and nd <= 900) or (life ~= nil and nd / ms + 5 <= life))
  -- a TP lands with 9 s and more (12 s of life): with 9 it killed nothing and stood till it ended (bot logs)
  local tpOut = tp.ready and tp.bot and on(ui.farmTp) and not enemyNear and life ~= nil and life > 12
  if not tpOut then
    F.noTp = not on(ui.farmTp) and "TP switch off" or not tp.ready and tp.why or not tp.bot and "no Boots of Travel"
      or enemyNear and "an enemy hero within 1200 or a fight 4 s ago" or "life under 12 s or unknown"
  end
  if nearest and nd > 2500 and tpOut then
    local o = tpCreep(nearest.c)
    if o then farmTp(u, s, tp, o, o.p, "onto our creep by the nearest wave", now) return end
  end
  local goal, why = nil, nil
  local follow = on(ui.farmFollow)
  if nearest and nd <= 2500 and walkOk and not behind(up, nearest.c, home) then
    goal, why = nearest.c, "walks to the nearest wave"
  elseif follow then
    -- our creep within 1800, not back, not under an enemy tower fewer than 2 of ours tank
    local ours, od = nil, 1800
    for _, o in ipairs(F.ours) do
      local d = dist(o.p, up)
      local fits = (life == nil and d <= 900) or (life ~= nil and d / ms + 5 <= life)
      if fits and d < od and not behind(up, o.p, home) and not exposed(o.p, team, 150) then ours, od = o, d end
    end
    if ours then
      goal, why = ours.p, "walks to our creeps"
      if laneItems(u, s, now, life, "with creeps") then return end
    end
  end
  if why == nil and soloTower(u, s, now, life) then return end
  if why == nil and tpOut then
    local g = pushGroup(up, home, team, 2500, false)
    if g then farmTp(u, s, tp, g.creep, g.creep.p, "onto our creeps pushing a lane", now) return end
  end
  if why == nil and nearest and walkOk and home and dist(up, home) < 4000 and not behind(up, nearest.c, home) then
    goal, why = nearest.c, "out of the base to a wave"
  end
  -- v22: our most pushed group anywhere, behind it too: on foot, or a TP when walking is 4 s longer. With the follow
  -- switch off (a tester: after a mid wave it walked to top and back) only by TP; else it waits here for the next wave
  if why == nil and not follow then
    local g = tpOut and pushGroup(up, home, team, 2500, true)
    if g then farmTp(u, s, tp, g.creep, g.creep.p, "onto our most pushed creeps", now) return end
    F.idle = "waits for the next wave here"
  elseif why == nil then
    local g = pushGroup(up, home, team, 0, true)
    if g == nil then
      F.idle = "no group of ours anywhere safe"
    else
      local w = { c = g.c, n = g.n }
      w.tower, w.towerD = ourTower(g.c, team)
      local plan = travel(dist(up, g.c), w, life, math.max(150, Try(NPC.GetMoveSpeed, u) or 300), enemyNear, tp)
      if plan == nil then
        F.idle = "our creeps too far for its life"
      elseif plan.how ~= "walk" then
        farmTp(u, s, tp, plan.to, plan.at, "onto our most pushed creeps", now)
        return
      elseif dist(up, g.c) > 250 then
        goal, why = g.c, "walks to our most pushed creeps"
      end
    end
  end
  -- its last seconds with nothing it may finish (a tester: «with 4-5 s left it just stops»): an attack-move on to the
  -- nearest enemy creep or tower (no backdoor) it reaches before it ends - a hit or two beats standing
  if why == nil and life ~= nil and life < 7 and not hasState(u, MS().MODIFIER_STATE_DISARMED) then
    local reach = math.max(150, Try(NPC.GetMoveSpeed, u) or 300) * math.max(0, life - 0.5) + attackRange(u)
    local best, bd = nil, reach
    local function hitFits(x, d)
      return math.max(0, d - attackRange(u)) / ms + swingPoint(u) + flightTime(u, x) + 0.1 < life
    end
    for _, c in ipairs(F.enemies) do
      local p = pos(c)
      if p and alive(c) and dist(p, up) < bd and hitFits(c, dist(p, up)) and towerOver(p, team, 0) == nil and heroNear(p, 1000) == nil then
        best, bd = p, dist(p, up)
      end
    end
    for _, t in ipairs(F.towers) do
      local p = pos(t)
      if best == nil and p and teamOf(t) ~= team and alive(t) and not backdoor(t) and dist(p, up) < bd
        and hitFits(t, dist(p, up)) and not hasState(t, MS().MODIFIER_STATE_INVULNERABLE) and heroNear(p, 1200) == nil then best, bd = p, dist(p, up) end
    end
    if best then farmMove(u, s, best, now, "last seconds: attack-moves to the nearest enemy", 1, AMOVE) return end
  end
  if why == nil then
    -- once a life: why it neither flies nor walks
    if not F.lifeState.idleLogged then
      F.lifeState.idleLogged = true
      Note("farm: double idle: %s; %s; nearest wave %d away, life %.1f", F.idle or "nothing ahead", F.noTp or tp.why or "TP ready",
           nearest and math.floor(nd) or -1, life or -1)
    end
    -- nothing ahead and its last walk was back: it holds where it is until our next wave comes up
    if s.fGoal and behind(up, s.fGoal, home) then farmMove(u, s, up, now, "holds, nothing ahead", 0.5, HOLD, true)
    else F.taskName = "idle" end
    -- aw_farm_idle.cpp awFarmIdle: nothing to hit -> a combo takes it from as far as it walks with 4 s of life to spare
    local ms = math.max(100, Try(NPC.GetMoveSpeed, u) or 300)
    F.idleAt, F.idleReach = now, life and math.min(3000, math.max(1600, ms * (life - 4))) or 1600
    return
  end
  if dist(up, goal) > 250 then farmMove(u, s, goal, now, why) else F.taskName = why end
end

-- in its own field at the tower it hits (v24, a tester: a wave came, it walked out of the bubble to farm it, then hit
-- the tower from outside): while the field lasts it stays in it - a creep it kills from where it stands, else the tower
local function fieldHold(u, s, now)
  local up, ta = pos(u), F.towerAt
  if up == nil or ta == nil or now - ta.at > 1.5 or not alive(ta.t) or hasState(ta.t, MS().MODIFIER_STATE_INVULNERABLE)
    or backdoor(ta.t) or not inField(u, up, now) or dist(ta.p, up) > attackRange(u) + 250 or hasState(u, MS().MODIFIER_STATE_DISARMED) then
    return false
  end
  local reach, inReach = attackRange(u) + 50, {}
  for _, c in ipairs(F.enemies) do
    local p = pos(c)
    if p and alive(c) and dist(p, up) <= reach then inReach[#inReach + 1] = c end
  end
  local kill = #inReach > 0 and farmTarget(u, s, inReach, now) or nil
  if kill then
    farmAttack(u, s, kill, now, "last hit from its field", (shot(u, s, kill, now)))
    return true
  end
  ta.at = now
  farmAttack(u, s, ta.t, now, "hits the tower from its field")
  illusionsOn(u, ta.t, now)
  return true
end

-- aw_farm_world.cpp smart clone: the enemy hero to fight, nil for none
local function farmFight(u)
  if not on(ui.farmFight) or has(u, "modifier_teleporting") then return nil end
  local up, team = pos(u), teamOf(u)
  local weak = hpFrac(u) < 0.3
  local best, bestD = nil, math.huge
  for _, h in ipairs(F.heroes) do
    local hp = pos(h)
    local low, kept = hpFrac(h) <= 0.35, F.fight == idx(h)
    local d = hp and dist(up, hp) or math.huge
    if hp and targetable(h) and not (weak and not low) and (towerOver(hp, team, 150) == nil or (kept and low))
      and d <= (kept and 1600 or 1200) and d < bestD then
      best, bestD = h, d
    end
  end
  return best
end

-- aw_farm_actor.cpp awFarmActorTick for the double: its fight, the guards, then a wave or none
local function farmTick(me, u, s, now, loss, z, life, up)
  local team = teamOf(u)
  local home = HOME[team]
  if retireFarmTower(u, s, now) then return end
  local h = farmFight(u)
  if h then
    if F.fight ~= idx(h) then
      F.fight, s.attackSentAt, G.startAt = idx(h), nil, now
      Note("farm: double fights %s", heroName(h))
    end
    F.foughtAt, F.taskName, s.fLease, F.task = now, "fights " .. heroName(h), nil, nil
    step(u, s, false, me, h, now, loss, z)
    return
  elseif F.fight then
    F.fight, s.fTarget, F.why = nil, nil, nil
    Note("farm: double back to farming")
  end
  illusionsFollow(me, u, s, now)
  -- never a TP with an enemy hero within 1200, nor 4 s after a fight (he stepped into the fog and it went off mid-fight)
  local foe, fp = heroNear(up, 1200)
  local enemyNear = foe ~= nil or now - (F.foughtAt or -100) < 4
  -- an enemy tower shooting it: out of its reach first, whatever else - not the tower it hits alone (v22: from inside
  -- its own field, where the shots miss; it backs off itself under half HP with no field)
  for _, t in ipairs(F.towers) do
    local held = F.towerAt and idx(F.towerAt.t) == idx(t) and now - F.towerAt.at < 1.5 and inField(u, up, now)
      and not backdoor(t) and not hasState(t, MS().MODIFIER_STATE_INVULNERABLE)
    if teamOf(t) ~= team and idx(towerTarget(t)) == idx(u) and not held
      and not (F.solo and F.solo.i == idx(t) and now - F.solo.at < 0.5) then
      s.fLease, F.task = nil, nil
      farmMove(u, s, toward(pos(t), up, attackRange(t) + 220), now, "the tower shoots it, out of its reach", 0.5, MOVE, true)
      return
    end
  end
  -- an enemy hero within 900 it does not fight: 700 back from him (a conservative escape, not a fight)
  if foe and dist(fp, up) < 900 then
    local d = math.max(1, dist(up, fp))
    s.fLease, F.task = nil, nil
    farmMove(u, s, Vector(up.x + (up.x - fp.x) / d * 700, up.y + (up.y - fp.y) / d * 700, up.z), now,
             "steps back from " .. heroName(foe) .. " (not its fight)", 0.5, MOVE, true)
    return
  end
  if leaseHolds(s, now) then F.taskName = "its swing" return end
  local tp = tpState(u, s, now)
  F.tpWhy = (not on(ui.farmTp) and "TP switch off") or (not tp.ready and tp.why)
    or (enemyNear and "an enemy hero within 1200 or a fight 4 s ago") or (tp.bot and "TP ready") or "TP ready (no Boots: towers only)"
  if tpWatch(u, s, now) then return end
  if fieldHold(u, s, now) then return end
  local w = pickWave(me, u, now, life, enemyNear, tp, home)
  if w == nil then noWave(u, s, now, life, enemyNear, tp, home) return end
  -- a wave a walk away: a camp by the lane first only with no creeps around it (aw_farm_actor.cpp, v25)
  if dist(up, w.c) > 900 and campBetween(u, s, now, life, up, home) then return end
  if dist(up, w.c) > 900 then travelTo(u, s, w, now, life, enemyNear, tp, home) return end
  atWave(u, s, w, now, life)
end

local function farm(me, u, s, now, loss, z)
  F.live, F.dbl, F.loss, F.z = true, idx(u), loss, z
  F.waitReason = nil
  for ci, list in pairs(F.hits) do
    for i = #list, 1, -1 do if list[i].land < now - 0.3 then table.remove(list, i) end end
    if #list == 0 then F.hits[ci] = nil end
  end
  for i, cy in pairs(F.cycles) do
    if not alive(cy.src) or now > cy.next + cy.spa * 2 then F.cycles[i] = nil end
  end
  farmScan(me, now)
  -- one Tempest Double life: its Static sends, its logs once a life, its task
  if F.lifeState == nil or F.lifeOf ~= D.bornAt or F.actor ~= u then
    F.actor = u
    F.lifeOf, F.lifeState, F.task, F.images = D.bornAt, { static = 0, staticAt = 0 }, nil, {}
    F.tp, F.tpGo, F.mantaAt, F.mantaBefore, F.mantaOwner = false, nil, nil, nil, nil
    F.fight, F.foughtAt, F.lockUntil, F.towerAt, F.solo = nil, -100, 0, nil, nil
    F.idleAt, F.idleReach, F.illAt, F.followAt = -100, nil, -100, -100
    F.neutralsAt, F.neutrals, F.why, F.taskName = nil, nil, nil, nil
  end
  local life = lifeLeft(u, now)
  if life == nil and not F.lifeState.unknownLogged then
    F.lifeState.unknownLogged = true
    Note("farm: double expiry unknown: nearby tasks only")
  end
  -- channelling a TP (its modifier; another channel is not a TP): no order cuts it. Its end is a landing only near
  -- where it was sent (the creep it flew to may have walked: 1200); elsewhere it was cut (Codex FARM-003)
  if has(u, "modifier_teleporting") then
    local g = F.tpGo
    if g and g.unit == u and g.birth == D.bornAt then g.seen = true F.tp = true end
    F.taskName = "TP channel"
  elseif Try(NPC.IsChannellingAbility, u) == true then
    F.taskName = "channelling"
  else
    if F.tp then
      local g, up0 = F.tpGo, pos(u)
      local goal = g and (g.creep and alive(g.creep) and pos(g.creep) or g.at)
      local landed = g and g.seen and g.unit == u and g.birth == D.bornAt and g.from and goal and up0
        and dist(up0, goal) <= 1200 and dist(up0, g.from) > math.max(150, dist(g.from, goal) * 0.5)
      F.tp, F.task, s.fGoal, s.fTarget, s.fLease, F.why, F.tpGo = false, nil, nil, nil, nil, nil, nil
      Note("farm: double %s, picks its next task", landed and "landed" or "TP cut (not at its target)")
    end
    local up = pos(u)
    if now < D.pauseUntil then F.taskName, F.waitReason = "waits after your click", "manual control"
    elseif up and ready(u, s, now) and now >= (F.lockUntil or 0) then
      farmTick(me, u, s, now, loss, z, life, up)
      if F.taskName == "idle" then F.waitReason = "no safe task"
      elseif F.taskName == "at a wave, nothing to hit" then F.waitReason = "no attack target"
      elseif F.taskName == "disarmed" or F.taskName == "disarmed at a tower" then F.waitReason = "controlled" end
    else
      F.waitReason = not canAct(u) and "controlled" or pendingBusy(s, now) and "waiting for cast"
        or not guardOk(now) and "orders blocked" or "waiting"
    end
  end
  -- every 10 s: the task, and why no TP / why idle
  if now - F.logAt > 10 then
    F.logAt = now
    local unsafe = 0
    for _, x in ipairs(F.waves) do if x.unsafe then unsafe = unsafe + 1 end end
    Note("farm: task %s; %d wave(s) in sight (%d not the double's), life %.1f; %s%s%s", F.taskName or "none", #F.waves,
         unsafe, life or -1, F.tpWhy or "TP not read", F.noTp and ", no TP: " .. F.noTp or "",
         F.idle and ", idle: " .. F.idle or "")
    F.noTp, F.idle = nil, nil
  end
end

-- the landing of an enemy hero's TP: the teleport_end particle (its owner chain gives the hero), then its position
-- from the first update with one (as the community TP trackers read it)
local function tpHero(e)
  local cur = e
  for _ = 1, 3 do
    if cur == nil then return nil end
    if Try(NPC.IsHero, cur) == true or Try(Entity.IsHero, cur) == true then return cur end
    cur = Try(Entity.GetOwner, cur)
  end
  return nil
end
local function tpSpot(p)
  if p == nil or type(p.x) ~= "number" or type(p.y) ~= "number" or (math.abs(p.x) <= 32 and math.abs(p.y) <= 32) then
    return nil
  end
  return Vector(p.x, p.y, p.z or 0)
end
function Script.OnParticleCreate(d)
  if not F.live then return end  -- every particle of the match comes here: nothing to build when not farming
  Try(function()
    if not F.live or type(d) ~= "table" then return end
    local n = string.lower(tostring(d.name or ""))
    if n ~= "teleport_end" and not string.lower(tostring(d.fullName or "")):find("teleport_end", 1, true) then return end
    local h, me = tpHero(d.entityForModifiers or d.entity), Try(Heroes.GetLocal)
    if h == nil or me == nil or teamOf(h) == teamOf(me) or Try(NPC.IsIllusion, h) == true then return end
    F.tps, F.tpPtc = F.tps or {}, F.tpPtc or {}
    local x = F.tps[idx(h)] or { hero = h, at = Try(GameRules.GetGameTime) or 0 }  -- a seen channel keeps its guess
    x.p = x.p or tpSpot(d.position)
    F.tps[idx(h)] = x
    if d.index ~= nil and x.p == nil then F.tpPtc[d.index] = h end
  end)
end
local function tpLanding(d)
  if F.tpPtc == nil or next(F.tpPtc) == nil then return end  -- updates come for every particle, many a frame
  Try(function()
    if type(d) ~= "table" or F.tpPtc == nil or F.tps == nil then return end
    local h = F.tpPtc[d.index]
    local x, p = h and F.tps[idx(h)], tpSpot(d.position)
    if x and p then x.p, F.tpPtc[d.index] = p, nil end
  end)
end
function Script.OnParticleUpdate(d) tpLanding(d) end
function Script.OnParticleUpdateFallback(d) tpLanding(d) end
function Script.OnParticleUpdateEntity(d) tpLanding(d) end
function Script.OnParticleDestroy(d)
  if F.tpPtc == nil or next(F.tpPtc) == nil then return end
  Try(function() if F.tpPtc and type(d) == "table" then F.tpPtc[d.index] = nil end end)
end

return farm, addHit, flightTime, hitOn, swingPoint, attackTargetOf
end)()

-- The hook and boulder saves in a function of their own (the main chunk's 200 locals, see the farm above).
local defense = (function()
-- ------------------------------------------------------------- hook save --
-- hook_defense.cpp hookDefense + spells/hook_intercept.h (Kir 2026-11-01): an enemy Pudge's Meat Hook on the hero's
-- line. A free live double walks onto the line in front of him (its speed, turn and life left, the way clear); else
-- the hero's Tempest Double at the last safe moment, the double there 0.05 s before the tip touches it. The wait is
-- planned again each tick: a hero that left the line keeps his R. One answer a hook.
-- 7.41: hook speed 1600, width 100, range 1300, cast point 0.3; Tempest Double cast point 0.15.
local HOOK_SPEED, HOOK_RANGE, HOOK_RADIUS, HOOK_CP = 1600, 1300, 100, 0.3
local SUMMON_LEAD, DOUBLE_HULL, SPARE, TICK, ECHO_GUESS, TD_CP = 130, 24, 0.05, 1 / 30, 0.10, 0.15
-- the live double's walk: order slack, the margin it must beat the tip by, its lease after the tip, the longest lease
local MOVE_SLACK, INTERCEPT_MARGIN, LEASE_TAIL, LEASE_MAX = 0.12, 0.08, 0.12, 1.4
-- boulder_defense.cpp (Kir 2026-11-01 «Да, делай»): Rolling Boulder rolls 0.6 s after the cast, 1000/s for 800; over
-- a Stone Remnant 1600/s for 1600; radius 160. The double 200 in front: the stop's stun stays off the hero.
local ROLL_DELAY, ROLL_SPEED, ROLL_RANGE, ROCK_SPEED, ROCK_RANGE, ROLL_RADIUS, BOULDER_LEAD = 0.6, 1000, 800, 1600, 1600, 160, 200

-- H: hooks (phase seen at, flying by Pudge index, the one answered); BR: rolls by Earth Spirit index
local H = { phaseSeen = {}, flying = {}, handledAt = nil, saidAt = nil, waitAt = nil, clock = 0 }
local BR = { rolls = {}, handledAt = nil, saidAt = nil, waitAt = nil }

-- the delay to plan a save with (Codex INT-05: the fastest old echo is no promise once the ping grew): the middle of the
-- echoes of the last 2 minutes, never under the current round trip (twice the outgoing latency); the guess + the round
-- trip with none. The turn is not in it (saves add their own).
local function echoBest()
  local now = Try(GameRules.GetGameTime) or 0
  local list = {}
  for i = 1, math.min(ECHO.n, 8) do
    local e = ECHO[i]
    if type(e) == "table" and now - e.at < 120 then list[#list + 1] = e.v end
  end
  local rtt = 2 * math.min(0.3, math.max(0, Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_OUTGOING) or 0))
  if #list == 0 then return ECHO_GUESS + rtt end
  table.sort(list)
  return math.max(list[math.floor(#list / 2) + 1], rtt)
end
-- along the line from its origin, and how far off it
local function lineOf(h, p)
  local ux, uy = math.cos(h.dir), math.sin(h.dir)
  local dx, dy = p.x - h.origin.x, p.y - h.origin.y
  return dx * ux + dy * uy, math.abs(-dx * uy + dy * ux), ux, uy
end
-- the turn as the bot counts it: 0.03 s for each 0.7 rad (unknown facing: 0.1)
local function turnTime(u, p)
  local off = facingOff(u, p)
  return off == 9 and 0.1 or 0.03 * off / 0.7
end

-- aw_combo.h hookBlockPoint (no spawn delay): on the line 0.45 x the way short of the hero (120..250)
local function blockPoint(h, hero, now)
  local along, side, ux, uy = lineOf(h, hero)
  if along < 80 or along > h.range + 100 or side > h.radius + 24 + 20 then return nil end
  local s = along - math.max(120, math.min(250, 0.45 * along))
  if s < 60 or h.launchAt + s / h.speed - now < 0.03 then return nil end
  return Vector(h.origin.x + ux * s, h.origin.y + uy * s, hero.z)
end
-- hook_intercept.h planHookIntercept: the double there 0.08 s before the tip, within a 1.4 s lease and its life
local function interceptPlan(h, hero, dp, ms, dbl, life, now)
  if life == nil or life <= 0 or ms <= 0 or ms > 1000 then return nil end
  local goal = blockPoint(h, hero, now)
  if goal == nil then return nil end
  local d = dist(dp, goal)
  local arrive = d <= 16 and now or now + math.max(MOVE_SLACK, echoBest()) + turnTime(dbl, goal) + d / ms
  local tip = h.launchAt + math.max(0, (lineOf(h, goal)) - h.radius - DOUBLE_HULL) / h.speed
  local deadline = tip + LEASE_TAIL
  if tip - arrive < INTERCEPT_MARGIN or deadline <= now or deadline - now > LEASE_MAX or life <= deadline - now then
    return nil
  end
  return { goal = goal, deadline = deadline, margin = tip - arrive, d = d }
end
-- hook_intercept.h planHookSummon: `lead` in front of the hero on the line, there `spare` before the tip touches it
-- (radius + the double's hull short of its centre); half the spare left is still a fair chance, less wastes R
local function summonPlan(h, hero, now, delay, lead)
  local along, side, ux, uy = lineOf(h, hero)
  if along < 80 or along > h.range + 100 or side > h.radius + DOUBLE_HULL + 20 then return nil end
  local s = along - lead
  if s < 60 then return nil end
  local touch = math.max(0, s - h.radius - DOUBLE_HULL)
  local p = { point = Vector(h.origin.x + ux * s, h.origin.y + uy * s, hero.z), hitAt = h.launchAt + touch / h.speed,
              spawnAt = now + delay }
  p.sendIn = p.hitAt - SPARE - p.spawnAt
  if p.hitAt - p.spawnAt < 0.5 * SPARE then return nil end
  return p
end

-- the hero may cast Tempest Double: learned, ready, its mana, neither silenced, stunned nor hexed
local function tdReady(me, hs, now)
  local td = Try(NPC.GetAbility, me, "arc_warden_tempest_double")
  if td == nil or (Try(Ability.GetLevel, td) or 0) <= 0 or not ready(me, hs, now)
    or not usable(me, hs, td, now) then return nil end
  if hasState(me, MS().MODIFIER_STATE_SILENCED) or hasState(me, MS().MODIFIER_STATE_STUNNED)
    or hasState(me, MS().MODIFIER_STATE_HEXED) then return nil end
  return td
end
local function sayOnce(S, key, fmt, ...)
  if S.saidAt == key then return end
  S.saidAt = key
  Note(fmt, ...)
end

-- the summon in the last safe moment, shared by the hook and the boulder: planned without the turn, then with it
-- one double, one save at a time (Codex INT-06): a hook walk or an R for one threat holds the double until that threat
-- is past; another threat waits instead of a second R replacing the double already on the job
local function saveBusy(owner, key, enemy, now)
  return now < (D.saveUntil or -100) and (D.saveOwner ~= owner or D.saveKey ~= key or D.saveEnemy ~= enemy)
end
local function saveTake(owner, key, enemy, untilT)
  D.saveUntil, D.saveOwner, D.saveKey, D.saveEnemy = untilT, owner, key, enemy
end

local function summon(me, hs, h, now, lead, S, what, victimPos)
  local mp = pos(me)
  local echo = echoBest()
  local plan = summonPlan(h, victimPos or mp, now, echo + TD_CP + TICK, lead)
  if plan == nil then
    local along, side = lineOf(h, mp)
    if S == H and side < 144 and along > 0 and along < 1400 then sayOnce(S, h.key, "%s on us: too late for the double", what) end
    return
  end
  local turn = turnTime(me, plan.point)
  plan = summonPlan(h, victimPos or mp, now, echo + turn + TD_CP + TICK, lead)
  if plan == nil then sayOnce(S, h.key, "%s on us: too late for the double after turning (%.2f s)", what, turn) return end
  local td = tdReady(me, hs, now)
  if td == nil then sayOnce(S, h.key, "%s on us: Tempest Double not ready", what) return end
  local range = (Try(Ability.GetCastRange, td) or 700) + castBonus(me)
  if dist(mp, plan.point) > range then return end
  if saveBusy(S, h.key, h.enemy, now) then sayOnce(S, h.key, "%s on us: the double is on another save", what) return end
  if plan.sendIn > 0 then
    if S.waitAt ~= h.key then
      S.waitAt = h.key
      Note("%s on us: R waits %.2f s (hit on the double in %.2f s, echo %.3f, turn %.2f)", what, plan.sendIn,
           plan.hitAt - now, echo, turn)
    end
    return
  end
  if send(me, hs, td, "tempest double (" .. what .. " save)", nil, plan.point, now) then
    hs.pending.freeAt = nil
    hs.pending.onConfirm = function() S.handledAt, S.handledEnemy = h.key, h.enemy end
    hs.pending.onRefuse = function() if D.saveOwner == S and D.saveKey == h.key and D.saveEnemy == h.enemy then D.saveUntil = now end end
    saveTake(S, h.key, h.enemy, plan.hitAt + 0.3)
    hs.nextOrder = math.max(hs.nextOrder, now + 0.3)  -- the bot's busyUntil: nothing else cuts the cast
    Note("%s on us: R now, the double %d in front, due %.3f before the hit (echo %.3f, turn %.2f, %.2f s more)", what,
         math.floor(dist(plan.point, mp)), plan.hitAt - plan.spawnAt, echo, turn, plan.hitAt - now)
  end
end

-- the live double may take the hook: alive and not brand new, no lease, no cast of its own unanswered, free to walk
local function doubleFree(dbl, ds, now)
  if dbl == nil or ds == nil or not alive(dbl) or D.bornAt == nil or now - D.bornAt < 0.2 or now < D.hookLease then
    return false
  end
  return now >= ds.nextOrder and not pendingBusy(ds, now) and #ds.inflight == 0 and canAct(dbl)
    and not hasState(dbl, MS().MODIFIER_STATE_ROOTED) and not castingAt(dbl)
end
-- the way to the goal clear (GridNav, as the community scripts ask it; unreadable: taken as clear)
local function wayOpen(a, b) return dist(a, b) <= 1 or Try(function() return GridNav.IsTraversableFromTo(a, b, true) end) ~= false end

local function facing(e)
  local ep, f = pos(e), Try(Entity.GetForwardPosition, e, 100)
  if ep == nil or f == nil then return nil end
  return atan2(f.y - ep.y, f.x - ep.x), ep
end

-- First circle entry on the swept line, not merely the closest projected centre.
local function lineEntry(h, p, hull)
  local along, side = lineOf(h,p)
  local radius = h.radius + hull
  if side > radius then return nil end
  return along - math.sqrt(math.max(0,radius*radius-side*side))
end
-- First threatened allied hero; main wins only a tie, never a later impact behind an ally.
local function lineVictim(h, now, me, dbl)
  local best, at, entryBest = nil, nil, math.huge
  for _, u in ipairs(Try(Heroes.GetAll) or {}) do
    if alive(u) and u ~= dbl and teamOf(u) == teamOf(me) and Try(NPC.IsIllusion, u) == false
      and not has(u, DOUBLE_MOD) and targetable(u) and pos(u) then
      local entry = lineEntry(h,pos(u),Try(NPC.GetHullRadius,u) or DOUBLE_HULL)
      if entry and entry >= 0 and entry <= h.range and h.launchAt + entry / h.speed > now
        and (entry < entryBest or (entry == entryBest and u == me)) then best,at,entryBest=u,pos(u),entry end
    end
  end
  return best, at
end
local function earlierBlocker(h, point, me, dbl, now)
  local entryLimit = lineEntry(h,point,DOUBLE_HULL)
  for _, u in ipairs(Try(NPCs.GetAll) or {}) do
    if u ~= dbl and alive(u) and pos(u)
      and Try(NPC.IsStructure, u) ~= true and Try(NPC.GetUnitName, u) ~= "npc_dota_roshan" then
      local hero = Try(NPC.IsHero, u) == true
      local illusion = Try(NPC.IsIllusion, u) == true
      local creep = Try(NPC.IsLaneCreep, u) == true or (Try(NPC.IsCreep, u) == true and Try(NPC.IsAncient, u) == false)
      local genuine = has(u,DOUBLE_MOD)
      local valid = h.kind == "sharpshooter" and (genuine or hero and not illusion)
        or h.kind ~= "sharpshooter" and (hero or illusion or creep)
      if valid then
        local entry = lineEntry(h,pos(u),Try(NPC.GetHullRadius,u) or DOUBLE_HULL)
        if entry and entryLimit and entry > 0 and entry < entryLimit
          and h.launchAt + entry / h.speed > now then return true end
      end
    end
  end
  return false
end
local function releaseLine(S, now, key, enemy)
  if S.walkKey == key and S.walkEnemy == enemy then
    S.walkKey, S.walkEnemy, S.walkActor, S.walkBirth = nil,nil,nil,nil
  end
  if D.saveOwner == S and D.saveKey == key and D.saveEnemy == enemy then
    D.saveUntil, D.hookLease = now, now
  end
end
local function answerLine(S, h, me, hs, dbl, ds, now, what)
  if S.handledAt == h.key and S.handledEnemy == h.enemy then return end
  local victim, vp = lineVictim(h, now, me, dbl)
  if not victim then releaseLine(S, now, h.key, h.enemy) return end
  if victim ~= me and (now < (D.pauseUntil or -100) or has(me,"modifier_pudge_dismember")
    or has(me,"modifier_legion_commander_duel")) then releaseLine(S,now,h.key,h.enemy) return end
  local ownWalk = S.walkKey == h.key and S.walkEnemy == h.enemy and S.walkActor == dbl
    and S.walkBirth == D.bornAt and now < D.hookLease
  local movable = dbl and ds and alive(dbl) and now >= ds.nextOrder and canAct(dbl)
    and not hasState(dbl,MS().MODIFIER_STATE_ROOTED) and not castingAt(dbl)
    and not pendingBusy(ds,now) and #ds.inflight == 0
  if (ownWalk and movable or doubleFree(dbl,ds,now)) and not saveBusy(S,h.key,h.enemy,now) then
    local dp = pos(dbl)
    local plan = dp and interceptPlan(h,vp,dp,Try(NPC.GetMoveSpeed,dbl) or 0,dbl,lifeLeft(dbl,now),now)
    if plan and wayOpen(dp,plan.goal) and not earlierBlocker(h,plan.goal,me,dbl,now) then
      if not ownWalk or not S.walkGoal or dist(plan.goal,S.walkGoal)>40 then
        if not (direct(dbl,ORDER.move,nil,plan.goal,nil) or orderCall(NPC.MoveTo,dbl,plan.goal,false,false)) then return end
        D.ownAt=now
        ds.attackSentAt,ds.fTarget,ds.fGoal,ds.fLease=nil,nil,nil,nil
      end
      S.walkKey,S.walkEnemy,S.walkActor,S.walkBirth,S.walkGoal=h.key,h.enemy,dbl,D.bornAt,plan.goal
      D.hookLease=plan.deadline
      saveTake(S,h.key,h.enemy,plan.deadline)
      return
    end
  end
  if ownWalk then releaseLine(S,now,h.key,h.enemy) end
  local rPoint = summonPlan(h,vp,now,0,SUMMON_LEAD)
  if rPoint and not earlierBlocker(h,rPoint.point,me,nil,now) then
    summon(me,hs,h,now,SUMMON_LEAD,S,what,vp)
  end
end

local function hookTick(me, hs, dbl, ds, now)
  local team = teamOf(me)
  for _, e in ipairs(Try(Heroes.GetAll) or {}) do
    if Try(NPC.GetUnitName, e) == "npc_dota_hero_pudge" and teamOf(e) ~= team and alive(e) and Try(NPC.IsIllusion, e) ~= true then
      local i = idx(e)
      local hook = Try(NPC.GetAbility, e, "pudge_meat_hook")
      local phase = hook ~= nil and Try(Ability.IsInAbilityPhase, hook) == true
      local fly = H.flying[i]
      -- in flight it stays a threat until the tip has passed; a phase that ended with no cooldown was cancelled
      -- (a hook seen only as its projectile, e.g. from the fog, needs no cooldown read)
      local cd = hook and Try(Ability.GetCooldown, hook) or 0
      if not phase and (fly == nil or (not fly.seen and cd <= 0) or now > fly.launchAt + fly.range / fly.speed + 0.1) then
        H.phaseSeen[i], H.flying[i] = nil, nil
      else
        H.phaseSeen[i] = H.phaseSeen[i] or now
        local key, h = H.phaseSeen[i], fly
        if phase then
          local dir, ep = facing(e)
          if dir then
            -- the hook leaves at its phase start + 0.3 (the start read when sane, else when we first saw the phase)
            local cs = Try(Ability.GetCastStartTime, hook)
            local since = (type(cs) == "number" and cs > 0 and now - cs >= 0 and now - cs < 0.35) and now - cs or now - key
            h = { origin = ep, dir = dir, launchAt = now + HOOK_CP - since, speed = HOOK_SPEED, range = HOOK_RANGE,
                  radius = HOOK_RADIUS, key = key, enemy = i }
            H.flying[i] = h
          else
            h = nil
          end
        end
        if h then answerLine(H,h,me,hs,dbl,ds,now,"meat hook") end
      end
    end
  end
end

local SH = { shots = {} }
local function sharpEvent(data, me, now)
  local name = data.fullName
  if name ~= "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_projectile.vpcf"
    and name ~= "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_projectile.vpcf_c" then return false end
  local src, o, v = data.source, data.origin, data.velocity
  local function finite(x) return type(x)=="number" and x==x and x>-math.huge and x<math.huge end
  if not src or not alive(src) or idx(src)<=0 or Try(NPC.IsIllusion,src)~=false
    or (teamOf(src)~=2 and teamOf(src)~=3) or teamOf(src)==teamOf(me)
    or Try(NPC.GetUnitName,src)~="npc_dota_hero_hoodwink" or not o or not v
    or not finite(o.x) or not finite(o.y) or not finite(o.z) or not finite(v.x) or not finite(v.y) or not finite(v.z)
    or not finite(data.handle) or data.handle<0 or data.handle%1~=0
    or not finite(data.distance) or data.distance<=0 or data.distance>3001 then return false end
  local speed=math.sqrt(v.x*v.x+v.y*v.y)
  if math.abs(speed-2200)>1 and math.abs(speed-2750)>1 then return false end
  if data.acceleration and (not finite(data.acceleration.x) or not finite(data.acceleration.y)
    or math.abs(data.acceleration.x)+math.abs(data.acceleration.y)>1) then return false end
  if SH.shots[data.handle] then
    local old=SH.shots[data.handle];releaseLine(old,now,old.key,old.enemy)
  end
  SH.shots[data.handle]={kind="sharpshooter",origin=Vector(o.x,o.y,o.z),dir=atan2(v.y,v.x),speed=speed,
    range=data.distance,radius=125,key=data.handle,enemy=idx(src),source=src,context=G,
    created=now,launchAt=now,expires=now+data.distance/speed+.2}
  return true
end
local function sharpTick(me,hs,dbl,ds,now)
  for handle,h in pairs(SH.shots) do
    if not on(ui.sharpSave) or h.context~=G or now<h.created or now>=h.expires
      or idx(h.source)~=h.enemy or teamOf(h.source)==teamOf(me) then
      releaseLine(h,now,h.key,h.enemy);SH.shots[handle]=nil
    else answerLine(h,h,me,hs,dbl,ds,now,"Sharpshooter") end
  end
end
function Script.OnLinearProjectileDestroy(data)
  if type(data)~="table" then return end
  local h=SH.shots[data.handle]
  if h then releaseLine(h,Try(GameRules.GetGameTime) or h.expires,h.key,h.enemy);SH.shots[data.handle]=nil end
end

-- the hook's projectile (as the community hook blockers read it: source, origin, velocity): its exact way, and a
-- hook whose cast we never saw (Pudge in the fog) still gets an answer
function Script.OnLinearProjectileCreate(data)
  Try(function()
    if type(data) ~= "table" or not on(ui.enabled) then return end
    local me = Try(Heroes.GetLocal)
    if me == nil or Try(NPC.GetUnitName, me) ~= ARC then return end
    if on(ui.sharpSave) and sharpEvent(data,me,Try(GameRules.GetGameTime) or 0) then return end
    if not on(ui.hookSave) then return end
    local src, n = data.source, string.lower(tostring(data.fullName or data.name or ""))
    if type(src) == "userdata" or type(src) == "table" then
      if Try(NPC.GetUnitName, src) ~= "npc_dota_hero_pudge" then return end
    elseif not n:find("hook", 1, true) then
      return
    else
      src = nil
    end
    local o, v = data.origin, data.velocity
    if o == nil or v == nil or type(v.x) ~= "number" or type(v.y) ~= "number" or type(o.x) ~= "number"
      or type(o.y) ~= "number" or (math.abs(v.x) < 10 and math.abs(v.y) < 10) then return end
    if src == nil then  -- no source in the fog: the enemy Pudge nearest the origin
      local bd = math.huge
      for _, e in ipairs(Try(Heroes.GetAll) or {}) do
        local ep = pos(e)
        if ep and Try(NPC.GetUnitName, e) == "npc_dota_hero_pudge" and dist(ep, o) < bd then src, bd = e, dist(ep, o) end
      end
    end
    if src == nil or teamOf(src) == teamOf(me) then return end
    local i, now = idx(src), Try(GameRules.GetGameTime) or 0
    local dir, fly = atan2(v.y, v.x), H.flying[i]
    if fly and now - fly.launchAt < 0.4 then
      fly.dir, fly.origin, fly.seen = dir, Vector(o.x, o.y, o.z or 0), true
    else
      H.phaseSeen[i] = now
      H.flying[i] = { origin = Vector(o.x, o.y, o.z or 0), dir = dir, launchAt = now, speed = HOOK_SPEED,
                      range = HOOK_RANGE, radius = HOOK_RADIUS, key = now, enemy = i, seen = true }
    end
  end)
end

-- ---------------------------------------------------------- boulder save --
-- a Stone Remnant on the roll's way: faster and farther from there, planned as from the start (the double a little
-- early, never late)
local function stoneOnLine(h)
  for _, u in ipairs(Try(NPCs.GetAll) or {}) do
    local p = Try(NPC.GetUnitName, u) == "npc_dota_earth_spirit_stone" and alive(u) and pos(u)
    if p then
      local along, side = lineOf(h, p)
      if along > -ROLL_RADIUS and along < ROLL_RANGE and side < ROLL_RADIUS then return true end
    end
  end
  return false
end

-- Kir 2026-11-01: an Earth Spirit within 1200 rolling anywhere but at us (an escape, a gap close) -> the double appears on
-- his line ahead of the boulder
-- and stops it (a boulder stops on the first enemy hero it meets). The nearest point it can still beat the boulder to
-- (spawn = echo + turn + 0.15 + a tick), within Tempest Double's cast range; one R a roll.
local function stopRoll(me, hs, r, now, ep)
  local mp = pos(me)
  local along, side = lineOf(r, mp)
  if (along >= 0 and along <= r.range + 100 and side <= r.radius + DOUBLE_HULL + 20) or dist(mp, r.origin) > 1200 then
    return false  -- it rolls at us (summon() takes that), or too far to matter
  end
  local td = tdReady(me, hs, now)
  if td == nil or saveBusy(BR, r.key, r.enemy, now) or now < D.hookLease then return false end
  local reach = math.max(700, Try(Ability.GetCastRange, td) or 0) + castBonus(me) - 10
  local ux, uy = math.cos(r.dir), math.sin(r.dir)
  local function at(d) return Vector(r.origin.x + ux * d, r.origin.y + uy * d, mp.z) end
  local guess = turnTime(me, at(math.min(r.range, 300)))
  local spawn = now + echoBest() + guess + TD_CP + TICK
  local front = r.speed * math.max(0, spawn - r.launchAt) + r.radius + DOUBLE_HULL + 20
  for d = math.max(60, front), r.range, 25 do
    local p = at(d)
    local readyAt = now + echoBest() + turnTime(me, p) + TD_CP + TICK
    local required = r.speed * math.max(0, readyAt - r.launchAt) + r.radius + DOUBLE_HULL + 20
    if d >= required and dist(mp, p) <= reach then
      if send(me, hs, td, "tempest double (stops a rolling boulder)", nil, p, now) then
        hs.pending.freeAt = nil
        hs.pending.onConfirm = function() BR.handledAt = r.key end
        hs.pending.onRefuse = function() if D.saveOwner == BR and D.saveKey == r.key and D.saveEnemy == r.enemy then D.saveUntil = now end end
        saveTake(BR, r.key, r.enemy, now + (d - front) / r.speed + 0.5)
        hs.nextOrder = math.max(hs.nextOrder, now + 0.3)
        Note("rolling boulder (not at us): the double %d down his line, front at %d", math.floor(d), math.floor(front))
        return true
      end
      return false
    end
  end
  return false
end

local function boulderTick(me, hs, now)
  local team = teamOf(me)
  for _, e in ipairs(Try(Heroes.GetAll) or {}) do
    if Try(NPC.GetUnitName, e) == "npc_dota_hero_earth_spirit" and teamOf(e) ~= team and alive(e)
      and Try(NPC.IsIllusion, e) ~= true then
      local i = idx(e)
      local r = BR.rolls[i]
      if r == nil then
        -- the cast: his roll modifier (its start), else the cooldown just started
        local m = Try(NPC.GetModifier, e, "modifier_earth_spirit_rolling_boulder_caster")
        local made = m and Try(Modifier.GetCreationTime, m)
        local castAt = nil
        if type(made) == "number" and now >= made and now - made < ROLL_DELAY then
          castAt = made
        else
          local a = Try(NPC.GetAbility, e, "earth_spirit_rolling_boulder")
          local cd, len = a and Try(Ability.GetCooldown, a) or 0, a and Try(Ability.GetCooldownLength, a) or 0
          if len > 0 and cd > 0 and cd > len - 0.15 then castAt = now end
        end
        if castAt and facing(e) then
          r = { launchAt = castAt + ROLL_DELAY, speed = ROLL_SPEED, range = ROLL_RANGE, radius = ROLL_RADIUS }
          r.key, r.launchAt0, r.enemy = r.launchAt, r.launchAt, i
          BR.rolls[i] = r
        end
      end
      -- done: its range used up, or longer than any roll lasts (the longest: 1600 at 1000/s, 1.6 s, + slack)
      if r and (now > r.launchAt0 + (r.full or r.range) / ROLL_SPEED + 0.4 or (r.full and r.range <= 0)) then
        BR.rolls[i] = nil
      elseif r then
        local ep = pos(e)
        if now < r.launchAt then  -- winding up: from where he stands, the way he faces
          local dir = facing(e)
          if dir and ep then
            r.origin, r.dir = ep, dir
            local rock = stoneOnLine(r)
            r.speed, r.range = rock and ROCK_SPEED or ROLL_SPEED, rock and ROCK_RANGE or ROLL_RANGE
          end
        elseif ep and r.origin then
          -- rolling (Codex INT-04): the segment left from where he is now - its way from his last steps, its speed as
          -- measured (1000 or over a stone 1600), what is left of its range; standing 0.15 s after the start = stopped
          -- (a hero or the end): the roll is dropped. Its modifier's life is not read (UNKNOWN in this API).
          r.start = r.start or r.origin
          r.full = r.full or r.range
          if r.lastP and now - r.lastT >= 0.05 then
            local step = dist(ep, r.lastP)
            local v = step / (now - r.lastT)
            if now - r.launchAt0 > 0.15 and step < 3 then
              r.still = (r.still or 0) + (now - r.lastT)
            else
              r.still = 0
            end
            if v > 300 and v < 2000 then
              r.speed = v > 1300 and ROCK_SPEED or ROLL_SPEED
              if r.speed == ROCK_SPEED then r.full = math.max(r.full, ROCK_RANGE) end
            end
            if step > 20 then r.dir = atan2(ep.y - r.lastP.y, ep.x - r.lastP.x) end
            r.lastP, r.lastT = ep, now
          elseif r.lastP == nil then
            r.lastP, r.lastT = ep, now
          end
          if (r.still or 0) >= 0.15 then
            BR.rolls[i] = nil
            r = nil
          else
            r.origin, r.launchAt = ep, now
            r.range = math.max(0, r.full - dist(r.start, ep))
          end
        end
        if r and r.origin and r.dir and r.key ~= BR.handledAt and r.range > 0 then
          if not stopRoll(me, hs, r, now, ep) then
            summon(me, hs, r, now, BOULDER_LEAD, BR, r.speed > ROLL_SPEED and "rolling boulder (over a stone)" or "rolling boulder")
          end
        end
      end
    end
  end
end

-- Emergency target is the actual channel caster, never the unrelated combo target.
local channelPending = nil
local function channelInterrupt(me, hs, dbl, ds, now)
  if not on(ui.channelSave) then channelPending = nil return nil end
  if channelPending then
    local q = channelPending
    local current = q.isDouble and dbl or me
    if q.context ~= G or current ~= q.actor or not alive(current)
      or (q.isDouble and q.birth ~= D.bornAt) then
      channelPending = nil
      return nil
    end
    pendingBusy(q.state, now)
    if alive(q.caster) and Try(NPC.GetModifier, q.victim, "modifier_pudge_dismember") == q.mod
      and Try(NPC.GetChannellingAbility, q.caster) == q.ability and now < q.untilT then return idx(q.actor) end
    channelPending = nil
  end
  local choices = { { me, hs } }
  if dbl and ds and now >= (D.pauseUntil or 0) and now >= D.hookLease
    and D.bornAt and now - D.bornAt >= 0.2 then choices[#choices + 1] = { dbl, ds } end
  local best = nil
  for _, victim in ipairs(Try(Heroes.GetAll) or {}) do
    if alive(victim) and teamOf(victim) == teamOf(me) and Try(NPC.IsIllusion, victim) ~= true then
      local mod = Try(NPC.GetModifier, victim, "modifier_pudge_dismember")
      local caster = mod and Try(Modifier.GetCaster, mod)
      local ab = caster and Try(NPC.GetChannellingAbility, caster)
      if caster and alive(caster) and teamOf(caster) ~= teamOf(me) and visible(caster) and targetable(caster)
        and ab and Try(Ability.GetName, ab) == "pudge_dismember" and Try(NPC.IsChannellingAbility, caster) == true
        and Try(NPC.IsLinkensProtected, caster) ~= true and not has(caster, "modifier_item_lotus_orb_active")
        and Try(NPC.GetItem, caster, "item_mirror_shield", true) == nil then
        for _, choice in ipairs(choices) do
          local actor, state = choice[1], choice[2]
          if actor ~= victim and alive(actor) and ready(actor, state, now) and not castingAt(actor) then
            local immune = hasState(caster, MS().MODIFIER_STATE_MAGIC_IMMUNE)
              or (MS().MODIFIER_STATE_DEBUFF_IMMUNE ~= nil and hasState(caster, MS().MODIFIER_STATE_DEBUFF_IMMUNE))
              or has(caster, "modifier_black_king_bar_immune")
            -- Root is deliberately absent: it does not interrupt this channel.
            for _, spec in ipairs({ {"item_sheepstick",800,false}, {"item_abyssal_blade",150,true},
                                    {"item_orchid",900,false}, {"item_bloodthorn",900,false} }) do
              local it = not (immune and not spec[3]) and item(actor, spec[1]) or nil
              local ap, cp = pos(actor), pos(caster)
              local range = it and ((Try(Ability.GetCastRange, it) or spec[2]) + castBonus(actor)) or 0
              if it and ap and cp and dist(ap, cp) <= range and usable(actor, state, it, now) then
                local delay = (Try(NPC.GetTimeToFacePosition, actor, cp) or 0.1) + (Try(Ability.GetCastPoint, it) or 0)
                  + 2 * (Try(NetChannel.GetAvgLatency, Enum.Flow.FLOW_OUTGOING) or 0) + 0.05
                local left = modLeft(victim, "modifier_pudge_dismember", now)
                local rank = delay + (victim == me and 0 or 2)
                local life = math.huge
                if actor == dbl then life = lifeLeft(actor, now) end
                if life ~= nil and life > delay + 0.15 and (left <= 0 or delay < left)
                  and (best == nil or rank < best.rank) then
                  best = {actor=actor,state=state,item=it,caster=caster,victim=victim,mod=mod,ability=ab,rank=rank,delay=delay}
                end
              end
            end
          end
        end
      end
    end
  end
  if best then
    local b = best
    -- Re-read before dispatch: a completed channel is not an emergency cast target.
    if Try(NPC.GetChannellingAbility, b.caster) ~= b.ability
      or Try(NPC.GetModifier, b.victim, "modifier_pudge_dismember") ~= b.mod then return nil end
    if send(b.actor, b.state, b.item, "interrupt Dismember on ally", b.caster, nil, now) then
      b.state.pending.freeAt = nil
      channelPending = {actor=b.actor,state=b.state,caster=b.caster,victim=b.victim,mod=b.mod,ability=b.ability,
                        context=G,isDouble=b.actor==dbl,birth=D.bornAt,untilT=now+math.max(0.4,b.delay+0.25)}
      G.push = nil
      return idx(b.actor)
    end
  end
  return nil
end

-- every tick with the hero alive (the bot's dodge pass): the hook, then the boulder
return function(me, hs, dbl, ds, now)
  if now < H.clock - 5 then H.phaseSeen, H.flying, BR.rolls, channelPending = {}, {}, {}, nil end  -- another game
  H.clock = now
  local interruptActor = channelInterrupt(me, hs, dbl, ds, now)
  if interruptActor then return interruptActor end
  if not alive(me) or pos(me) == nil then return end
  if on(ui.hookSave) then hookTick(me, hs, dbl, ds, now) end
  if on(ui.boulderSave) then boulderTick(me, hs, now) end
  sharpTick(me,hs,dbl,ds,now)
end
end)()

-- The same ground ring / chevron / actor-to-target line as the native overlay.
-- Render-only geometry leaves no persistent particles behind on reload or disable.
local visuals = (function()
  local V = { targets = {}, clone = nil, at = -100 }
  local font, strongFont, retryAt, names = nil, nil, -100, {}
  local function text(ru, en) return langRu and ru or en end
  local function visibleUnit(u) return u ~= nil and alive(u) and visible(u) and pos(u) ~= nil end
  local function unitName(u)
    if u == nil then return "?" end
    if Try(NPC.IsLaneCreep, u) == true then return text("Крип", "Creep") end
    if Try(NPC.IsTower, u) == true then return text("Башня", "Tower") end
    local key = Try(NPC.GetUnitName, u) or "?"
    local id = tostring(langRu) .. key
    if names[id] then return names[id] end
    local value = Try(function() return GameLocalizer.Find("#" .. key) end)
    if type(value) ~= "string" or value == "" or value:sub(1, 1) == "#" then
      value = key:gsub("^npc_dota_hero_", ""):gsub("^npc_dota_", ""):gsub("_", " ")
    end
    names[id] = value
    return value
  end
  local function spellName(p)
    local key = p.key or ""
    local simple = {
      item_sheepstick = { "Хекс", "Hex" }, item_orchid = { "Орчид", "Orchid" },
      item_bloodthorn = { "Bloodthorn", "Bloodthorn" }, item_manta = { "Манта", "Manta" },
      item_hand_of_midas = { "Мидас", "Midas" }, item_force_staff = { "Форс", "Force Staff" },
      item_hurricane_pike = { "Пика", "Pike" }, arc_warden_magnetic_field = { "Купол", "Field" },
      arc_warden_spark_wraith = { "Спарк", "Spark Wraith" }, arc_warden_flux = { "Flux", "Flux" },
      item_tpscroll = { "Телепорт", "Teleport" }, item_travel_boots = { "Телепорт", "Teleport" },
      item_travel_boots_2 = { "Телепорт", "Teleport" },
    }
    local title = simple[key]
    if title then return text(title[1], title[2]) end
    local localized = Try(function() return GameLocalizer.Find("#DOTA_Tooltip_ability_" .. key) end)
    if type(localized) == "string" and localized ~= "" and localized:sub(1, 1) ~= "#" then return localized end
    return key:gsub("^item_", ""):gsub("_", " ")
  end
  local function detail(u, s, combo, now)
    if has(u, "modifier_teleporting") then return text("Телепортируется", "Teleporting") end
    for i = #(s and s.inflight or {}), 1, -1 do
      local p = s.inflight[i]
      if not p.confirmed and p.actor == u then
        local caption = text(p.inPhase and "Применяет " or "В очереди: ", p.inPhase and "Casting " or "Queued: ") .. spellName(p)
        return caption, p.target
      end
    end
    if not canAct(u) then return text("Под контролем", "Disabled") end
    local actual = Try(NPC.GetAttackTarget, u)
    if visibleUnit(actual) and Try(NPC.IsAttacking, u) == true then
      return text("Атакует", "Attacking"), actual
    end
    if on(ui.guard) and G.guardSince ~= nil then return tr("orders blocked") end
    if combo and visibleUnit(G.target) then
      return text("Выполняет комбо", "Executing combo"), G.target
    end
    if F.live and F.actor == u and on(ui.farm) and F.waitReason then return tr(F.waitReason) end
    if Try(NPC.IsRunning, u) == true then return text("Идёт к цели", "Moving to target") end
    if F.taskName == "its swing" then return text("Заканчивает атаку", "Finishing attack") end
    return on(ui.farm) and tr("waiting") or text("Готов", "Ready")
  end
  function V.clear()
    V.targets, V.clone, V.at = {}, nil, -100
    names = {}
  end
  function V.update(me, dbl, hs, ds, now, heroKey, held, pushing, leased, interruptActor)
    V.targets, V.clone, V.at = {}, nil, now
    local function add(target, actor, isClone)
      if not visibleUnit(target) then return end
      for _, t in ipairs(V.targets) do
        if t.unit == target then t.actors[#t.actors + 1] = actor return end
      end
      V.targets[#V.targets + 1] = { unit = target, actors = { actor }, clone = isClone }
    end
    if heroKey and visibleUnit(me) and not pushing and interruptActor ~= idx(me) then add(G.target, me, false) end
    if not visibleUnit(dbl) then return end
    local dp, tp = pos(dbl), G.target and pos(G.target)
    local join = not on(ui.farm) and math.huge
      or ((now - (F.idleAt or -100) < 1) and (F.idleReach or 1600) or 1600)
    local combo = tp ~= nil and targetable(G.target) and ((held and dist(dp, tp) <= join)
      or (now < G.afterUntil and now >= D.pauseUntil and dist(dp, tp) < 2000))
    if on(ui.linesOnly) then
      if not pushing and not leased and interruptActor ~= idx(dbl) then
        if combo then add(G.target, dbl, true)
        elseif F.live and F.actor == dbl then
          local actual = Try(NPC.GetAttackTarget, dbl)
          if actual and F.fight == idx(actual) then add(actual, dbl, true) end
        end
      end
      return
    end
    local mode, description, detailTarget = text("Клон", "Double"), nil, nil
    if pushing then description = text("Двойной толчок", "Paired push")
    elseif leased or interruptActor == idx(dbl) then description = text("Спасает союзника", "Saving an ally")
    elseif now < D.pauseUntil and not combo then description = tr("manual control")
    else
      description, detailTarget = detail(dbl, ds, combo, now)
      if combo then mode = mode .. text(" · комбо", " · combo") add(G.target, dbl, true)
      elseif F.live and F.actor == dbl then
        mode = mode .. text(" · фарм", " · farm")
        local actual = Try(NPC.GetAttackTarget, dbl)
        if actual and F.fight == idx(actual) then add(actual, dbl, true) end
      end
    end
    V.clone = { unit = dbl, title = mode, detail = description, target = detailTarget, life = D.life }
  end
  local function project(p)
    if p == nil or not Render or type(Render.WorldToScreen) ~= "function" then return nil end
    local ok, point, shown = pcall(Render.WorldToScreen, p)
    if ok and shown == true and point and type(point.x) == "number" and type(point.y) == "number" then return point end
  end
  local function head(u)
    local p = pos(u)
    if p then return project(Vector(p.x, p.y, p.z + (Try(NPC.GetHealthBarOffset, u) or 160))) end
  end
  local function line(a, b, color, width)
    if a and b then Try(Render.Line, a, b, color, width or 1.5) end
  end
  local function ring(p, radius, color, dashed)
    local previous = nil
    for i = 0, 28 do
      local angle = i * math.pi * 2 / 28
      local point = project(Vector(p.x + math.cos(angle) * radius, p.y + math.sin(angle) * radius, p.z))
      if not dashed or i % 2 == 0 then line(previous, point, color, 2) end
      previous = point
    end
  end
  local function tether(from, to, color)
    local a, b = project(from), project(to)
    if not a or not b then return end
    local dx, dy = b.x - a.x, b.y - a.y
    local count = math.max(1, math.min(32, math.ceil(math.sqrt(dx * dx + dy * dy) / 24)))
    for i = 0, count - 1 do
      local start, finish = i / count, (i + 0.58) / count
      line(Vec2(a.x + dx * start, a.y + dy * start), Vec2(a.x + dx * finish, a.y + dy * finish), color, 1.5)
    end
  end
  local function plate(anchor, title, subtitle, color, screen)
    if not anchor then return end
    local size = math.max(16, math.min(20, num(ui.cloneTextSize, 22) * 0.8))
    local a = Try(Render.TextSize, strongFont or font, size, title)
    local b = subtitle and Try(Render.TextSize, font, size - 1, subtitle)
    if not a then return end
    local w, h = math.max(a.x, b and b.x or 0) + 18, subtitle and size * 2 + 16 or size + 12
    local x = math.max(4, math.min(screen.x - w - 4, anchor.x - w / 2))
    local y = math.max(4, anchor.y - h - 10)
    Try(Render.FilledRect, Vec2(x, y), Vec2(x + w, y + h), Color(14, 17, 22, 225), 4)
    line(Vec2(x + 5, y + h), Vec2(x + w - 5, y + h), color, 2)
    Try(Render.Text, strongFont or font, size, title, Vec2(x + 9, y + 5), color)
    if subtitle then Try(Render.Text, font, size - 1, subtitle, Vec2(x + 9, y + size + 8), Color(240, 243, 248, 255)) end
  end
  local function cloneCard(anchor, row, color, screen)
    local size = math.max(16, math.min(30, num(ui.cloneTextSize, 22)))
    local small, actionSize = math.max(12, size * 0.59), math.max(14, size * 0.68)
    local target = row.target and visibleUnit(row.target) and row.target or nil
    local primary, action = target and unitName(target) or row.detail, target and row.detail or nil
    if row.target and not target then primary, action = text("Цель недоступна", "Target unavailable"), nil end
    local timer = type(row.life) == "number" and string.format("%d %s", math.ceil(math.max(0, row.life)), text("с", "s")) or nil
    local a = Try(Render.TextSize, strongFont or font, size, primary)
    local b = action and Try(Render.TextSize, font, actionSize, action)
    local titleSize = Try(Render.TextSize, font, small, row.title)
    local timerSize = timer and Try(Render.TextSize, font, small, timer)
    if not a or not titleSize then return end
    local w = math.max(210, a.x + 32, (b and b.x or 0) + 32,
      titleSize.x + (timerSize and timerSize.x + 28 or 0) + 32)
    local h = small + size + (action and actionSize + 5 or 0) + 29
    local x = math.max(6, math.min(screen.x - w - 6, anchor.x - w / 2))
    local y = math.max(6, anchor.y - h - 14)
    Try(Render.FilledRect, Vec2(x + 1, y + 3), Vec2(x + w + 1, y + h + 3), Color(0, 0, 0, 75), 7)
    Try(Render.FilledRect, Vec2(x, y), Vec2(x + w, y + h), Color(16, 21, 29, 244), 6)
    Try(Render.FilledRect, Vec2(x, y + 10), Vec2(x + 3, y + h - 10), color, 1)
    Try(Render.Text, font, small, row.title, Vec2(x + 16, y + 10), color)
    if timerSize then
      local tx = x + w - timerSize.x - 14
      Try(Render.Text, font, small, timer, Vec2(tx, y + 10), Color(174, 185, 199, 255))
    end
    local contentY = y + small + 18
    Try(Render.Text, strongFont or font, size, primary, Vec2(x + 16, contentY), Color(246, 249, 255, 255))
    if action then Try(Render.Text, font, actionSize, action, Vec2(x + 16, contentY + size + 5), Color(195, 207, 224, 255)) end
    line(Vec2(anchor.x, y + h), anchor, Color(115, 205, 255, 150), 1)
  end
  function V.draw()
    if not Render or type(Render.WorldToScreen) ~= "function" or not on(ui.enabled) then return end
    local me, now = Try(Heroes.GetLocal), Try(GameRules.GetGameTime) or 0
    if me == nil or Try(NPC.GetUnitName, me) ~= ARC or now < V.at or now - V.at > 0.6 then return end
    if on(ui.linesOnly) then
      if on(ui.targetLine) then
        for _, target in ipairs(V.targets) do
          if visibleUnit(target.unit) then
            for _, actor in ipairs(target.actors) do
              if visibleUnit(actor) then
                local tone = target.clone and Color(115, 205, 255, 185) or Color(255, 201, 74, 185)
                line(project(pos(actor)), project(pos(target.unit)), tone, 2)
              end
            end
          end
        end
      end
      return
    end
    if not on(ui.targetVisual) and not on(ui.cloneStatus) then return end
    if (not font or not strongFont) and (now >= retryAt or now < retryAt - 5) then
      retryAt = now + 5
      font = font or Try(Render.LoadFont, "Arial", 0, 500)
      strongFont = strongFont or Try(Render.LoadFont, "Arial", 0, 700)
    end
    local screen = Try(Render.ScreenSize)
    if not font or not screen then return end
    local gold, blue = Color(255, 201, 74, 240), Color(115, 205, 255, 240)
    local heads = {}
    if on(ui.targetVisual) then
      for _, target in ipairs(V.targets) do
        if visibleUnit(target.unit) then
          local p, h = pos(target.unit), head(target.unit)
          local color = target.clone and blue or gold
          ring(p, math.max(72, (Try(NPC.GetHullRadius, target.unit) or 24) + 40), color)
          if on(ui.targetLine) then
            for _, actor in ipairs(target.actors) do
              if visibleUnit(actor) then
                tether(pos(actor), p, target.clone and Color(115, 205, 255, 140) or Color(255, 201, 74, 140))
              end
            end
          end
          if on(ui.targetPredict) then
            local v = G.track[idx(target.unit)]
            if v and v.unit == target.unit and v.vx * v.vx + v.vy * v.vy > 3600 then
              ring(Vector(p.x + v.vx * 0.5, p.y + v.vy * 0.5, p.z), 45, color, true)
            end
          end
          if h then
            heads[#heads + 1] = h
            line(Vec2(h.x - 8, h.y - 14), Vec2(h.x, h.y - 6), color, 2.5)
            line(Vec2(h.x, h.y - 6), Vec2(h.x + 8, h.y - 14), color, 2.5)
            plate(Vec2(h.x, h.y - 20), text("Цель комбо", "Combo target"), nil, color, screen)
          end
        end
      end
    end
    local clone = V.clone
    if on(ui.cloneStatus) and clone and visibleUnit(clone.unit) then
      local h = head(clone.unit)
      if h then
        for _, other in ipairs(heads) do
          if math.abs(other.x - h.x) < 180 and math.abs(other.y - h.y) < 80 then h = Vec2(h.x, h.y - 58) break end
        end
        cloneCard(h, clone, blue, screen)
      end
    end
  end
  return V
end)()

-- ---------------------------------------------------------------- callbacks --
local CALM = { focused = false, incoming = false, near = 0, attackers = 0, spots = {} }

-- the menu at load, so it is there outside a match too (OnUpdate runs only in a game: a tester saw no tab in the
-- lobby, 2026-11-01); OnUpdate retries if the menu was not ready yet
local menuReady = buildMenu()
if menuReady then
  applyLanguage()
  Note("loaded %s; %s; source=%s", BUILD_ID, tostring(_VERSION), Try(function() return debug.getinfo(1, "S").source end) or "unknown")
  if on(ui.debug) then configReport("load") G.configShown = true end
end

function Script.OnUpdate()
  if not menuReady then
    menuReady = buildMenu()
    if not menuReady then return end
    Note("loaded %s; %s; source=%s", BUILD_ID, tostring(_VERSION), Try(function() return debug.getinfo(1, "S").source end) or "unknown")
  end
  applyLanguage()
  if on(ui.debug) and not G.configShown then configReport("debug enabled") end
  G.configShown = on(ui.debug)
  -- off, or not Arc: the callbacks have nothing to fill (Codex CR-06: off left them live with old entities)
  local me = Try(Heroes.GetLocal)
  local ours = on(ui.enabled) and me ~= nil and Try(NPC.GetUnitName, me) == ARC
  if not ours then F.live, F.tpPtc, F.tps = false, nil, nil visuals.clear() end
  if not on(ui.enabled) or Try(GameRules.IsPaused) == true then return end
  if not ours then G.target = nil status(tr("Waiting for Arc Warden")) return end
  local now = Try(GameRules.GetGameTime)
  if type(now) ~= "number" then return end
  if now < G.lastNow - 1 then reset() visuals.clear() end
  G.lastNow = now

  -- held with the hero dead too: the double fights alone. The double's own key (a tester, 2026-11-01): the double's
  -- combo on the target at the cursor, the hero left to you; with both keys down both fight
  local captured = Try(Input.IsInputCaptured) == true
  local heroKey = Try(function() return ui.key:IsDown() end) == true and not captured
  local doubleKey = ui.keyD ~= nil and Try(function() return ui.keyD:IsDown() end) == true and not captured
  local held = heroKey or doubleKey
  -- the auto farm's own key (a tester, 2026-11-01: «no separate key for farming»): each press flips the menu switch
  local farmKey = ui.farmKey ~= nil and Try(function() return ui.farmKey:IsDown() end) == true and not captured
  if farmKey and not G.farmKeyWas and ui.farm then
    Try(function() ui.farm:Set(not on(ui.farm)) end)
    Note("auto farm %s (key)", on(ui.farm) and "ON" or "OFF")
  end
  G.farmKeyWas = farmKey
  local pushing = false
  G.heroIn = heroKey
  if held and not G.wasHeld and G.target and alive(G.target) and now - G.releasedAt < 1 then
    Note("resume on %s", Try(NPC.GetUnitName, G.target) or "?")  -- a quick re-press goes on with the same run
  elseif held and (not G.wasHeld or G.target == nil or not alive(G.target)) then
    G.target, G.startAt = pickTarget(me), now
    freshFight()
    if G.target then Note("start on %s", Try(NPC.GetUnitName, G.target) or "?") end
  elseif held and targetMode() == 0 then
    -- another hero nearest the cursor for 0.15 s takes over (the locked modes keep the first pick until it dies)
    local c = cursorHero(me)
    if c and idx(c) ~= idx(G.target) then
      if G.cand ~= idx(c) then
        G.cand, G.candSince = idx(c), now
      elseif now - G.candSince >= 0.15 then
        G.target = c
        freshFight()
        Note("switch to %s  t=%.2f", Try(NPC.GetUnitName, c) or "?", now - G.startAt)
      end
    else
      G.cand = nil
    end
  elseif not held and G.wasHeld then
    G.afterUntil, G.releasedAt = now + num(ui.after, 3), now
    Note("released  t=%.2f", now - G.startAt)
  end
  G.wasHeld, G.held = held, held
  if not held and (now >= math.max(G.afterUntil, G.releasedAt + 1) or not alive(G.target)) then G.target = nil end

  local dbl = findDouble(me, now)
  trackDouble(me, dbl, now)
  local young = D.bornAt ~= nil and now - D.bornAt < 0.2  -- the game refuses orders to a brand-new double
  local hs = unitState(me)
  local hLoss, hz = hpLoss2s(me, hs, now), danger(me, now)
  G.heroFocused, G.heroLoss, G.heroAttackers, G.heroSpots = hz.focused, hLoss, hz.attackers, hz.spots
  local ds = dbl and unitState(dbl)
  local dLoss = ds and hpLoss2s(dbl, ds, now) or 0
  local dz = dbl and danger(dbl, now) or CALM
  pairCheck(me, dbl, now)
  -- the hook / boulder save first (the bot's dodge pass runs before the combo); a double walking onto a hook line is
  -- left alone by the combo and the farm until its lease ends
  local interruptActor = defense(me, hs, dbl, ds, now)
  if not interruptActor then
    pushing = pushTick(me, ui.push ~= nil and Try(function() return ui.push:IsDown() end) == true and not captured, now)
  end
  local leased = now < math.max(D.hookLease or -100, D.saveUntil or -100)
  local duelCast = dbl ~= nil and not leased and not (D.bornAt ~= nil and now - D.bornAt < 0.2) and duelSave(me, dbl, ds, now)

  local h = G.target
  local fight = h ~= nil and targetable(h)
  if fight then velocity(h, now) end
  if on(ui.debug) and held and h and now >= (G.debugAt or 0) then
    G.debugAt = now + 0.2
    local function unit(x, s)
      if x == nil or s == nil then return "-" end
      local hex = item(x, "item_sheepstick")
      local tp, xp = pos(h), pos(x)
      return string.format("hex %s cd %.1f d %d ready %s busy %s back %.1f",
        hex and (castable(x, hex) and "ok" or "no") or "none", hex and (Try(Ability.GetCooldown, hex) or -1) or -1,
        (tp and xp) and math.floor(dist(xp, tp)) or -1, tostring(ready(x, s, now)), tostring(pendingBusy(s, now)),
        hex and math.max(0, (s.backoff["item_sheepstick"] or 0) - now) or 0)
    end
    Note("dbg t=%.2f held %.2f (states %.2f, our mods %s) lastHold %.2f ago | hero: %s | double: %s",
      now - G.startAt, heldLeft(h),
      stateLeft(h, { MS().MODIFIER_STATE_STUNNED, MS().MODIFIER_STATE_HEXED, MS().MODIFIER_STATE_ROOTED }),
      tostring(holdModsLeft(h, now)), now - fightState(h, now).lastHoldAt, unit(me, hs), unit(dbl, ds))
  end
  -- the hero: its step, or only its saves while the target cannot be hit
  if heroKey and h and alive(me) and interruptActor ~= idx(me) and not pushing and ready(me, hs, now) then
    if fight then step(me, hs, true, dbl, h, now, hLoss, hz) else saves(me, hs, now, hLoss, hz) end
  end
  -- the double: its gift first; the combo while the key is held - from 1600 when it farms (aw_farm_actor.cpp
  -- cloneJoinReach; farther when it stands idle, see awFarmIdle), from anywhere with the farm off - within 2000 after it
  local inCombo = false
  if dbl then
    local dp, tp = pos(dbl), h and pos(h)
    local join = math.huge
    if on(ui.farm) then join = (now - (F.idleAt or -100) < 1) and (F.idleReach or 1600) or 1600 end
    inCombo = dp ~= nil and tp ~= nil and ((held and dist(dp, tp) <= join)
      or (fight and now < G.afterUntil and now >= D.pauseUntil and dist(dp, tp) < 2000))
  end
  -- Combo ownership survives a cast/ACK wait: farm must not take the actor between its steps.
  local dblBusy = duelCast or pushing or inCombo
  if dbl and interruptActor ~= idx(dbl) and not young and not leased and not duelCast and not pushing and ready(dbl, ds, now) then
    local gave = on(ui.gift) and gift(dbl, ds, me, now, dLoss)
    if not gave and inCombo then
      if fight then step(dbl, ds, false, me, h, now, dLoss, dz) else saves(dbl, ds, now, dLoss, dz) end
    end
    dblBusy = dblBusy or gave
    if dblBusy then ds.fTarget, ds.fGoal, ds.fOrder, ds.fMove = nil, nil, nil, nil end
  end
  if heroKey and fight and on(ui.units) then unitsJoin(me, dbl, h, now) end
  local farming = false
  local free = (not young and not leased and (not dbl or interruptActor ~= idx(dbl))) and dbl or nil
  if not held and not pushing then
    autoField(me, free, hs, ds, now)
    autoMidas(me, free, hs, ds, now)
  end
  -- with the key held the double far from the target goes on farming (the bot's join reach)
  do
    farming = free ~= nil and not dblBusy and on(ui.farm)
    if farming then
      local ok, err = pcall(farm, me, free, ds, now, dLoss, dz)
      if not ok then F.waitReason = "farm error" end
      if not ok and now - (F.errAt or -100) > 5 then F.errAt = now Note("farm error: %s", tostring(err)) end
    end
  end
  if not farming then F.live, F.fight = false, nil end
  G.farmMode = not dbl and "no double"
    or now < D.pauseUntil and "manual control"
    or leased and "saving" or pushing and "push" or dblBusy and "combo"
    or F.tp and "teleporting" or farming and (F.waitReason or (F.live and "farming")) or "waiting"
  visuals.update(me, dbl, hs, ds, now, heroKey, held, pushing, leased, interruptActor)

  if held and h == nil then status(tr("No enemy at the cursor"))
  elseif h then status(tr(held and "Combo on " or "Double on ") .. (Try(NPC.GetUnitName, h) or "?"):gsub("^npc_dota_hero_", ""))
  else status(tr("Ready")) end
end

do
  local font, retryAt, lastText, textSize = nil, -100, nil, nil
  function Script.OnDraw()
    visuals.draw()
    if on(ui.linesOnly) then return end
    if not on(ui.farmHud) or not Render or not Render.Text or not Render.ScreenSize then return end
    local me = Try(Heroes.GetLocal)
    if me == nil or Try(NPC.GetUnitName, me) ~= ARC then return end
    local enabled = on(ui.enabled) and on(ui.farm)
    local reason = not on(ui.enabled) and "script off"
      or Try(GameRules.IsPaused) == true and "paused" or G.farmMode or "waiting"
    local text = tr(enabled and "Auto farm: ON" or "Auto farm: OFF")
    if enabled or not on(ui.enabled) then text = text .. " | " .. tr(reason) end
    local now = Try(GameRules.GetGameTime) or 0
    if font == nil and (now >= retryAt or now < retryAt - 5) then
      retryAt = now + 5
      font = Try(Render.LoadFont, "Verdana", 0, 600)
    end
    if font == nil then return end
    Try(function()
      local screen = Render.ScreenSize()
      if lastText ~= text then
        textSize = Render.TextSize and Render.TextSize(font, 16, text) or nil
        lastText = text
      end
      local x, y = 20, math.floor(screen.y * 0.20)
      if Render.FilledRect then
        Render.FilledRect(Vec2(x - 8, y - 5), Vec2(x + (textSize and textSize.x or 360) + 8, y + 24), Color(16, 18, 23, 210), 4)
      end
      Render.Text(font, 16, text, Vec2(x, y), enabled and Color(120, 235, 155, 255) or Color(240, 145, 135, 255))
    end)
  end
end

-- Local external orders yield control of every addressed body; an identifier, not
-- the game-time tick, distinguishes our orders from a click in the same frame.
function Script.OnPrepareUnitOrders(data)
  Try(function()
    if type(data) ~= "table" or data.identifier == "arc_rage" then return end
    local player = Try(Players.GetLocal)
    if player == nil or data.player ~= player then return end
    local now = Try(GameRules.GetGameTime) or 0
    local me, dbl = Try(Heroes.GetLocal), G.double
    local units, seen = {}, {}
    if data.npc then units[#units + 1] = data.npc end
    if data.orderIssuer == Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS then
      for _, x in ipairs(Try(Player.GetSelectedUnits, player) or {}) do units[#units + 1] = x end
    elseif data.orderIssuer == Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY and me then
      units[#units + 1] = me
    end
    for _, x in ipairs(units) do
      local i = idx(x)
      if not seen[i] then
        seen[i] = true
        if x == me then D.playerAt, G.pushCancelAt, G.push = now, now, nil end
        if x == dbl then
          if num(ui.dPause, 2) > 0 then D.pauseUntil = now + num(ui.dPause, 2) end
          G.pushCancelAt, G.push = now, nil
        end
        if Try(NPC.IsIllusion, x) == true and Try(NPC.GetUnitName, x) == ARC then
          G.imageManual = G.imageManual or {}
          G.imageManual[i] = now + math.max(0.5, num(ui.dPause, 2))
        end
      end
    end
  end)
  return true
end

-- the farm's forecast (only while it runs): attack swings, attack projectiles, swings cut short, hits landed
local function attackSwing(data, u)
  local A, act = Enum.GameActivity, tonumber(data.activity or 0) or 0
  if A and (act == A.ACT_DOTA_ATTACK or act == A.ACT_DOTA_ATTACK2 or act == A.ACT_DOTA_ATTACK_EVENT) then return true end
  if string.lower(tostring(data.sequenceName or "")):find("attack", 1, true) then return true end
  return Try(NPC.IsAttacking, u) == true
end

function Script.OnUnitAnimation(data)
  Try(function()
    if not F.live or type(data) ~= "table" then return end
    local u = data.unit or data.npc
    if u == nil or not alive(u) or not attackSwing(data, u) then return end
    local now = Try(GameRules.GetGameTime) or 0
    local start = now - (tonumber(data.lag_compensation_time) or 0)
    local cp = tonumber(data.castpoint or data.castPoint) or 0
    if cp <= 0 then cp = swingPoint(u) end
    local spa = Try(NPC.GetSecondsPerAttack, u, false) or 1
    local ui_ = idx(u)
    if ui_ == F.dbl then
      local s = unitState(u)
      s.fRelease, s.fReady = start + cp, start + spa
    end
    -- a hero's swing may be cut at will: only its projectile counts (the double's own swing does)
    if Try(NPC.IsHero, u) == true and ui_ ~= F.dbl then return end
    local t = attackTargetOf(u)
    if t == nil or not alive(t) or Try(NPC.IsLaneCreep, t) ~= true then return end
    local ranged = Try(NPC.IsRanged, u) == true or Try(NPC.IsTower, u) == true
    local release = start + cp
    addHit(u, t, release + (ranged and flightTime(u, t) or 0), release, false)
    if ui_ ~= F.dbl then
      F.cycles[ui_] = { src = u, target = idx(t), next = start + spa, cp = cp, spa = spa, ranged = ranged, dmg = hitOn(u, t) }
    end
  end)
end

function Script.OnUnitAnimationEnd(data)
  Try(function()
    if not F.live or type(data) ~= "table" then return end
    local u = data.unit or data.npc
    if u == nil then return end
    local now, si = Try(GameRules.GetGameTime) or 0, idx(u)
    for _, list in pairs(F.hits) do
      for i = #list, 1, -1 do
        if list[i].src == si and not list[i].projectile and list[i].release > now then table.remove(list, i) end
      end
    end
    if Try(NPC.IsAttacking, u) ~= true then F.cycles[si] = nil end
  end)
end

function Script.OnProjectile(data)
  Try(function()
    if not F.live or type(data) ~= "table" or data.isAttack ~= true or data.source == nil or data.target == nil then return end
    local t = data.target
    if Try(NPC.IsLaneCreep, t) ~= true then return end
    local now = Try(GameRules.GetGameTime) or 0
    local land = tonumber(data.maxImpactTime) or 0
    if land <= now then
      local speed, a, b = tonumber(data.moveSpeed) or 0, pos(data.source), pos(t)
      if speed <= 0 or a == nil or b == nil then return end
      land = now + dist(a, b) / speed
    end
    -- the swing's guess gives way to the projectile itself
    local list, si = F.hits[idx(t)], idx(data.source)
    if list then
      for i = #list, 1, -1 do
        if list[i].src == si and not list[i].projectile and list[i].release <= now + 0.1 then table.remove(list, i) break end
      end
    end
    addHit(data.source, t, land, now, true)
  end)
end

function Script.OnEntityHurt(data)
  Try(function()
    if not F.live or type(data) ~= "table" or data.target == nil or data.source == nil or data.ability then return end
    local list = F.hits[idx(data.target)]
    if list == nil then return end
    local now, si, pick = Try(GameRules.GetGameTime) or 0, idx(data.source), nil
    for i, e in ipairs(list) do
      if e.src == si and e.land <= now + 0.2 and (pick == nil or e.land < list[pick].land) then pick = i end
    end
    if pick then table.remove(list, pick) end
  end)
end

function Script.OnGameEnd() visuals.clear() reset() end

return Script
