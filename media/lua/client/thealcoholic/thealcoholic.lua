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

-- for compatibility with the previous version of the mod
local function init2(player)
    if player:getModData().AlcoholicInit2 == nil
    then
        if player:getModData().AlcoholicHasDrank == nil
        then
            player:getModData().AlcoholicHasDrank = false
        end

        if player:getModData().AlcoholicTolerance == nil
        then
            player:getModData().AlcoholicTolerance = 0
        end

        if player:getModData().LastDrinkTimestamp == nil
        then
            player:getModData().LastDrinkTimestamp = 0
        end
        player:getModData().AlcoholicInit2 = true
    end
end

-- new game / new character event
function TheAlcoholic.OnCreatePlayer(playernum, character)
    local player = getSpecificPlayer(playernum)

    init(player)
    init2(player)

    if player:HasTrait("Alcoholic")
    then
        player:getInventory():AddItem("Base.WhiskeyFull") -- finished bottle for the drunkard
    end
end


-- update event to support the mod being added to an existing game
function TheAlcoholic.OnBoot()
    for i=0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(i)
        if player
        then
            if player:getModData().AlcoholicInit == nil
            then
                init(player)
            elseif player:getModData().AlcoholicInit2 == nil
            then
                init2(player)
            end
        end
    end
end

TheAlcoholic.values = {
    withdrawal_phase1 = {12,18,24,48},      --phase 1
    withdrawal_phase2 = {24,48,72,96},      --phase 2
    withdrawal_phase3 = {48,72,96,120},     --phase 3
    withdrawal_phase4 = {72,96,120,144,168},--phase 4
    daystolose = {504,672,1344,1920},       --sober values
    thresholdtogain = {200,400,800,1600},   --threshold values
    poison = {25,35,45,55},                 --poison values
    headachedmg = {30,50,65,80},            --headache values
    headachechance = {10,7,5,3},            --headache chance
    withdrawal_chance = {10,7,5,2},         --withdrawal sickness chance
    maxstress = {0.3,0.5,0.7,0.9},          --max alcoholic stress
}

TheAlcoholic.options = {
    headaches = getSandboxOptions():getOptionByName("thealcoholic.headaches"):getValue(),
    withdrawal = getSandboxOptions():getOptionByName("thealcoholic.withdrawal"):getValue(),
    dynamic = getSandboxOptions():getOptionByName("thealcoholic.dynamic"):getValue(),
    withdrawal_phase1 = getSandboxOptions():getOptionByName("thealcoholic.withdrawal_phase1"):getValue(),
    withdrawal_phase2 = getSandboxOptions():getOptionByName("thealcoholic.withdrawal_phase2"):getValue(),
    withdrawal_phase3 = getSandboxOptions():getOptionByName("thealcoholic.withdrawal_phase3"):getValue(),
    withdrawal_phase4 = getSandboxOptions():getOptionByName("thealcoholic.withdrawal_phase4"):getValue(),
    daystolose = getSandboxOptions():getOptionByName("thealcoholic.daystolose"):getValue(),
    thresholdtogain = getSandboxOptions():getOptionByName("thealcoholic.thresholdtogain"):getValue(),
    poison = getSandboxOptions():getOptionByName("thealcoholic.poisondamage"):getValue(),
    headachedmg = getSandboxOptions():getOptionByName("thealcoholic.headachedamage"):getValue(),
    headachechance = getSandboxOptions():getOptionByName("thealcoholic.headachechance"):getValue(),
    withdrawal_chance = getSandboxOptions():getOptionByName("thealcoholic.withdrawalchance"):getValue(),
    maxstress = getSandboxOptions():getOptionByName("thealcoholic.maxstress"):getValue(),
}

