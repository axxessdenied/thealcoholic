-- (c) 2024 - axxessdenied [Nick Slusarczyk]

--methods for the alcoholic mod

function TheAlcoholic.increaseFatigue(player, fatigue, chance)
    if chance == 0
    then
        local currentFatigue = player:getStats():getFatigue()

        if currentFatigue + fatigue > 0.99
        then
            player:getStats():setFatigue(0.99)
        else
            player:getStats():setFatigue(currentFatigue + fatigue)
        end
    end
end

function TheAlcoholic.decreaseEndurance(player, endurance, chance)
    if chance == 0
    then
        local currentEndurance = player:getStats():getEndurance()

        if currentEndurance < endurance
        then
            player:getStats():setEndurance(0)
        else
            player:getStats():setEndurance(currentEndurance - endurance)
        end
    end
end

function TheAlcoholic.increaseStress(player, stress)
    local currentStress = player:getStats():getStress() - player:getStats():getStressFromCigarettes() 
    if currentStress + stress > 0.99
    then
        player:getStats():setStress(1)
    else
        player:getStats():setStress(currentStress + stress)
    end
end

function TheAlcoholic.decreaseStress(player, stress)
    local currentStress = player:getStats():getStress() - player:getStats():getStressFromCigarettes() 

    if currentStress < stress
    then
        player:getStats():setStress(0)
    else
        player:getStats():setStress(currentStress - stress)
    end
end

function TheAlcoholic.alcoholicStress(player)
    -- remove other stress factors
    local currentStress = player:getStats():getStress() - player:getStats():getStressFromCigarettes() - player:getModData().AlcoholicPrevStress
    player:getModData().AlcoholicPrevStress = player:getModData().AlcoholicStress
    player:getStats():setStress(currentStress + player:getModData().AlcoholicStress)
    
end

function TheAlcoholic.increaseHappiness(player, happiness)
    local currentHappiness = player:getBodyDamage():getUnhappynessLevel()
    if currentHappiness < happiness
    then
        player:getBodyDamage():setUnhappynessLevel(0)
    else
        player:getBodyDamage():setUnhappynessLevel(currentHappiness - happiness)
    end
end

function TheAlcoholic.decreaseHappiness(player, unhappiness)
    local bodyDamage = player:getBodyDamage()
    local temp = bodyDamage:getBoredomLevel()
    local currentUnhappiness = player:getBodyDamage():getUnhappynessLevel()
    if unhappiness + currentUnhappiness > 99
    then
        player:getBodyDamage():setUnhappynessLevel(100)
    else
        player:getBodyDamage():setUnhappynessLevel(currentUnhappiness + unhappiness)
    end
end

function TheAlcoholic.increasePain(player, bodyPart, pain, chance)
    if chance == 0
    then
        local bodyPartType = BodyPartType.FromString(bodyPart)
        local playerBodyPart = player:getBodyDamage():getBodyPart(bodyPartType)
        local currentPain = playerBodyPart:getPain()

        if currentPain + pain > 99
        then
            playerBodyPart:setAdditionalPain(99)
        else
            playerBodyPart:setAdditionalPain(currentPain + pain)
        end
    end
end

function TheAlcoholic.decreasePain(player, bodyPart, pain)
    local bodyPartType = BodyPartType.FromString(bodyPart)
    local playerBodyPart = player:getBodyDamage():getBodyPart(bodyPartType)
    local currentPain = playerBodyPart:getPain()

    if currentPain < pain
    then
        playerBodyPart:setAdditionalPain(0)
    else
        playerBodyPart:setAdditionalPain(currentPain - pain)
    end
end

function TheAlcoholic.increasePoison(player, poison, chance)
    local currentFoodPoison = player:getBodyDamage():getFoodSicknessLevel()
    if chance == 0
    then
        if player:HasTrait("WeakStomach")
        then
            poison = poison * 1.25
        end
        if player:HasTrait("ProneToIllness")
        then
            poison = poison * 1.2
        end
        if player:HasTrait("Resilient")
        then
            poison = poison * 0.8
        end
        if player:HasTrait("IronGut")
        then
            poison = poison * 0.8
        end

        if currentFoodPoison + poison > 95
        then
            player:getBodyDamage():setFoodSicknessLevel(95)
        else
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + poison)
            player:getModData().AlcoholicPoisonDamageTotal = player:getModData().AlcoholicPoisonDamageTotal + poison
        end
    end
end

function TheAlcoholic.increaseWithdrawalSickness(player, sickness, chance)
    if chance == 0
    then
        if player:HasTrait("WeakStomach")
        then
            sickness = sickness * 1.25
        end
        if player:HasTrait("ProneToIllness")
        then
            sickness = sickness * 1.25
        end
        if player:HasTrait("IronGut")
        then
            sickness = sickness * 0.8
        end
        if player:HasTrait("Resilient")
        then
            sickness = sickness * 0.8
        end
        if player:getModData().AlcoholicWithdrawalSickness < TheAlcoholic.values.max_withdrawal[player:getModData().AlcoholicWithdrawalPhase]
        then
            player:getModData().AlcoholicWithdrawalSickness = player:getModData().AlcoholicWithdrawalSickness + sickness
        end
    end
