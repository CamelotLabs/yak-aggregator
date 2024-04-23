const {
    arbitrum: arb,
    arbitrumSepolia: arbsep,
    sanko: sanko,
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
    "sanko": {
        adapterWhitelist: [
            'CamelotAdapter',
            'WETHAdapter',
            'CamelotAlgebraAdapter',
        ],
        hopTokens: [
            sanko.assets.WDMT,
            sanko.assets.USDC
        ],
        wnative: sanko.assets.WDMT
    },
    "xai": {
        adapterWhitelist: [
            'CamelotAdapter',
            'WETHAdapter',
            'CamelotAlgebraAdapter',
        ],
        hopTokens: [
            xai.assets.WXAI,
            xai.assets.USDC,
            xai.assets.WETH
        ],
        wnative: xai.assets.WXAI
    }
}