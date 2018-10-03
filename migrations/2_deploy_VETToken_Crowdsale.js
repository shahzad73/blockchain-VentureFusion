var VentureFusion_VET = artifacts.require("VentureFusion_VET");
var VentureFusionVET_Crowdsale = artifacts.require("VentureFusionVET_Crowdsale");


module.exports = function(deployer, network, accounts) {

	var name = "Venture Fusion VET Token";
	var symbol = "VFVT";
	var decimals = 4;	
    var rate = new web3.BigNumber(1);
	const wallet = accounts[1];
	
	
  return deployer.then(() =>
  {
	  return deployer.deploy(VentureFusion_VET, name, symbol, decimals, {gas: 6721975})
  })
  .then(() => {
            return deployer.deploy(
                VentureFusionVET_Crowdsale,
                rate,
                wallet,
                VentureFusion_VET.address
            );
  });  
  

};