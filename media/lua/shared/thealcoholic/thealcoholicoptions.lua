-- (c) 2024 - axxessdenied [Nick Slusarczyk]

TheAlcoholic = TheAlcoholic or {}

-- values for the mod
TheAlcoholic.values = {
    spawnitem = {"Nothing", "Base.BeerEmpty", "Base.BeerBottle", "Base.BeerCan", "Base.WhiskeyFull", "Base.Wine", "Base.Wine2", "Base.WineEmpty", "Base.WineEmpty2", "Base.WhiskeyEmpty"},
    threshold_build_max = { 0.1, 0.15, 0.20 },      --threshold build max
    base_tolerance = { 0.65, 0.60, 0.55 },          --base tolerance
    tolerance_drinks_per_day = { 8, 10, 12, 15 },   --tolerance drinks per day
    stress_per_drink = { 0.10, 0.15, 0.25, 0.50 },  --stress removed per drink
    happiness_per_drink = { 10, 15, 25, 50 },       --happiness per drink
    pain_per_drink = { 10, 15, 25, 50 },            --pain per drink
    withdrawal_phase1 = {12,18,24,48},              --phase 1
    withdrawal_phase2 = {24,48,72,96},              --phase 2
    withdrawal_phase3 = {48,72,96,120},             --phase 3
    withdrawal_phase4 = {72,96,120,144,168},        --phase 4
    daystolose = {504,672,1344,1920},               --sober values
    thresholdtogain = {200,400,800,1600},           --threshold values
    poisondmg = {25,35,45,55},                         --poison values
    headachedmg = {30,50,65,80},                    --headache values
    headachechance = {10,7,5,3},                    --headache chance
    withdrawal_chance = {10,7,5,2},                 --withdrawal sickness chance
    withdrawal_rate = {0.001,0.002,0.003,0.004},    --withdrawal rate
    max_withdrawal = {0.3,0.5,0.7,1.0},             --max withdrawal
    withdrawal_deathchance = {100,50,25,10},        --withdrawal death chance
    withdrawal_poisonchance = {50,20,10,4},         --withdrawal poison chance
    maxstress = {0.3,0.5,0.7,0.9},                  --max alcoholic stress
}

local bV = {
    SpawnItem = {"Nothing", "Base.BeerEmpty", "Base.BeerBottle", "Base.BeerCan", "Base.WhiskeyFull", "Base.Wine", "Base.Wine2", "Base.WineEmpty", "Base.WineEmpty2", "Base.WhiskeyEmpty"},
    ToleranceBuildMax = { 0.1, 0.15, 0.20 },        --tolerance build max
    BaseTolerance = { 0.65, 0.60, 0.55 },           --base tolerance
    ToleranceDrinksPerDay = { 8, 10, 12, 15 },      --tolerance drinks per day
    StressPerDrink = { 0.10, 0.15, 0.25, 0.50 },    --stress removed per drink
    HappinessPerDrink = { 10, 15, 25, 50 },         --happiness per drink
    PainPerDrink = { 10, 15, 25, 50 },              --pain per drink
    WithdrawalPhase1 = {12,18,24,48},               --phase 1
    WithdrawalPhase2 = {24,48,72,96},               --phase 2
    WithdrawalPhase3 = {48,72,96,120},              --phase 3
    WithdrawalPhase4 = {72,96,120,144,168},         --phase 4
    DaysToLose = {504,672,1344,1920},               --sober values
    ThresholdToGain = {200,400,800,1600},           --threshold values
    PoisonDamage = {25,35,45,55},                   --poison values
    HeadacheDamage = {30,50,65,80},                 --headache values
    HeadacheChance = {10,7,5,3},                    --headache chance
    WithdrawalChance = {10,7,5,2},                  --withdrawal sickness chance
    WithdrawalRate = {0.001,0.002,0.003,0.004},     --withdrawal rate
    MaxWithdrawal = {0.3,0.5,0.7,1.0},              --max withdrawal
    WithdrawalDeathChance = {100,50,25,10},         --withdrawal death chance
    WithdrawalPoisonChance = {50,20,10,4},          --withdrawal poison chance
    MaxStress = {0.3,0.5,0.7,0.9},                  --max alcoholic stress
}

