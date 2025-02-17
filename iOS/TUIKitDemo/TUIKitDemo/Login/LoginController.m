#import "LoginController.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import "TUIKit.h"
#import "AppDelegate.h"
#import "GenerateTestUserSig.h"
#import "ReactiveObjC/ReactiveObjC.h"

@import ImSDK_Plus;

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFeild;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)login:(id)sender {
    if (SDKAPPID == 0 || [SECRETKEY isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo 尚未配置 sdkAppid 和加密密钥，请前往 GenerateTestUserSig.h 配置" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([_userNameTextFeild.text isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入用户名！" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        //genTestUserSig 方法仅用于本地测试，请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
        /*
        *  本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
        *  这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
        *  一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
        *
        *  正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
        *  由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
        */
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate login:_userNameTextFeild.text userSig:[GenerateTestUserSig genTestUserSig:_userNameTextFeild.text] succ:nil fail:nil];
    }
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [_userNameTextFeild resignFirstResponder];
}

- (BOOL)isiPhoneX {
    static BOOL isiPhoneX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#if TARGET_IPHONE_SIMULATOR
        // 获取模拟器所对应的 device model
        NSString *model = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
#else
        // 获取真机设备的 device model
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
#endif
        // 判断 device model 是否为 "iPhone10,3" 和 "iPhone10,6" 或者以 "iPhone11," 开头
        // 如果是，就认为是 iPhone X
        isiPhoneX = [model isEqualToString:@"iPhone10,3"] || [model isEqualToString:@"iPhone10,6"] || [model hasPrefix:@"iPhone11,"];
    });
    
    return isiPhoneX;
}
@end
