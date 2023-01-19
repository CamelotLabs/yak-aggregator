const { 
    avalanche: ava, 
    dogechain: dog, 
    arbitrum: arb
} = require('./addresses.json')

module.exports = {
    "avalanche": {
        adapterWhitelist: [
            'TraderJoeAdapter',
            'PangolinAdapter',
            'SushiswapAdapter',
      
            'SynapseAdapter',
            'AxialAS4DAdapter',
            'PlatypusAdapter',
            
            'CurveAtricryptoAdapter',
            'Curve3poolV2Adapter',
            'Curve3poolfAdapter',
            'CurveAaveAdapter',
            'CurveUSDCAdapter',
            'CurveYUSDAdapter',
            
            'LiquidityBookAdapter',
            'KyberElasticAdapter',
            'WoofiV2Adapter',
            'GeodeWPAdapter',
            'GmxAdapter',
            
            'SAvaxAdapter',
            'WAvaxAdapter',
        ],
        hopTokens: [
            ava.assets.WAVAX,
            ava.assets.WETHe,
            ava.assets.USDTe,
            ava.assets.USDC,
            ava.assets.USDCe,
            ava.assets.WBTCe,
            ava.assets.DAIe,
            ava.assets.USDt,
          ],
        wnative: ava.assets.WAVAX
    }, 
    "dogechain": {
        adapterWhitelist: [
            'DogeSwapAdapter',
            'KibbleSwapAdapter',
            'YodeSwapAdapter',
            'QuickswapAdapter'
        ],
        hopTokens: [
            dog.assets.ETH,
            dog.assets.USDC,
            dog.assets.USDT,
            dog.assets.WWDOGE,
        ], 
        wnative: dog.assets.WWDOGE
    },
    "arbitrum": {
        adapterWhitelist: [
            'BalancerV2Adapter',
            'Curve3cryptoAdapter',
            'Curve2stableAdapter',
            'CurveFraxVstAdapter',
            'CurveFraxBpAdapter',
            'CurveMetaAdapter',
            'DodoV1Adapter',
            'DodoV2Adapter',
            'GmxAdapter',
            'SaddleArbUsdAdapter',
            'SaddleArbUsdV2Adapter',
            'SushiswapAdapter',
            'SwaprAdapter',
            'UniswapV3Adapter',
            'LiquidityBookAdapter',
            'KyberElasticAdapter',
            'WoofiV2Adapter',
        ],
        hopTokens: [
            arb.assets.WETH,
            arb.assets.WBTC,
            arb.assets.USDC,
            arb.assets.USDT,
            arb.assets.DAI,
        ], 
        wnative: arb.assets.WETH
    }
}