#	音视频合成
##	接口
```
function testit()
{
    var videoFile = document.getElementById("txtVideo").value;
    var audioFile = document.getElementById("txtAudio").value;
	var opt = {
		items: [
			{type: 'audio', value: audioFile}, // 音频
			{type: 'image', value: 'cdvfile://localhost/temporary/1.png'}, // 图片
			{type: 'text', value: '配音: 张三丰 - 网友1', from: 15.0, to: 16.0, x: 120, y: 150}, // 文本
			{type: 'text', value: '配音: 张无忌 - 网友2', from: 16.0, to: 17.0, x: 120, y: 150} // 文本2
		]
	};

	videoproc.compose(videoFile, opt, onSuccess, onFail);
	
	function onSuccess(file) {
		alert('generate file: ' + file);
	}

	function onFail(msg) {
		alert('fail: ' + msg);
	}
}
```
### 	原生代码接口说明

####    接口文件在 VideoProc.h

```
- (void)compose:(NSString *)videoFile withConfig:(NSDictionary *)configopt;
1.videofile 视频的地址  
2.opt 视频配置参数 
{
    "items": [
                {
                    "type": "audio", //音频的type  
                    "value": "audioFile" //音频的url地址
                },
                {
                    "type": "image",//图片的type
                    "value": "cdvfile: //localhost/temporary/1.png"//图片地址
                },
                {
                    "type": "text", //文字的type  
                    "value": "配音: 张三丰-网友1",//文字内容
                    "from": 15.0,  //从15秒的地方开始播放 
                    "to": 16.0,    //到16秒消失
                    "x": 120,     //显示坐标  x  
                    "y": 150      //显示坐标  y 
                },
                {
                    "type": "text",
                    "value": "配音: 张无忌-网友2",
                    "from": 16.0,
                    "to": 17.0,
                    "x": 120,
                    "y": 150
                }
            ]
}

- (UIImage *)getThumbnail;  //获取缩略图


- (void)cancleExport;   //取消导出


```



###	Video_Const.h 说明

```
如下修改:(启用文字图片以及片尾模糊功能)
#ifndef ImageAndText 
#define ImageAndText
#endif
如下修改:(只启用音视频合成功能)
#ifndef ImageAndText 
//#define ImageAndText
#endif

//定义了片尾变暗的时间(默认是2s内变暗)
#define kTailDuration  2.0f  

//定义了文字绘制在视频上的字体大小
#define kFontSize  50


```