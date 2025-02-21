-- Set the namespace according to the map name.
local ns = {};
setmetatable(ns, {__index = _G});
layna_forest_south_west_script = ns;
setfenv(1, ns);

-- The map name, subname and location image
map_name = "Layna Forest"
map_image_filename = "data/story/common/locations/layna_forest.png"
map_subname = ""

-- The music file used as default background music on this map.
-- Other musics will have to handled through scripting.
music_filename = "data/music/house_in_a_forest_loop_horrorpen_oga.ogg"

-- c++ objects instances
local Map = nil
local EventManager = nil

-- the main character handler
local hero = nil

-- Dialogue sprites
local bronann = nil
local kalya = nil

-- the main map loading code
function Load(m)

    Map = m;
    EventManager = Map:GetEventSupervisor();
    Map:SetUnlimitedStamina(false);

    Map:SetMinimapImage("data/story/layna_forest/minimaps/layna_forest_south_west_minimap.png");

    _CreateCharacters();
    _CreateObjects();
    _CreateEnemies();

    -- Set the camera focus on hero
    Map:SetCamera(hero);
    -- This is a dungeon map, we'll use the front battle member sprite as default sprite.
    Map:SetPartyMemberVisibleSprite(hero);

    _CreateEvents();
    _CreateZones();

    -- Add clouds overlay
    Map:GetEffectSupervisor():EnableAmbientOverlay("data/visuals/ambient/clouds.png", 5.0, -5.0, true);

        -- Trigger the save point and spring speech event once
    if (GlobalManager:GetGameEvents():DoesEventExist("story", "kalya_speech_about_snakes_done") == false) then
        hero:SetMoving(false);
        hero:SetDirection(vt_map.MapMode.WEST);
        EventManager:StartEvent("Forest entrance dialogue about snakes", 200);
    end

    _HandleTwilight();
end

-- Handle the twilight advancement after the crystal scene
function _HandleTwilight()

    -- If the characters have seen the crystal, then it's time to make the twilight happen
    if (GlobalManager:GetGameEvents():GetEventValue("story", "layna_forest_crystal_event_done") < 1) then
        return;
    end

    Map:GetScriptSupervisor():AddScript("data/story/layna_forest/after_crystal_twilight.lua");
end

-- the map update function handles checks done on each game tick.
function Update()
    -- Check whether the character is in one of the zones
    _CheckZones();
end

-- Character creation
function _CreateCharacters()
    -- Default hero and position
    hero = CreateSprite(Map, "Bronann", 124, 85, vt_map.MapMode.GROUND_OBJECT);
    hero:SetDirection(vt_map.MapMode.WEST);
    hero:SetMovementSpeed(vt_map.MapMode.NORMAL_SPEED);

    if (GlobalManager:GetMapData():GetPreviousLocation() == "from_layna_forest_NW") then
        hero:SetPosition(54, 4);
        hero:SetDirection(vt_map.MapMode.SOUTH);
    end

    bronann = CreateSprite(Map, "Bronann", 0, 0, vt_map.MapMode.GROUND_OBJECT);
    bronann:SetDirection(vt_map.MapMode.WEST);
    bronann:SetMovementSpeed(vt_map.MapMode.NORMAL_SPEED);
    bronann:SetCollisionMask(vt_map.MapMode.NO_COLLISION);
    bronann:SetVisible(false);

    kalya = CreateSprite(Map, "Kalya", 0, 0, vt_map.MapMode.GROUND_OBJECT);
    kalya:SetDirection(vt_map.MapMode.WEST);
    kalya:SetMovementSpeed(vt_map.MapMode.NORMAL_SPEED);
    kalya:SetCollisionMask(vt_map.MapMode.NO_COLLISION);
    kalya:SetVisible(false);
end

