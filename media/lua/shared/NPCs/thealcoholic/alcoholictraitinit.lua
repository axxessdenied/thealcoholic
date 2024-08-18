AlcoholicCharacterDetails = {}

AlcoholicCharacterDetails.DoTraits = function()
    local alcoholic = TraitFactory.addTrait("Alcoholic", getText("UI_trait_Alcoholic"), -4, getText("UI_trait_AlcoholicDesc"), false);
end

Events.OnGameBoot.Add(AlcoholicCharacterDetails.DoTraits);