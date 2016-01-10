//
//  Constant.h
//  THWebController
//
//  Created by 欧阳志鑫 on 16/1/9.
//  Copyright © 2016年 欧阳志鑫. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static const int fontSize = 14;

static CGRect NIRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}

static BOOL NIIsPad(void) {
    //#ifdef UI_USER_INTERFACE_IDIOM
    //    static NSInteger isPad = -1;
    //    if (isPad < 0) {
    //        isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    //    }
    //    return isPad > 0;
    //#else
    //    return NO;
    //#endif
    return NO;
}

static CGFloat NIToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
    return (NIIsPad()
            ? 44
            : (UIInterfaceOrientationIsPortrait(orientation)
               ? 44
               : 33));;
}

static UIInterfaceOrientation NIInterfaceOrientation(void) {
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    
    // This code used to use the navigator to find the currently visible view controller and
    // fall back to checking its orientation if we didn't know the status bar's orientation.
    // It's unclear when this was actually necessary, though, so this assertion is here to try
    // to find that case. If this assertion fails then the repro case needs to be analyzed and
    // this method made more robust to handle that case.
    // XXX NSParameterAssert(UIDeviceOrientationUnknown != orient);
    
    return orient;
}

static NSString* NIPathForBundleResource(NSBundle* bundle, NSString* relativePath) {
    NSString* resourcePath = [(nil == bundle ? [NSBundle mainBundle] : bundle) resourcePath];
    return [resourcePath stringByAppendingPathComponent:relativePath];
}

#endif /* Constant_h */