function _CreateObjects()
    local object = nil
    local npc = nil
    local event = nil

    -- Info sign
    object = CreateObject(Map, "Wood sign info", 120, 82, vt_map.MapMode.GROUND_OBJECT)
    object:SetEventWhenTalking("Info about status effects")
    dialogue = vt_map.SpriteDialogue.Create();
    text = vt_system.Translate("Did you know?\nSpecial attacks can trigger effects decreasing enemy defense, stamina, attack, ...\nThe enemy can do the same. For instance, snakes can stun you with their attacks.");
    dialogue:AddLine(text, nil);
    event = vt_map.DialogueEvent.Create("Info about status effects", dialogue)

    -- Only add the squirrels and butterflies when the night isn't about to happen
    if (GlobalManager:GetGameEvents():GetEventValue("story", "layna_forest_crystal_event_done") < 1) then

        npc = CreateSprite(Map, "Butterfly", 42, 18, vt_map.MapMode.GROUND_OBJECT);
        npc:SetCollisionMask(vt_map.MapMode.NO_COLLISION);
        event = vt_map.RandomMoveSpriteEvent.Create("Butterfly1 random move", npc, 1000, 1000);
        event:AddEventLinkAtEnd("Butterfly1 random move", 4500); -- Loop on itself

        EventManager:StartEvent("Butterfly1 random move");

        npc = CreateSprite(Map, "Butterfly", 12, 30, vt_map.MapMode.GROUND_OBJECT);
        npc:SetCollisionMask(vt_map.MapMode.NO_COLLISION);
        event = vt_map.RandomMoveSpriteEvent.Create("Butterfly2 random move", npc, 1000, 1000);
        event:AddEventLinkAtEnd("Butterfly2 random move", 4500); -- Loop on itself

        EventManager:StartEvent("Butterfly2 random move", 2400);

        npc = CreateSprite(Map, "Butterfly", 50, 25, vt_map.MapMode.GROUND_OBJECT);
        npc:SetCollisionMask(vt_map.MapMode.NO_COLLISION);
        event = vt_map.RandomMoveSpriteEvent.Create("Butterfly3 random move", npc, 1000, 1000);
        event:AddEventLinkAtEnd("Butterfly3 random move", 4500); -- Loop on itself

        EventManager:StartEvent("Butterfly3 random move", 1050);

        npc = CreateSprite(Map, "Butterfly", 40, 30, vt_map.MapMode.GROUND_OBJECT);
        npc:SetCollisionMask(vt_map.MapMode.NO_COLLISION);
        event = vt_map.RandomMoveSpriteEvent.Create("Butterfly4 random move", npc, 1000, 1000);
        event:AddEventLinkAtEnd("Butterfly4 random move", 4500); -- Loop on itself

        EventManager:StartEvent("Butterfly4 random move", 3050);

        npc = CreateSprite(Map, "Squirrel", 18, 24, vt_map.MapMode.GROUND_OBJECT);
        -- Squirrels don't collide with the npcs.
        npc:SetCollisionMask(vt_map.MapMode.WALL_COLLISION);
        npc:SetSpriteAsScenery(true);
        event = vt_map.RandomMoveSpriteEvent.Create("Squirrel1 random move", npc, 1000, 1000);
        event:AddEventLinkAtEnd("Squirrel1 random move", 4500); -- Loop on itself

        EventManager:StartEvent("Squirrel1 random move");

        npc = CreateSprite(Map, "Squirrel", 40, 14, vt_map.MapMode.GROUND_OBJECT);
        -- Squirrels don't collide with the npcs.
        npc:SetCollisionMask(vt_map.MapMode.WALL_COLLISION);
        npc:SetSpriteAsScenery(true);
        event = vt_map.RandomMoveSpriteEvent.Create("Squirrel2 random move", npc, 1000, 1000);
        event:AddEventLinkAtEnd("Squirrel2 random move", 4500); -- Loop on itself

        EventManager:StartEvent("Squirrel2 random move", 1800);
    end

    -- Trees array
    local map_trees = {
    --  right entrance upper side
    { "Tree Small3", 126, 82 },
    { "Tree Small4", 121, 81 },
    { "Tree Small3", 117, 80 },
    { "Tree Small5", 114, 78.2 },
    { "Tree Small3", 110, 81 },
    { "Tree Small3", 113, 75.8 },
    { "Tree Small6", 108, 75 },
    { "Tree Small3", 103.5, 76 },
    { "Tree Small5", 100, 74 },
    { "Tree Small3", 95, 73 },
    { "Tree Small6", 90, 70 },
    { "Tree Small3", 89, 67 },
    { "Tree Small5", 85, 66 },
    { "Tree Small3", 87.2, 70.2 },
    { "Tree Small4", 81, 63 },
    { "Tree Small4", 78, 61 },
    { "Tree Small3", 75, 59 },
    { "Tree Small5", 70, 60 },
    { "Tree Small6", 65, 61 },
    { "Tree Small5", 67, 65 },
    { "Tree Small4", 65, 57 },
    { "Tree Small5", 62, 56 },
    { "Tree Small3", 57, 55.5 },
    { "Tree Small6", 56, 54 },
    { "Tree Small3", 51, 55 },
    { "Tree Small5", 47, 56 },
    { "Tree Small3", 46, 53 },
    { "Tree Small5", 43, 57 },
    { "Tree Small4", 39, 59 },

    -- bottom side
    { "Tree Small3", 127, 93 },
    { "Tree Small6", 124, 92 },
    { "Tree Small3", 121, 94 },
    { "Tree Small4", 125, 96 },
    { "Tree Small3", 119, 97 },
    { "Tree Small5", 114, 93 },
    { "Tree Small3", 111, 92.2 },
    { "Tree Small6", 107, 94 },
    { "Tree Small3", 103, 96 },
    { "Tree Small4", 99, 97 },
    { "Tree Small3", 95, 93 },
    { "Tree Small5", 91, 94.2 },
    { "Tree Small4", 87, 92.2 },
    { "Tree Small3", 83, 97 },
    { "Tree Small6", 79, 96 },
    { "Tree Small5", 94, 96 },
    { "Tree Small3", 87, 95 },
    { "Tree Small6", 115, 95 },
    { "Tree Small3", 73, 93 },
    { "Tree Small6", 63, 92 },
    { "Tree Small3", 75, 95 },
    { "Tree Small6", 56, 92 },
    { "Tree Small3", 53, 93 },
    { "Tree Small5", 50, 95 },
    { "Tree Small3", 60, 97 },
    { "Tree Small4", 48, 96 },
    { "Tree Small3", 44, 95 },
    { "Tree Small5", 40, 94 },
    { "Tree Small3", 31, 90 },
    { "Tree Small5", 22, 93 },
    { "Tree Small3", 18, 95 },
    { "Tree Small6", 14, 96 },
    { "Tree Small3", 10, 94 },
    { "Tree Small4", 6, 97 },
    { "Tree Small4", 2, 99 },

    -- then left side
    { "Tree Small3", 40, 62 },
    { "Tree Small4", 39, 65 },
    { "Tree Small3", 34, 67 },
    { "Tree Small5", 33, 70 },
    { "Tree Small3", 29, 72 },
    { "Tree Small6", 25, 70.2 },
    { "Tree Small3", 15, 71 },
    { "Tree Small5", 14, 65 },

    -- all in the way
    { "Tree Small3", 49, 62 },
    { "Tree Small4", 60, 91 },
    { "Tree Small3", 63, 89 },
    { "Tree Small5", 68, 93.2 },
    { "Tree Small6", 79, 92 },
    { "Tree Small5", 73, 91 },
    { "Tree Small4", 114, 85 },
    { "Tree Small3", 91, 92 },
    { "Tree Small4", 90.8, 83 },
    { "Tree Small5", 87, 82 },
    { "Tree Small6", 74, 74 },
    { "Tree Small5", 64, 71 },
    { "Tree Small4", 102, 83 },
    { "Tree Small3", 108, 92 },
    { "Tree Small4", 67, 77 },
    { "Tree Small3", 21, 68 },
    { "Tree Small6", 17, 67 },
    { "Tree Small5", 36, 91 },
    { "Tree Small4", 26, 92 },
    { "Tree Small3", 19, 87 },
    { "Tree Small4", 32, 80 },
    { "Tree Small5", 26, 78 },
    { "Tree Small3", 39, 81 },

    -- left map border
    { "Tree Small4", 0, 93 },
    { "Tree Small3", -1, 89 },
    { "Tree Small4", 1, 84 },
    { "Tree Small4", 0, 79 },
    { "Tree Small5", -2, 75 },
    { "Tree Small5", 0, 69 },
    { "Tree Small3", 1, 64 },
    { "Tree Small6", 0, 58 },
    { "Tree Small6", -1, 53 },
    { "Tree Small5", 0, 48 },
    { "Tree Small5", -2, 44 },
    { "Tree Small4", 1, 39 },
    { "Tree Small3", 0, 34 },
    { "Tree Small4", -1, 29 },
    { "Tree Small5", 0, 24 },
    { "Tree Small6", -2, 20 },
    { "Tree Small5", -1, 16 },
    { "Tree Small6", 0, 11 },
    { "Tree Small4", 1, 7 },
    { "Tree Small3", 2, 2 },

    -- uper map border
    { "Tree Small3", 5, 4 },
    { "Tree Small4", 9, 3 },
    { "Tree Small5", 13, 2 },
    { "Tree Small6", 17, 1 },
    { "Tree Small5", 21, 3 },
    { "Tree Small6", 25, 4 },
    { "Tree Small5", 29, 5 },
    { "Tree Small3", 34, 4.2 },
    { "Tree Small4", 38, 2 },
    { "Tree Small5", 42, 1 },
    { "Tree Small6", 46, 3 },
    { "Tree Small4", 50, 2 },

    -- right part of path
    { "Tree Small3", 13, 61 },
    { "Tree Small4", 14, 58 },
    { "Tree Small3", 13, 55 },
    { "Tree Small4", 15, 52 },
    { "Tree Small5", 16, 50 },
    { "Tree Small3", 19, 48 },
    { "Tree Small5", 22, 47 },
    { "Tree Small6", 25, 44 },
    { "Tree Small5", 27, 42 },
    { "Tree Small4", 29, 39 },
    { "Tree Small3", 28, 35 },
    { "Tree Small5", 29, 31 },
    { "Tree Small4", 30, 28 },
    { "Tree Small3", 32, 24 },
    { "Tree Small6", 36, 23 },
    { "Tree Small6", 40, 24.2 },
    { "Tree Small4", 45, 25 },
    { "Tree Small5", 50, 26 },
    { "Tree Small4", 54, 23 },
    { "Tree Small3", 57, 20 },
    { "Tree Small6", 58, 17 },
    { "Tree Small5", 59, 14 },
    { "Tree Small3", 60, 11 },
    { "Tree Small4", 61, 8 },
    { "Tree Small3", 62, 5 },
    { "Tree Small5", 64, 2 },

    -- missing trees
    { "Tree Small6", 124, 77 },
    { "Tree Small4", 128, 74 },
    { "Tree Small3", 130, 70 },
    { "Tree Small3", 116, 73 },
    { "Tree Small6", 119, 74.2 },
    { "Tree Small5", 123, 72 },
    { "Tree Small6", 110, 70 },
    { "Tree Small5", 105, 73.2 },
    { "Tree Small5", 98, 71 },
    { "Tree Small4", 94, 69 },
    { "Tree Small6", 102, 68 },
    { "Tree Small3", 113, 67 },
    { "Tree Small3", 104, 66 },
    { "Tree Small3", 119, 66 },
    { "Tree Small6", 97, 63 },
    { "Tree Small4", 30, 97 },
    { "Tree Small6", 34, 95 },
    { "Tree Small4", 92, 62 },
    { "Tree Small6", 84, 59 },
    { "Tree Small4", 79, 56 },
    { "Tree Small6", 72, 54 },
    { "Tree Small3", 67, 53 },
    { "Tree Small6", 59, 52 },
    { "Tree Small6", 88, 60 },
    { "Tree Small6", 100, 61 },
    { "Tree Small4", 107, 64 },
    { "Tree Small6", 94, 58 },
    { "Tree Small6", 87, 53 },
    { "Tree Small6", 82, 52 },
    { "Tree Small5", 75, 50 },
    { "Tree Small6", 63, 51 },
    { "Tree Small6", 53, 49 },
    { "Tree Small4", 91, 52 },
    { "Tree Small6", 68, 47 },
    { "Tree Small6", 57, 46 },
    { "Tree Small6", 49, 48 },
    { "Tree Small6", 40, 51 },
    { "Tree Small3", 44, 47 },
    { "Tree Small6", 37, 53 },
    { "Tree Small6", 34, 56 },
    { "Tree Small6", 35, 60 },
    { "Tree Small4", 31, 63 },
    { "Tree Small6", 26, 65 },
    { "Tree Small6", 34, 49 },
    { "Tree Small5", 30, 58 },
    { "Tree Small6", 27, 59 },
    { "Tree Small6", 19, 62 },
    { "Tree Small6", 30, 50 },
    { "Tree Small4", 22, 58 },
    { "Tree Small6", 17, 56 },
    { "Tree Small6", 22, 51 },
    { "Tree Small4", 25, 49 },
    { "Tree Small6", 28, 45 },
    { "Tree Small6", 32, 42.2 },
    { "Tree Small4", 33, 38 },
    { "Tree Small6", 32, 35.2 },
    { "Tree Small5", 35, 30 },
    { "Tree Small6", 34, 27 },
    { "Tree Small4", 36, 43 },
    { "Tree Small6", 41, 40 },
    { "Tree Small2", 36, 36 },
    { "Tree Small6", 39, 33 },
    { "Tree Small1", 40, 29 },
    { "Tree Small6", 44, 28 },
    { "Tree Small2", 43, 32 },
    { "Tree Small6", 48, 30 },
    { "Tree Small5", 54, 27 },
    { "Tree Small6", 46, 34 },
    { "Tree Small3", 50, 33 },
    { "Tree Small3", 53, 31 },
    { "Tree Small3", 58, 25 },
    { "Tree Small6", 61, 23 },
    { "Tree Small4", 62, 16 },
    { "Tree Small5", 55, 35 },
    { "Tree Small6", 58, 32 },
    { "Tree Small4", 63, 27 },
    { "Tree Small6", 66, 17 },
    { "Tree Small5", 62, 34 },
    { "Tree Small4", 67, 29 },
    { "Tree Small6", 69, 18 },
    { "Tree Small5", 64, 9 },
    { "Tree Small6", 67, 4 },
    { "Tree Small3", 71, 28 },
    { "Tree Small6", 66, 33 },
    { "Tree Small3", 67, 10 },
    { "Tree Small6", 69, 7 },
    { "Tree Small4", 71, 15 },
    { "Tree Small4", 72, 9 },
    { "Tree Small5", 74, 5 },
    { "Tree Small5", 48, 37 },
    { "Tree Small6", 59, 38 },
    { "Tree Small6", 70, 32 },
    { "Tree Small5", 75, 27 },
    { "Tree Small6", 74, 17 },
    { "Tree Small4", 76, 11 },
    }

    -- Loads the trees according to the array
    for my_index, my_array in pairs(map_trees) do
        --print(my_array[1], my_array[2], my_array[3]);
        CreateObject(Map, my_array[1], my_array[2], my_array[3], vt_map.MapMode.GROUND_OBJECT);
    end

    -- grass array
    local map_grass = {
        -- the grass, hiding a bit the snakes
        { "Grass Clump1", 99, 85 },
        { "Grass Clump1", 101, 86 },
        { "Grass Clump1", 107, 84 },
        { "Grass Clump1", 85, 73 },
        { "Grass Clump1", 77, 71 },
        { "Grass Clump1", 80, 74 },
        { "Grass Clump1", 68, 78 },
        { "Grass Clump1", 70, 80 },
        { "Grass Clump1", 68, 82 },
        { "Grass Clump1", 70, 70 },
        { "Grass Clump1", 68, 68 },
        { "Grass Clump1", 73, 71 },
        { "Grass Clump1", 63, 72 },

        -- near first snake
        { "Grass Clump1", 41, 69 },
        { "Grass Clump1", 43, 70 },
        { "Grass Clump1", 36, 69.5 },
        { "Grass Clump1", 45, 69 },
        { "Grass Clump1", 47, 70 },
        { "Grass Clump1", 41, 72 },
        { "Grass Clump1", 43.5, 71 },
        { "Grass Clump1", 45, 73 },
        { "Grass Clump1", 49, 72 },
        { "Grass Clump1", 42, 75 },
        { "Grass Clump1", 44, 77 },
        { "Grass Clump1", 46, 76 },
        { "Grass Clump1", 48, 74 },
        { "Grass Clump1", 35, 72.5 },
        { "Grass Clump1", 41, 78 },
        { "Grass Clump1", 43, 79 },
        { "Grass Clump1", 47, 78.2 },
        { "Grass Clump1", 42, 81.4 },
        { "Grass Clump1", 45, 80 },
        { "Grass Clump1", 46, 82 },
        { "Grass Clump1", 48, 81.2 },
        { "Grass Clump1", 51, 80.2 },
        { "Grass Clump1", 50, 76.2 },
        { "Grass Clump1", 40, 83 },
        { "Grass Clump1", 39.5, 86 },
        { "Grass Clump1", 46.5, 84 },
        { "Grass Clump1", 52, 82 },
        { "Grass Clump1", 54, 84 },
        { "Grass Clump1", 43, 85 },
        { "Grass Clump1", 49, 86 },

        -- near second snake
        { "Grass Clump1", 23, 81 },
        { "Grass Clump1", 11, 80 },
        { "Grass Clump1", 6.5, 82 },
        { "Grass Clump1", 3, 75 },
        { "Grass Clump1", 4, 70 },
        { "Grass Clump1", 49, 67 },
        { "Grass Clump1", 9, 72 },
        { "Grass Clump1", 6, 77 },
        { "Grass Clump1", 10, 83 },
        { "Grass Clump1", 5, 86 },
        { "Grass Clump1", 7.5, 79 },
        { "Grass Clump1", 12, 85 },
        { "Grass Clump1", 5.5, 88 },
        { "Grass Clump1", 11.5, 76 },
        { "Grass Clump1", 8, 67 },
        { "Grass Clump1", 9, 86.2 },
        { "Grass Clump1", 4, 73 },
        { "Grass Clump1", 9.2, 74 },
        { "Grass Clump1", 8.5, 69 },
        { "Grass Clump1", 14, 73 },
        { "Grass Clump1", 15, 78 },
        { "Grass Clump1", 18, 75 },

        -- near third snake
        { "Grass Clump1", 5, 55 },
        { "Grass Clump1", 6, 49 },
        { "Grass Clump1", 3, 47 },
        { "Grass Clump1", 11, 41 },
        { "Grass Clump1", 7, 37 },
        { "Grass Clump1", 9, 35 },
        { "Grass Clump1", 12, 37 },
        { "Grass Clump1", 14, 35 },
        { "Grass Clump1", 16, 37.2 },
        { "Grass Clump1", 19, 36 },
        { "Grass Clump1", 20, 35 },
        { "Grass Clump1", 19, 37 },
        { "Grass Clump1", 3, 31 },
        { "Grass Clump1", 5, 33 },
        { "Grass Clump1", 8, 31 },
        { "Grass Clump1", 9, 33 },
        { "Grass Clump1", 12, 31 },
        { "Grass Clump1", 13, 33 },
        { "Grass Clump1", 16, 31 },
        { "Grass Clump1", 17, 33 },
        { "Grass Clump1", 20, 31 },
        { "Grass Clump1", 3, 29 },
        { "Grass Clump1", 4, 27 },
        { "Grass Clump1", 7, 29 },
        { "Grass Clump1", 9, 27 },
        { "Grass Clump1", 12, 29 },
        { "Grass Clump1", 14, 27.5 },
        { "Grass Clump1", 17, 28.5 },
        { "Grass Clump1", 19, 27 },
        { "Grass Clump1", 20, 29 },

        -- near fourth snake
        { "Grass Clump1", 8, 23.5 },
        { "Grass Clump1", 13, 20 },
        { "Grass Clump1", 18, 17 },
        { "Grass Clump1", 15, 14 },
        { "Grass Clump1", 10, 12 },
        { "Grass Clump1", 12, 8 },
        { "Grass Clump1", 18, 6 },
        { "Grass Clump1", 22, 8 },
        { "Grass Clump1", 6, 7 },
        { "Grass Clump1", 17, 10 },
        { "Grass Clump1", 8, 16 },
        { "Grass Clump1", 5, 18 },
        { "Grass Clump1", 25, 11 },
        { "Grass Clump1", 18, 22 },

        -- up to the next map
        { "Grass Clump1", 34, 12 },
        { "Grass Clump1", 38, 8 },
        { "Grass Clump1", 42, 14 },
        { "Grass Clump1", 46, 10 },
        { "Grass Clump1", 51, 13 },
        { "Grass Clump1", 53, 6 },
        { "Grass Clump1", 49, 4 },


    }
    -- Loads the trees according to the array
    for my_index, my_array in pairs(map_grass) do
        --print(my_array[1], my_array[2], my_array[3]);
        object = CreateObject(Map, my_array[1], my_array[2], my_array[3], vt_map.MapMode.GROUND_OBJECT);
        object:SetCollisionMask(vt_map.MapMode.NO_COLLISION);
    end
