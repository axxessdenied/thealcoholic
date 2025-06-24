-- (c) 2024 - axxessdenied [Nick Slusarczyk]

-- ACTIONS

local base_perform_eat = ISEatFoodAction.perform

function ISEatFoodAction:perform()
    base_perform_eat(self)
    if TheAlcoholic.values.DebugMode == true
    then
        print("The Alcoholic: ISEatFoodAction:perform()")
    end
    if self.item:isAlcoholic()
    then
        TheAlcoholic.drankAlcohol(self.character)
    end
end