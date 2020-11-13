const CapitalDistribution = artifacts.require("CapitalDistribution");


module.exports = async function (deployer) {
    await deployer.deploy(CapitalDistribution);
    
};
