require 'TimedActions/ISDrinkFromBottle'

local base_perform_drink = ISDrinkFromBottle.perform

function ISDrinkFromBottle:perform()
    print("The Alcoholic: ISDrinkFromBottle:perform()")
    local fluid = self.item:getFluidContainer():getPrimaryFluid()
    base_perform_drink(self)
    
    if TheAlcoholic.values.DebugMode == true
    then
        print("The Alcoholic: ISDrinkFromBottle:perform()")
    end
    if fluid:isCategory(FluidCategory.Alcoholic)
    then
        print("The Alcoholic: ISDrinkFromBottle:perform()")
        TheAlcoholic.drankAlcohol(self.character)
    end
end