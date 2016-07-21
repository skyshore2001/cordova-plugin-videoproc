//
//  ConfigItem.h
//  HelloCordova
//
//  Created by 管伟东 on 16/7/14.
//
//

#import <Foundation/Foundation.h>
#import "Video_Const.h"
@interface ConfigItem : NSObject
@property (nonatomic ,assign)kMediaType type;
@property (nonatomic ,strong)NSString * value ;
@property (nonatomic ,assign)NSInteger  frome;
@property (nonatomic ,assign)NSInteger  to ;
@property (nonatomic ,assign)NSInteger  pointX;
@property (nonatomic ,assign)NSInteger  pointY;
@property (nonatomic ,assign)NSInteger  width ;
@property (nonatomic ,assign)NSInteger  height ; 
@end