end

function _CreateEnemies()
    local enemy = nil
    local roam_zone = nil

    -- Hint: left, right, top, bottom
    roam_zone = vt_map.EnemyZone.Create(40, 52, 67, 87);

    enemy = CreateEnemySprite(Map, "snake");
    _SetBattleEnvironment(enemy);
    enemy:NewEnemyParty();
    enemy:AddEnemy(4);
    enemy:AddEnemy(2);
    enemy:AddEnemy(1);
    enemy:NewEnemyParty();
    enemy:AddEnemy(4);
    enemy:AddEnemy(2);
    roam_zone:AddEnemy(enemy, 1);

    roam_zone = vt_map.EnemyZone.Create(77, 84, 71, 87);
    enemy = CreateEnemySprite(Map, "spider");
    _SetBattleEnvironment(enemy);
    enemy:NewEnemyParty();
    enemy:AddEnemy(1);
    enemy:AddEnemy(2);
    enemy:AddEnemy(1);
    enemy:NewEnemyParty();
    enemy:AddEnemy(2);
    enemy:AddEnemy(1);
    roam_zone:AddEnemy(enemy, 1);

    -- Hint: left, right, top, bottom
    roam_zone = vt_map.EnemyZone.Create(2, 11, 66, 87);

    enemy = CreateEnemySprite(Map, "snake");
    _SetBattleEnvironment(enemy);
    enemy:NewEnemyParty();
    enemy:AddEnemy(4);
    enemy:AddEnemy(2);
    enemy:AddEnemy(1);
    enemy:NewEnemyParty();
    enemy:AddEnemy(4);
    enemy:AddEnemy(2);
    roam_zone:AddEnemy(enemy, 1);

    -- Hint: left, right, top, bottom
    roam_zone = vt_map.EnemyZone.Create(5, 25, 5, 37);

    enemy = CreateEnemySprite(Map, "snake");
    _SetBattleEnvironment(enemy);
    enemy:NewEnemyParty();
    enemy:AddEnemy(4);
    enemy:AddEnemy(2);
    enemy:AddEnemy(1);
    enemy:NewEnemyParty();
    enemy:AddEnemy(4);
    enemy:AddEnemy(2);
    roam_zone:AddEnemy(enemy, 1);
