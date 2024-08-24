require 'Items/ProceduralDistributions'

function TheAlcoholic.addDistribution(data, locations)
    for i=1, #data
    do
        local item = data[i][1]
        local chance = data[i][2]

        for j = 1, #locations
        do
            local location = locations[j]

            if ProceduralDistributions.list[location] and ProceduralDistributions.list[location].items[item]
            then
                table.insert(ProceduralDistributions.list[location].items[item], item)
                table.insert(ProceduralDistributions.list[location].items[item], chance)
            end
        end
    end
end

local sBVars = TheAlcoholic.AutoDrink.sBVars
local flaskFullRarity = sBVars.LootSpawnChance * 0.1
local flaskEmptyRarity = sBVars.LootSpawnChance * 1

if sBVars.WorldSpawnFlasks == true
then
    TheAlcoholic.addDistribution(
        {
            {"TheAlcoholic.FlaskEmpty", flaskEmptyRarity},
            {"TheAlcoholic.FlaskFull", flaskFullRarity}
        },
        {
            "BathroomCabinet",
            "BathroomCounter",
            "BedroomDresser",
            "BedroomSideTable",
            "ClosetShelfGeneric",
            "DeskGeneric",
            "DresserGeneric",
            "FilingCabinetGeneric",
            "FridgeOffice",
            "GarageTools",
            "JunkHoard",
            "KitchenRandom",
            "LibraryCounter",
            "LivingRoomShelf",
            "LivingRoomSideTable",
            "Locker",
            "LockerArmyBedroom",
            "LockerClassy",
            "MechanicShelfMisc",
            "OfficeCounter",
            "OfficeDesk",
            "OfficeDeskHome",
            "OfficeDrawers",
            "OtherGeneric",
            "PlankStashMisc",
            "PoliceDesk",
            "RandomFiller",
            "SafehouseMedical",
            "ShelfGeneric",
            "WardrobeMan",
            "WardrobeManClassy",
            "WardrobeWoman",
            "WardrobeWomanClassy"
        }
    )
else
    TheAlcoholic.addDistribution(
        {
            {"TheAlcoholic.FlaskEmpty", flaskEmptyRarity},
            {"TheAlcoholic.FlaskFull", flaskFullRarity}
        },
        {}
    )
end
