const { deployAdapter, addresses } = require('../../utils')
const { WDMT } = addresses.sanko.assets

const networkName = 'sanko'
const tags = [ 'weth' ]
const name = 'WETHAdapter'
const contractName = 'WNativeAdapter'

const gasEstimate = 80_000
const wnative = WDMT
const args = [ wnative, gasEstimate ]

module.exports = deployAdapter(networkName, tags, name, contractName, args)