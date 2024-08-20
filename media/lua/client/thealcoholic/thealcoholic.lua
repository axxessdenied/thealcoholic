-- (c) 2024 - axxessdenied [Nick Slusarczyk]

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
        if player:getModData().AlcoholicWithdrawalPhase == nil
        then
            player:getModData().AlcoholicWithdrawalPhase = 0
        end
        if player:getModData().AlcoholicWithdrawalSickness == nil
        then
            player:getModData().AlcoholicWithdrawalSickness = 0
        end
        if player:getModData().AlcoholicDrinksPerDay == nil
        then
            player:getModData().AlcoholicDrinksPerDay = 0
        end
        if player:getModData().AlcoholicPrevStress == nil
        then
            player:getModData().AlcoholicPrevStress = 0
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
        if TheAlcoholic.options.spawnitem > 1 -- 1 is nothing
        then
            player:getInventory():AddItem(TheAlcoholic.values.spawnitem[TheAlcoholic.options.spawnitem])
        end
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
                
                player:getModData().AlcoholicWithdrawalPhase = 0
                if timeSinceDrink > TheAlcoholic.values.withdrawal_phase1[TheAlcoholic.options.withdrawal_phase1] and timeSinceDrink <= TheAlcoholic.values.withdrawal_phase2[TheAlcoholic.options.withdrawal_phase2]
                then
                    player:getModData().AlcoholicWithdrawalPhase = 1
                    TheAlcoholic.increaseStress(player, 0.10)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(7))
                    TheAlcoholic.decreaseHappiness(player, 2)
                    if player:getModData().AlcoholicTolerance > 0
                    then
                        player:getModData().AlcoholicTolerance = player:getModData().AlcoholicTolerance - 0.01
                    end
                elseif timeSinceDrink > TheAlcoholic.values.withdrawal_phase2[TheAlcoholic.options.withdrawal_phase2] and timeSinceDrink <= TheAlcoholic.values.withdrawal_phase3[TheAlcoholic.options.withdrawal_phase3]
                then
                    player:getModData().AlcoholicWithdrawalPhase = 2
                    TheAlcoholic.increaseStress(player, 0.15)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(4))
                    TheAlcoholic.decreaseHappiness(player, 6)
                    if TheAlcoholic.options.headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]), ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]))
                    end
                    player:getModData().AlcholicTolerance = 0
                elseif timeSinceDrink > TheAlcoholic.values.withdrawal_phase3[TheAlcoholic.options.withdrawal_phase3] and timeSinceDrink <= TheAlcoholic.values.withdrawal_phase4[TheAlcoholic.options.withdrawal_phase4]
                then
                    player:getModData().AlcoholicWithdrawalPhase = 3
                
                    TheAlcoholic.increaseStress(player, 0.25)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(3))
                    TheAlcoholic.decreaseHappiness(player, 7)
                    if TheAlcoholic.options.headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]+10), ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]-1))
                    end
                    if TheAlcoholic.options.withdrawal == true
                    then
                        --TheAlcoholic.increasePoison(player, ZombRand(TheAlcoholic.values.poison[TheAlcoholic.options.poison]), ZombRand(TheAlcoholic.values.headachechance[TheAlcoholic.options.headachechance]))
                    end
                    player:getModData().AlcholicTolerance = 0
                elseif timeSinceDrink > TheAlcoholic.values.withdrawal_phase4[TheAlcoholic.options.withdrawal_phase4] and timeSinceDrink <= TheAlcoholic.values.daystolose[TheAlcoholic.options.daystolose]
                then
                    player:getModData().AlcoholicWithdrawalPhase = 4
                    TheAlcoholic.increaseStress(player, 0.3)
                    TheAlcoholic.increaseFatigue(player, 0.1, ZombRand(2))
                    TheAlcoholic.decreaseHappiness(player, 10)
                    if TheAlcoholic.options.headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]+15), ZombRand(TheAlcoholic.values.headachedmg[TheAlcoholic.options.headachedmg]-2))
                    end
                    if TheAlcoholic.options.withdrawal == true
                    then
                        --TheAlcoholic.increasePoison(player, ZombRand(TheAlcoholic.values.poison[TheAlcoholic.options.poison]+20), ZombRand(TheAlcoholic.values.headachechance[TheAlcoholic.options.headachechance]-1))
                    end
                    player:getModData().AlcholicTolerance = 0
                elseif timeSinceDrink > TheAlcoholic.values.daystolose[TheAlcoholic.options.daystolose] and TheAlcoholic.options.dynamic == true
                then
                    player:getTraits():remove("Alcoholic")
                    HaloTextHelper.addTextWithArrow(player, getText("UI_trait_AlcoholicLost"), true, HaloTextHelper.getColorGreen())
                end
                
                -- debug
                if isDebugEnabled()
                then
                    print("----------The Alcoholic: Trait update----------")
                    print("Hours since last drink:"..timeSinceDrink)
                    print("Alcoholic stress level:"..player:getModData().AlcoholicStress)
                    print("Alcoholic threshold:"..player:getModData().AlcoholicThreshold)
                    print("Alcoholic tolerance:"..player:getModData().AlcoholicTolerance)
                    print("Alcoholic withdrawal phase:"..player:getModData().AlcoholicWithdrawalPhase)
                    print("Alcoholic withdrawal sickness:"..player:getModData().AlcoholicWithdrawalSickness)
                    print("Alcoholic drinks per day:"..player:getModData().AlcoholicDrinksPerDay)
                    print("Alcoholic last drink timestamp:"..player:getModData().LastDrinkTimestamp)
                    print("-----------------------------------------------")

                end
                -- end debug
            else
                if player:getModData().AlcoholicThreshold > TheAlcoholic.values.thresholdtogain[TheAlcoholic.options.thresholdtogain]  and TheAlcoholic.options.dynamic == true
                then
                    player:getTraits():add("Alcoholic")
                    HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Alcoholic"), true, HaloTextHelper.getColorRed())
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

function TheAlcoholic.OnDailyUpdate()
    for i=0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(i)
        if player and player:isAlive()
        then
            if isDebugEnabled()
            then
                print("The Alcoholic: Daily update")
                print("Alcoholic drinks: "..player:getModData().AlcoholicDrinksPerDay)
            end
            if player:HasTrait("Alcoholic")
            then
                if player:getModData().AlcoholicDrinksPerDay > TheAlcoholic.values.tolerance_drinks_per_day[TheAlcoholic.options.tolerance_drinks_per_day]
                then
                    player:getModData().AlcoholicTolerance = player:getModData().AlcoholicTolerance + 0.01
                end
            end
            player:getModData().AlcoholicDrinksPerDay = 0
        end
    end
end

-- SET EVENT HANDLERS

Events.OnCreatePlayer.Add(TheAlcoholic.OnCreatePlayer)
Events.OnGameBoot.Add(TheAlcoholic.OnBoot)
Events.EveryTenMinutes.Add(TheAlcoholic.OnStressCheck)
Events.EveryHours.Add(TheAlcoholic.OnTraitUpdate)
Events.EveryDays.Add(TheAlcoholic.OnDailyUpdate)

-- ACTIONS

local base_perform_eat = ISEatFoodAction.perform

function ISEatFoodAction:perform()
    base_perform_eat(self)
    if self.item:isAlcoholic()
    then
        TheAlcoholic.drankAlcohol(self.character)
    end
end