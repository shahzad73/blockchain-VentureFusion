var Incubator = artifacts.require("./Incubator.sol");
var projectEquity = artifacts.require("./ProjectEquity.sol");
const truffleAssert = require('truffle-assertions');

contract('Incubator', function(accounts) {


  beforeEach(async () => {

  });

  

  it("Test constructor values", async () => {  
    
	const meta = await Incubator.deployed();
	
	var percent = (await meta.incubatorOwnerPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 3000, "Expected value 3000 was not returned");
	
	percent = (await meta.ventureFusionPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 2000, "Expected value 2000 was not returned");
	
	percent = (await meta.ProjectSingleShareDivision.call()).toNumber();
	assert.equal(percent.valueOf(), 1000, "Expected value 1000 was not returned");
		
	percent = (await meta.transactionPriceInTokens.call()).toNumber();
	assert.equal(percent.valueOf(), 10, "Expected value 10 was not returned");
		
  });




  
  it("Test setting incubator ownership values", async () => {  
    
	const ventureFusionAccount = accounts[0];
	const incubatorOwner1 = accounts[1];
	
	const meta = await Incubator.deployed();
	
	let tx = await meta.changeIncubatorOwnerProjectPercentage(4000, {from : ventureFusionAccount});
    truffleAssert.eventEmitted(tx, 'changeIncubatorOwnerProjectPercentageEvent', (ev) => {
		return ev.oldPercentage == 3000 && ev.percentage == 4000;
    });	
	var percent = (await meta.incubatorOwnerPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 4000, "Expected value 4000 was not returned");
	
	tx = await meta.changeVentureFusionProjectPercentage(3000, {from : ventureFusionAccount})
    truffleAssert.eventEmitted(tx, 'changeVentureFusionProjectPercentageEvent', (ev) => {
		return ev.oldPercentage == 2000 && ev.percentage == 3000;
    });		
	var percent = (await meta.ventureFusionPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 3000, "Expected value 3000 was not returned");
	
	tx = await meta.changeVETTokenForTransactions(20, {from : ventureFusionAccount});
    truffleAssert.eventEmitted(tx, 'changeVETTokenForTransactionsEvent', (ev) => {
		return ev.oldPrice == 10 && ev.price == 20;
    });	
	var percent = (await meta.transactionPriceInTokens.call()).toNumber();
	assert.equal(percent.valueOf(), 20, "Expected value 20 was not returned");
	
	tx = await meta.changeProjectSingleShareDivision(1001, {from : ventureFusionAccount});
    truffleAssert.eventEmitted(tx, 'changeProjectSingleShareDivisionEvent', (ev) => {
		return ev.oldSingleShareDivision == 1000 && ev.singleShareDivision == 1001;
    });	
	var percent = (await meta.ProjectSingleShareDivision.call()).toNumber();
	assert.equal(percent.valueOf(), 1001, "Expected value 1001 was not returned");
	//make it again 1000
	tx = await meta.changeProjectSingleShareDivision(1000, {from : ventureFusionAccount});
  });



  


  it("Test creating new projects in incubator", async () => {  
  
	const ventureFusionAccount = accounts[0];
	const incubatorOwner1 = accounts[1];
	const projectOwner = accounts[3];
	 
 	 var meta = await Incubator.deployed();

	 let tx = await meta.addNewProject("Test Proj 101", projectOwner, {from : incubatorOwner1});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 101" && ev.ProjectNo == 0;
     });
	 var zz = await meta.incubatorProjects(0);	 
	 var inc = await projectEquity.at(zz[1]);
	 
	 var projectDecimals = await inc.ProjectSingleShareDivision();
	 assert.equal(projectDecimals.valueOf(), 1000, "1000 decimals should be returned");
	 
	 var incubatorOwnPercent = await inc.shareBalanceOf(incubatorOwner1);
	 assert.equal(incubatorOwnPercent.valueOf(), 4000, "4000 decimals should be returned");

	 var VFOwnPercent = await inc.shareBalanceOf(ventureFusionAccount);
	 assert.equal(VFOwnPercent.valueOf(), 3000, "3000 decimals should be returned");

	 var projectOwnPercent = await inc.shareBalanceOf(projectOwner);
	 assert.equal(projectOwnPercent.valueOf(), 93000, "93000 decimals should be returned");
	 
	 
	 tx = await meta.addNewProject("Test Proj 102", projectOwner, {from : incubatorOwner1});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 102" && ev.ProjectNo == 1;
     });


	 var counts = await meta.numberOfProjectsInThisIncubator();
	 assert.equal(counts.valueOf(), 2, "2 Project should have been created");
	 //console.log("Number of Project : " + counts);

	 
  });


  
  

  
  afterEach(async () => {

  });





});









/*
     
  it("Check VentureFusion Percentage in project has been initialized correctly", function() {
    
	return Incubator.deployed()
	.then(function(instance) 
	{
		return instance.ventureFusionPercentageInProject.call();
    }).then(function(balance) 
	{
	    assert.equal(balance.valueOf(), 1, "Expected value 1 was not returned");
    });
	
  });
  
  
  
  
  
  it("Check VentureFusion Percentage in project has been initialized correctly", function() {  
	
		return Incubator.deployed()
		.then(function(instance) 
		{
			return instance.addNewProject.call("Test Proj 1");
		}).then(function(params) 
		{
			assert.equal(params[0].valueOf(), 0, "Expected value 0 was not returned");
			return Incubator.deployed();
		})
		.then(function(instance) 
		{
			return instance.addNewProject.call("Test Proj 2");
		}).then(function(params) 
		{
			assert.equal(params[0].valueOf(), 0, "Expected value 1 was not returned");
		});
  
  });
  
 */