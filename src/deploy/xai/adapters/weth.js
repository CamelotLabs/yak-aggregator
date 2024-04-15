const { deployAdapter, addresses } = require('../../utils')
const { WXAI } = addresses.xai.assets

const networkName = 'xai'
const tags = [ 'weth' ]
const name = 'WETHAdapter'
const contractName = 'WNativeAdapter'

const gasEstimate = 80_000
const wnative = WXAI
const args = [ wnative, gasEstimate ]

module.exports = deployAdapter(networkName, tags, name, contractName, args)