function TheAlcoholic.OnInitModData()
    -- load sandbox options
    TheAlcoholic.options = {
        spawnitem = getSandboxOptions():getOptionByName("TheAlcoholic.SpawnItem"):getValue(),
        headaches = getSandboxOptions():getOptionByName("TheAlcoholic.Headaches"):getValue(),
        withdrawal = getSandboxOptions():getOptionByName("TheAlcoholic.Withdrawal"):getValue(),
        dynamic = getSandboxOptions():getOptionByName("TheAlcoholic.Dynamic"):getValue(),
        tolerance = getSandboxOptions():getOptionByName("TheAlcoholic.Tolerance"):getValue(),
        happiness = getSandboxOptions():getOptionByName("TheAlcoholic.Happiness"):getValue(),
        poison = getSandboxOptions():getOptionByName("TheAlcoholic.Poison"):getValue(),
        tolerance_build_max = getSandboxOptions():getOptionByName("TheAlcoholic.ToleranceBuildMax"):getValue(),
        tolerance_drinks_per_day = getSandboxOptions():getOptionByName("TheAlcoholic.ToleranceDrinksPerDay"):getValue(),
        base_tolerance = getSandboxOptions():getOptionByName("TheAlcoholic.BaseTolerance"):getValue(),
        stress_per_drink = getSandboxOptions():getOptionByName("TheAlcoholic.StressPerDrink"):getValue(),
        happiness_per_drink = getSandboxOptions():getOptionByName("TheAlcoholic.HappinessPerDrink"):getValue(),
        pain_per_drink = getSandboxOptions():getOptionByName("TheAlcoholic.PainPerDrink"):getValue(),
        withdrawal_phase1 = getSandboxOptions():getOptionByName("TheAlcoholic.WithdrawalPhase1"):getValue(),
        withdrawal_phase2 = getSandboxOptions():getOptionByName("TheAlcoholic.WithdrawalPhase2"):getValue(),
        withdrawal_phase3 = getSandboxOptions():getOptionByName("TheAlcoholic.WithdrawalPhase3"):getValue(),
        withdrawal_phase4 = getSandboxOptions():getOptionByName("TheAlcoholic.WithdrawalPhase4"):getValue(),
        daystolose = getSandboxOptions():getOptionByName("TheAlcoholic.DaysToLose"):getValue(),
        thresholdtogain = getSandboxOptions():getOptionByName("TheAlcoholic.ThresholdToGain"):getValue(),
        poisondmg = getSandboxOptions():getOptionByName("TheAlcoholic.PoisonDamage"):getValue(),
        headachedmg = getSandboxOptions():getOptionByName("TheAlcoholic.HeadacheDamage"):getValue(),
        headachechance = getSandboxOptions():getOptionByName("TheAlcoholic.HeadacheChance"):getValue(),
        withdrawal_chance = getSandboxOptions():getOptionByName("TheAlcoholic.WithdrawalChance"):getValue(),
        withdrawal_rate = getSandboxOptions():getOptionByName("TheAlcoholic.WithdrawalRate"):getValue(),
        withdrawal_deathchance = getSandboxOptions():getOptionByName("TheAlcoholic.WithdrawalDeathChance"):getValue(),
        withdrawal_poisonchance = getSandboxOptions():getOptionByName("TheAlcoholic.WithdrawalPoisonChance"):getValue(),
        maxstress = getSandboxOptions():getOptionByName("TheAlcoholic.MaxStress"):getValue(),
        debugmode = getSandboxOptions():getOptionByName("TheAlcoholic.DebugMode"):getValue(),
    }

    TheAlcoholic.sBVars = SandboxVars.TheAlcoholic
    
    local sBVars = TheAlcoholic.sBVars
    
    -- set the values
    TheAlcoholic.values.SpawnItem               =       sBVars.UseSpawnItemCustom and sBVars.SpawnItemCustom or bV.SpawnItem[sBVars.SpawnItem]
    TheAlcoholic.values.Headaches               =       sBVars.Headaches
    TheAlcoholic.values.Withdrawal              =       sBVars.Withdrawal
    TheAlcoholic.values.Dynamic                 =       sBVars.Dynamic
    TheAlcoholic.values.Tolerance               =       sBVars.Tolerance
    TheAlcoholic.values.Happiness               =       sBVars.Happiness
    TheAlcoholic.values.Poison                  =       sBVars.Poison
    TheAlcoholic.values.ToleranceBuildMax       =       sBVars.UseToleranceBuildMaxCustom and 1 / sBVars.ToleranceBuildMaxCustom or bV.ToleranceBuildMax[sBVars.ToleranceBuildMax]
    TheAlcoholic.values.ToleranceDrinksPerDay   =       sBVars.UseToleranceDrinksPerDayCustom and sBVars.ToleranceDrinksPerDayCustom or bV.ToleranceDrinksPerDay[sBVars.ToleranceDrinksPerDay]
    TheAlcoholic.values.BaseTolerance           =       sBVars.UseBaseToleranceCustom and 1.0 - 1 / sBVars.BaseToleranceCustom or bV.BaseTolerance[sBVars.BaseTolerance]
    TheAlcoholic.values.StressPerDrink          =       sBVars.UseStressPerDrinkCustom and 1 / sBVars.StressPerDrinkCustom or bV.StressPerDrink[sBVars.StressPerDrink]
    TheAlcoholic.values.HappinessPerDrink       =       sBVars.UseHappinessPerDrinkCustom and sBVars.HappinessPerDrinkCustom or bV.HappinessPerDrink[sBVars.HappinessPerDrink]
    TheAlcoholic.values.PainPerDrink            =       sBVars.UsePainPerDrinkCustom and sBVars.PainPerDrinkCustom or bV.PainPerDrink[sBVars.PainPerDrink]
    TheAlcoholic.values.WithdrawalPhase1        =       sBVars.UseWithdrawalPhase1Custom and sBVars.WithdrawalPhase1Custom or bV.WithdrawalPhase1[sBVars.WithdrawalPhase1]
    TheAlcoholic.values.WithdrawalPhase2        =       sBVars.UseWithdrawalPhase2Custom and sBVars.WithdrawalPhase2Custom or bV.WithdrawalPhase2[sBVars.WithdrawalPhase2]
    TheAlcoholic.values.WithdrawalPhase3        =       sBVars.UseWithdrawalPhase3Custom and sBVars.WithdrawalPhase3Custom or bV.WithdrawalPhase3[sBVars.WithdrawalPhase3]
    TheAlcoholic.values.WithdrawalPhase4        =       sBVars.UseWithdrawalPhase4Custom and sBVars.WithdrawalPhase4Custom or bV.WithdrawalPhase4[sBVars.WithdrawalPhase4]
    TheAlcoholic.values.DaysToLose              =       sBVars.UseDaysToLoseCustom and 24 * sBVars.DaysToLoseCustom or bV.DaysToLose[sBVars.DaysToLose]
    TheAlcoholic.values.ThresholdToGain         =       sBVars.UseThresholdToGainCustom and sBVars.ThresholdToGainCustom or bV.ThresholdToGain[sBVars.ThresholdToGain]
    TheAlcoholic.values.PoisonDamage            =       sBVars.UsePoisonDamageCustom and sBVars.PoisonDamageCustom or bV.PoisonDamage[sBVars.PoisonDamage]
    TheAlcoholic.values.HeadacheDamage          =       sBVars.UseHeadacheDamageCustom and sBVars.HeadacheDamageCustom or bV.HeadacheDamage[sBVars.HeadacheDamage]
    TheAlcoholic.values.HeadacheChance          =       sBVars.UseHeadacheChanceCustom and sBVars.HeadacheChanceCustom or bV.HeadacheChance[sBVars.HeadacheChance]
    TheAlcoholic.values.WithdrawalChance        =       sBVars.UseWithdrawalChanceCustom and sBVars.WithdrawalChanceCustom or bV.WithdrawalChance[sBVars.WithdrawalChance]
    TheAlcoholic.values.WithdrawalRate          =       sBVars.UseWithdrawalRateCustom and sBVars.WithdrawalRateCustom or bV.WithdrawalRate[sBVars.WithdrawalRate]
    TheAlcoholic.values.WithdrawalDeathChance   =       sBVars.UseWithdrawalDeathChanceCustom and sBVars.WithdrawalDeathChanceCustom or bV.WithdrawalDeathChance[sBVars.WithdrawalDeathChance]
    TheAlcoholic.values.WithdrawalPoisonChance  =       sBVars.UseWithdrawalPoisonChanceCustom and sBVars.WithdrawalPoisonChanceCustom or bV.WithdrawalPoisonChance[sBVars.WithdrawalPoisonChance]
    TheAlcoholic.values.MaxStress               =       sBVars.UseMaxStressCustom and 1 / sBVars.MaxStressCustom or bV.MaxStress[sBVars.MaxStress]
    TheAlcoholic.values.DebugMode               =       sBVars.DebugMode
    TheAlcoholic.values.MaxWithdrawal           =       {
        sBVars.UseCustomWithdrawalPhase1Custom and sBVars.WithdrawalPhase1Custom or bV.WithdrawalPhase1[sBVars.WithdrawalPhase1],
        sBVars.UseCustomWithdrawalPhase2Custom and sBVars.WithdrawalPhase2Custom or bV.WithdrawalPhase2[sBVars.WithdrawalPhase2],
        sBVars.UseCustomWithdrawalPhase3Custom and sBVars.WithdrawalPhase3Custom or bV.WithdrawalPhase3[sBVars.WithdrawalPhase3],
        sBVars.UseCustomWithdrawalPhase4Custom and sBVars.WithdrawalPhase4Custom or bV.WithdrawalPhase4[sBVars.WithdrawalPhase4],
    }
end

Events.OnInitGlobalModData.Add(TheAlcoholic.OnInitModData)