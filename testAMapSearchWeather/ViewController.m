//
//  ViewController.m
//  testAMapSearchWeather
//
//  Created by lsfb on 2020/9/8.
//  Copyright © 2020 lsfb. All rights reserved.
//

#import "ViewController.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface ViewController ()<AMapSearchDelegate,AMapLocationManagerDelegate>
@property (nonatomic,strong) AMapLocationManager *locationManager;
@property (nonatomic,strong) AMapSearchAPI *search;
@property (weak, nonatomic) IBOutlet UILabel *label;
///区域编码
@property (nonatomic, copy) NSString *adcode;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self location];
}

- (void)location{
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，最低2s，此处设置为2s
    self.locationManager.locationTimeout =5;
    //   逆地理请求超时时间，最低2s，此处设置为2s
    self.locationManager.reGeocodeTimeout = 5;
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    __weak typeof(self) weakSelf = self;
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        NSLog(@"location:%@", location);
        
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
            weakSelf.adcode = regeocode.adcode;
            [weakSelf requestWeather];
        }
    }];
}

//获取天气数据
- (void)requestWeather{
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = self.adcode;
    request.type = AMapWeatherTypeLive; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气
    
    [self.search AMapWeatherSearch:request];
}

- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    //解析response获取天气信息，具体解析见 Demo
    AMapLocalWeatherLive *live = response.lives.lastObject;
    NSLog(@"%@˚C %@ %@风%@级 湿度：%@%%",live.temperature,live.weather,live.windDirection,live.windPower,live.humidity);
    _label.text = [NSString stringWithFormat:@"%@˚C %@ %@风%@级 湿度：%@%%",live.temperature,live.weather,live.windDirection,live.windPower,live.humidity];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}


@end
