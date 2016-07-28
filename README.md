# cordova-plugin-videoproc

本插件提供视频、音频、图文的合成。

## 支持平台

- Android
- iOS

## API接口

### 视频合成

	window.videoproc.compose(videoFile, opt={@items, replaceAudio?=false, videoVolume?=1.0}, onSuccess, onFail)

**参数**

- videoFile: String. 源视频文件
- opt.items: [ {type, value, from?, to?, x?, y?, volume?=1.0} ] 一个数组，每项为要在视频上合成的项目，可以是音频、图片、文本等。
	- type: Enum. audio-音频, image-图片, text-文本
	- value: 如果type为audio或image, 则value表示文件路径；如果type为text, value表示文本内容。
	- from,to: Double. 指定从第几秒到第几秒添加内容。可缺省。如果from未指定，则从一开始就添加。如果to未指定，则添加该内容直到视频最后。
	- x, y: Integer. 起始位置。单位为像素。仅对type为image和text有效，表示在指定位置合成图片或文本。
	- volume: Double. 音量。缺省值1.0。仅对type=audio有效。值范围是0.0-1.0.

- opt.replaceAudio: Boolean. 缺省值为false. 如果值为true, 则用新的音频替代原音频，即删除原视频中的所有音轨。
- opt.videoVolume: Double. 视频音量(即视频中原音频的音量, 如果opt.replaceAudio=true，则该选项无效)。缺省值为1.0. 值范围是0.0-1.0.

- onSuccess: Function(newVideoFile). 操作成功时的回调。
	- newVideoFile: 生成的新的视频文件。

- onFail: Function(msg). 操作失败时回调。
	- msg: 失败信息。


**示例**

	var opt = {
		items: [
			{type: 'audio', value: 'cdvfile://localhost/temporary/1.mp3'}, // 音频
			{type: 'audio', value: 'cdvfile://localhost/temporary/2.mp3'}, // 音频2
			{type: 'image', value: 'cdvfile://localhost/temporary/1.png', x: 10, y: 10}, // 图片
			{type: 'text', value: '配音: 张三丰 - 网友1', from: 1.0, to: 2.0, x: 20, y: 20}, // 文本
			{type: 'text', value: '配音: 张无忌 - 网友2', from: 2.0, to: 3.0, x: 40, y: 40} // 文本2
		]
	};

	videoproc.compose('cdvfile://localhost/temporary/1.mp4', opt, onSuccess, onFail);
	
	function onSuccess(file) {
		alert('generate file: ' + file);
	}

	function onFail(msg) {
		alert('fail: ' + msg);
	}

注意：

- 文件应使用全路径。
 在安卓上，路径可以为 file.externalDataDirectory + "1.mp3", 其实际路径可能是 "file:///storage/emulated/0/Android/data/io.cordova.hellocordova/files/1.mp3"
 在IOS上，路径可以为 file.dataDirectory + "1.mp3"，但需要将前面协议部分如 "file://" 去掉，即路径是 "/User/.../1.mp3"
