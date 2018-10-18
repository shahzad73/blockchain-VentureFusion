var Incubator = artifacts.require("Incubator");


module.exports = function(deployer, network, accounts) {


  return deployer.then(() =>
  {
	  return deployer.deploy(Incubator, {gas: 6721975});
  });


};