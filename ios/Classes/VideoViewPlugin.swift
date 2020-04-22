//
//  VideoViewPlugin.swift
//  Runner
//
//  Created by Yaroslav on 21/04/2020.
//

import UIKit
import Flutter
import AVFoundation
import AVKit


//public class VideoViewFactory: NSObject, FlutterPlatformViewFactory{
//    let controller: FlutterViewController
//    init(controller: FlutterViewController) {
//        self.controller = controller
//    }
//    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
//        let channel = FlutterMethodChannel(name: "VideoView" + String(viewId),binaryMessenger: controller.binaryMessenger)
//        return VideoView(frame,viewId:viewId,args:args,channel:channel)
//    }
//}
//
//
//public class VideoView: NSObject,FlutterPlatformView{
//    let frame:CGRect
//    let viewId: Int64
//    let channel:FlutterMethodChannel
//    var playerView:CustomView
//    
//    let seekToMethod:String = "seekTo"
//    let getDurationMethod:String = "getDuration"
//    let getCurrentTimeMethod:String = "getCurrentPosition"
//    let loadHlsMethod:String = "loadHls"
//    let loadWssMethod:String = "loadWss"
//    let playPauseMethod:String = "setPlayback"
//    let setVolumeMethod:String = "setVolume"
//    let dispose:String = "dispose"
//    let fitMode:String = "fitMode"
//    static let fitModeContain = "contain"
//    static let fitModeCover = "cover"
//    
//    
//    
//    init(_ frame:CGRect,viewId:Int64,args:Any?,channel:FlutterMethodChannel) {
//        self.frame = frame
//        self.viewId = viewId
//        self.channel = channel
//        playerView = CustomView(frame: frame,channel: self.channel)
//    }
//    
//    
//    
//    
//    public func view() -> UIView {
//        self.channel.setMethodCallHandler({
//            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//            switch(call.method){
//            case self.loadHlsMethod:
//                let url = (call.arguments as! NSDictionary).object(forKey: "url") as! String
//                let fit = (call.arguments as! NSDictionary).object(forKey: self.fitMode) as! String
//                self.playerView.loadHls(url: url,fitMode:fit)
//                break
//            case self.loadWssMethod:
//                let url = (call.arguments as! NSDictionary).object(forKey: "url") as! String
//                let mediaId = (call.arguments as! NSDictionary).object(forKey: "mediaId") as! NSNumber
//                let token = (call.arguments as! NSDictionary).object(forKey: "token") as! String
//                let fit = (call.arguments as! NSDictionary).object(forKey: self.fitMode) as! String
//                self.playerView.loadWss(url: url, token: token, mediaId: "\(mediaId)" ,fitMode:fit)
//                break
//                
//            case self.seekToMethod:
//                let position = (call.arguments) as! Int
//                self.playerView.seekTo(position: position)
//                break
//            case self.playPauseMethod:
//                let playPause = (call.arguments) as! Bool
//                self.playerView.playPause(play: playPause)
//                break
//            case self.setVolumeMethod:
//                let volume = (call.arguments) as! Double
//                self.playerView.setVolume(volume: volume)
//                break
//            case self.getDurationMethod:
//                self.playerView.getDuration{
//                    duration in result(duration)
//                }
//                break
//            case self.getCurrentTimeMethod:
//                result(self.playerView.getCurrentTime())
//                break
//            case self.dispose:
//                self.playerView.dispose()
//                break
//            default:
//                print(call.method)
//                //print("hmm... no implemented commands for this request")
//                break
//            }
//        })
//        return self.playerView
//    }
//    
//    
//}
//class PlayerEvents{
//    static let endTime:String = "endTime"
//    static let playBackStalled:String = "playBackStalled"
//    static let onProgressChanged:String = "onProgressChanged"
//    static let itemTimeJumped:String = "itemTimeJumped"
//    static let failedToPlayToEndTime:String = "failedToPlayToEndTime"
//    static let assetDurationDidChange:String = "assetDurationDidChange"
//    static let newErrorLogEntry:String = "newErrorLogEntry"
//    
//}
//class CustomView: UIView {
//    var position:Int = -1
//    var rate:Int = 1
//    var volume:Double = 1.0
//    var onFirstFrameFired:Bool = false
//    var doomed:Bool = false
//    var wss:Bool = false
//    var channel:FlutterMethodChannel?
//    var fitMode:String = VideoView.fitModeCover
//    
//    
//    
//    override func willRemoveSubview(_ subview: UIView) {
//        //print("remove view")
//        playerViewController.player?.pause()
//        super.willRemoveSubview(subview)
//        
//    }
//    
//    
//    override func didMoveToWindow() {
//        if(self.window == nil){
//            doomed = true
//            playerViewController.player?.pause()
//            playerViewController.player = nil
//        }
//        super.didMoveToWindow()
//    }
//    
//    
//    func loadHls(url:String,fitMode:String) -> Void {
//        position = 0
//        self.fitMode = fitMode
//        self.willRemoveSubview(playerViewController.view)
//        let nativeUrl:URL = URL(string: url)!
//        self.playerViewController.view.frame = self.frame
//        self.playerViewController.player = player
//        self.playerViewController.player?.replaceCurrentItem(with: AVPlayerItem(url: nativeUrl))
//        self.rate = 1
//        reInitializePlayer()
//        addSubview(playerViewController.view)
//    }
//    func loadWss(url:String,token:String,mediaId:String,fitMode:String) -> Void {
//        //self.willRemoveSubview(socketView)
//        wss = true
//        position = -1
//        socketView = SocketView(frame: playerViewController.view.frame)
//        socketView.onFirstFrame = self.firstFrameEvent
//        socketView.setToken(streamUrl: url,token:token,mediaId: mediaId,fitMode: fitMode)
//        self.layer.contentsGravity = .resizeAspectFill
//        sizeToFit()
//        addSubview(socketView)
//    }
//    
//    func dispose() -> Void {
//        playerViewController.player?.pause()
//        playerViewController.player = nil
//        socketView.disposeSocket()
//        socketView = SocketView()
//    }
//    
//    lazy var player:AVPlayer = {
//        let player = AVPlayer()
//        //do here some initialization
//        //player.automaticallyWaitsToMinimizeStalling = true
//        return player
//    }()
//    
//    func seekTo(position:Int){
//        if(self.position != -1){
//            self.position = position
//            reInitializePlayer()
//        }
//    }
//    func setVolume(volume:Double){
//        self.volume = volume
//        reInitializePlayer()
//    }
//    func playPause(play:Bool){
//        if(play){
//            self.playerViewController.player!.play()
//        }else{
//            self.playerViewController.player!.pause()
//        }
//    }
//    func getDuration(completion: @escaping (Int)->Void){
//        DispatchQueue.main.async {
//            if(self.wss || !self.onFirstFrameFired){
//                completion(-1); return
//            }
//            let duration = self.playerViewController.player?.currentItem?.asset.duration.seconds
//            if(duration?.isNormal == false) {completion(0); return}
//            if(duration == 0) {completion(0); return}
//            if(duration!.isNaN){completion(0); return}
//            if(duration!.isInfinite) {completion(-1); return}
//            else{
//                print("durrT: \(Int( (duration ?? 0) * 1000))")
//                completion(Int( (duration ?? 0) * 1000))}
//        }
//    }
//    func getCurrentTime()->Int{
//        print("currT: \(Int((self.playerViewController.player?.currentItem?.currentTime().seconds ?? 0) * 1000))")
//        print("currT: \(!self.onFirstFrameFired)")
//        if(!self.onFirstFrameFired) {return 0}
//        return Int((self.playerViewController.player?.currentItem?.currentTime().seconds ?? 0) * 1000)
//    }
//    
//    lazy var socketView:SocketView =  {
//        let sockView:SocketView = SocketView(frame: playerViewController.view.frame)
//        //sockView.layer.contentsGravity = .resizeAspectFill
//        return sockView
//    }()
//    
//    
//    lazy var playerViewController: AVPlayerViewController = {
//        let player = self.player
//        //initialization instructions
//        let playerViewController = AVPlayerViewController()
//        playerViewController.allowsPictureInPicturePlayback = false
//        playerViewController.showsPlaybackControls = false
//        //playerViewController.updatesNowPlayingInfoCenter
//        playerViewController.player = player
//        //playerViewController.videoGravity = .resizeAspectFill
//        //playerViewController.view.frame = self.frame
//        print("frame/// \(playerViewController.view.frame); \(playerViewController.view.frame.height) \(playerViewController.view.frame.size)")
//        //player.actionAtItemEnd = .none
//        return playerViewController
//    }()
//    
//    func errorEvent(type:String,data:NSDictionary)->Void{
//        channel?.invokeMethod("player_exception", arguments: ["type":type,"message":data["message"]])
//    }
//    func firstFrameEvent()->Void{
//        rawEvent(type: "onRenderedFirstFrame", data: [:])
//    }
//    func rawEvent(type:String,data:NSDictionary)->Void{
//        channel?.invokeMethod("player_event", arguments: ["type":type,"data":data])
//    }
//    @objc func playerItemEvent(notification: Notification) {
//        let eventType: String = notification.object as! String
//        rawEvent(type: eventType, data: [:])
//    }
//    /*@objc func playerItemErrorEvent(notification: Notification) {
//     let eventType: String = notification.object as! String
//     errorEvent(type: eventType, data: [:])
//     }*/
//    @objc func newErrorLogEntry(notification: Notification) {
//        let object = notification.object
//        let playerItem = object as? AVPlayerItem
//        let errorLog: String = String(data:playerItem!.errorLog()!.extendedLogData()!,encoding: .utf8)!
//        //print("here: \(errorLog)")
//        errorEvent(type: PlayerEvents.newErrorLogEntry, data: ["message":errorLog])
//        //print("done here: \(errorLog)")
//    }
//    @objc func failedToPlayToEndTime(notification: Notification) {
//        let error = String(describing: notification.userInfo!["AVPlayerItemFailedToPlayToEndTimeErrorKey"])
//        //print("here1: \(error)")
//        errorEvent(type: PlayerEvents.failedToPlayToEndTime, data: ["message": error])
//        //print("done here1: \(error)")
//    }
//    
//    
//    func reInitializePlayer(){
//        if(doomed) {return}
//        if(self.onFirstFrameFired){
//            self.playerViewController.player!.seek(to: CMTime(seconds: Double(self.position/1000),preferredTimescale: self.playerViewController.player?.currentItem?.asset.duration.timescale ?? CMTimeScale()),completionHandler: {(_)in
//                self.playerViewController.player?.play()
//                //self.playerViewController.player?.currentItem?.duration.timescale
//                self.rawEvent(type: "onLoaded", data: [:])
//            })
//        }
//        if(fitMode == VideoView.fitModeCover){
//            playerViewController.videoGravity = .resizeAspectFill
//        }else{
//            playerViewController.videoGravity = .resizeAspect
//            
//            //playerViewController. = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
//        }
//        self.playerViewController.player!.volume = Float(self.volume)
//        playerViewController.player!.rate = Float(self.rate)
//        playerViewController.player!.automaticallyWaitsToMinimizeStalling  = true
//        /// observers for events
//        
//        playerViewController.player!.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
//            if(self!.doomed) {return}
//            if let duration = self!.playerViewController.player!.currentItem?.duration {
//                
//                let durationSeconds = CMTimeGetSeconds(duration)
//                var seconds = CMTimeGetSeconds(progressTime)
//                var progress = Float(seconds/durationSeconds)
//                if(progress.isNormal == false){progress = 0;}
//                if(seconds.isNormal == false){seconds = 0;}
//                print("currT \(seconds*1000); \(progress)")
//                DispatchQueue.main.async {
//                    if(!self!.onFirstFrameFired){
//                        self!.onFirstFrameFired = true
//                        self?.firstFrameEvent()}
//                    self!.rawEvent(type: PlayerEvents.onProgressChanged, data: ["currentPosition":Int(seconds*1000),"currentPositionPercent":progress])
//                    
//                }
//            }
//        }
//        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(playerItemEvent(notification:)),
//                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
//                                               object: PlayerEvents.endTime)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(playerItemEvent(notification:)),
//                                               name: NSNotification.Name.AVPlayerItemPlaybackStalled,
//                                               object: PlayerEvents.playBackStalled)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(playerItemEvent(notification:)),
//                                               name: NSNotification.Name.AVPlayerItemTimeJumped,
//                                               object: PlayerEvents.itemTimeJumped)
//        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(playerItemEvent(notification:)),
//                                               name: NSNotification.Name.AVAssetDurationDidChange,
//                                               object: PlayerEvents.assetDurationDidChange)
//        
//        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(failedToPlayToEndTime(notification:)),
//                                               name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
//                                               object: playerViewController.player!.currentItem)
//        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(newErrorLogEntry(notification:)),
//                                               name: NSNotification.Name.AVPlayerItemNewErrorLogEntry,
//                                               object: playerViewController.player!.currentItem)
//        
//        //playerViewController.player!.pause()
//        //self.playerViewController.player!.play()
//        //playerViewController.player!.currentItem?.seek(to: CMTime(), completionHandler: { (_) in
//        //    self.playerViewController.player!.play()
//        //})
//    }
//    
//    init(frame: CGRect, channel: FlutterMethodChannel) {
//        self.channel = channel
//        super.init(frame: frame)
//    }
//    override func didAddSubview(_ subview: UIView) {
//        //print("")
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupView()
//    }
//    
//    private func setupView() {
//        //backgroundColor = .red
//        
//    }
//    
//    override class var requiresConstraintBasedLayout: Bool {
//        return true
//    }
//}
