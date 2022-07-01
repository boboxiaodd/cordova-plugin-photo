const exec = require('cordova/exec');
const CDVLocalWWW = {
    update:function (success,fail,option){
        exec(success,fail,'CDVLocalWWW','update',[option]);
    }
};
module.exports = CDVLocalWWW;