-- update event to handle the alcoholic trait
function TheAlcoholic.OnTraitUpdate()
    for i=0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(i)
        if player and player:isAlive()
        then
            if player:getModData().AlcoholicHasDrank == true
            then
                player:getModData().AlcoholicHasDrank = false
            else
                TheAlcoholic.noDrinkAlcohol(player)
            end
            if player:HasTrait("Alcoholic") 
            then

                local timeSinceDrink = player:getModData().AlcoholicTimeSinceLastDrink
                
                -- debug
                print("Hours since last drink:"..timeSinceDrink)
                print("Alcoholic stress level:"..player:getModData().AlcoholicStress)
                -- end debug
            
                if timeSinceDrink > TheAlcoholic.values.withdrawal_phase1[TheAlcoholic.options.withdrawal_phase1] and timeSinceDrink <= TheAlcoholic.values.withdrawal_phase2[TheAlcoholic.options.withdrawal_phase2]
                then
                    TheAlcoholic.increaseStress(player, 0.10)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(7))
                    TheAlcoholic.decreaseHappiness(player, 2)
                elseif timeSinceDrink > TheAlcoholic.values.withdrawal_phase2[TheAlcoholic.options.withdrawal_phase2] and timeSinceDrink <= TheAlcoholic.values.withdrawal_phase3[TheAlcoholic.options.withdrawal_phase3]
                then
                    TheAlcoholic.increaseStress(player, 0.15)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(4))
                    TheAlcoholic.decreaseHappiness(player, 6)
                    if TheAlcoholic.options.headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]), ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]))
                    end
                elseif timeSinceDrink > TheAlcoholic.values.withdrawal_phase3[TheAlcoholic.options.withdrawal_phase3] and timeSinceDrink <= TheAlcoholic.values.withdrawal_phase4[TheAlcoholic.options.withdrawal_phase4]
                then
                    TheAlcoholic.increaseStress(player, 0.25)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(3))
                    TheAlcoholic.decreaseHappiness(player, 7)
                    if TheAlcoholic.options.headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]+10), ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]-1))
                    end
                    if TheAlcoholic.options.withdrawal == true
                    then
                        TheAlcoholic.increasePoison(player, ZombRand(TheAlcoholic.values.poison[TheAlcoholic.options.poison]), ZombRand(TheAlcoholic.values.headachechance[TheAlcoholic.options.headachechance]))
                    end
                elseif timeSinceDrink > TheAlcoholic.values.withdrawal_phase4[TheAlcoholic.options.withdrawal_phase4] and timeSinceDrink <= TheAlcoholic.values.daystolose[TheAlcoholic.options.daystolose]
                then
                    TheAlcoholic.increaseStress(player, 0.3)
                    TheAlcoholic.increaseFatigue(player, 0.1, ZombRand(2))
                    TheAlcoholic.decreaseHappiness(player, 10)
                    if TheAlcoholic.options.headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]+15), ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]-2))
                    end
                    if TheAlcoholic.options.withdrawal == true
                    then
                        TheAlcoholic.increasePoison(player, ZombRand(TheAlcoholic.values.poison[TheAlcoholic.options.poison]+20), ZombRand(TheAlcoholic.values.headachechance[TheAlcoholic.options.headachechance]-1))
                    end
                elseif timeSinceDrink > TheAlcoholic.values.daystolose[TheAlcoholic.options.daystolose] and TheAlcoholic.options.dynamic == true
                then
                    player:getTraits():remove("Alcoholic");
                    HaloTextHelper.addTextWithArrow(player, getText("UI_trait_AlcoholicLost"), true, HaloTextHelper.getColorGreen());
                end
            else
                if player:getModData().AlcoholicThreshold > TheAlcoholic.values.thresholdtogain[TheAlcoholic.options.thresholdtogain]  and TheAlcoholic.options.dynamic == true
                then
                    player:getTraits():add("Alcoholic");
                    HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Alcoholic"), true, HaloTextHelper.getColorRed());
                end
            end
        end
    end
end

function TheAlcoholic.OnStressCheck()
    local timeMultiplier = getGameTime():getTrueMultiplier()
    local timestamp = getTimestampMs()

    if timestamp < timeCheck_stress and timeMultiplier == previousTimeMultiplier_stress
    then
        return
    end

    timeCheck_stress = timestamp + timeCheck_stressDelta / timeMultiplier
    previousTimeMultiplier_stress = timeMultiplier

    print()
    for i=0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(i)
        if player and player:isAlive()
        then
            if player:HasTrait("Alcoholic")
            then
                TheAlcoholic.alcoholicStress(player)
            end
        end
    end
end


-- SET EVENT HANDLERS

Events.OnCreatePlayer.Add(TheAlcoholic.OnCreatePlayer)
Events.OnGameBoot.Add(TheAlcoholic.OnBoot)
Events.OnTick.Add(TheAlcoholic.OnStressCheck)
Events.EveryHours.Add(TheAlcoholic.OnTraitUpdate)

-- ACTIONS

local base_perform_eat = ISEatFoodAction.perform

function ISEatFoodAction:perform()
    base_perform_eat(self)
    if self.item:isAlcoholic()
    then
        TheAlcoholic.drankAlcohol(self.character)
    end
end
