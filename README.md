# cordova-plugin-videoproc

本插件提供视频、音频、图文的合成。

## 支持平台

- Android
- iOS

## API接口

### 视频合成

	window.videoproc.compose(videoFile, opt={@items}, onSuccess, onFail)

**参数**

- videoFile: String. 源视频文件
- opt.items: [ {type, value, from?, to?, x?, y?} ] 一个数组，每项为要在视频上合成的项目，可以是音频、图片、文本等。
	- type: Enum. audio-音频, image-图片, text-文本
	- value: 如果type为audio或image, 则value表示文件路径；如果type为text, value表示文本内容。
	- from,to: Double. 指定从第几秒到第几秒添加内容。可缺省。如果from未指定，则从一开始就添加。如果to未指定，则添加该内容直到视频最后。TODO: 考虑是否支持按帧数，支持负数;
	- x, y: Integer. 起始位置。单位为像素。仅对type为image和text有效，表示在指定位置合成图片或文本。TODO: 是否支持百分率。

- onSuccess: Function(newVideoFile). 操作成功时的回调。
	- newVideoFile: 生成的新的视频文件。

- onFail: Function(msg). 操作失败时回调。
	- msg: 失败信息。


**示例**

	var opt = {
		items: [
			{type: 'audio', value: 'cdvfile://localhost/temporary/1.mp3'}, // 音频
			{type: 'image', value: 'cdvfile://localhost/temporary/1.png'}, // 图片
			{type: 'text', value: '配音: 张三丰 - 网友1', from: 15.0, to: 16.0, x: 120, y: 150}, // 文本
			{type: 'text', value: '配音: 张无忌 - 网友2', from: 16.0, to: 17.0, x: 120, y: 150}, // 文本2
		]
	};

	videoproc.compose('cdvfile://localhost/temporary/1.mp4', opt, onSuccess, onFail);
	
	function onSuccess(file) {
		alert('generate file: ' + file);
	}

	function onFail(msg) {
		alert('fail: ' + msg);
	}
