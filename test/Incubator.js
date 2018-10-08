var Incubator = artifacts.require("./Incubator.sol");
const truffleAssert = require('truffle-assertions');

contract('Incubator', function(accounts) {


  beforeEach(async () => {

  });




  it("Test constructor values", async () => {  
    
	const meta = await Incubator.deployed();
	
	var percent = (await meta.incubatorOwnerPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 98, "Expected value 98 was not returned");
	
	var percent = (await meta.ventureFusionPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 2, "Expected value 2 was not returned");
	
	var percent = (await meta.transactionPriceInTokens.call()).toNumber();
	assert.equal(percent.valueOf(), 10, "Expected value 10 was not returned");
	
  });




  
  it("Test setting incubator ownership values", async () => {  
    
	const ventureFusionAccount = accounts[0];
	const incubatorOwner1 = accounts[1];
	
	const meta = await Incubator.deployed();
	
	let tx = await meta.changeIncubatorOwnerProjectPercentage(97, {from : ventureFusionAccount});
    truffleAssert.eventEmitted(tx, 'changeIncubatorOwnerProjectPercentageEvent', (ev) => {
		return ev.oldPercentage == 98 && ev.percentage == 97;
    });	
	var percent = (await meta.incubatorOwnerPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 97, "Expected value 97 was not returned");
	
	tx = await meta.changeVentureFusionProjectPercentage(3, {from : ventureFusionAccount})
    truffleAssert.eventEmitted(tx, 'changeVentureFusionProjectPercentageEvent', (ev) => {
		return ev.oldPercentage == 2 && ev.percentage == 3;
    });		
	var percent = (await meta.ventureFusionPercentageInProject.call()).toNumber();
	assert.equal(percent.valueOf(), 3, "Expected value 3 was not returned");
	
	tx = await meta.changeVETTokenForTransactions(20, {from : incubatorOwner1});
    truffleAssert.eventEmitted(tx, 'changeVETTokenForTransactionsEvent', (ev) => {
		return ev.oldPrice == 10 && ev.price == 20;
    });	
	var percent = (await meta.transactionPriceInTokens.call()).toNumber();
	assert.equal(percent.valueOf(), 20, "Expected value 20 was not returned");
	
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
	 
	 tx = await meta.addNewProject("Test Proj 102", projectOwner, {from : incubatorOwner1});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 102" && ev.ProjectNo == 1;
     });	 
	 
	 tx = await meta.addNewProject("Test Proj 103", projectOwner, {from : incubatorOwner1});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 103" && ev.ProjectNo == 2;
     });
 
	 var counts = await meta.numberOfProjectsInThisIncubator();
	 assert.equal(counts.valueOf(), 3, "3 Project should have been created");
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