end

-- Special event references which destinations must be updated just before being called.
local move_next_to_bronann_event = nil

-- Creates all events and sets up the entire event sequence chain
function _CreateEvents()
    local event = nil
    local dialogue = nil
    local text = nil

    vt_map.MapTransitionEvent.Create("to forest SE", "data/story/layna_forest/layna_forest_south_east_map.lua",
                                     "data/story/layna_forest/layna_forest_south_east_script.lua", "from forest SW");

    vt_map.MapTransitionEvent.Create("to forest NW", "data/story/layna_forest/layna_forest_north_west_map.lua",
                                     "data/story/layna_forest/layna_forest_north_west_script.lua", "from forest SW");

    -- Dialogue events
    vt_map.LookAtSpriteEvent.Create("Kalya looks at Bronann", kalya, bronann);
    vt_map.LookAtSpriteEvent.Create("Bronann looks at Kalya", bronann, kalya);

    vt_map.ScriptedSpriteEvent.Create("kalya:SetCollision(NONE)", kalya, "Sprite_Collision_off", "");
    vt_map.ScriptedSpriteEvent.Create("kalya:SetCollision(ALL)", kalya, "Sprite_Collision_on", "");

    -- First time forest entrance dialogue about save points and the heal spring.
    event = vt_map.ScriptedEvent.Create("Forest entrance dialogue about snakes", "forest_dialogue_about_snakes_start", "");
    event:AddEventLinkAtEnd("Kalya moves next to Bronann", 50);

    -- NOTE: The actual destination is set just before the actual start call
    move_next_to_bronann_event = vt_map.PathMoveSpriteEvent.Create("Kalya moves next to Bronann", kalya, 0, 0, false);
    move_next_to_bronann_event:AddEventLinkAtEnd("Kalya Tells about snakes");
    move_next_to_bronann_event:AddEventLinkAtEnd("kalya:SetCollision(ALL)");

    dialogue = vt_map.SpriteDialogue.Create();
    text = vt_system.Translate("Woah, wait!");
    dialogue:AddLineEventEmote(text, kalya, "Bronann looks at Kalya", "Kalya looks at Bronann", "exclamation");
    text = vt_system.Translate("Look at the grass. Snakes like to hide in the tall grass. We need to be careful because their venom causes drowsiness.");
    dialogue:AddLine(text, kalya);
    event = vt_map.DialogueEvent.Create("Kalya Tells about snakes", dialogue);
    event:AddEventLinkAtEnd("kalya:SetCollision(NONE)");
    event:AddEventLinkAtEnd("Set Camera back to Bronann");

    event = vt_map.ScriptedSpriteEvent.Create("Set Camera back to Bronann", bronann, "SetCamera", "");
    event:AddEventLinkAtEnd("kalya goes back to party");

    event = vt_map.PathMoveSpriteEvent.Create("kalya goes back to party", kalya, bronann, false);
    event:AddEventLinkAtEnd("end of dialogue about snakes");

    vt_map.ScriptedEvent.Create("end of dialogue about snakes", "end_of_dialogue_about_snakes", "");
