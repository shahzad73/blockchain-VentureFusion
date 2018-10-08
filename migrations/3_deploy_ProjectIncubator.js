var Incubator = artifacts.require("Incubator");


module.exports = function(deployer, network, accounts) {


  return deployer.then(() =>
  {
	  return deployer.deploy(Incubator, 98, 2, web3.eth.accounts[0], 10, {gas: 6721975});
  }).then(() => {
	    var inc = Incubator.at(Incubator.address);
		inc.transferOwnership(web3.eth.accounts[1])
  })
  


};
