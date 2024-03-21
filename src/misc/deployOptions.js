const {
    arbitrum: arb,
    arbitrumSepolia: arbsep,
    xai: xai
} = require('./addresses.json')

module.exports = {
    "arbitrum": {
        adapterWhitelist: [
            'CamelotAdapter',
            'WETHAdapter',
            'CamelotAlgebraAdapter',
        ],
        hopTokens: [
            arb.assets.WETH,
            arb.assets.WBTC,
            arb.assets.USDC,
            arb.assets.USDCe,
            arb.assets.ARB,
            arb.assets.USDT,
            arb.assets.DAI,
        ], 
        wnative: arb.assets.WETH
    },
    "arbitrumSepolia": {
        adapterWhitelist: [
            'CamelotAdapter',
            'WETHAdapter',
            'CamelotAlgebraAdapter',
        ],
        hopTokens: [
            arbsep.assets.WETH,
            arbsep.assets.USDC,
        ],
        wnative: arbsep.assets.WETH
    },
    "xai": {
        adapterWhitelist: [
            'CamelotAdapter',
            'WETHAdapter',
            'CamelotAlgebraAdapter',
        ],
        hopTokens: [
            xai.assets.WETH,
            xai.assets.USDC,
        ],
        wnative: xai.assets.WETH
    }
}