

function Refinery.getOre(material)
    if material.value == 0 then return goods["XIronOre"]:good()
    elseif material.value == 1 then return goods["XTitaniumOre"]:good()
    elseif material.value == 2 then return goods["XNaoniteOre"]:good()
    elseif material.value == 3 then return goods["XTriniumOre"]:good()
    elseif material.value == 4 then return goods["XXanionOre"]:good()
    elseif material.value == 5 then return goods["XOgoniteOre"]:good()
    else return goods["XAvorionOre"]:good()
    end
end

function Refinery.getScrap(material)
    if material.value == 0 then return goods["XScrapIron"]:good()
    elseif material.value == 1 then return goods["XScrapTitanium"]:good()
    elseif material.value == 2 then return goods["XScrapNaonite"]:good()
    elseif material.value == 3 then return goods["XScrapTrinium"]:good()
    elseif material.value == 4 then return goods["XScrapXanion"]:good()
    elseif material.value == 5 then return goods["XScrapOgonite"]:good()
    else return goods["XScrapAvorion"]:good()
    end
end

function Refinery.getRiftOre(material)
    if material.value == 0 then return goods["XIronOre"]:good()
    elseif material.value == 1 then return goods["XTitaniumOre"]:good()
    elseif material.value == 2 then return goods["XNaoniteOre"]:good()
    elseif material.value == 3 then return goods["XTriniumOre"]:good()
    elseif material.value == 4 then return goods["XXanionOre"]:good()
    elseif material.value == 5 then return goods["XOgoniteOre"]:good()
    else return goods["XAvorionOre"]:good()
    end
end
