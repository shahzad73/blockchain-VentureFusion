var Incubator = artifacts.require("./Incubator.sol");
var projectEquity = artifacts.require("./ProjectEquity.sol");
const truffleAssert = require('truffle-assertions');

contract('Incubator', function(accounts) {


  beforeEach(async () => {

  });

  

  it("Set Incubator Defaults", async () => {  
    
	const meta = await Incubator.deployed();
	
	var percent = (await meta.incubatorOwnerPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 3000, "Expected value 3000 was not returned");
	
	var percent = (await meta.ventureFusionPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 2000, "Expected value 2000 was not returned");
	
	var percent = (await meta.transactionPriceInTokens.call()).toNumber();
	assert.equal(percent.valueOf(), 10, "Expected value 10 was not returned");
	
  });



  
  


  it("Create new project and make transfers", async () => {  
  
	const ventureFusionAccount = accounts[0];
	const incubatorOwner1 = accounts[1];
	const projectOwner = accounts[3];
	 
 	 var meta = await Incubator.deployed();

	 let tx = await meta.addNewProject("Test Proj 101", projectOwner, 1000, {from : incubatorOwner1});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 101" && ev.ProjectNo == 0;
     });
	 var zz = await meta.incubatorProjects(0);	 
	 var inc = await projectEquity.at(zz[1]);
	 
	 var projectDecimals = await inc.decimals();
	 assert.equal(projectDecimals.valueOf(), 1000, "1000 decimals should be returned");
	 
	 var incubatorOwnPercent = await inc.shareBalanceOf(incubatorOwner1);
	 assert.equal(incubatorOwnPercent.valueOf(), 3000, "3000 decimals should be returned");

	 var VFOwnPercent = await inc.shareBalanceOf(ventureFusionAccount);
	 assert.equal(VFOwnPercent.valueOf(), 2000, "2000 decimals should be returned");

	 var projectOwnPercent = await inc.shareBalanceOf(projectOwner);
	 assert.equal(projectOwnPercent.valueOf(), 95000, "95000 decimals should be returned");
	 
  });


  
  
  
  
  it("Test trasnfer of shares between people", async () => {  
  
	const ventureFusionAccount = accounts[0];        //2000 shares 
	const incubatorOwner1 = accounts[1];             //3000 shares
	const projectOwner = accounts[3];                //9500 shares 
	const shareHolder1 = accounts[5];                //0 shares 
	const shareHolder2 = accounts[6];                //0 shares 
	 
 	var meta = await Incubator.deployed();  
  
	//check there is one project
	var counts = await meta.numberOfProjectsInThisIncubator();
	assert.equal(counts.valueOf(), 1, "1 Project should have been created");
	
	
	 	
	//transfer some shares from project owner to share holder 1
	 var zz = await meta.incubatorProjects(0);	 //get the first project contract 
	 var project = await projectEquity.at(zz[1]);
	 
	 
	 //first check that share holder 1 has 0 shares
	 var share1 = await project.shareBalanceOf(shareHolder1);
	 assert.equal(share1.valueOf(), 0, "0 decimals should be returned");	 
	 
	 tx = await project.transferShares(shareHolder1, 1000, {from : projectOwner});
	 //ToDo  raise a event and check the values 
	 //Now check that share holder 1 has 1000 shares 
	 share1 = await project.shareBalanceOf(shareHolder1);
	 assert.equal(share1.valueOf(), 1000, "1000 decimals should be returned");  
     
	 share1 = await project.shareBalanceOf(projectOwner);
	 assert.equal(share1.valueOf(), 94000, "1000 decimals should be returned");  
	 

	 tx = await project.transferShares(shareHolder2, 300, {from : shareHolder1});
	 //Now check that share holder 1 has 700 shares 
	 share1 = await project.shareBalanceOf(shareHolder1);
	 assert.equal(share1.valueOf(), 700, "700 decimals should be returned");  
     
	 share1 = await project.shareBalanceOf(shareHolder2);
	 assert.equal(share1.valueOf(), 300, "300 decimals should be returned");  


	 
  });
  

  
  afterEach(async () => {

  });





});





