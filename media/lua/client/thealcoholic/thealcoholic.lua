-- (c) 2024 - axxessdenied [Nick Slusarczyk]

TheAlcoholic = TheAlcoholic or {}

local timeCheck_stress = 0
local timeCheck_stressDelta = 5000
local previousTimeMultiplier_stress = 1

-- values for the mod
TheAlcoholic.values = {
    spawnitem = {"Nothing", "Base.BeerEmpty", "Base.BeerBottle", "Base.BeerCan", "Base.WhiskeyFull", "Base.Wine", "Base.Wine2", "Base.WineEmpty", "Base.WineEmpty2", "Base.WhiskeyEmpty"},
    threshold_build_max = { 0.1, 0.15, 0.20 },      --threshold build max
    base_tolerance = { 0.65, 0.60, 0.55 },          --base tolerance
    tolerance_drinks_per_day = { 8, 10, 12, 15 },   --tolerance drinks per day
    stress_per_drink = { 0.10, 0.15, 0.25, 0.50 },  --stress removed per drink
    happiness_per_drink = { 10, 15, 25, 50 },       --happiness per drink
    pain_per_drink = { 10, 15, 25, 50 },            --pain per drink
    withdrawal_phase1 = {2,18,24,48},               --phase 1
    withdrawal_phase2 = {6,48,72,96},               --phase 2
    withdrawal_phase3 = {10,72,96,120},             --phase 3
    withdrawal_phase4 = {16,96,120,144,168},        --phase 4
    daystolose = {504,672,1344,1920},               --sober values
    thresholdtogain = {200,400,800,1600},           --threshold values
    poison = {25,35,45,55},                         --poison values
    headachedmg = {30,50,65,80},                    --headache values
    headachechance = {10,7,5,3},                    --headache chance
    withdrawal_chance = {10,7,5,2},                 --withdrawal sickness chance
    maxstress = {0.3,0.5,0.7,0.9},                  --max alcoholic stress
}
function TheAlcoholic.OnInitModData()
    -- load sandbox options
    TheAlcoholic.options = {
        spawnitem = getSandboxOptions():getOptionByName("thealcoholic.spawnitem"):getValue(),
        headaches = getSandboxOptions():getOptionByName("thealcoholic.headaches"):getValue(),
        withdrawal = getSandboxOptions():getOptionByName("thealcoholic.withdrawal"):getValue(),
        dynamic = getSandboxOptions():getOptionByName("thealcoholic.dynamic"):getValue(),
        tolerance = getSandboxOptions():getOptionByName("thealcoholic.tolerance"):getValue(),
        happiness = getSandboxOptions():getOptionByName("thealcoholic.happiness"):getValue(),
        tolerance_build_max = getSandboxOptions():getOptionByName("thealcoholic.tolerance_build_max"):getValue(),
        tolerance_drinks_per_day = getSandboxOptions():getOptionByName("thealcoholic.tolerance_drinks_per_day"):getValue(),
        base_tolerance = getSandboxOptions():getOptionByName("thealcoholic.base_tolerance"):getValue(),
        stress_per_drink = getSandboxOptions():getOptionByName("thealcoholic.stress_per_drink"):getValue(),
        happiness_per_drink = getSandboxOptions():getOptionByName("thealcoholic.happiness_per_drink"):getValue(),
        pain_per_drink = getSandboxOptions():getOptionByName("thealcoholic.pain_per_drink"):getValue(),
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
end

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

Events.OnInitGlobalModData.Add(TheAlcoholic.OnInitModData)
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