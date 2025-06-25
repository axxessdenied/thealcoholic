require 'TimedActions/ISDrinkFluidAction'
local base_new_drink = ISDrinkFluidAction.new

function ISDrinkFluidAction:new(character, item, percentage)
    local o = base_new_drink(self, character, item, percentage)
    if TheAlcoholic.values.DebugMode == true
    then
        print("The Alcoholic: ISDrinkFluidAction:new()")
    end
    o.fluid = o.fluidContainer:getPrimaryFluid()
    o.isFluidAlcoholic = o.fluid:isCategory(FluidCategory.Alcoholic)
    return o
end

local base_perform_drink = ISDrinkFluidAction.perform

function ISDrinkFluidAction:perform()
    --local fluid = self.item:getFluidContainer():getPrimaryFluid()
    base_perform_drink(self)
    
    if TheAlcoholic.values.DebugMode == true
    then
        print("The Alcoholic: ISDrinkFluidAction:perform()")
    end
    if self.isFluidAlcoholic
    then
        TheAlcoholic.drankAlcohol(self.character)
    end
end