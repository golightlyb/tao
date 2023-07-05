BuildingKnowledgeMerchant.interactionThreshold = -1000
BuildingKnowledgeMerchant.shop.relationThreshold = -1000

function BuildingKnowledgeMerchant.initUI()
    BuildingKnowledgeMerchant.shop:initUI("Building Knowledge"%_t, "Building Knowledge"%_t, "Building Knowledge"%_t, "data/textures/icons/building-knowledge.png", {showSpecialOffer = false})
    BuildingKnowledgeMerchant.shop.tabbedWindow:deactivateTab(BuildingKnowledgeMerchant.shop.sellTab)
    BuildingKnowledgeMerchant.shop.tabbedWindow:deactivateTab(BuildingKnowledgeMerchant.shop.buyBackTab)
end