//
//  ConfigItem.m
//  HelloCordova
//
//  Created by 管伟东 on 16/7/14.
//
//

#import "ConfigItem.h"

@implementation ConfigItem
- (instancetype)init
{
    self = [super init];
    if(!self)return nil;
    self.type = kMediaType_unKnown;
    self.value = @"";
    self.frome = 0;
    self.to = 0 ;
    self.pointY = 0 ;
    self.pointX = 0 ;
    self.height = 0;
    self.width = 0 ;
    self.volume = 1.0;
    return self;
}
- (NSInteger)frome
{
    if (_frome <= 0) {
       return  0;
    }
    
    return _frome;
}
- (NSInteger)to
{
    if (_to<=0) {
        return -1;
    }
    return _to;
}
- (CGFloat)volume
{
    if (_volume<=0) {
        _volume = 0;
    }
    if (_volume>=1) {
        _volume = 1.0; 
    }
    return _volume;
}
@end