end

-- zones
local to_forest_SE_zone = nil
local to_forest_NW_zone = nil

-- Create the different map zones triggering events
function _CreateZones()
    -- N.B.: left, right, top, bottom
    to_forest_SE_zone = vt_map.CameraZone.Create(126, 128, 82, 87);
    to_forest_NW_zone = vt_map.CameraZone.Create(52, 59, 0, 2);
end

-- Check whether the active camera has entered a zone. To be called within Update()
function _CheckZones()
    if (to_forest_SE_zone:IsCameraEntering() == true) then
        hero:SetMoving(false);
        EventManager:StartEvent("to forest SE");
    end

    if (to_forest_NW_zone:IsCameraEntering() == true) then
        hero:SetMoving(false);
        EventManager:StartEvent("to forest NW");
    end
end

-- Sets common battle environment settings for enemy sprites
function _SetBattleEnvironment(enemy)
    enemy:SetBattleMusicTheme("data/music/heroism-OGA-Edward-J-Blakeley.ogg");
    enemy:SetBattleBackground("data/battles/battle_scenes/forest_background.png");
    if (GlobalManager:GetGameEvents():GetEventValue("story", "layna_forest_crystal_event_done") == 1) then
        -- Setup time of the day lighting on battles
        enemy:AddBattleScript("data/story/layna_forest/after_crystal_twilight_battles.lua");
        if (GlobalManager:GetGameEvents():GetEventValue("story", "layna_forest_twilight_value") > 2) then
            enemy:SetBattleBackground("data/battles/battle_scenes/forest_background_evening.png");
        end
    end
