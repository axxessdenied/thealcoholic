-- (c) 2024 - axxessdenied [Nick Slusarczyk]

TheAlcoholic = TheAlcoholic or {}

local timeCheck_stress = 0
local timeCheck_stressDelta = 5000
local previousTimeMultiplier_stress = 1

local function init(player)
    -- hours since last drink
    if player:getModData().AlcoholicTimeSinceLastDrink == nil 
    then
        player:getModData().AlcoholicTimeSinceLastDrink = 0
    end

    -- progress towards becoming an alcoholic
    if player:getModData().AlcoholicThreshold == nil 
    then
        player:getModData().AlcoholicThreshold = 0
    end

    -- added stress from not drinking
    if player:getModData().AlcoholicStress == nil
    then
        player:getModData().AlcoholicStress = 0
    end

    player:getModData().AlcoholicInit = true;
end

-- new game / new character event
function TheAlcoholic.OnCreatePlayer(playernum, character)
    local player = getSpecificPlayer(playernum)

    init(player)

    if player:HasTrait("Alcoholic")
    then
        player:getInventory():AddItem("Base.BeerEmpty") -- finished bottle for the drunkard
    end
end


-- update event to support the mod being added to an existing game
function TheAlcoholic:OnBoot()
    if self.player:getModData().AlcoholicInit == nil
    then
        init(self.player)
    end
end

-- update event to handle the alcoholic trait
function TheAlcoholic:OnTraitUpdate()
    local player = self.player
    
    if player:HasTrait("Alcoholic") 
    then
        local timeSinceDrink = player:getModData().AlcoholicTimeSinceLastDrink;
        
        -- debug
        print("Hours since last drink:"..timeSinceDrink);
        print("Alcoholic stress level:"..player:getModData().AlcoholicStress);
        -- end debug
        
        if timeSinceDrink > THEALCOHOLIC.VALUES.drop4[THEALCOHOLIC.SETTINGS.options.drop4] and timeSinceDrink <= THEALCOHOLIC.VALUES.drop5[THEALCOHOLIC.SETTINGS.options.drop5]
        then
            TheAlcoholic.increaseStress(player, 0.10)
            TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(7))
            TheAlcoholic.decreaseHappiness(player, 2)
        elseif timeSinceDrink > THEALCOHOLIC.VALUES.drop5[THEALCOHOLIC.SETTINGS.options.drop5] and timeSinceDrink <= THEALCOHOLIC.VALUES.drop6[THEALCOHOLIC.SETTINGS.options.drop6]
        then
            TheAlcoholic.increaseStress(player, 0.15)
            TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(4))
            TheAlcoholic.decreaseHappiness(player, 6)
            if (THEALCOHOLIC.SETTINGS.options.box1) == true
            then
                increasePain(player, "Head", ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]), ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]))
            end
        elseif timeSinceDrink > THEALCOHOLIC.VALUES.drop6[THEALCOHOLIC.SETTINGS.options.drop6] and timeSinceDrink <= THEALCOHOLIC.VALUES.drop7[THEALCOHOLIC.SETTINGS.options.drop7]
        then
            TheAlcoholic.increaseStress(player, 0.25)
            TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(3))
            TheAlcoholic.decreaseHappiness(player, 7)
            if (THEALCOHOLIC.SETTINGS.options.box1) == true
            then
                TheAlcoholic.increasePain(player, "Head", ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]+10), ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]-1))
            end
            if (THEALCOHOLIC.SETTINGS.options.box2) == true
            then
                TheAlcoholic.increasePoison(player, ZombRand(THEALCOHOLIC.VALUES.drop10[THEALCOHOLIC.SETTINGS.options.drop10]), ZombRand(THEALCOHOLIC.VALUES.drop12[THEALCOHOLIC.SETTINGS.options.drop12]))
            end
        elseif timeSinceDrink > THEALCOHOLIC.VALUES.drop7[THEALCOHOLIC.SETTINGS.options.drop7] and timeSinceDrink <= THEALCOHOLIC.VALUES.drop8[THEALCOHOLIC.SETTINGS.options.drop8]
        then
            TheAlcoholic.increaseStress(player, 0.3)
            TheAlcoholic.increaseFatigue(player, 0.1, ZombRand(2))
            TheAlcoholic.decreaseHappiness(player, 10)
            if (THEALCOHOLIC.SETTINGS.options.box1) == true
            then
                TheAlcoholic.increasePain(player, "Head", ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]+15), ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]-2))
            end
            if (THEALCOHOLIC.SETTINGS.options.box2) == true
            then
                TheAlcoholic.increasePoison(player, ZombRand(THEALCOHOLIC.VALUES.drop10[THEALCOHOLIC.SETTINGS.options.drop10]+20), ZombRand(THEALCOHOLIC.VALUES.drop12[THEALCOHOLIC.SETTINGS.options.drop12]-1))
            end
        elseif timeSinceDrink > THEALCOHOLIC.VALUES.drop8[THEALCOHOLIC.SETTINGS.options.drop8] and (THEALCOHOLIC.SETTINGS.options.box3) == true
        then
            player:getTraits():remove("Alcoholic");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_AlcoholicLost"), true, HaloTextHelper.getColorGreen());
        end
    else
        if player:getModData().AlcoholicThreshold > THEALCOHOLIC.VALUES.drop9[THEALCOHOLIC.SETTINGS.options.drop9]  and (THEALCOHOLIC.SETTINGS.options.box3) == true
        then
            player:getTraits():add("Alcoholic");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Alcoholic"), true, HaloTextHelper.getColorRed());
        end
    end
end

function TheAlcoholic:OnStressCheck()
    local timeMultiplier = getGameTime():getTrueMultiplier()
    local timestamp = getTimestampMs()

    if timestamp < timeCheck_stress and timeMultiplier == previousTimeMultiplier_stress
    then
        return
    end

    if self.player:HasTrait("Alcoholic")
    then
        TheAlcoholic.alcoholicStress()
    end
end

-- SET EVENT HANDLERS


Events.OnCreatePlayer.Add(TheAlcoholic.OnCreatePlayer)
Events.OnGameBoot.Add(TheAlcoholic.OnBoot)
Events.OnTick.Add(TheAlcoholic.OnStressCheck)
Events.EveryHours.Add(TheAlcoholic.OnTraitUpdate)

