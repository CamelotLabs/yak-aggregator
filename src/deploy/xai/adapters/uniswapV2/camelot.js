const { deployAdapter, addresses } = require('../../../utils')
const { factory } = addresses.xai.camelot

const networkName = 'xai'
const contractName = 'CamelotAdapter'
const tags = [ 'camelot', 'camelot_v2' ]
const name = contractName
const gasEstimate = 238_412
const args = [ name, factory, gasEstimate ]

module.exports = deployAdapter(networkName, tags, contractName, contractName, args)