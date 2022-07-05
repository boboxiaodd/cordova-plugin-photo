const exec = require('cordova/exec');
const CDVPhotoPicker = {
    picker:function (success,fail,option){
        exec(success,fail,'CDVPhotoPicker','picker',[option]);
    }
};
module.exports = CDVPhotoPicker;