end

function TheAlcoholic.removeWithdrawalSickness(player)
    player:getModData().AlcoholicWithdrawalSickness = 0
    player:getModData().AlcoholicWithrawalPhase = 0
    player:getModData().AlcoholicHasWithdrawalSickness = false
    --stress
    local stress = player:getStats():getStress() - player:getStats():getStressFromCigarettes()
    player:getStats():setStress(stress * 0.5)
    --happiness
    local happiness = player:getBodyDamage():getUnhappynessLevel()
    player:getBodyDamage():setUnhappynessLevel(happiness * 0.5)
    --fatigue
    local fatigue = player:getStats():getFatigue()
    player:getStats():setFatigue(fatigue * 0.5)
    --headaches
    if TheAlcoholic.options.headaches == true
    then
        local head = player:getBodyDamage():getBodyPart(BodyPartType.FromString("Head")):getPain()
        player:getBodyDamage():getBodyPart(BodyPartType.FromString("Head")):setAdditionalPain(head * 0.5)
    end
    --food poisoning
    local foodPoison = player:getBodyDamage():getFoodSicknessLevel()
    player:getBodyDamage():setFoodSicknessLevel(foodPoison - player:getModData().AlcoholicPoisonDamageTotal * 0.5)
end

function TheAlcoholic.decreaseSanity(player, sanity, chance)
    local currentSanity = player:getStats():getSanity()
end

-- reduces how drunk 
function TheAlcoholic.drunkResistance(player)
    local resistance = TheAlcoholic.values.base_tolerance[TheAlcoholic.options.base_tolerance] - player:getModData().AlcoholicTolerance
    if player:HasTrait("Alcoholic")
    then
        player:getStats():setDrunkenness(player:getStats():getDrunkenness() * resistance)
    end
end

function TheAlcoholic.alcoholicDrankAlcohol(player)
    TheAlcoholic.drunkResistance(player)
    TheAlcoholic.decreaseStress(player, TheAlcoholic.values.stress_per_drink[TheAlcoholic.options.stress_per_drink])
    if TheAlcoholic.options.happiness == true
    then
        TheAlcoholic.increaseHappiness(player, TheAlcoholic.values.happiness_per_drink[TheAlcoholic.options.happiness_per_drink])
    end
    if TheAlcoholic.options.headaches == true
    then
        TheAlcoholic.decreasePain(player, "Head", TheAlcoholic.values.pain_per_drink[TheAlcoholic.options.pain_per_drink])
    end
    if TheAlcoholic.options.withdrawal == true
    then
        if player:getModData().AlcoholicWithdrawalPhase > 0
        then
            TheAlcoholic.removeWithdrawalSickness(player)
        end
    end
end

function TheAlcoholic.drankAlcohol(player)
    if getTimestampMs() - player:getModData().LastDrinkTimestamp < 5000
    then
        return
    end
    player:getModData().LastDrinkTimestamp = getTimestampMs()

    player:getModData().AlcoholicHasDrank = true
    player:getModData().AlcoholicDrinksPerDay = player:getModData().AlcoholicDrinksPerDay + 1
    player:getModData().AlcoholicTimeSinceLastDrink = 0
    player:getModData().AlcoholicDrinksTotal = player:getModData().AlcoholicDrinksTotal + 1
    player:getModData().AlcoholicThreshold = player:getModData().AlcoholicThreshold + 4

    if player:getModData().AlcoholicThreshold > TheAlcoholic.values.thresholdtogain[TheAlcoholic.options.thresholdtogain]+1
    then
        player:getModData().AlcoholicThreshold = TheAlcoholic.values.thresholdtogain[TheAlcoholic.options.thresholdtogain]+1
    end
    player:getModData().AlcoholicPrevStress = 0
    player:getModData().AlcoholicStress = 0
    if player:HasTrait("Alcoholic")
    then
        TheAlcoholic.alcoholicDrankAlcohol(player)
    end
end

function TheAlcoholic.noDrinkAlcohol(player)
    player:getModData().AlcoholicTimeSinceLastDrink = player:getModData().AlcoholicTimeSinceLastDrink + 1
    if player:getModData().AlcoholicTimeSinceLastDrink > TheAlcoholic.values.daystolose[TheAlcoholic.options.daystolose]+1
    then
        player:getModData().AlcoholicTimeSinceLastDrink = TheAlcoholic.values.daystolose[TheAlcoholic.options.daystolose]+1
    end
    player:getModData().AlcoholicThreshold = player:getModData().AlcoholicThreshold - 1
    if player:getModData().AlcoholicThreshold < 0
    then
        player:getModData().AlcoholicThreshold = 0
    end
    if player:HasTrait("Alcoholic")
    then
        player:getModData().AlcoholicStress = player:getModData().AlcoholicStress + 0.02
        if player:getModData().AlcoholicStress > TheAlcoholic.values.maxstress[TheAlcoholic.options.maxstress]
        then
            player:getModData().AlcoholicStress = TheAlcoholic.values.maxstress[TheAlcoholic.options.maxstress]
        end
    end
end