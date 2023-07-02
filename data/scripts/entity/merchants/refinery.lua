


function Refinery.getRiftOre(material)
    if material.value == 0 then return goods["Iron Ore"]:good()
    elseif material.value == 1 then return goods["Titanium Ore"]:good()
    elseif material.value == 2 then return goods["Naonite Ore"]:good()
    elseif material.value == 3 then return goods["Trinium Ore"]:good()
    elseif material.value == 4 then return goods["Xanion Ore"]:good()
    elseif material.value == 5 then return goods["Ogonite Ore"]:good()
    else return goods["Avorion Ore"]:good()
    end
end
