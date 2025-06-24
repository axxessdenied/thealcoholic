require 'TimedActions/ISDrinkFluidAction'

local base_perform_drink = ISDrinkFluidAction.perform

function ISDrinkFluidAction:perform()
    print("The Alcoholic: ISDrinkFluidAction:perform()")
    local fluid = self.item:getFluidContainer():getPrimaryFluid()
    base_perform_drink(self)
    
    if TheAlcoholic.values.DebugMode == true
    then
        print("The Alcoholic: ISDrinkFluidAction:perform()")
    end
    if fluid:isCategory(FluidCategory.Alcoholic)
    then
        print("The Alcoholic: ISDrinkFluidAction:perform()")
        TheAlcoholic.drankAlcohol(self.character)
    end
end