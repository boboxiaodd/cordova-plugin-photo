# cordova-plugin-photo
cordova photo picker

#### 选择图片

```js
let emojilist = [ //以第一张图作为顶部图标
    ["http://xxxx0.png","http://xxxx1.png","http://xxxx2.png","http://xxxx3.png","http://xxxx4.png"],
    ["http://xxxx0.png","http://xxxx1.png","http://xxxx2.png","http://xxxx3.png","http://xxxx4.png"],
]
CDVPhotoPicker.picker(function (res){
      /*
      res = [
         {
            path : "/private/var/mobile/Containers/Data/Application/xxxxxx/tmp/xxxxx.jpg",
            filesize : 56811,
            size: {
                width: 293,
                height: 520
            }
         }
      ]
      */
},function (){

},{
    picker_type:1,   //1代表图片，2代表视频
    max:5,           //最多选择多少张图片
    is_avatar:false, //是否为选择头像，如果为true,将忽略 max
    max_size:520,    //图片尺寸压缩
    emoji:emojilist  //贴图 url 二维数组
});
```

#### 选择视频

```js
CDVPhotoPicker.picker(function (res){
      /*
      res = [
         {
            path : "/private/var/mobile/Containers/Data/Application/xxxxxx/tmp/xxxxx.mp4",
            filesize : 56811,
            duration: 12.95, //时长(秒)
         }
      ]
      */
},function (){

},{
    picker_type:2,   //1代表图片，2代表视频
    max:1,           //最多选择多少个视频
    max_duration:60, //视频最大时长(秒)
    min_duration:10, //视频最小时长(秒)
    quality: 8       //清晰度 (1 - 10)
});
```
