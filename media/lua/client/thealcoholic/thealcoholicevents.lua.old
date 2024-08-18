-- initialize variables in mod data

function alcoholicDataInit(playernum, character)
    local player = getSpecificPlayer(playernum); 

    -- hours since last drink
    if player:getModData().AlcoholicTimeSinceLastDrink == nil 
    then
        player:getModData().AlcoholicTimeSinceLastDrink = 0;
    end

    -- progress towards becoming an alcoholic
    if player:getModData().AlcoholicThreshold == nil 
    then
        player:getModData().AlcoholicThreshold = 0;
    end

    -- added stress from not drinking
    if player:getModData().AlcoholicStress == nil
    then
        player:getModData().AlcoholicStress = 0;
    end

    if player:HasTrait("Alcoholic")
    then
        player:getInventory():AddItem("Base.BeerEmpty");
    end
end

Events.OnCreatePlayer.Add(alcoholicDataInit);

function alcoholicExistingGameInit(player)
    if player:getModData().AlcoholicTimeSinceLastDrink == nil 
    then
        player:getModData().AlcoholicTimeSinceLastDrink = 0;
    end

    if player:getModData().AlcoholicThreshold == nil 
    then
        player:getModData().AlcoholicThreshold = 0;
    end
    if player:getModData().AlcoholicStress == nil
    then
        player:getModData().AlcoholicStress = 0;
    end
end

Events.OnPlayerUpdate.Add(alcoholicExistingGameInit);

function alcoholicTrait()
    for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);

        if player:HasTrait("Alcoholic") 
        then
            local timeSinceDrink = player:getModData().AlcoholicTimeSinceLastDrink;
            
            -- debug
            print("Hours since last drink:"..timeSinceDrink);
            print("Alcoholic stress level:"..player:getModData().AlcoholicStress);
            -- end debug
            
            if timeSinceDrink > THEALCOHOLIC.VALUES.drop4[THEALCOHOLIC.SETTINGS.options.drop4] and timeSinceDrink <= THEALCOHOLIC.VALUES.drop5[THEALCOHOLIC.SETTINGS.options.drop5]
            then
                increaseStress(player, 0.10)
                increaseFatigue(player, 0.05, ZombRand(7))
                decreaseHappiness(player, 2)
            elseif timeSinceDrink > THEALCOHOLIC.VALUES.drop5[THEALCOHOLIC.SETTINGS.options.drop5] and timeSinceDrink <= THEALCOHOLIC.VALUES.drop6[THEALCOHOLIC.SETTINGS.options.drop6]
            then
                increaseStress(player, 0.15)
                increaseFatigue(player, 0.05, ZombRand(4))
                decreaseHappiness(player, 6)
                if (THEALCOHOLIC.SETTINGS.options.box1) == true
                then
                    increasePain(player, "Head", ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]), ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]))
                end
            elseif timeSinceDrink > THEALCOHOLIC.VALUES.drop6[THEALCOHOLIC.SETTINGS.options.drop6] and timeSinceDrink <= THEALCOHOLIC.VALUES.drop7[THEALCOHOLIC.SETTINGS.options.drop7]
            then
                increaseStress(player, 0.25)
                increaseFatigue(player, 0.05, ZombRand(3))
                decreaseHappiness(player, 7)
                if (THEALCOHOLIC.SETTINGS.options.box1) == true
                then
                    increasePain(player, "Head", ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]+10), ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]-1))
                end
                if (THEALCOHOLIC.SETTINGS.options.box2) == true
                then
                    increasePoison(player, ZombRand(THEALCOHOLIC.VALUES.drop10[THEALCOHOLIC.SETTINGS.options.drop10]), ZombRand(THEALCOHOLIC.VALUES.drop12[THEALCOHOLIC.SETTINGS.options.drop12]))
                end
            elseif timeSinceDrink > THEALCOHOLIC.VALUES.drop7[THEALCOHOLIC.SETTINGS.options.drop7] and timeSinceDrink <= THEALCOHOLIC.VALUES.drop8[THEALCOHOLIC.SETTINGS.options.drop8]
            then
                increaseStress(player, 0.3)
                increaseFatigue(player, 0.1, ZombRand(2))
                decreaseHappiness(player, 10)
                if (THEALCOHOLIC.SETTINGS.options.box1) == true
                then
                    increasePain(player, "Head", ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]+15), ZombRand(THEALCOHOLIC.VALUES.drop11[THEALCOHOLIC.SETTINGS.options.drop11]-2))
                end
                if (THEALCOHOLIC.SETTINGS.options.box2) == true
                then
                    increasePoison(player, ZombRand(THEALCOHOLIC.VALUES.drop10[THEALCOHOLIC.SETTINGS.options.drop10]+20), ZombRand(THEALCOHOLIC.VALUES.drop12[THEALCOHOLIC.SETTINGS.options.drop12]-1))
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
end

