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
        if player:getModData().AlcoholicHasWithdrawalSickness == nil
        then
            player:getModData().AlcoholicHasWithdrawalSickness = false
        end
        if player:getModData().AlcoholicDrinksPerDay == nil
        then
            player:getModData().AlcoholicDrinksPerDay = 0
        end
        if player:getModData().AlcoholicPrevStress == nil
        then
            player:getModData().AlcoholicPrevStress = 0
        end
        if player:getModData().AlcoholicTolerancePenalty == nil
        then
            player:getModData().AlcoholicTolerancePenalty = 0
        end
        if player:getModData().AlcoholicPoisonDamageTotal == nil
        then
            player:getModData().AlcoholicPoisonDamageTotal = 0
        end
        if player:getModData().AlcoholicDrinksTotal == nil
        then
            player:getModData().AlcoholicDrinksTotal = 0
        end
        player:getModData().AlcoholicInit2 = true
    end
end

-- new game / new character event
function TheAlcoholic.onCreatePlayer(playernum, character)
    local player = getSpecificPlayer(playernum)

    init(player)
    init2(player)

    if player:HasTrait("Alcoholic")
    then
        if TheAlcoholic.sBVars.SpawnItem > 1 or TheAlcoholic.values.UseSpawnItemCustom -- 1 is nothing
        then
            player:getInventory():AddItem(TheAlcoholic.values.SpawnItem)
        end
    end
end

-- update event to support the mod being added to an existing game
function TheAlcoholic.onBoot()
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
function TheAlcoholic.onTraitUpdate()
    local values = TheAlcoholic.values
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
                
                if timeSinceDrink > values.WithdrawalPhase1 and timeSinceDrink <= values.WithdrawalPhase2
                then
                    if player:getModData().AlcoholicWithdrawalPhase == 0
                    then
                        HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Alcoholic_WithdrawalPhase1"), true, HaloTextHelper.getColorRed())
                    end
                    player:getModData().AlcoholicWithdrawalPhase = 1
                    player:getModData().AlcoholicHasWithdrawalSickness = true
                    TheAlcoholic.increaseStress(player, 0.10)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(7))
                    TheAlcoholic.decreaseHappiness(player, 2)
                    if player:getModData().AlcoholicTolerance > 0
                    then
                        player:getModData().AlcoholicTolerance = player:getModData().AlcoholicTolerance - 0.01
                    end
                elseif timeSinceDrink > values.WithdrawalPhase2 and timeSinceDrink <= values.WithdrawalPhase3
                then
                    if player:getModData().AlcoholicWithdrawalPhase == 1
                    then
                        HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Alcoholic_WithdrawalPhase2"), false, HaloTextHelper.getColorRed())
                    end
                    player:getModData().AlcoholicWithdrawalPhase = 2
                    player:getModData().AlcoholicHasWithdrawalSickness = true
                    TheAlcoholic.increaseStress(player, 0.15)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(4))
                    TheAlcoholic.decreaseHappiness(player, 6)
                    if values.Headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(values.HeadacheDamage), ZombRand(values.HeadacheDamage))
                    end
                    player:getModData().AlcholicTolerance = 0
                elseif timeSinceDrink > values.WithdrawalPhase3 and timeSinceDrink <= values.WithdrawalPhase4
                then
                    if player:getModData().AlcoholicWithdrawalPhase == 2
                    then
                        HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Alcoholic_WithdrawalPhase3"), false, HaloTextHelper.getColorRed())
                    end
                    player:getModData().AlcoholicWithdrawalPhase = 3
                    player:getModData().AlcoholicHasWithdrawalSickness = true
                
                    TheAlcoholic.increaseStress(player, 0.25)
                    TheAlcoholic.increaseFatigue(player, 0.05, ZombRand(3))
                    TheAlcoholic.decreaseHappiness(player, 7)
                    if values.Headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(values.HeadacheDamage+10), ZombRand(values.HeadacheDamage-1))
                    end
                    player:getModData().AlcholicTolerance = 0
                elseif timeSinceDrink > values.WithdrawalPhase4 and timeSinceDrink <= values.DaysToLose
                then
                    if player:getModData().AlcoholicWithdrawalPhase == 3
                    then
                        HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Alcoholic_WithdrawalPhase4"), false, HaloTextHelper.getColorRed())
                    end
                    player:getModData().AlcoholicWithdrawalPhase = 4
                    player:getModData().AlcoholicHasWithdrawalSickness = true
                    TheAlcoholic.increaseStress(player, 0.3)
                    TheAlcoholic.increaseFatigue(player, 0.1, ZombRand(2))
                    TheAlcoholic.decreaseHappiness(player, 10)
                    if values.Headaches == true
                    then
                        TheAlcoholic.increasePain(player, "Head", ZombRand(values.HeadacheDamage+15), ZombRand(values.HeadacheDamage-2))
                    end
                    player:getModData().AlcholicTolerance = 0
                elseif timeSinceDrink > values.DaysToLose and values.Dynamic == true
                then
                    player:getTraits():remove("Alcoholic")
                    HaloTextHelper.addTextWithArrow(player, getText("UI_trait_AlcoholicLost"), false, HaloTextHelper.getColorGreen())
                end
                
                -- debug
                if values.DebugMode == true
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
                    print("Alcoholic has withdrawal sickness:"..tostring(player:getModData().AlcoholicHasWithdrawalSickness))
                    print("Alcoholic has drank:"..tostring(player:getModData().AlcoholicHasDrank))
                    print("Alcoholic tolerance penalty:"..player:getModData().AlcoholicTolerancePenalty)
                    print("Alcoholic previous stress:"..player:getModData().AlcoholicPrevStress)
                    print("Alcoholic time since last drink:"..player:getModData().AlcoholicTimeSinceLastDrink)
                    print("Alcoholic poison damage total:"..player:getModData().AlcoholicPoisonDamageTotal)
                    print("-----------------------------------------------")

                end
                -- end debug
            else
                if player:getModData().AlcoholicThreshold > values.ThresholdToGain  and values.Dynamic == true
                then
                    player:getTraits():add("Alcoholic")
                    HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Alcoholic"), true, HaloTextHelper.getColorRed())
                end
            end
        end
    end