end

-- Map Custom functions
-- Used through scripted events
map_functions = {

    -- Kalya tells Bronann about the snakes - start event.
    forest_dialogue_about_snakes_start = function()
        Map:PushState(vt_map.MapMode.STATE_SCENE);
        hero:SetMoving(false);

        bronann:SetPosition(hero:GetXPosition(), hero:GetYPosition())
        bronann:SetDirection(hero:GetDirection())
        bronann:SetVisible(true)
        hero:SetVisible(false)
        Map:SetCamera(bronann)
        hero:SetPosition(0, 0)

        kalya:SetVisible(true);
        kalya:SetPosition(bronann:GetXPosition(), bronann:GetYPosition());
        bronann:SetCollisionMask(vt_map.MapMode.ALL_COLLISION);
        kalya:SetCollisionMask(vt_map.MapMode.NO_COLLISION);

        Map:SetCamera(kalya, 800);

        move_next_to_bronann_event:SetDestination(bronann:GetXPosition() - 2.0, bronann:GetYPosition(), false);
    end,

    SetCamera = function(sprite)
        Map:SetCamera(sprite, 800);
    end,

    Sprite_Collision_on = function(sprite)
        if (sprite ~= nil) then
            sprite:SetCollisionMask(vt_map.MapMode.ALL_COLLISION);
        end
    end,

    Sprite_Collision_off = function(sprite)
        if (sprite ~= nil) then
            sprite:SetCollisionMask(vt_map.MapMode.NO_COLLISION);
        end
    end,

    end_of_dialogue_about_snakes = function()
        Map:PopState();
        kalya:SetPosition(0, 0);
        kalya:SetVisible(false);
        kalya:SetCollisionMask(vt_map.MapMode.NO_COLLISION);

        hero:SetPosition(bronann:GetXPosition(), bronann:GetYPosition())
        hero:SetDirection(bronann:GetDirection())
        hero:SetVisible(true)
        bronann:SetVisible(false)
        Map:SetCamera(hero)
        bronann:SetPosition(0, 0)

        -- Set event as done
        GlobalManager:GetGameEvents():SetEventValue("story", "kalya_speech_about_snakes_done", 1);
    end
}