Events.EveryHours.Add(alcoholicTrait);

function alcoholicStressCheck()
    for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
        if player:HasTrait("Alcoholic")
        then
            alcoholicStress(player)
        end
    end
end

Events.EveryTenMinutes.Add(alcoholicStressCheck)

--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISDrinkFromBottle = ISBaseTimedAction:derive("ISDrinkFromBottle");

function ISDrinkFromBottle:isValid()
    return self.character:getInventory():contains(self.item);
end

function ISDrinkFromBottle:update()
    self.item:setJobDelta(self:getJobDelta());
    if self.eatAudio ~= 0 and not self.character:getEmitter():isPlaying(self.eatAudio) then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
    end
end

function ISDrinkFromBottle:start()
    if self.eatSound ~= '' then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
    end
    if self.item:getCustomMenuOption() then
        self.item:setJobType(self.item:getCustomMenuOption())
    else
        self.item:setJobType(getText("ContextMenu_Drink"));
    end
    self.item:setJobDelta(0.0);

    self:setActionAnim(CharacterActionAnims.Drink);
    self:setOverrideHandModels(nil, self.item);
    if self.item:getEatType() then
        self:setAnimVariable("FoodType", self.item:getEatType());
        if self.item:getEatType() == "Pot" then
            self:setOverrideHandModels(self.item, nil);
        end
    else
        self:setAnimVariable("FoodType", "bottle");
    end
    self.character:reportEvent("EventEating");
end

function ISDrinkFromBottle:stop()
    if self.eatAudio ~= 0 and self.character:getEmitter():isPlaying(self.eatAudio) then
        self.character:getEmitter():stopSound(self.eatAudio);
    end
    self.item:setJobDelta(0.0);
    if self.character:getInventory():contains(self.item) then
        self:drink(self.item, self:getJobDelta());
    end
    ISBaseTimedAction.stop(self);
end

function ISDrinkFromBottle:perform()
    if self.eatAudio ~= 0 and self.character:getEmitter():isPlaying(self.eatAudio) then
        self.character:getEmitter():stopSound(self.eatAudio);
    end
    self.item:setJobDelta(0.0);
    self.item:getContainer():setDrawDirty(true);
    self:drink(self.item, 1);

    -- needed to remove from queue / start next.
    -- custom code
    local player = self.character;
    local drunk = player:getStats():getDrunkenness();

        ISBaseTimedAction.perform(self);
end

function ISDrinkFromBottle:drink(food, percentage)
    -- calcul the percentage drank
    if percentage > 0.95 then
        percentage = 1.0;
    end
    local uses = math.floor(self.uses * percentage + 0.001);

    for i=1,uses do
        if not self.character:getInventory():contains(self.item) then
            break
        end
        if self.character:getStats():getThirst() > 0 then
            self.character:getStats():setThirst(self.character:getStats():getThirst() - 0.1);
            if self.character:getStats():getThirst() < 0 then
                self.character:getStats():setThirst(0);
            end
            if self.item:isTaintedWater() then
                --tainted water shouldn't kill the player but make them sick - dangerous when sick
                local bodyDamage	= self.character:getBodyDamage();
                local stats			= self.character:getStats();
                if bodyDamage:getPoisonLevel() < 20 and stats:getSickness() < 0.3 then
                    bodyDamage:setPoisonLevel(math.min(bodyDamage:getPoisonLevel() + 10, 20));
                end
            end
            if self.item:isAlcoholic()
            then
                drankAlcohol(player);
            else
                noDrinkAlcohol(player);
            end
        end
    end
end

function ISDrinkFromBottle:new (character, item, uses)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.item = item;
    o.stopOnWalk = false;
    o.stopOnRun = true;
    o.uses = uses;
    if o.uses < 1 then
        o.uses = 1;
    end
    if not o.uses then
        o.uses = 1;
    end
    o.maxTime = o.uses * 30;
    if o.maxTime < 120 then
        o.maxTime = 120;
    end
    o.eatSound = "DrinkingFromBottle";
    o.eatAudio = 0
    o.tick = 0;
    o.ignoreHandsWounds = true;
    return o
end