end

function TheAlcoholic.onStressCheck()
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

function TheAlcoholic.onDailyUpdate()
    local values = TheAlcoholic.values
    if TheAlcoholic.values.DebugMode == true
    then
        print("The Alcoholic: Daily update")
    end
    for i=0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(i)
        if player and player:isAlive()
        then
            if TheAlcoholic.values.DebugMode == true
            then
                print(player:getUsername().." drank "..player:getModData().AlcoholicDrinksPerDay.." drinks today")
            end
            if player:HasTrait("Alcoholic")
            then
                if values.Tolerance == true
                then
                    if player:getModData().AlcoholicDrinksPerDay >= values.ToleranceDrinksPerDay
                    then
                        if player:getModData().AlcoholicTolerance < values.ToleranceBuildMax
                        then
                            player:getModData().AlcoholicTolerance = player:getModData().AlcoholicTolerance + 0.01
                        end
                    end
                end
            end
            player:getModData().AlcoholicDrinksPerDay = 0
        end
    end
end

function TheAlcoholic.onWithdrawalSickness()
    local values = TheAlcoholic.values
    if values.Withdrawal == true
    then
        for i=0, getNumActivePlayers()-1 do
            local player = getSpecificPlayer(i)
            if player and player:isAlive()
            then
                if player:HasTrait("Alcoholic")
                then
                    if player:getModData().AlcoholicHasWithdrawalSickness == true
                    then
                        TheAlcoholic.increaseWithdrawalSickness(player, values.WithdrawalRate, ZombRand(5 - player:getModData().AlcoholicWithdrawalPhase))
                    end
                end
                if player:getModData().AlcoholicWithdrawalSickness > 0.6
                then
                    if values.Poison == true
                    then
                        local chance = ZombRand(values.WithdrawalPoisonChance)
                        local poisondmg = ZombRand(values.PoisonDamage)
                        TheAlcoholic.increasePoison(player, poisondmg, chance)
                    end
                end
                if player:getModData().AlcoholicWithdrawalSickness > 0.90
                then
                    local chance = ZombRand(values.WithdrawalDeathChance)
                    if chance == 0
                    then
                        player:die()
                    end
                end
            end
        end
    end
end

-- SET EVENT HANDLERS

Events.OnCreatePlayer.Add(TheAlcoholic.onCreatePlayer)
Events.OnGameBoot.Add(TheAlcoholic.onBoot)
Events.OnTick.Add(TheAlcoholic.onStressCheck)
Events.EveryTenMinutes.Add(TheAlcoholic.onWithdrawalSickness)
Events.EveryHours.Add(TheAlcoholic.onTraitUpdate)
Events.EveryDays.Add(TheAlcoholic.onDailyUpdate)

-- ACTIONS

local base_perform_eat = ISEatFoodAction.perform

function ISEatFoodAction:perform()
    base_perform_eat(self)
    if self.item:isAlcoholic()
    then
        TheAlcoholic.drankAlcohol(self.character)
    end
end